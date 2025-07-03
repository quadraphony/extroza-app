import 'package:extroza/core/services/notification_service.dart';
import 'package:extroza/core/theme/theme_notifier.dart';
import 'package:extroza/features/auth/screens/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:extroza/core/theme/app_theme.dart';

void main() async {
  // Ensure that Flutter bindings are initialized before any Flutter-specific code.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for the current platform.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize the notification service to handle push notifications.
  await NotificationService().initialize();
  
  // Run the app with a ThemeNotifier provided to the widget tree.
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
    // Consume the ThemeNotifier to react to theme changes.
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Extroza',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          debugShowCheckedModeBanner: false,
          // The AuthWrapper handles whether to show the login/welcome screen
          // or the main app content based on the user's authentication state.
          home: const AuthWrapper(),
        );
      },
    );
  }
}
