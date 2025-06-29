import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:extroza/features/auth/screens/otp_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // This function will handle the entire phone sign-in process
  Future<void> sendOtpToPhone({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      // (A) This is called when verification is successful automatically
      // This is rare and happens only on some Android devices.
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        // TODO: Navigate to HomeScreen
      },
      // (B) This is called if there is an error
      verificationFailed: (FirebaseAuthException e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Verification Failed: ${e.message}')),
        );
      },
      // (C) This is the most important one for us. It's called when the SMS
      // has been sent from Firebase to the user's phone.
      codeSent: (String verificationId, int? resendToken) {
        // We navigate to the OTP screen and pass the verificationId
        // so we can use it to verify the code the user enters.
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OTPScreen(verificationId: verificationId),
          ),
        );
      },
      // (D) This handles timeouts.
      codeAutoRetrievalTimeout: (String verificationId) {
        // You could handle this if needed, for now we'll do nothing.
      },
    );
  }
}