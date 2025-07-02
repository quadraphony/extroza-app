import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the data model for a user profile in the Extroza app.
class UserModel {
  final String uid;
  final String fullName;
  final String username;
  final String nickname;
  final String? bio;
  final String? ageRange;
  final String? gender;
  final String? profilePictureUrl;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.nickname,
    this.bio,
    this.ageRange,
    this.gender,
    this.profilePictureUrl,
  });

  /// Converts a UserModel instance into a Map to be stored in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'username': username,
      'nickname': nickname,
      'bio': bio,
      'ageRange': ageRange,
      'gender': gender,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': FieldValue.serverTimestamp(), // Track when the user joined
    };
  }

  /// Creates a UserModel instance from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? '',
      username: data['username'] ?? '',
      nickname: data['nickname'] ?? '',
      bio: data['bio'],
      ageRange: data['ageRange'],
      gender: data['gender'],
      profilePictureUrl: data['profilePictureUrl'],
    );
  }
}
