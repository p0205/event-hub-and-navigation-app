import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FloorTransition extends StatefulWidget {
  final String svgPath;
  final bool isTransitioning;
  final Widget child;

  const FloorTransition({
    super.key,
    required this.svgPath,
    required this.isTransitioning,
    required this.child,
  });

  @override
  State<FloorTransition> createState() => _FloorTransitionState();
}

class _FloorTransitionState extends State<FloorTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
  }

  @override
  void didUpdateWidget(FloorTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTransitioning != oldWidget.isTransitioning) {
      if (widget.isTransitioning) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Current floor map
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: child,
                ),
              ),
            );
          },
          child: widget.child,
        ),
        // Next floor map
        if (widget.isTransitioning)
          FutureBuilder<String>(
            future: Future.value(widget.svgPath),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              return SvgPicture.asset(
                snapshot.data!,
                fit: BoxFit.contain,
              );
            },
          ),
      ],
    );
  }
} 