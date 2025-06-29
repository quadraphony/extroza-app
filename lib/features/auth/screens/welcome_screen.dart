import 'package:extroza/core/services/auth_service.dart';
import 'package:extroza/features/main_screen.dart'; // Import the new MainScreen
import 'package:flutter/material.dart';
import 'package:extroza/features/auth/screens/phone_auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleGoogleSignIn() async {
    // --- DEVELOPMENT BYPASS ---
    // This will skip the real Google Sign-In and go straight to the main screen with tabs.
    print("Bypassing login for development...");
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()), // Navigate to MainScreen
      (route) => false,
    );
    // --- END OF BYPASS ---
  }

  @override
  Widget build(BuildContext context) {
    // The rest of the build method remains the same...
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
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
                  const Spacer(),
                  // This button will now act as our bypass
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    // We'll keep the Google logo for now
                    icon: Image.asset('assets/google_logo.png', height: 24.0), 
                    label: const Text('Sign in with Google'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PhoneAuthScreen(),
                              ),
                            );
                          },
                    child: const Text('Continue with Phone Number'),
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
