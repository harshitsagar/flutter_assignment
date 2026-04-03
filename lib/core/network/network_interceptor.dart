// lib/core/network/network_interceptor.dart

import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Custom interceptor that purposely fails 30% of GET requests
/// and implements exponential backoff retry as per assignment requirement.
class RandomFailureInterceptor extends Interceptor {
  final Random _random = Random();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Only apply to GET requests as required
    if (options.method.toUpperCase() == 'GET') {
      if (_random.nextDouble() < AppConstants.failureProbability) {
        // Simulate random failure: 50% SocketException, 50% 500 error
        if (_random.nextBool()) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: const SocketException('Simulated network failure (30% random)'),
              type: DioExceptionType.connectionError,
            ),
          );
          return;
        } else {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 500,
                statusMessage: 'Simulated 500 Internal Server Error (30% random)',
              ),
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
      }
    }
    handler.next(options);
  }
}

/// Retry interceptor with exponential backoff
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = AppConstants.maxRetries});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] ?? 0;

    final statusCode = err.response?.statusCode;

    // NEVER retry auth errors (401, 403) or not-found (404) — these are permanent
    if (statusCode == 401 || statusCode == 403 || statusCode == 404) {
      handler.next(err);
      return;
    }

    // Only retry transient errors: network issues or 5xx server errors
    final isRetriable = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (statusCode != null && statusCode >= 500);

    if (isRetriable && retryCount < maxRetries) {
      // Exponential backoff: 1s, 2s, 4s
      final waitSeconds = pow(2, retryCount).toInt();
      await Future.delayed(Duration(seconds: waitSeconds));

      final options = err.requestOptions;
      options.extra['retryCount'] = retryCount + 1;

      try {
        final response = await dio.fetch(options);
        handler.resolve(response);
        return;
      } catch (_) {
        // Will call onError again with incremented retryCount
      }
    }

    handler.next(err);
  }
}
