import 'dart:typed_data';
import '../../features/profile/domain/repositories/storage_repository.dart';

class DemoStorageRepository implements StorageRepository {
  @override
  Future<void> deleteProfileImage() async {}

  @override
  Future<String> uploadProfileImage(Uint8List bytes, String fileName) async {
    return 'https://example.com/demo-profile.png';
  }
}
