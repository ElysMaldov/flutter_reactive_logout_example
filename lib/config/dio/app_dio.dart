import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_reactive_logout_example/config/api_routes.dart';
import 'package:flutter_reactive_logout_example/config/dio/interceptors/inject_auth_token_interceptor.dart';
import 'package:flutter_reactive_logout_example/config/dio/interceptors/refresh_token_interceptor.dart';
import 'package:flutter_reactive_logout_example/data/core/app_signals.dart';
import 'package:flutter_reactive_logout_example/data/storage/secure_storage.dart';

class AppDio extends DioForNative {
  final SecureStorage storage;
  final AppSignals appSignals;

  AppDio({required this.storage, required this.appSignals})
    : super(BaseOptions(baseUrl: ApiRoutes.baseUrl)) {
    interceptors.addAll([
      InjectAuthTokenInterceptor(storage: storage),
      RefreshTokenInterceptor(
        storage: storage,
        appSignals: appSignals,
        dio: this,
      ),
      LogInterceptor(
        error: true,
        request: false,
        requestBody: false,
        requestHeader: false,
        responseBody: false,
        responseHeader: false,
      ),
    ]);
  }
}
