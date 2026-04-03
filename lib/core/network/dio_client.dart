// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'network_interceptor.dart';

class DioClient {
  late final Dio reqresDio;
  late final Dio tmdbDio;
  late final Dio omdbDio;

  DioClient() {
    reqresDio = _buildDio(AppConstants.reqresBaseUrl);
    tmdbDio = _buildDio(AppConstants.tmdbBaseUrl);
    omdbDio = _buildDio(AppConstants.omdbBaseUrl);
  }

  Dio _buildDio(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    // Add random failure interceptor first
    dio.interceptors.add(RandomFailureInterceptor());

    // Add retry interceptor after failure interceptor
    dio.interceptors.add(RetryInterceptor(dio: dio));

    // Logging in debug mode
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: false,
      error: true,
    ));

    return dio;
  }
}
