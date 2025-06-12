import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' show Vector4;

import '../models/floor_data.dart';
import '../models/nav_path.dart';
import '../models/node.dart';
import '../services/map_service.dart';
import '../widgets/floor_navigation.dart';
import '../widgets/floor_transition.dart';
import '../widgets/map_marker.dart';
import '../widgets/navigation_button_group.dart';
import '../widgets/path_painter.dart';

class InteractiveSvgMap extends StatefulWidget {
  final bool isStepByStep;
  final List<NavPath>? naviPaths;
  final Node? source;
  final Node? des;
  final Node? userNode;
  final Offset? userLocation; // User's current location marker
  final int currentPathPointIndex;
  final List<MapMarker> venueNodes;
  final List<MapMarker> stairNodes;
  final VoidCallback? onNavigationPressed;
  final bool? isNavigationEnabled;
  final bool isLoading;
  final List<FloorData> floors;
  final FloorData currentFloor;
  final Function(int)? onFloorChanged;
  final List<Offset>? transitionPoints;

  const InteractiveSvgMap({
    super.key,
    required this.isStepByStep,
    this.naviPaths,
    this.source,
    this.des,
    this.userNode,
    this.userLocation,
    required this.venueNodes,
    required this.stairNodes,
    required this.currentPathPointIndex,
    this.onNavigationPressed,
    this.isNavigationEnabled,
    this.isLoading = false,
    required this.floors,
    required this.currentFloor,
    this.onFloorChanged,
    this.transitionPoints,
  });

  @override
  State<InteractiveSvgMap> createState() => InteractiveSvgMapState();
}

class InteractiveSvgMapState extends State<InteractiveSvgMap>
    with TickerProviderStateMixin {
  double _scale = 1.0;
  double _rotation = 0.0;
  Offset _offset = Offset.zero;

  double _initialScale = 1.0;
  double _initialRotation = 0.0;
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialOffset = Offset.zero;

  static const double _minScale = 0.5;
  static const double _maxScale = 2.0;
  static const double _animationTargetScale = 1.5;

  late Future<Size> _svgSizeFuture;

  late AnimationController _mapAnimationController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  Offset? _animationPivotPointSvg;

  late AnimationController _markerAnimationController;
  Animation<Offset?>? _markerPositionAnimation;
  Node? _currentUserNode;
  
  bool _isShowLocationPin = true;

  bool _isUserGesturing =
  false; // Track if user is manually controlling the map
  final bool _relocateUserLocation = true; // Always keep auto-tracking enabled

  // Timer to delay re-centering after user gesture
  int _gestureEndTime = 0;
  static const int _reTrackingDelayMs = 8000; // 3 seconds delay

  // Junction rotation control
  bool _isAtJunction =
  false; // Whether user is at a junction requiring rotation
  double _pendingRotation = 0.0; // The rotation angle waiting to be applied
  bool _showNextButton = false; // Whether to show the next button

  bool get _isAnimating =>
      _mapAnimationController.isAnimating ||
          _markerAnimationController.isAnimating;

  bool _isTransitioning = false;
  int? _previousFloorId;

  @override
  void initState() {
    super.initState();
        _svgSizeFuture = MapService.getSvgSize(widget.currentFloor.svgPath);
    _currentUserNode = widget.userNode;

    
    _mapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 1000), // Slightly longer for smoother animation
    );

    _mapAnimationController.addListener(() {
      if (!mounted) return;
      final currentAnimatedScale = _scaleAnimation.value;
      final currentAnimatedRotation = _rotationAnimation.value;

      if (_animationPivotPointSvg != null) {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          final Size visibleAreaSize = renderBox.size;
          final double screenCenterX = visibleAreaSize.width / 2;
          final double screenCenterY = visibleAreaSize.height / 2;

          final double rotatedScaledX = _animationPivotPointSvg!.dx *
              math.cos(currentAnimatedRotation) -
              _animationPivotPointSvg!.dy * math.sin(currentAnimatedRotation);
          final double rotatedScaledY = _animationPivotPointSvg!.dx *
              math.sin(currentAnimatedRotation) +
              _animationPivotPointSvg!.dy * math.cos(currentAnimatedRotation);

          final Offset transformedPivotAtOrigin = Offset(
            rotatedScaledX * currentAnimatedScale,
            rotatedScaledY * currentAnimatedScale,
          );

          final Offset newOffset = Offset(
            screenCenterX - transformedPivotAtOrigin.dx,
            screenCenterY - transformedPivotAtOrigin.dy,
          );

          setState(() {
            _offset = newOffset;
            _scale = currentAnimatedScale;
            _rotation = currentAnimatedRotation;
          });
        } else {
          setState(() {
            _offset = _offsetAnimation.value;
            _scale = currentAnimatedScale;
            _rotation = currentAnimatedRotation;
          });
        }
      } else {
        setState(() {
          _offset = _offsetAnimation.value;
          _scale = currentAnimatedScale;
          _rotation = currentAnimatedRotation;
        });
      }
    });

    _offsetAnimation = AlwaysStoppedAnimation(_offset);
    _scaleAnimation = AlwaysStoppedAnimation(_scale);
    _rotationAnimation = AlwaysStoppedAnimation(_rotation);

    _markerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 800), // Slightly longer for smoother marker movement
    );

    _markerAnimationController.addListener(() {
      if (!mounted || _markerPositionAnimation == null) return;

      final Offset? newMarkerPosSvg = _markerPositionAnimation!.value;

      if (newMarkerPosSvg == null) {
        if (_currentUserNode != null) {
          setState(() {
            _currentUserNode = null;
          });
        }
        return;
      }

      // Always update the displayed marker position
      setState(() {

        _currentUserNode = Node(
          floorId: widget.userNode?.floorId ?? _currentUserNode?.floorId ?? 1,
          nodeId: -1,
          name: 'User',
          coord: newMarkerPosSvg,
        );
      });

      // Always center map on marker position when it updates (unless user is actively gesturing)
      if (_shouldCenterOnUser()) {
        _centerMapOnUserLocation();
      }
    });

    // When marker animation completes, ensure we're centered
    _markerAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _shouldCenterOnUser()) {
        _centerMapOnUserLocation();
      }
    });

    _currentUserNode = widget.userNode != null ? Node(
      floorId: widget.userNode!.floorId,
      nodeId: -1,
      name: 'User',
      coord: widget.userLocation!,
    ) : null;

   
  }

  bool _shouldCenterOnUser() {
    // Don't center if user is actively gesturing

    if (_isUserGesturing|| (widget.currentFloor.floorId != widget.userNode?.floorId)) return false;

    // Don't center if we're within the delay period after gesture ended
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - _gestureEndTime < _reTrackingDelayMs) return false;

    // Don't center if _relocateUserLocation is disabled
    if (!_relocateUserLocation) return false;

    return true;
  }

  @override
  void didUpdateWidget(covariant InteractiveSvgMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool userLocationChanged = widget.userLocation != oldWidget.userLocation;
    bool userNodeChanged = widget.userNode != oldWidget.userNode;

    if (userLocationChanged || userNodeChanged) {
      if (_markerAnimationController.isAnimating) {
        _markerAnimationController.stop();
      }

      if (widget.userLocation != null) {
        Offset beginLocation = _currentUserNode?.coord ??
            oldWidget.userLocation ??
            widget.userLocation!;

        if (beginLocation != widget.userLocation!) {
          // Animate marker to new position with smooth curve
          _markerPositionAnimation = Tween<Offset?>(
            begin: beginLocation,
            end: widget.userLocation,
          ).animate(CurvedAnimation(
            parent: _markerAnimationController,
            curve: Curves.easeInOutCubic, // Smoother curve
          ));
          _markerAnimationController.reset();
          _markerAnimationController.forward();
        } else {
          // No animation needed, but still center if appropriate
          setState(() {
            _currentUserNode = Node(
              floorId: widget.userNode?.floorId ?? _currentUserNode?.floorId ?? 1,
              nodeId: -1,
              name: 'User',
              coord: widget.userLocation!,
            );
          });

          // Center map immediately if conditions are met
          if (_shouldCenterOnUser()) {
            _centerMapOnUserLocation();
          }
        }
      } else {
        setState(() {
          _currentUserNode = null;
        });
      }
    }
  }

  void _centerMapOnUserLocation({double? preservedRotation}) {
    if (_currentUserNode == null || !mounted) return;


    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final Size visibleAreaSize = renderBox.size;
    final double screenCenterX = visibleAreaSize.width / 2;
    final double screenCenterY = visibleAreaSize.height / 2;

    // Calculate rotation based on path direction if available
    double targetRotation = preservedRotation ?? _rotation;
    bool shouldRotate = false;

    if (widget.naviPaths != null &&
        widget.naviPaths!.isNotEmpty &&
        widget.naviPaths!.any((path) => path.floorId == widget.currentFloor.floorId)) {
      // Find the current path for this floor
      final currentPath = widget.naviPaths!.firstWhere(
        (path) => path.floorId == widget.currentFloor.floorId,
        orElse: () => widget.naviPaths!.first,
      );
      
      int currentIndex = currentPath.points.indexOf(_currentUserNode!.coord);
      if (currentIndex != -1 && currentIndex < currentPath.points.length - 1) {
        final Offset segmentStart = currentPath.points[currentIndex];
        final Offset segmentEnd = currentPath.points[currentIndex + 1];
        final Offset segmentVector = Offset(
          segmentEnd.dx - segmentStart.dx,
          segmentEnd.dy - segmentStart.dy,
        );
        if (segmentVector.dx.abs() > 1e-6 || segmentVector.dy.abs() > 1e-6) {
          final double segmentAngle = math.atan2(segmentVector.dy, segmentVector.dx);
          final double calculatedRotation = (-math.pi / 2) - segmentAngle;


          // Only calculate new rotation if we're not preserving rotation from floor transition
          if (preservedRotation == null) {
            // Check if significant rotation is needed (more than 15 degrees)
            final double rotationDiff = (_rotation - _shortestAngleTweenEnd(_rotation, calculatedRotation)).abs();
            if (rotationDiff > (math.pi / 12)) {
              _pendingRotation = calculatedRotation;
              _isAtJunction = true;
              _showNextButton = true;
              shouldRotate = false;
            } else {
              targetRotation = calculatedRotation;
              shouldRotate = true;
            }
          }
        }
      }
    }

    final double targetScale = _animationTargetScale.clamp(_minScale, _maxScale);

    final double rotatedScaledX = _currentUserNode!.coord.dx * math.cos(targetRotation) -
        _currentUserNode!.coord.dy * math.sin(targetRotation);
    final double rotatedScaledY = _currentUserNode!.coord.dx * math.sin(targetRotation) +
        _currentUserNode!.coord.dy * math.cos(targetRotation);

    final Offset transformedPivotAtOrigin = Offset(
      rotatedScaledX * targetScale,
      rotatedScaledY * targetScale,
    );

    final Offset newMapOffset = Offset(
      screenCenterX - transformedPivotAtOrigin.dx,
      screenCenterY - transformedPivotAtOrigin.dy,
    );


    // Only animate if we should rotate or if it's just centering
    if (shouldRotate || !_isAtJunction) {
      _triggerMapAnimation(
        targetOffset: newMapOffset,
        targetScale: targetScale,
        targetRotation: targetRotation,
        pivotPointSvg: _currentUserNode!.coord,
      );
    } else {
      // Just center without rotation
      _triggerMapAnimation(
        targetOffset: newMapOffset,
        targetScale: targetScale,
        targetRotation: targetRotation, // Use the preserved rotation
        pivotPointSvg: _currentUserNode!.coord,
      );
    }
  }

  @override
  void dispose() {
    _mapAnimationController.dispose();
    _markerAnimationController.dispose();
    super.dispose();
  }

  double _shortestAngleTweenEnd(double beginAngle, double endAngle) {
    double diff = endAngle - beginAngle;
    if (diff > math.pi) {
      diff -= 2 * math.pi;
    } else if (diff <= -math.pi) {
      diff += 2 * math.pi;
    }
    return beginAngle + diff;
  }

  void _triggerMapAnimation({
    required Offset targetOffset,
    required double targetScale,
    required double targetRotation,
    Offset? pivotPointSvg,
  }) {

    if (_mapAnimationController.isAnimating) {
      _mapAnimationController.stop();
    }
    _animationPivotPointSvg = pivotPointSvg;

    _offsetAnimation = Tween<Offset>(
      begin: _offset,
      end: targetOffset,
    ).animate(CurvedAnimation(
        parent: _mapAnimationController,
        curve: Curves.easeInOutCubic));
    _scaleAnimation = Tween<double>(
      begin: _scale,
      end: targetScale,
    ).animate(CurvedAnimation(
        parent: _mapAnimationController, curve: Curves.easeInOutCubic));
    _rotationAnimation = Tween<double>(
      begin: _rotation,
      end: _shortestAngleTweenEnd(_rotation, targetRotation),
    ).animate(CurvedAnimation(
        parent: _mapAnimationController, curve: Curves.easeInOutCubic));

    _mapAnimationController.reset();
    _mapAnimationController.forward();
  }

  void goToPointOnPath(Offset targetPointSvgToCenter,
      {int? alignMapToPathSegmentIndex, int? currentPathIndex}) {
    if (!mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final Size visibleAreaSize = renderBox?.size ?? const Size(300, 300);
    final double screenCenterX = visibleAreaSize.width / 2;
    final double screenCenterY = visibleAreaSize.height / 2;

    double desiredScale = _animationTargetScale.clamp(_minScale, _maxScale);
    double calculatedRotation = _rotation;

    if (widget.naviPaths != null &&
        alignMapToPathSegmentIndex != null &&
        widget.naviPaths!.isNotEmpty) {
      // Find the current path for this floor
      final currentPath = widget.naviPaths!.firstWhere(
        (path) => path.floorId == widget.currentFloor.floorId,
        orElse: () => widget.naviPaths!.first,
      );
      
      // Get the correct path based on currentPathIndex
      final List<NavPath> pathsForFloor = widget.naviPaths!
          .where((path) => path.floorId == widget.currentFloor.floorId)
          .toList();
      
      final NavPath pathToUse = currentPathIndex != null && 
          currentPathIndex < pathsForFloor.length ? 
          pathsForFloor[currentPathIndex] : currentPath;
      
      if (alignMapToPathSegmentIndex >= 0 &&
          alignMapToPathSegmentIndex < pathToUse.points.length - 1) {
        final Offset segmentStart = pathToUse.points[alignMapToPathSegmentIndex];
        final Offset segmentEnd = pathToUse.points[alignMapToPathSegmentIndex + 1];
        final Offset segmentVector = Offset(
          segmentEnd.dx - segmentStart.dx,
          segmentEnd.dy - segmentStart.dy,
        );
        if (segmentVector.dx.abs() > 1e-6 || segmentVector.dy.abs() > 1e-6) {
          final double segmentAngle = math.atan2(segmentVector.dy, segmentVector.dx);
          calculatedRotation = (-math.pi / 2) - segmentAngle;
        }
      }
    } else if (alignMapToPathSegmentIndex == null &&
        widget.userLocation == null) {
      calculatedRotation = 0.0;
    }

    final double rotatedScaledXFinal =
        targetPointSvgToCenter.dx * math.cos(calculatedRotation) -
            targetPointSvgToCenter.dy * math.sin(calculatedRotation);
    final double rotatedScaledYFinal =
        targetPointSvgToCenter.dx * math.sin(calculatedRotation) +
            targetPointSvgToCenter.dy * math.cos(calculatedRotation);
    final Offset transformedPivotAtOriginFinal = Offset(
      rotatedScaledXFinal * desiredScale,
      rotatedScaledYFinal * desiredScale,
    );
    final Offset finalTargetOffsetForMapAnimation = Offset(
      screenCenterX - transformedPivotAtOriginFinal.dx,
      screenCenterY - transformedPivotAtOriginFinal.dy,
    );

    _triggerMapAnimation(
      targetOffset: finalTargetOffsetForMapAnimation,
      targetScale: desiredScale,
      targetRotation: calculatedRotation,
      pivotPointSvg: targetPointSvgToCenter,
    );
  }


  /// Programmatically change the floor and trigger transition animation
  void changeFloor(int floorId) {
    if (!mounted) return;


    // Check if the floor actually exists
    final floorExists = widget.floors.any((floor) => floor.floorId == floorId);
    if (!floorExists) {
      return;
    }

    // Only proceed if it's a different floor
    if (floorId != widget.currentFloor.floorId) {
      // Store the current rotation and scale before transition
      final double preservedRotation = _rotation;
      final double preservedScale = _scale;

      setState(() {
        _previousFloorId = widget.currentFloor.floorId;
        _isTransitioning = true;
        // Immediately set the rotation to preserve it
        _rotation = preservedRotation;
      });


      // Call the floor change callback after a short delay to allow animation to start
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.onFloorChanged?.call(floorId);
      });

      // Reset transition state after animation completes
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isTransitioning = false;
            _previousFloorId = null;
            // Ensure rotation is preserved
            _rotation = preservedRotation;
            _scale = preservedScale;
          });
        }
      });

      // If user location exists, center the map after floor change
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _currentUserNode != null && _shouldCenterOnUser()) {
          // Pass the preserved rotation to maintain consistency
          _centerMapOnUserLocation(preservedRotation: preservedRotation);
        }
      });
    }
  }

  /// Get the current floor name (useful for external access)
  String getCurrentFloor() {
    return widget.currentFloor.name;
  }

  /// Check if a floor transition is currently in progress
  bool isTransitioning() {
    return _isTransitioning;
  }

  void _showFloorNavigation() {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            child: FloorNavigation(
              floors: widget.floors.map((floor) => floor).toList(),
              currentFloorId: widget.currentFloor.floorId,
              onFloorSelected: (floorId) {
                Navigator.pop(context);
                if (floorId != widget.currentFloor.floorId) {
                  setState(() {
                    _previousFloorId = widget.currentFloor.floorId;
                    _isTransitioning = true;
                  });

                  // Call the callback after a short delay to allow animation to start
                  Future.delayed(const Duration(milliseconds: 100), () {
                    widget.onFloorChanged?.call(floorId);
                  });

                  // Reset transition state after animation completes
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      setState(() {
                        _isTransitioning = false;
                        _previousFloorId = null;
                      });
                    }
                  });
                }
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Size>(
      future: _svgSizeFuture,
      builder: (context, AsyncSnapshot<Size> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final svgSize = snapshot.data!;


        return Stack(
          children: [
            GestureDetector(
              onScaleStart: (details) {
                // User started gesturing - temporarily pause auto-tracking
                setState(() {
                  _isUserGesturing = true;
                });

                if (_mapAnimationController.isAnimating) {
                  _mapAnimationController.stop();
                }
                _animationPivotPointSvg = null;
                _initialScale = _scale;
                _initialRotation = _rotation;
                _initialOffset = _offset;
                _initialFocalPoint = details.focalPoint;
              },
              onScaleUpdate: (details) {
                if (_mapAnimationController.isAnimating) {
                  _mapAnimationController.stop();
                }
                _animationPivotPointSvg = null;

                setState(() {
                  double newScale = _initialScale * details.scale;
                  _scale = newScale.clamp(_minScale, _maxScale);
                  _rotation = _initialRotation + details.rotation;

                  Matrix4 initialTransform = Matrix4.identity()
                    ..translate(_initialOffset.dx, _initialOffset.dy)
                    ..rotateZ(_initialRotation)
                    ..scale(_initialScale);

                  Matrix4 initialTransformInverse =
                  Matrix4.copy(initialTransform)
                    ..invert();

                  final Vector4 focalPointVectorInMapContent =
                  initialTransformInverse.transform(
                    Vector4(
                        _initialFocalPoint.dx, _initialFocalPoint.dy, 0.0, 1.0),
                  );
                  final Offset focalPointOnMapContent = Offset(
                      focalPointVectorInMapContent.x,
                      focalPointVectorInMapContent.y);

                  Matrix4 currentGestureTransform = Matrix4.identity()
                    ..rotateZ(_rotation)
                    ..scale(_scale);

                  final Vector4 newFocalPointVectorOnScreen =
                  currentGestureTransform.transform(
                    Vector4(focalPointOnMapContent.dx,
                        focalPointOnMapContent.dy, 0.0, 1.0),
                  );
                  final Offset newFocalPointOnScreen = Offset(
                      newFocalPointVectorOnScreen.x,
                      newFocalPointVectorOnScreen.y);

                  _offset = details.focalPoint - newFocalPointOnScreen;
                });
              },
              onScaleEnd: (details) {
                // User finished gesturing - record the time and allow re-centering after delay
                _gestureEndTime = DateTime
                    .now()
                    .millisecondsSinceEpoch;
                setState(() {
                  _isUserGesturing = false;
                });

                // Set up delayed re-centering
                Future.delayed(Duration(milliseconds: _reTrackingDelayMs), () {
                  if (mounted &&
                      _shouldCenterOnUser() &&
                      _currentUserNode != null) {
                    _centerMapOnUserLocation();
                  }
                });
              },
              child: OverflowBox(
                minWidth: 0.0,
                maxWidth: double.infinity,
                minHeight: 0.0,
                maxHeight: double.infinity,
                alignment: Alignment.topLeft,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(_offset.dx, _offset.dy)
                    ..rotateZ(_rotation)
                    ..scale(_scale),
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: svgSize.width,
                    height: svgSize.height,
                    child: FloorTransition(
                      svgPath: widget.currentFloor.svgPath,
                      isTransitioning: _isTransitioning,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SvgPicture.asset(

                            clipBehavior: Clip.none,
                            widget.currentFloor.svgPath,
                            fit: BoxFit.none,
                            alignment: Alignment.topLeft,
                          ),
                          if (widget.naviPaths != null &&
                              widget.naviPaths!.isNotEmpty &&
                              widget.naviPaths!.any((path) => path.floorId == widget.currentFloor.floorId))
                            CustomPaint(
                              painter: PathPainter(
                                naviPaths: widget.naviPaths!.where((path) => path.floorId == widget.currentFloor.floorId).toList(),
                              ),
                              size: svgSize,
                            ),

                          if (_isShowLocationPin) ...[
                            ...widget.venueNodes.map((venue) =>
                                MapMarker(
                                  position: venue.position,
                                  label: venue.label ?? 'Venue',
                                  venueFullName: venue.venueFullName,
                                  color: venue.color,
                                  radius: 12,
                                  mapRotation: _rotation,
                                  imageUrl: venue.imageUrl,
                                  floorId: venue.floorId,
                                )
                            ),


                          ],
                          ...?widget.transitionPoints?.map((transitionPoint) =>
                              MapMarker(
                                position: transitionPoint,
                                customIconData: Icons.stairs_rounded,
                                radius: 13,
                                mapRotation: _rotation,
                                floorId: 1, // Default to ground floor for transition points
                              )),
                          if (widget.source != null && (widget.source!.floorId == widget.currentFloor.floorId))
                            MapMarker(
                              position: widget.source!.coord,
                              color: Colors.redAccent,
                              radius: 15.0,
                              mapRotation: _rotation,
                              floorId: 1, // Default to ground floor for source
                            ),
                          if (widget.des != null&& (widget.des!.floorId == widget.currentFloor.floorId))
                            MapMarker(
                              position: widget.des!.coord,
                              color: Colors.redAccent,
                              radius: 15.0,
                              mapRotation: _rotation,
                              floorId: 1, // Default to ground floor for destination
                            ),
                          if (_currentUserNode != null && (_currentUserNode!.floorId == widget.currentFloor.floorId))
                            MapMarker(
                              position: _currentUserNode!.coord,
                              color: Colors.blue,
                              radius: 12.0,
                              mapRotation: _rotation,
                              floorId: _currentUserNode!.floorId,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Add the center location button

            NavigationButtonGroup(
              onCenterPressed: () {
                if (_currentUserNode != null) {
                  _centerMapOnUserLocation();
                }
              },
              onNavigationPressed: widget.onNavigationPressed ?? () {},
              onChangeFloorButtonPressed: _showFloorNavigation,

              isCenterEnabled: _currentUserNode != null && (_currentUserNode?.floorId == widget.currentFloor.floorId),
              isNavigationEnabled: !_isAnimating && (_currentUserNode?.floorId == widget.currentFloor.floorId),
                isLoading: widget.isLoading,
              onShowLocationPinPressed: () {
                setState(() {
                  _isShowLocationPin = !_isShowLocationPin;
                });
              },
              showLocationPin: _isShowLocationPin,

              isNavigatingStatus: (widget.isStepByStep) && (_currentUserNode != null) ,

            ),

          ],
        );
      },
    );
  }
}
