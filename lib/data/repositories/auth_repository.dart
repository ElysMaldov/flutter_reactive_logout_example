import 'package:flutter_reactive_logout_example/data/core/app_error.dart';
import 'package:flutter_reactive_logout_example/data/core/app_signals.dart';
import 'package:flutter_reactive_logout_example/data/services/auth_service.dart';
import 'package:flutter_reactive_logout_example/data/storage/secure_storage.dart';
import 'package:flutter_reactive_logout_example/domain/enums/auth_status.dart';
import 'package:flutter_reactive_logout_example/domain/models/auth_token.dart';
import 'package:flutter_reactive_logout_example/domain/models/login_request.dart';
import 'package:flutter_reactive_logout_example/domain/models/register_request.dart';
import 'package:flutter_reactive_logout_example/domain/models/user.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

abstract class AuthRepository {
  Stream<AuthStatus> get authStatusStream;
  AuthStatus get currentAuthStatus;

  Future<void> register(RegisterRequest registerRequest);
  Future<void> login(LoginRequest loginRequest);
  Future<User> getUserProfile();

  Future<void> logout();
  void dispose();
}

class AuthRepositoryRemote extends AuthRepository {
  final Logger _log = Logger('AuthRepositoryRemote');
  final AuthService _authService;
  final SecureStorage _secureStorage;
  final AppSignals _appSignals;

  final BehaviorSubject<AuthStatus> _authStatusSubject =
      BehaviorSubject<AuthStatus>.seeded(AuthStatus.unknown);
  @override
  Stream<AuthStatus> get authStatusStream => _authStatusSubject.stream;
  @override
  AuthStatus get currentAuthStatus => _authStatusSubject.value;

  AuthRepositoryRemote({
    required AuthService authService,
    required SecureStorage secureStorage,
    required AppSignals appSignals,
  }) : _authService = authService,
       _secureStorage = secureStorage,
       _appSignals = appSignals {
    _initializeAuthStatus();
    _listenToLogoutSignal();
  }

  void _listenToLogoutSignal() {
    _appSignals.logoutSignalStream.listen((_) async {
      _log.info('Logout signal received, performing logout');
      await logout();
    });
  }

  Future<void> _initializeAuthStatus() async {
    try {
      _log.info('Initializing auth status');
      await _secureStorage.refreshAuthToken();
      final hasToken = _secureStorage.authToken != null;
      if (hasToken) {
        _authStatusSubject.add(AuthStatus.authenticated);
        _log.info(
          'Auth status initialized: authenticated (existing token found)',
        );
      } else {
        _authStatusSubject.add(AuthStatus.unauthenticated);
        _log.info('Auth status initialized: unauthenticated (no token found)');
      }
    } on Exception catch (e, stack) {
      _log.severe(
        'Token refresh failed during auth status initialization',
        e,
        stack,
      );
      _authStatusSubject.add(AuthStatus.unauthenticated);
    }
  }

  @override
  Future<void> register(RegisterRequest registerRequest) async {
    try {
      _log.info('Registering user: ${registerRequest.email}');
      await _authService.register(registerRequest);
      _log.info('Registration successful for: ${registerRequest.email}');
    } catch (e, stack) {
      final appError = _mapToAppError(e);
      _log.severe('Registration failed', appError, stack);
      throw appError;
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

      _authStatusSubject.add(AuthStatus.authenticated);
      _log.info('Login successful for: ${loginRequest.email}');
    } catch (e, stack) {
      final appError = _mapToAppError(e);
      _log.severe('Login failed', appError, stack);
      throw appError;
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
      final appError = _mapToAppError(e);
      _log.severe('Failed to fetch user profile', appError, stack);
      throw appError;
    }
  }

  @override
  Future<void> logout() async {
    try {
      _log.info('Logging out user');
      await _secureStorage.clearAuthToken();
      _authStatusSubject.add(AuthStatus.unauthenticated);
      _log.info('Logout successful');
    } catch (e, stack) {
      final appError = _mapToAppError(e);
      _log.severe('Logout failed', appError, stack);
      _authStatusSubject.add(AuthStatus.unauthenticated);
      throw appError;
    }
  }

  AppError _mapToAppError(dynamic error) => AppError.from(error);

  @override
  void dispose() {
    _authStatusSubject.close();
  }
}
