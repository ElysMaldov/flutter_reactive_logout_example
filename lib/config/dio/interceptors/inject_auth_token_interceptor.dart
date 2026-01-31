import 'package:dio/dio.dart';
import 'package:flutter_reactive_logout_example/data/core/app_error.dart';
import 'package:flutter_reactive_logout_example/data/storage/secure_storage.dart';
import 'package:logging/logging.dart';

/// Handles injecting auth token from secure storage into Authorization header
class InjectAuthTokenInterceptor extends Interceptor {
  final _log = Logger('InjectAuthTokenInterceptor');

  final SecureStorage _storage;

  InjectAuthTokenInterceptor({required SecureStorage storage})
    : _storage = storage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authToken = _storage.authToken;
    final accessToken = authToken?.accessToken;

    if (accessToken != null) {
      _log.fine('Injecting auth token');
      options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      _log.warning('Auth token not found');
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appError = AppError.from(err);
    _log.severe(
      'ERROR[${appError.statusCode}] => ${err.requestOptions.method} ${err.requestOptions.path}: ${appError.message}',
      err,
    );
    super.onError(err, handler);
  }
}
