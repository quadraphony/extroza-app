import 'package:extroza/core/theme/theme_notifier.dart';
import 'package:extroza/features/auth/screens/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:extroza/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Extroza',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          debugShowCheckedModeBanner: false,
          // The AuthWrapper will now decide which screen to show
          home: const AuthWrapper(),
        );
      },
    );
  }
}
