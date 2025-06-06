// lib/widgets/navigation_screen
import 'package:flutter/material.dart';
import '../models/floor_data.dart';
import '../models/nav_path.dart';
import '../models/nav_segment.dart';
import '../models/navigate_instruction.dart';
import '../models/node.dart';
import '../services/map_service.dart';
import '../services/navigation_service.dart';
import '../services/turn_instruction_service.dart';
import 'interactive_svg_map.dart';
import 'map_marker.dart'; // Still needed for getTurnAngle if used elsewhere or if TurnInstructionService depends on it

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final GlobalKey<InteractiveSvgMapState> _interactiveMapKey = GlobalKey();

  String? _selectedSource;
  String? _selectedDestination;

  // Multi-level navigation state
  // bool _isMultiLevel = false;
  Map<int, NavPath> _pathsByFloor = {};
  Map<int, List<Offset>> _transitionPoints = {};
  Set<int> _involvedFloors = {};
  int _currentFloorId = 1; // Track current floor being viewed

  // Single-level navigation state (existing)

  List<NavSegment> _simplifiedSegments = [];

  // Common navigation state
  bool _isLoading = false;
  String? _error;
  Node? _sourceNode;
  Node? _desNode;
  List<MapMarker> venueNodes = [];
  List<MapMarker> stairNodes = [];
  List<String> _allVenuesName = [];
  List<FloorData> _floors = [];

  // Navigation flow state
  Map<int,List<TurnInstruction>> _instructionsByFloor = {};
  String _currentInstruction = "Select source and destination to find a path.";
  int _currentPathPointIndex = 0;
  bool _isPendingRotation = false;
  int _previousPathPointIndex = -1;
  Offset? _userLocationOnMap;
  bool _isNavigationCompleted = false;

  static const double _destinationReachedThreshold = 5.0;

  @override
  void initState() {
    super.initState();
    _currentFloorId = 1; // Set initial floor to Ground Floor
    _loadVenueNodes();

    _floors = [
      FloorData(name: 'Ground Floor', svgPath: 'assets/floorplan/ftmk_gf.svg', floorId: 1),
      FloorData(name: 'Level 1', svgPath: 'assets/floorplan/ftmk_level1.svg', floorId: 2)
    ];
  }

  Future<void> _loadVenueNodes() async {
    final nodes = await MapService.loadVenueNodes(_currentFloorId);
    setState(() {
      venueNodes = nodes["venues"] as List<MapMarker>;
      stairNodes = nodes["stairs"] as List<MapMarker>;
      _allVenuesName = nodes["allVenuesName"] as List<String>;
    });
  }

  Future<void> _getNavigationPath(String source, String destination) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _resetNavigationState();
    });

    try {
      final result = await NavigationService.getNavigationPath(source, destination);

      setState(() {
        // _isMultiLevel = result['isMultiLevel'];
        _sourceNode = result['sourceNode'];
        _desNode = result['desNode'];
        _userLocationOnMap = result['userLocationOnMap'];
        _simplifiedSegments = result['simplifiedSegments'];
        _pathsByFloor = result['pathsByFloor'];
        _transitionPoints = result['transitionPoints'];
        _involvedFloors = result['involvedFloors'];
        _currentInstruction = "Start navigation";
        // Generate instructions
        _instructionsByFloor = TurnInstructionService.generateTurnInstructions(
            _simplifiedSegments, _desNode);

        _isNavigationCompleted = false;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _interactiveMapKey.currentState?.goToPointOnPath(
            _userLocationOnMap!,
            alignMapToPathSegmentIndex: _getCurrentNavPath()?.points.length != null &&
                _getCurrentNavPath()!.points.length > 1 ? 0 : null,
          );
        });
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _currentInstruction = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetNavigationState() {

    _pathsByFloor.clear();
    _transitionPoints.clear();
    _involvedFloors.clear();
    // _isMultiLevel = false;
    _currentFloorId = 1;
    _sourceNode = null;
    _desNode = null;
    _instructionsByFloor.clear();
    _currentInstruction = "Finding path...";
    _currentPathPointIndex = 0;
    _isPendingRotation = false;
    _previousPathPointIndex = -1;
    _userLocationOnMap = null;
    _isNavigationCompleted = false;
    _simplifiedSegments = [];
  }

  // Get the current NavPath based on current floor
  NavPath? _getCurrentNavPath() {

      return _pathsByFloor[_currentFloorId];

  }

  // Get transition points for current floor
  List<Offset> _getCurrentFloorTransitions() {
    return _transitionPoints[_currentFloorId] ?? [];
  }

  // Handle floor changes in multi-level navigation
  void _handleFloorChange(String floorName) {
    // Map floor names to floor IDs (adjust based on your floor naming)
    int newFloorId = 1; // Default
    switch (floorName) {
      case 'Ground Floor':
        newFloorId = 1;
        break;
      case 'Level 1':
        newFloorId = 2;
        break;
      case 'Level 2':
        newFloorId = 3;
        break;
    }

    setState(() {
      _currentFloorId = newFloorId;
      //
      // if (_isMultiLevel) {
      //   // Update instruction based on new floor
      //   if (_involvedFloors.contains(newFloorId)) {
      //     _currentInstruction = "Viewing Floor $newFloorId navigation path";
      //   } else {
      //     _currentInstruction = "No navigation path on Floor $newFloorId";
      //   }
      // }
    });

    // Reload venue nodes for the new floor
    _loadVenueNodes();
  }

  Future<void> _handleNextNavigationStep() async {
    NavPath? currentPath = _getCurrentNavPath();

    if (currentPath == null || currentPath.points.isEmpty || _isNavigationCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have reached your destination')),
      );
      return;
    }

      List<Offset> transitions = _getCurrentFloorTransitions();
      if (transitions.isNotEmpty) {
        // Check if user is near a transition point
        for (Offset transitionPoint in transitions) {
          if ((_userLocationOnMap! - transitionPoint).distance < _destinationReachedThreshold) {
            await _handleFloorTransition();
            currentPath = _getCurrentNavPath();
            if (currentPath == null || currentPath.points.isEmpty) {
              print('No navigation path available on the new floor');
              return;
            }

            // Reset navigation state for new floor
            setState(() {
              _currentPathPointIndex = 0;
              _previousPathPointIndex = -1;
              _userLocationOnMap = currentPath!.points[0];
              // _currentInstruction = "Continue navigation on ${_getFloorName(_currentFloorId)}";
            });


          }


      }
    }

      print("current path");
      print(currentPath?.floorId);

    _handleSingleLevelNavigation(currentPath!);
  }

  Future<void> _handleFloorTransition()async {
    // Check if map is currently transitioning to avoid conflicts
    if (_interactiveMapKey.currentState?.isTransitioning() == true) {
      print('Floor transition already in progress, skipping...');
      return;
    }

    // Find which floor to transition to
    for (var segment in _simplifiedSegments) {
      if (segment.segmentType == "inter_floor_transition" &&
          segment.startFloodId == _currentFloorId) {

        setState(() {
          _currentFloorId = segment.endFloorId;
          _userLocationOnMap = segment.endCoord;
          // _currentInstruction = "Moved to Floor $_currentFloorId via ${segment.segmentType}";
        });

        // Notify the map to change floors
        final floorName = _getFloorName(_currentFloorId);
        _interactiveMapKey.currentState?.changeFloor(floorName);

        // Optional: Add a delay before continuing navigation
        await Future.delayed(const Duration(milliseconds: 800), () {
          // Continue with navigation logic after floor change
          if (mounted) {
            // Update any other navigation state as needed
            print('Floor transition completed to: $floorName');
          }
        });

        break;
      }
    }
  }

  String _getFloorName(int floorId) {
    switch (floorId) {
      case 1: return 'Ground Floor';
      case 2: return 'Level 1';
      case 3: return 'Level 2';
      default: return 'Ground Floor';
    }
  }

  void _handleSingleLevelNavigation(NavPath currentPath) {
    // Your existing navigation logic here
    if (_isPendingRotation) {
      setState(() {

        _isPendingRotation = false;

        List<TurnInstruction> instruction = TurnInstructionService.findInstructionForLocation(
            _instructionsByFloor[_currentFloorId]!, _userLocationOnMap!);

        if (instruction.length > 1) {
          _currentInstruction = instruction[1].instruction;}
        else{
          _currentInstruction = instruction[0].instruction;
        }

      });

      _interactiveMapKey.currentState?.goToPointOnPath(
        _userLocationOnMap!,
        alignMapToPathSegmentIndex: _currentPathPointIndex,
      );
    } else {
      int nextPointIndex = _currentPathPointIndex + 1;
      bool isMovingToDestination = false;

      if (nextPointIndex < currentPath.points.length && _desNode != null) {
        if (NavigationService.isMovingToDestination(
            currentPath.points[nextPointIndex],
            (_desNode as Node).coord,
            _destinationReachedThreshold)) {
          isMovingToDestination = true;
        }
      }

      setState(() {
        _previousPathPointIndex = _currentPathPointIndex;
        _currentPathPointIndex = nextPointIndex;

        if (_currentPathPointIndex >= currentPath.points.length) {
          _currentPathPointIndex = currentPath.points.length - 1;
        }
        _userLocationOnMap = currentPath.points[_currentPathPointIndex];
      });

      if (isMovingToDestination ||
          (_currentPathPointIndex == currentPath.points.length - 1 &&
              _desNode != null &&
              NavigationService.isDestinationReached(_userLocationOnMap!,
                  (_desNode as Node).coord, _destinationReachedThreshold))) {
        setState(() {
          _currentInstruction = "Arrived at your destination.";
          _isNavigationCompleted = true;
        });

        _interactiveMapKey.currentState?.goToPointOnPath(
          _userLocationOnMap!,
          alignMapToPathSegmentIndex: null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigation completed!')),
        );
        return;
      }

      // Continue with existing navigation logic...
      bool isUpcomingTurn = false;

      String nextInstructionText = "Follow the path.";

      if (_currentPathPointIndex < currentPath.points.length - 1) {
        List<TurnInstruction> upcomingTurnInstruction =
        TurnInstructionService.findInstructionForLocation(
            _instructionsByFloor[_currentFloorId]!, _userLocationOnMap!);
        isUpcomingTurn = true;
        if (upcomingTurnInstruction.isNotEmpty) {
          nextInstructionText = upcomingTurnInstruction[0].instruction;
        }
      } else {
        nextInstructionText = "Arrived at the end of the path.";
      }

      setState(() {
        _currentInstruction = nextInstructionText;

        _isPendingRotation = isUpcomingTurn;
      });

      if (isUpcomingTurn) {
        _interactiveMapKey.currentState?.goToPointOnPath(
          _userLocationOnMap!,
          alignMapToPathSegmentIndex: null,
        );
      } else {
        _interactiveMapKey.currentState?.goToPointOnPath(
          _userLocationOnMap!,
          alignMapToPathSegmentIndex: _currentPathPointIndex,
        );
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FTMK Map'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveSvgMap(
              key: _interactiveMapKey,
              naviPath: _getCurrentNavPath(), // Current floor's path
              source: _sourceNode,
              des: _desNode,
              userLocation: _userLocationOnMap,
              currentPathPointIndex: _currentPathPointIndex,
              venueNodes: venueNodes,
              stairNodes: stairNodes,
              transitionPoints: _getCurrentFloorTransitions(), // Add transition points
              onNavigationPressed: _handleNextNavigationStep,
              isNavigationEnabled: _getCurrentNavPath() != null && !_isNavigationCompleted,
              isLoading: _isLoading,
              floors: _floors,
              currentFloor: _getFloorName(_currentFloorId),
              onFloorChanged: _handleFloorChange,
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedSource,
                        hint: const Text("Source"),
                        items: _allVenuesName.map((venueName) {
                          return DropdownMenuItem(
                            value:venueName,
                            child: Text(venueName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSource = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedDestination,
                        hint: const Text("Destination"),
                        items: _allVenuesName.map((venueName) {
                          return DropdownMenuItem(
                            value: venueName,
                            child: Text(venueName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDestination = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_selectedSource != null && _selectedDestination != null) {
                          await _getNavigationPath(_selectedSource!, _selectedDestination!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Find Path'),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                      Text(
                        _currentFloorId == 1 ? "Ground Floor" : 'Floor ${_currentFloorId-1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),

                    Text(
                      _currentInstruction,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}