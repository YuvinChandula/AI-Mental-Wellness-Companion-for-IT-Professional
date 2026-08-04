import 'dart:typed_data';

abstract class StorageRepository {
  Future<String> uploadProfileImage(Uint8List bytes, String fileName);
  Future<void> deleteProfileImage();
}
