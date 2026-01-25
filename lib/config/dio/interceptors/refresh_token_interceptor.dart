import 'package:dio/dio.dart';
import 'package:flutter_reactive_logout_example/config/api_routes.dart';
import 'package:flutter_reactive_logout_example/data/storage/secure_storage.dart';
import 'package:flutter_reactive_logout_example/domain/models/auth_token.dart';
import 'package:logging/logging.dart';

class RefreshTokenInterceptor extends QueuedInterceptorsWrapper {
  final Dio _dio;
  final SecureStorage _storage;

  final _log = Logger('RefreshTokenInterceptor');

  RefreshTokenInterceptor({required Dio dio, required SecureStorage storage})
    : _dio = dio,
      _storage = storage;

  /// Catch 401 by listening to the error
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    // We check this to prevent an infinite loop if the refresh attempt itself fails with a 401
    final isRefreshRequest = err.requestOptions.path.contains(
      ApiRoutes.refreshToken,
    );

    if (isUnauthorized && !isRefreshRequest) {
      _log.warning('Token expired! Refreshing token...');

      try {
        final requestOptions = err.requestOptions;
        final authToken = _storage.authToken;

        if (authToken == null || authToken.refreshToken.isEmpty) {
          _log.warning('No refresh token available.');
          return handler.next(err);
        }

        final tokenDio = Dio(
          BaseOptions(
            baseUrl: _dio.options.baseUrl,
            headers: requestOptions.headers,
          ),
        );

        // Retry request
        final refreshResponse = await tokenDio.post(
          ApiRoutes.refreshToken,
          data: FormData.fromMap({'refresh_token': authToken.refreshToken}),
        );

        final newAccessToken = refreshResponse.data['access_token'];
        final newRefreshToken = refreshResponse.data['refresh_token'];

        _log.fine('Saving refreshed auth token');
        await _storage.saveAuthToken(
          AuthToken(accessToken: newAccessToken, refreshToken: newRefreshToken),
        );

        _log.info('Token refreshed! Retrying request.');

        // Update the retry header with the new access token
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _dio.fetch(requestOptions);

        return handler.resolve(retryResponse);
      } catch (e) {
        _log.severe('Refresh token failed. Logging user out', e);

        // TODO signal app to logout here

        return handler.next(err);
      }
    }

    // Pass through non-401 errors
    return handler.next(err);
  }
}
