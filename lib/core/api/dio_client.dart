import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openai.com/v1',
      connectTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // Add retry interceptor
  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      logPrint: (message) => print(message),
      retries: AppConstants.maxRetries,
    ),
  );

  return dio;
});