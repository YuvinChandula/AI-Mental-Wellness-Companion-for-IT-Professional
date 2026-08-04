import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/privacy_settings.dart';
import '../../domain/entities/application_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/privacy_settings_model.dart';
import '../models/application_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Dio _dio;

  SettingsRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Dio? dio,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _dio = dio ?? Dio();

  String get _userId => _auth.currentUser?.uid ?? 'usr_mock_123';

  @override
  Future<PrivacySettings> getPrivacy() async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final String cacheKey = 'privacy_settings_$_userId';

    final dynamic cached = box.get(cacheKey);
    if (cached != null) {
      return PrivacySettingsModel.fromMap(Map<String, dynamic>.from(cached as Map));
    }

    try {
      final DocumentSnapshot doc = await _firestore.collection('privacy_settings').doc(_userId).get();
      if (doc.exists) {
        final PrivacySettingsModel privacy = PrivacySettingsModel.fromFirestore(doc);
        await box.put(cacheKey, privacy.toMap());
        return privacy;
      }
    } catch (_) {}

    return PrivacySettingsModel(
      analyticsCollection: true,
      aiPersonalization: true,
      locationAccess: true,
      notificationPermissions: true,
      dataSharing: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> savePrivacy(PrivacySettings privacy) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final String cacheKey = 'privacy_settings_$_userId';

    final PrivacySettingsModel model = PrivacySettingsModel(
      analyticsCollection: privacy.analyticsCollection,
      aiPersonalization: privacy.aiPersonalization,
      locationAccess: privacy.locationAccess,
      notificationPermissions: privacy.notificationPermissions,
      dataSharing: privacy.dataSharing,
      updatedAt: DateTime.now(),
    );

    await box.put(cacheKey, model.toMap());

    await _firestore
        .collection('privacy_settings')
        .doc(_userId)
        .set(model.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<ApplicationSettings> getAppSettings() async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final String cacheKey = 'application_settings_$_userId';

    final dynamic cached = box.get(cacheKey);
    if (cached != null) {
      return ApplicationSettingsModel.fromMap(Map<String, dynamic>.from(cached as Map));
    }

    try {
      final DocumentSnapshot doc = await _firestore.collection('application_settings').doc(_userId).get();
      if (doc.exists) {
        final ApplicationSettingsModel settings = ApplicationSettingsModel.fromFirestore(doc);
        await box.put(cacheKey, settings.toMap());
        return settings;
      }
    } catch (_) {}

    return ApplicationSettingsModel(
      theme: 'system',
      fontSize: 'medium',
      animationsEnabled: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveAppSettings(ApplicationSettings settings) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final String cacheKey = 'application_settings_$_userId';

    final ApplicationSettingsModel model = ApplicationSettingsModel(
      theme: settings.theme,
      fontSize: settings.fontSize,
      animationsEnabled: settings.animationsEnabled,
      updatedAt: DateTime.now(),
    );

    await box.put(cacheKey, model.toMap());

    await _firestore
        .collection('application_settings')
        .doc(_userId)
        .set(model.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<List<int>> exportPersonalData(String format) async {
    if (format.toLowerCase() == 'pdf') {
      try {
        // Fetch raw PDF bytes from backend analytics summary exporter
        final Response<List<int>> response = await _dio.post<List<int>>(
          '/api/analytics/report/export?format=pdf',
          options: Options(responseType: ResponseType.bytes),
          data: <String, dynamic>{
            'userId': _userId,
            'wellnessScore': 75.0,
            'summaryText': 'Personal account backup data export',
            'createdAt': DateTime.now().toIso8601String(),
          },
        );
        if (response.statusCode == 200 && response.data != null) {
          return response.data!;
        }
      } catch (_) {}
      return utf8.encode('Failed to construct PDF format backup data.');
    }

    // Client-side local JSON compile
    final Map<String, dynamic> dataMap = <String, dynamic>{
      'userId': _userId,
      'exportedAt': DateTime.now().toIso8601String(),
      'privacy': (await getPrivacy()).props,
      'appSettings': (await getAppSettings()).props,
    };

    if (format.toLowerCase() == 'csv') {
      final StringBuffer buffer = StringBuffer();
      buffer.writeln('Attribute,Value');
      dataMap.forEach((String key, dynamic value) {
        buffer.writeln('$key,${value.toString().replaceAll(',', ';')}');
      });
      return utf8.encode(buffer.toString());
    }

    // Default JSON
    final String jsonStr = const JsonEncoder.withIndent('  ').convert(dataMap);
    return utf8.encode(jsonStr);
  }
}
