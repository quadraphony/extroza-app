import 'package:flutter/material.dart';
import 'package:extroza/features/auth/screens/phone_auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Getting theme colors for consistency
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Using a placeholder icon for now
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Extroza',
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'A data-friendly chat app for South Africa. Simple, fast, and secure.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const Spacer(), // Pushes the button to the bottom
              ElevatedButton(
                onPressed: () {
                  // Navigate to the phone authentication screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PhoneAuthScreen(),
                    ),
                  );
                },
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 12),
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}