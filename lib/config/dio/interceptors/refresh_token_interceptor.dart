import 'package:dio/dio.dart';
import 'package:flutter_reactive_logout_example/config/api_routes.dart';
import 'package:flutter_reactive_logout_example/data/core/app_error.dart';
import 'package:flutter_reactive_logout_example/data/core/app_signals.dart';
import 'package:flutter_reactive_logout_example/data/storage/secure_storage.dart';
import 'package:flutter_reactive_logout_example/domain/models/auth_token.dart';
import 'package:logging/logging.dart';

/// Uses [QueuedInterceptorsWrapper] so if multiple request fails at once, we refresh
/// the first one before retrying the rest using the new token
class RefreshTokenInterceptor extends QueuedInterceptorsWrapper {
  final Dio _dio;
  final SecureStorage _storage;
  final AppSignals _appSignals;
  final _log = Logger('RefreshTokenInterceptor');

  RefreshTokenInterceptor({
    required Dio dio,
    required SecureStorage storage,
    required AppSignals appSignals,
  }) : _dio = dio,
       _storage = storage,
       _appSignals = appSignals;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['throw401Error'] == true) {
      _log.info('Demo: Throwing 401 error as requested');

      final error = DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 401),
        type: DioExceptionType.badResponse,
      );

      return handler.reject(error, true);
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    // Avoid infinite loop if the refresh-token endpoint itself fails
    final isRefreshRequest = err.requestOptions.path.contains(
      ApiRoutes.refreshToken,
    );

    if (isUnauthorized && !isRefreshRequest) {
      _log.warning('Token expired! Refreshing token...');

      try {
        // If throw401Error is true, throw AppError to trigger the catch block
        if (err.requestOptions.extra['throw401Error'] == true) {
          _log.info('Demo: Throwing AppError as requested');
          throw AppError(message: 'Demo 401 error', statusCode: 401);
        }

        // Refresh token
        final requestOptions = err.requestOptions;
        final authToken = _storage.authToken;
        if (authToken == null || authToken.refreshToken.isEmpty) {
          _log.warning('No refresh token available.');
          return handler.next(err);
        }

        // We create a separate Dio instance here so the refresh call
        // doesn't trigger the interceptors of the main Dio instance
        final tokenDio = Dio(
          BaseOptions(
            baseUrl: _dio.options.baseUrl,
            headers: requestOptions.headers,
          ),
        );

        // XXX We don't group the refresh token request into AuthService since
        // this request requires a different Dio instance than what is injected
        // in the AuthService. It's easier this way too, but a cleaner way is to
        // abstract this away into its own service.
        final refreshResponse = await tokenDio.post(
          ApiRoutes.refreshToken,
          data: FormData.fromMap({'refresh_token': authToken.refreshToken}),
        );

        final newAccessToken = refreshResponse.data['access_token'];
        final newRefreshToken = refreshResponse.data['refresh_token'];

        await _storage.saveAuthToken(
          AuthToken(accessToken: newAccessToken, refreshToken: newRefreshToken),
        );

        try {
          // Retry request
          _log.info('Token refreshed! Retrying request.');
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // We use the original dio instance to retry because it has been setup with interceptors and other configs
          final retryResponse = await _dio.fetch(requestOptions);

          return handler.resolve(retryResponse);
        } catch (e) {
          _log.warning('Failed to retry request', e);
          final appError = AppError.from(e);
          return handler.next(
            DioException(requestOptions: err.requestOptions, error: appError),
          );
        }
      } catch (e) {
        _log.severe('Refresh token failed. Logging user out', e);
        final appError = AppError.from(e);

        // Important piece to signal logout for our app
        _appSignals.emitLogoutSignal();

        return handler.next(
          DioException(requestOptions: err.requestOptions, error: appError),
        );
      }
    }

    return handler.next(err);
  }
}
