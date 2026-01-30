import 'package:dio/dio.dart';
import 'package:flutter_reactive_logout_example/data/core/app_error.dart';
import 'package:flutter_reactive_logout_example/data/services/auth_service.dart';
import 'package:flutter_reactive_logout_example/data/storage/secure_storage.dart';
import 'package:flutter_reactive_logout_example/domain/models/auth_token.dart';
import 'package:flutter_reactive_logout_example/domain/models/login_request.dart';
import 'package:flutter_reactive_logout_example/domain/models/register_request.dart';
import 'package:flutter_reactive_logout_example/domain/models/user.dart';
import 'package:logging/logging.dart';

abstract class AuthRepository {
  Future<void> register(RegisterRequest registerRequest);
  Future<void> login(LoginRequest loginRequest);
  Future<User> getUserProfile();
}

class AuthRepositoryRemote implements AuthRepository {
  final Logger _log = Logger('AuthRepositoryRemote');
  final AuthService _authService;
  final SecureStorage _secureStorage;

  AuthRepositoryRemote({
    required AuthService authService,
    required SecureStorage secureStorage,
  }) : _authService = authService,
       _secureStorage = secureStorage;

  @override
  Future<void> register(RegisterRequest registerRequest) async {
    try {
      _log.info('Registering user: ${registerRequest.email}');
      await _authService.register(registerRequest);
      _log.info('Registration successful for: ${registerRequest.email}');
    } catch (e, stack) {
      _log.severe('Registration failed', e, stack);
      throw _mapToAppError(e);
    }
  }

  @override
  Future<void> login(LoginRequest loginRequest) async {
    try {
      _log.info('Logging in user: ${loginRequest.email}');
      final response = await _authService.login(loginRequest);

      if (response.accessToken != null && response.refreshToken != null) {
        await _secureStorage.saveAuthToken(
          AuthToken(
            accessToken: response.accessToken!,
            refreshToken: response.refreshToken!,
          ),
        );
      }

      _log.info('Login successful for: ${loginRequest.email}');
    } catch (e, stack) {
      _log.severe('Login failed', e, stack);
      throw _mapToAppError(e);
    }
  }

  @override
  Future<User> getUserProfile() async {
    try {
      _log.info('Fetching user profile');
      final response = await _authService.getUserProfile();
      _log.info('User profile fetched successfully');
      return response.toDomain();
    } catch (e, stack) {
      _log.severe('Failed to fetch user profile', e, stack);
      throw _mapToAppError(e);
    }
  }

  AppError _mapToAppError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    int? statusCode;
    String? message;

    if (error is DioException) {
      statusCode = error.response?.statusCode;
      message = error.message;
    } else if (error is Exception) {
      message = error.toString();
    }

    return AppError(title: null, statusCode: statusCode, message: message);
  }
}
