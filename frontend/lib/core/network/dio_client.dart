import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../errors/exceptions.dart';
import 'auth_interceptor.dart';

class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio() {
    final String baseUrl = dotenv.env['BACKEND_URL'] ?? 'https://ai-mental-wellness-companion-for-it.onrender.com';
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (Object object) => print('DioLog: $object'),
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkException(message: 'Connection timed out. Please check your internet.');
    }

    if (e.response != null) {
      final int statusCode = e.response!.statusCode ?? 500;
      final dynamic data = e.response!.data;
      String message = 'Unexpected error occurred.';
      if (data is Map && data.containsKey('message')) {
        message = data['message'].toString();
      }
      return ServerException(message: message, statusCode: statusCode);
    }

    return NetworkException(message: e.message ?? 'Network connection failed.');
  }
}
