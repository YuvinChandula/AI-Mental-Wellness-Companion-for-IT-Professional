import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      String? token;
      if (Hive.isBoxOpen(AppConstants.authBoxName)) {
        final Box<dynamic> authBox = Hive.box<dynamic>(AppConstants.authBoxName);
        token = authBox.get(AppConstants.keyJwtToken) as String?;
      }

      // Only attach Authorization header if we have a real Firebase token
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('AuthInterceptor Error: $e');
    }
    super.onRequest(options, handler);
  }
}
