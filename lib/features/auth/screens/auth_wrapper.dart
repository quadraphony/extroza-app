import 'package:extroza/features/auth/screens/welcome_screen.dart';
import 'package:extroza/features/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading spinner while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If the user is logged in, show the main screen
        if (snapshot.hasData) {
          return const MainScreen();
        }

        // If the user is not logged in, show the welcome screen
        return const WelcomeScreen();
      },
    );
  }
}
