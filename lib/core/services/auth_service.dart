import 'package:extroza/core/services/database_service.dart';
import 'package:extroza/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  /// Signs up a new user with their profile information.
  Future<void> signUpWithUsernameAndPassword({
    required BuildContext context,
    required String fullName,
    required String username,
    required String password,
    required String nickname,
    String? bio,
    String? ageRange,
    String? gender,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // Remove the leading '@' if it exists before creating the dummy email.
      final String formattedUsername = username.startsWith('@') ? username.substring(1) : username;
      final String email = '$formattedUsername@extroza.app';

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Create a user model with the provided information
        UserModel newUser = UserModel(
          uid: user.uid,
          fullName: fullName,
          username: username, // Store the original username with the '@'
          nickname: nickname,
          bio: bio,
          ageRange: ageRange,
          gender: gender,
        );
        
        // Save the new user's profile to Firestore
        await _db.createUserProfile(newUser);

        // The AuthWrapper will automatically navigate to the MainScreen
      }
    } on FirebaseAuthException catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Sign-up Failed: ${e.message}')),
      );
    } catch (e) {
       scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  /// Signs in a user with their username and password.
  Future<void> signInWithUsernameAndPassword({
    required BuildContext context,
    required String username,
    required String password,
  }) async {
     final scaffoldMessenger = ScaffoldMessenger.of(context);
     try {
       // Remove the leading '@' if it exists before creating the dummy email.
       final String formattedUsername = username.startsWith('@') ? username.substring(1) : username;
       final String email = '$formattedUsername@extroza.app';
       
       await _auth.signInWithEmailAndPassword(email: email, password: password);
       // The AuthWrapper will handle navigation to the MainScreen on success.
     } on FirebaseAuthException catch (e) {
        scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Login Failed: ${e.message}')),
      );
     } catch (e) {
        scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
     }
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    await _auth.signOut();
    // The AuthWrapper will handle navigation to the WelcomeScreen.
  }
}
