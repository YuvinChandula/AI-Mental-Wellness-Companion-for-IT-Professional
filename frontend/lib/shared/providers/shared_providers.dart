import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/auth_interceptor.dart';

// Expose standard DioClient singleton instance
final Provider<DioClient> dioClientProvider = Provider<DioClient>((Ref ref) {
  final DioClient client = DioClient();
  // Register the auth token verification interceptor
  client.dio.interceptors.add(AuthInterceptor());
  return client;
});

// App Theme selection state tracker
final StateProvider<String> themeModeProvider = StateProvider<String>((Ref ref) => 'system');

// Connection State tracker provider
final StateProvider<bool> internetConnectionProvider = StateProvider<bool>((Ref ref) => true);
