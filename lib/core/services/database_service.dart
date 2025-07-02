import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extroza/models/user_model.dart';

/// A service class to handle all Firestore database operations.
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _usersCollection = 'users';

  /// Creates a new user profile document in the 'users' collection.
  /// The document ID will be the user's unique ID (UID) from Firebase Auth.
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _db.collection(_usersCollection).doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error creating user profile: $e');
      // In a real app, you might want to show an error message to the user.
    }
  }

  /// Fetches a user profile from Firestore using their UID.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection(_usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting user profile: $e');
    }
    return null;
  }

  /// Updates a user's profile data in Firestore.
  /// [data] is a map of the fields to update, e.g., {'bio': 'New bio'}.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
     try {
      await _db.collection(_usersCollection).doc(uid).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }
}
