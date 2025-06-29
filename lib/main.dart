import 'package:extroza/core/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:extroza/core/theme/app_theme.dart';
import 'package:extroza/features/auth/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // We wrap our entire app with the ChangeNotifierProvider.
  // This makes the ThemeNotifier available everywhere in the app.
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const ExtrozaApp(),
    ),
  );
}

class ExtrozaApp extends StatelessWidget {
  const ExtrozaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a Consumer widget to listen to changes in our ThemeNotifier.
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Extroza',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // The themeMode is now controlled by our ThemeNotifier.
          themeMode: themeNotifier.themeMode,
          debugShowCheckedModeBanner: false,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
