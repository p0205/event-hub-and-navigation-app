// lib/screens/navigation_screen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/navigation_bloc.dart';
import '../models/floor_data.dart';
import '../models/nav_path.dart';
import '../models/nav_segment.dart';
import '../models/navigate_instruction.dart';
import '../models/node.dart';
import '../services/map_service.dart';
import '../services/navigation_service.dart';
import '../services/turn_instruction_service.dart';
import '../widgets/map_marker.dart';
import '../widgets/navigation_options_menu.dart';
import '../widgets/venue_selection_dialog.dart';
import 'interactive_svg_map.dart';

class NavigationScreen extends StatefulWidget {

  String? destination;
   NavigationScreen({super.key, this.destination});

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
  Node? _userNode;
  List<MapMarker> venueNodes = [];
  List<MapMarker> stairNodes = [];
  // List<String> _allVenuesName = [];
  List<FloorData> _floors = [];
  bool _isStepByStep = true;

  // Navigation flow state
  Map<int,List<TurnInstruction>> _instructionsByFloor = {};
  late TurnInstruction _currentInstruction;
  int _currentPathPointIndex = 0;
  bool _isPendingRotation = false;
  int _previousPathPointIndex = -1;
  bool _isNavigationCompleted = false;

  static const double _destinationReachedThreshold = 5.0;

  @override
  void initState() {
    super.initState();
    _currentFloorId = 1; // Set initial floor to Ground Floor
    _loadVenueNodes();
    _currentInstruction = TurnInstruction(
      location: Offset.zero,
      instruction: "Select source and destination to find a path.",
    );

    _floors = [
      FloorData(name: 'Level 4', svgPath: 'assets/floorplan/ftmk_level4.svg', floorId: 4),
      FloorData(name: 'Level 3', svgPath: 'assets/floorplan/ftmk_level3.svg', floorId: 3),
      FloorData(name: 'Level 2', svgPath: 'assets/floorplan/ftmk_level2.svg', floorId: 2),
      FloorData(name: 'Ground Floor', svgPath: 'assets/floorplan/ftmk_gf.svg', floorId: 1),

    ];

    if (mounted) {
      context.read<NavigationBloc>().add(LoadAllVenuesNameEvent());
    }

    // Set destination if provided
    if (widget.destination != null) {
      setState(() {
        _selectedDestination = widget.destination;
      });
    }
  }

  Future<void> _loadVenueNodes() async {
    final nodes = await MapService.loadVenueNodes(_currentFloorId);
    setState(() {
      venueNodes = nodes["venues"] as List<MapMarker>;
      stairNodes = nodes["stairs"] as List<MapMarker>;
      // _allVenuesName = nodes["allVenuesName"] as List<String>;
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

      // Generate instructions first
      final instructionsByFloor = TurnInstructionService.generateTurnInstructions(
          result['simplifiedSegments'], result['desNode']);



      // Switch to the source's floor if it's different from current floor
      // print(_currentFloorId);
      // print()
      if (result['sourceNode'] != null && result['sourceNode'].floorId != _currentFloorId) {
        // First update the floor
        _interactiveMapKey.currentState?.changeFloor(result['sourceNode'].floorId);
        // Wait for floor transition animation
        // Optional: Add a delay before continuing navigation
        await Future.delayed(const Duration(milliseconds: 800), () {
          // Continue with navigation logic after floor change
          if (mounted) {
            // Update any other navigation state as needed
            // print('Floor transition completed to: $floorName');
          }
        });
      }

      setState(() {
        _sourceNode = result['sourceNode'];
        _desNode = result['desNode'];
        _userNode = result['sourceNode'];
        _simplifiedSegments = result['simplifiedSegments'];
        _pathsByFloor = result['pathsByFloor'];
        _transitionPoints = result['transitionPoints'];
        _involvedFloors = result['involvedFloors'];
        _instructionsByFloor = instructionsByFloor;
        _isNavigationCompleted = false;
        _currentFloorId = _sourceNode!.floorId;
        // Set initial instruction
        if (_instructionsByFloor.containsKey(_currentFloorId) &&
            _instructionsByFloor[_currentFloorId]!.isNotEmpty) {
          _currentInstruction = _instructionsByFloor[_currentFloorId]![0];
        } else {
          // _currentInstruction = "Start navigation";
        }
      });

      // Center on the path after state updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_userNode != null) {
          _interactiveMapKey.currentState?.goToPointOnPath(
            _userNode!.coord,
            alignMapToPathSegmentIndex: _getCurrentNavPath()?.points.length != null &&
                _getCurrentNavPath()!.points.length > 1 ? 0 : null,
          );
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _currentInstruction = TurnInstruction(
          location: Offset.zero,
          instruction: "Error: ${e.toString()}",
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showVenueSelectionDialog(bool isSource) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          if (state is AllVenuesLoadedState) {
            return VenueSelectionDialog(
              venues: state.allVenuesName!,
              title: isSource ? 'Select Source' : 'Select Destination',
              onVenueSelected: (venueName) {
                setState(() {

                  if (isSource) {
                    _selectedSource = venueName;
                  } else {
                    _selectedDestination = venueName;

                  }

                });
              },
            );
          }else{
            context.read<NavigationBloc>().add(LoadAllVenuesNameEvent());
          }
          return const CircularProgressIndicator();

        },
      ),
    );
  }

  void _resetNavigationState() {
    _pathsByFloor.clear();
    _transitionPoints.clear();
    _involvedFloors.clear();
    _currentFloorId = 1;
    _sourceNode = null;
    _desNode = null;
    _userNode = null;
    _instructionsByFloor.clear();
    _currentPathPointIndex = 0;
    _isPendingRotation = false;
    _previousPathPointIndex = -1;
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
  void _handleFloorChange(int floorId) {
    // Map floor names to floor IDs (adjust based on your floor naming)


    setState(() {
      _currentFloorId = floorId;
    });

    // Reload venue nodes for the new floor
    _loadVenueNodes().then((_) {
      // After loading venue nodes, update the map if we have a navigation path
      if (_pathsByFloor.containsKey(floorId)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _interactiveMapKey.currentState?.goToPointOnPath(
            _userNode!.coord,
            alignMapToPathSegmentIndex: _getCurrentNavPath()?.points.length != null &&
                _getCurrentNavPath()!.points.length > 1 ? 0 : null,
          );
        });
      }
    });
  }

  FloorData getCurrentFloorData(int currentFloorId){
    // Find current floor data
    return  _floors.firstWhere(
          (floor) => floor.floorId == currentFloorId,
      orElse: () => _floors.first,
    );
  }

  Future<void> _handleNextNavigationStep() async {
    NavPath? currentPath = _getCurrentNavPath();

    if (currentPath == null || currentPath.points.isEmpty || _isNavigationCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have reached your destination')),
      );
      return;
    }

    // Check for floor transitions first
    List<Offset> transitions = _getCurrentFloorTransitions();
    if (transitions.isNotEmpty) {
      // Check if user is near a transition point
      for (Offset transitionPoint in transitions) {
        if (_userNode != null &&
            (_userNode!.coord - transitionPoint).distance < _destinationReachedThreshold) {
          // Handle floor transition immediately
          await _handleFloorTransition();
          // After floor transition, continue with navigation on the new floor
          currentPath = _getCurrentNavPath();
          if (currentPath != null && currentPath.points.isNotEmpty) {
            _handleSingleLevelNavigation(currentPath);
          }
          return;
        }
      }
    }


    if (mounted) {
      _handleSingleLevelNavigation(currentPath!);
    }
  }

  Future<void> _handleFloorTransition() async {
    // Check if map is currently transitioning to avoid conflicts
    if (_interactiveMapKey.currentState?.isTransitioning() == true) {
      return;
    }

    // Find which floor to transition to
    for (var segment in _simplifiedSegments) {
      if (segment.segmentType == "inter_floor_transition" &&
          segment.startFloodId == _currentFloorId) {

        // // Store the current floor ID before transition
        // final int previousFloorId = _currentFloorId;
        final int newFloorId = segment.endFloorId;

        setState(() {
          _currentFloorId = newFloorId;
          _userNode = Node(
            floorId: newFloorId,
            nodeId: -1,
            name: 'User',
            coord: segment.endCoord,
          );
          // Reset navigation state for new floor
          _currentPathPointIndex = 0;
          _previousPathPointIndex = -1;
          _isPendingRotation = true;
        });

        // Notify the map to change floors
        _interactiveMapKey.currentState?.changeFloor(newFloorId);

        // Wait for floor transition to complete
        await Future.delayed(const Duration(milliseconds: 800));

        // After floor transition, update the navigation state
        if (mounted) {
          setState(() {
            // Update navigation state for the new floor
            if (_instructionsByFloor.containsKey(newFloorId)) {
              List<TurnInstruction> instructions = _instructionsByFloor[newFloorId]!;
              if (instructions.isNotEmpty) {
                _currentInstruction = instructions[0];
              }
            }

            // Ensure we have a valid path for the new floor
            if (_pathsByFloor.containsKey(newFloorId)) {
              NavPath newFloorPath = _pathsByFloor[newFloorId]!;
              if (newFloorPath.points.isNotEmpty) {
                // Update user position to the first point of the new floor's path
                _userNode = Node(
                  floorId: newFloorId,
                  nodeId: -1,
                  name: 'User',
                  coord: newFloorPath.points[0],
                );
                _currentPathPointIndex = 0;
              }
            }
          });

          // Center the map on the user's new position
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_userNode != null) {
              _interactiveMapKey.currentState?.goToPointOnPath(
                _userNode!.coord,
                alignMapToPathSegmentIndex: _getCurrentNavPath()?.points.length != null &&
                    _getCurrentNavPath()!.points.length > 1 ? 0 : null,
              );
            }
          });
        }

        break;
      }
    }
  }

  void _handleSingleLevelNavigation(NavPath currentPath) {
    if (_isPendingRotation) {
      setState(() {
        _isPendingRotation = false;

        List<TurnInstruction> instruction = TurnInstructionService.findInstructionForLocation(
            _instructionsByFloor[_currentFloorId]!, _userNode!.coord);

        if (instruction.length > 1) {
          _currentInstruction = instruction[1];
        } else {
          _currentInstruction = instruction[0];
        }
      });

      _interactiveMapKey.currentState?.goToPointOnPath(
        _userNode!.coord,
        alignMapToPathSegmentIndex: _currentPathPointIndex,
      );
    } else {
      int nextPointIndex = _currentPathPointIndex + 1;
      bool isMovingToDestination = false;

      if (nextPointIndex < currentPath.points.length && _desNode != null) {
        if (NavigationService.isMovingToDestination(
            currentPath.points[nextPointIndex],
            _desNode!.coord,
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
        _userNode = Node(
          floorId: _currentFloorId,
          nodeId: -1,
          name: 'User',
          coord: currentPath.points[_currentPathPointIndex],
        );
      });

      if (isMovingToDestination ||
          (_currentPathPointIndex == currentPath.points.length - 1 &&
              _desNode != null &&
              NavigationService.isDestinationReached(_userNode!.coord,
                  _desNode!.coord, _destinationReachedThreshold))) {
        setState(() {
          _currentInstruction = TurnInstruction(
            location: _userNode!.coord,
            instruction: "Arrived at your destination.",
          );
          _isNavigationCompleted = true;
        });

        _interactiveMapKey.currentState?.goToPointOnPath(
          _userNode!.coord,
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
            _instructionsByFloor[_currentFloorId]!, _userNode!.coord);
        isUpcomingTurn = true;
        if (upcomingTurnInstruction.isNotEmpty) {
          nextInstructionText = upcomingTurnInstruction[0].instruction;
          _currentInstruction = TurnInstruction(
            location: _userNode!.coord,
            instruction: nextInstructionText,
            icon: upcomingTurnInstruction[0].icon,
          );
        }
      } else {
        nextInstructionText = "Arrived at the end of the path.";
        _currentInstruction = TurnInstruction(
          location: _userNode!.coord,
          instruction: nextInstructionText,
        );
      }

      setState(() {
        _isPendingRotation = isUpcomingTurn;
      });

      if (isUpcomingTurn) {
        _interactiveMapKey.currentState?.goToPointOnPath(
          _userNode!.coord,
          alignMapToPathSegmentIndex: null,
        );
      } else {
        _interactiveMapKey.currentState?.goToPointOnPath(
          _userNode!.coord,
          alignMapToPathSegmentIndex: _currentPathPointIndex,
        );
      }
    }
  }


Future<void> _showNavigationOptions()  async {
  showDialog(
    context: context,
    builder: (context) => NavigationOptionsMenu(
      onNavigationOptionSelected: (isStepByStep) async {
        if (isStepByStep) {
            setState(() {
              _isStepByStep = true;
            });
          } else {
            // Show path on map
            setState(() {
              _isStepByStep = false;
            });
          }
          await _getNavigationPath(_selectedSource!, _selectedDestination!);
        
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
        bloc: BlocProvider.of<NavigationBloc>(context),
        listener: (context, state) {

          if(state is SelectSourceDialogShownState){
            setState(() {
              _selectedDestination  = state.destination;
            });
            _showVenueSelectionDialog(true);
          }
        },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Indoor Navigation'),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: InteractiveSvgMap(
                key: _interactiveMapKey,
                isStepByStep: _isStepByStep,
                naviPath: _getCurrentNavPath(),
                source: _sourceNode,
                des: _desNode,
                userNode: _userNode,
                userLocation: _userNode?.coord,
                currentPathPointIndex: _currentPathPointIndex,
                venueNodes: venueNodes,
                stairNodes: stairNodes,
                transitionPoints: _getCurrentFloorTransitions(),
                onNavigationPressed: _handleNextNavigationStep,
                isNavigationEnabled: _getCurrentNavPath() != null && !_isNavigationCompleted,
                isLoading: _isLoading,
                floors: _floors,
                onFloorChanged: _handleFloorChange,

                currentFloor: getCurrentFloorData(_currentFloorId),

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
                        child: InkWell(
                          onTap: () => _showVenueSelectionDialog(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              _selectedSource ?? "Select Source",
                              style: TextStyle(
                                color: _selectedSource == null ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _showVenueSelectionDialog(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              _selectedDestination ?? "Select Destination",
                              style: TextStyle(
                                color: _selectedDestination == null ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_selectedSource != null && _selectedDestination != null) {
                            await _showNavigationOptions();
                            // await _getNavigationPath(_selectedSource!, _selectedDestination!);
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('You have reached your destination')),
                            );
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
                        _currentFloorId == 1 ? "Ground Floor" : 'Level $_currentFloorId',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),


                      if(_currentFloorId == _userNode?.floorId && _isStepByStep)
                      Row(
                        children: [
                          if (_instructionsByFloor.containsKey(_currentFloorId) &&
                              _instructionsByFloor[_currentFloorId]!.isNotEmpty &&
                              _currentInstruction.icon != null)
                            SizedBox(
                              width: 50,
                              child:
                                _currentInstruction.icon,

                            ),
                          Expanded(
                            child: Center(
                              child: Text(
                                _instructionsByFloor.containsKey(_currentFloorId) ? _currentInstruction.instruction : "No instructions for this floor",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Add an empty SizedBox with the same width as the icon to maintain symmetry
                          if (_instructionsByFloor.containsKey(_currentFloorId) &&
                              _instructionsByFloor[_currentFloorId]!.isNotEmpty &&
                              _currentInstruction.icon != null)
                            const SizedBox(width: 50),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}