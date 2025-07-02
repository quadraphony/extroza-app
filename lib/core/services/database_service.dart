import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extroza/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A service class to handle all Firestore database operations.
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _usersCollection = 'users';

  /// Creates a new user profile document in the 'users' collection.
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _db.collection(_usersCollection).doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error creating user profile: $e');
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

  /// Fetches a list of all users from the database, excluding the current user.
  Future<List<UserModel>> getUsers() async {
    try {
      final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      QuerySnapshot snapshot = await _db.collection(_usersCollection).get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.uid != currentUserId) // Exclude current user
          .toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  /// Updates a user's profile data in Firestore.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
     try {
      await _db.collection(_usersCollection).doc(uid).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }
}
