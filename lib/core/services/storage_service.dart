import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// A service to handle file uploads to Firebase Storage.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Uploads an image file to a chat's folder in Firebase Storage.
  /// Returns the download URL of the uploaded image.
  Future<String?> uploadImageToChat(File imageFile, String chatId) async {
    try {
      // Generate a unique file name to prevent conflicts.
      String fileName = _uuid.v4();
      
      // Create a reference to the file location.
      Reference ref = _storage.ref().child('chat_images').child(chatId).child(fileName);
      
      // Upload the file.
      UploadTask uploadTask = ref.putFile(imageFile);
      
      // Await the upload to complete.
      TaskSnapshot snapshot = await uploadTask;
      
      // Get the public URL for the file.
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
