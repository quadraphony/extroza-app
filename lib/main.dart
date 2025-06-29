import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Make sure this is imported
import 'firebase_options.dart';                   // Make sure this is imported
import 'package:extroza/core/theme/app_theme.dart';
import 'package:extroza/features/auth/screens/welcome_screen.dart';

// The 'async' keyword is essential here
void main() async {
  // This line is required to ensure everything is ready before using plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  // This line is the most important one. 'await' tells the app to wait
  // until Firebase is fully initialized before continuing.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // This line only runs AFTER Firebase is ready.
  runApp(const ExtrozaApp());
}

class ExtrozaApp extends StatelessWidget {
  const ExtrozaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extroza',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}