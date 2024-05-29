import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(
      Uint8List imageData, Function(double) onProgress) async {
    final fileName = Uuid().v4();
    final storageRef = _storage.ref().child('products/$fileName.jpg');
    final uploadTask = storageRef.putData(
        imageData, SettableMetadata(contentType: 'image/jpeg'));

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress =
          snapshot.bytesTransferred.toDouble() / snapshot.totalBytes.toDouble();
      onProgress(progress);
    });

    try {
      await uploadTask; // Ensure the upload task is completed before proceeding
      final downloadUrl = await storageRef
          .getDownloadURL(); // Get the download URL after upload is complete
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Exception: ${e.message}');
      if (e.code == 'canceled') {
        // Handle the cancellation here if necessary
        print('Upload was canceled.');
      }
      // You can add more specific error handling based on the error code
      rethrow;
    } catch (e) {
      // General error handling
      print('An error occurred: $e');
      rethrow;
    }
  }

  Future<String> uploadImageWithRetry(
      Uint8List imageData, Function(double) onProgress,
      {int maxRetries = 3}) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await uploadImage(imageData, onProgress);
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          rethrow;
        }
        print('Retrying upload... Attempt: $attempt');
      }
    }
    throw Exception('Failed to upload image after $maxRetries attempts.');
  }
}
