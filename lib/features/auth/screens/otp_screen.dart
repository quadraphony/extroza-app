import 'package:flutter/material.dart';

class OTPScreen extends StatelessWidget {
  // This line is the critical part.
  final String verificationId;

  // This constructor is the critical part.
  const OTPScreen({super.key, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Number'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the 6-digit code we sent to your number.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 40),
              // We will add the OTP input field here in the next step
              const Text(
                'OTP Input Field Coming Soon...',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // TODO: Verify the OTP using the verificationId
                  print('Verification ID received: $verificationId');
                },
                child: const Text('Verify & Proceed'),
              )
            ],
          ),
        ),
      ),
    );
  }
}