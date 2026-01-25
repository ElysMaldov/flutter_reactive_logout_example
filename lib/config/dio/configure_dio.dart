import 'package:dio/dio.dart';
import 'package:flutter_reactive_logout_example/config/api_routes.dart';
import 'package:flutter_reactive_logout_example/config/dio/interceptors/inject_auth_token_interceptor.dart';
import 'package:flutter_reactive_logout_example/config/dio/interceptors/refresh_token_interceptor.dart';
import 'package:flutter_reactive_logout_example/data/storage/secure_storage.dart';

Dio configureDio({required SecureStorage storage}) {
  final dio = Dio(BaseOptions(baseUrl: ApiRoutes.baseUrl));

  dio.interceptors.add(InjectAuthTokenInterceptor(storage: storage));
  dio.interceptors.add(RefreshTokenInterceptor(storage: storage, dio: dio));

  // Optional logging interceptor
  dio.interceptors.add(
    LogInterceptor(
      error: true,
      request: false,
      requestBody: false,
      requestHeader: false,
      responseBody: false,
      responseHeader: false,
    ),
  );

  return dio;
}
