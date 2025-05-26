import 'dart:async'; // Required for Timer
import 'package:event_hub_and_navigation_app/common_widget/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_hub_and_navigation_app/auth/bloc/auth_bloc.dart';
import 'package:event_hub_and_navigation_app/auth/screens/sign_in_screen.dart';
import 'package:event_hub_and_navigation_app/home/screens/home_page.dart';

// Your AuthBloc events and states are assumed to be correctly defined elsewhere.
// e.g., auth_bloc.dart, auth_event.dart, auth_state.dart

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _splashScreenFinished = false; // Flag to track if splash screen duration is over

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController for fading effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Duration of the fade animation
    );

    // Define a fade animation (e.g., from transparent to opaque)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn, // Smooth acceleration
      ),
    );

    // Start the fade animation
    _animationController.forward();

    // Set a timer for the total splash screen duration (3 seconds)
    Timer(const Duration(seconds: 3), () {
      print("MOUNTED: $mounted" );
      if (mounted) {
        setState(() {
          _splashScreenFinished = true; // Mark splash screen as finished
        });
        // Dispatch the AppStarted event *after* the splash screen
        // duration is over.
        context.read<AuthBloc>().add(AppStarted());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The BlocBuilder listens to AuthBloc state changes.
    // However, we only allow it to render HomePage or SignInScreen
    // *after* the fixed splash screen duration has passed.
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previousState, currentState) {
        // Rebuild only if the splash screen has finished AND
        // the state is either AuthenticatedState or UnAuthenticatedState.
        // This prevents rebuilding during the splash screen's fixed duration,
        // and also prevents rebuilding for AuthLoadingState/ErrorState once
        // _splashScreenFinished is true, as those are handled by the top-level
        // listener in main.dart (as per previous discussions).
        return _splashScreenFinished &&
            (currentState is AuthenticatedState || currentState is UnAuthenticatedState ||  currentState is AuthInitialState);
      },
      builder: (context, state) {
        // If the splash screen duration is not over yet,
        // always show the animated splash screen content.
        if (state is AuthenticatedState) {
          return const MainWrapper();
        } else if(state is AuthenticatedState && state is! AuthInitialState ) {
          // This will cover UnAuthenticatedState, AuthLoadingState, ErrorState,
          // or any other state that's not AuthenticatedState after splash.
          return const SignInScreen();
        }
        else{
          return Scaffold(
            backgroundColor: Colors.yellow.shade200, // Light yellow background
            body: FadeTransition(
              opacity: _animation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Event Hub',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow.shade900, // Darker yellow for contrast
                      ),
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // // Once the splash screen duration is over (_splashScreenFinished is true),
        // // then render based on the actual AuthBloc state.
        // else {
        //   if (state is AuthenticatedState) {
        //     return const HomePage();
        //   } else {
        //     // This will cover UnAuthenticatedState, AuthLoadingState, ErrorState,
        //     // or any other state that's not AuthenticatedState after splash.
        //     return const SignInScreen();
        //   }
        // }
      },
    );
  }
}