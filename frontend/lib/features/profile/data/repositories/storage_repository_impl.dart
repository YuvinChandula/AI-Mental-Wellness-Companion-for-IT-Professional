import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/storage_repository.dart';

class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  StorageRepositoryImpl({
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'usr_mock_123';

  @override
  Future<String> uploadProfileImage(Uint8List bytes, String fileName) async {
    final Reference ref = _storage.ref().child('users/$_userId/profile_photo.jpg');
    final UploadTask uploadTask = ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Future<void> deleteProfileImage() async {
    try {
      final Reference ref = _storage.ref().child('users/$_userId/profile_photo.jpg');
      await ref.delete();
    } catch (_) {}
  }
}
