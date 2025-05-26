import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:event_hub_and_navigation_app/auth/screens/app_entry_point.dart';
import 'package:event_hub_and_navigation_app/feedback/bloc/feedback_bloc.dart';
import 'package:event_hub_and_navigation_app/home/bloc/home_bloc.dart';
import 'package:event_hub_and_navigation_app/my_events/bloc/event_bloc.dart';
import 'package:event_hub_and_navigation_app/services/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'auth/bloc/auth_bloc.dart';

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

    MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(),
          ),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc()
          ),
          BlocProvider<EventBloc>(
              create: (context) => EventBloc()
          ),
          BlocProvider<FeedbackBloc>(
              create: (context) => FeedbackBloc()
          ),
          // Add other BLoCs here
        ],
      child: const MyApp()))
    ;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 245, 197, 66)),
        appBarTheme:  AppBarTheme(

            centerTitle: true,
            backgroundColor: Color.fromARGB(255, 245, 197, 66)
        ),
        useMaterial3: true,
      ),
      home: const AppEntryPoint()

    );
  }
}
