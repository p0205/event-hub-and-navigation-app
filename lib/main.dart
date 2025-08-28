import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:event_hub_and_navigation_app/auth/screens/app_entry_point.dart';
import 'package:event_hub_and_navigation_app/feedback/bloc/feedback_bloc.dart';
import 'package:event_hub_and_navigation_app/home/bloc/home_bloc.dart';
import 'package:event_hub_and_navigation_app/navigation/bloc/navigation_bloc.dart';
import 'package:event_hub_and_navigation_app/qr_scanner/bloc/qr_scanner_bloc.dart';
import 'package:event_hub_and_navigation_app/services/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'auth/bloc/auth_bloc.dart';
import 'common_widget/bottom_navigation_bar.dart';
import 'common_widget/navigation_provider.dart';
import 'event_details/bloc/event_bloc.dart';
import 'my_events/blocs/my_events_calendar_view_bloc/bloc/event_bloc.dart';
import 'my_events/blocs/my_events_tab_view_bloc/bloc/event_bloc.dart';
import 'auth/screens/sign_in_screen.dart';
import 'auth/sign_up/screens/sign_up_success_screen.dart';
import 'profile/bloc/profile_bloc.dart';
import 'profile/screens/profile_screen.dart';
import 'repositories/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- IMPORTANT: Add the CookieManager setup here first ---
  // Get the application documents directory for storing cookies persistently
  final appDocDir = await getApplicationDocumentsDirectory();
  final appDocPath = appDocDir.path;
  final cookieJar = PersistCookieJar(storage: FileStorage(Directory("$appDocPath/.cookies/").path));

  // Add CookieManager to Dio's interceptors via ApiService.dio
  ApiService.dio.interceptors.add(CookieManager(cookieJar));
  // --- END CookieManager setup ---

  // --- CALL YOUR LOGGING INTERCEPTOR INITIALIZATION HERE ---
  await ApiService.initializeDioWithInterceptors(); // <--- THIS IS THE MISSING CALL!
  // --- END CALL ---

  await ApiService.loadTokenFromStorage();

  // Initialize the Api client BEFORE running the app
  // This ensures cookies can be managed from the start

  runApp(
      MultiProvider(
          providers: [
            RepositoryProvider(create: (context) => UserRepository()),
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(),
            ),
            BlocProvider<HomeBloc>(
                create: (context) => HomeBloc()
            ),
            BlocProvider<EventDetailsBloc>(
                create: (context) => EventDetailsBloc()
            ),
            BlocProvider<MyEventsCalendarViewBloc>(
                create: (context) => MyEventsCalendarViewBloc()
            ),
            BlocProvider<MyEventsTabViewBloc>(
                create: (context) => MyEventsTabViewBloc()
            ),
            BlocProvider<FeedbackBloc>(
                create: (context) => FeedbackBloc()
            ),
            BlocProvider<NavigationBloc>(
                create: (context) => NavigationBloc()
            ),
            BlocProvider<ProfileBloc>(
              create: (context) => ProfileBloc(),
            ),
            BlocProvider<QrScannerBloc>(
              create: (context) => QrScannerBloc(),
            ),
            ChangeNotifierProvider(
              create: (context) => NavigationProvider(),
            ),
            // Add other BLoCs here
          ],
          child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Store pending deep link to handle after splash
  Uri? _pendingDeepLink;
  bool _splashCompleted = false;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle app launch from deep link (when app is closed)
    try {
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        print('App launched with deep link: $appLink');
        // Store the deep link instead of handling immediately
        _pendingDeepLink = appLink;
      }
    } catch (e) {
      print('Failed to get initial app link: $e');
    }

    // Handle deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
          (uri) {
        print('Received deep link while app running: $uri');
        if (_splashCompleted) {
          handleDeepLink(uri);
        } else {
          _pendingDeepLink = uri;
        }
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  // This method will be called from AppEntryPoint when splash is complete
  void onSplashComplete() {
    print('Splash screen completed');
    _splashCompleted = true;


    // Handle pending deep link if exists
    if (_pendingDeepLink != null) {
      print('Handling pending deep link: $_pendingDeepLink');
      // Add a small delay to ensure the navigation is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        handleDeepLink(_pendingDeepLink!);
        _pendingDeepLink = null;
      });
    }
  }

  void handleDeepLink(Uri uri) {
    print('Handling deep link: $uri');

    if (uri.scheme == 'ftmkeventhub') {
      final context = navigatorKey.currentContext;
      if (context == null) {
        print('Navigator context not available');
        return;
      }

      if (uri.host == 'navigate') {
        // Extract venue parameter
        String? venue = uri.queryParameters['venue'];

        print('Navigation parameters: venue=$venue');
        if(venue!=null){
          context.read<NavigationBloc>().add(SelectDestinationFromDeepLink(destination: venue));
        }


        // Navigate to MainWrapper and switch to Map tab (index 2)
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
              (route) => false, // Remove all previous routes
          arguments: {
            'initialTab': 2, // Map tab index
            'venue': venue,
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => UserRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc()),
          BlocProvider(
            create: (context) => ProfileBloc(),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey, // Add this for deep link navigation
          title: 'Event Hub',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 245, 197, 66)),
            appBarTheme: AppBarTheme(
                centerTitle: true,
                backgroundColor: Color.fromARGB(255, 245, 197, 66)
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => AppEntryPoint(
              onSplashComplete: onSplashComplete, // Pass callback
            ),
            '/sign-in': (context) => const SignInScreen(),
            '/registration-success': (context) => const SignUpSuccessScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/main': (context) => MainWrapper(), // Add route for MainWrapper
          },
        ),
      ),
    );
  }
}