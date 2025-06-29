import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:extroza/core/services/auth_service.dart'; // Import our new service
import 'package:extroza/features/auth/screens/otp_screen.dart'; // Keep this for the OTPScreen class

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final AuthService _authService = AuthService();
  String _fullPhoneNumber = '';
  bool _isLoading = false; // To track the loading state

  void _onContinuePressed() {
    if (_fullPhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading spinner
    });

    // Call our service to send the OTP
    _authService.sendOtpToPhone(
      context: context,
      phoneNumber: _fullPhoneNumber,
    ).whenComplete(() {
      // No matter what happens, stop loading when the process is complete
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Your Phone Number'),
      ),
      // We use a Stack to show a loading spinner on top of the content
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Extroza will send an SMS message to verify your phone number.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                IntlPhoneField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(borderSide: BorderSide()),
                  ),
                  initialCountryCode: 'ZA',
                  onChanged: (phone) {
                    _fullPhoneNumber = phone.completeNumber;
                  },
                ),
                const Spacer(),
                // We disable the button when loading
                ElevatedButton(
                  onPressed: _isLoading ? null : _onContinuePressed,
                  child: const Text('Continue'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // If _isLoading is true, show a translucent overlay with a spinner
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