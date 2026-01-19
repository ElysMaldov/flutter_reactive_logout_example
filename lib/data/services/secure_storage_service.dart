import 'dart:async';

import 'package:flutter_reactive_logout_example/domain/models/auth_token.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

class SecureStorageService {
  final _log = Logger('SecureStorageService');
  final _storage = const FlutterSecureStorage(aOptions: AndroidOptions());

  // Keys
  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';

  SecureStorageService();

  Future<void> init() async {
    await refreshAuthToken();
  }

  // Auth Token
  final _authTokenStreamController = BehaviorSubject<AuthToken?>();
  Stream<AuthToken?> get authTokenStream => _authTokenStreamController.stream;

  Future<void> refreshAuthToken() async {
    try {
      _log.info('Refreshing auth token');
      final results = await Future.wait([
        _storage.read(key: _accessTokenKey),
        _storage.read(key: _refreshTokenKey),
      ]);

      final access = results[0];
      final refresh = results[1];
      AuthToken? newAuthToken;

      if (access != null && refresh != null) {
        newAuthToken = AuthToken(accessToken: access, refreshToken: refresh);
      }

      _log.info('Refreshing auth token finished');
      _authTokenStreamController.add(newAuthToken);
    } catch (e, stack) {
      _log.severe('Refreshing auth token failed', e, stack);
      rethrow;
    }
  }

  Future<void> saveAuthToken(AuthToken authToken) async {
    try {
      _log.info('Saving auth token');

      await Future.wait([
        _storage.write(key: _accessTokenKey, value: authToken.accessToken),
        _storage.write(key: _refreshTokenKey, value: authToken.refreshToken),
      ]);

      _log.info('Saving auth token finished');

      _authTokenStreamController.add(authToken);
    } catch (e, stack) {
      _log.severe('Saving auth token finished failed', e, stack);
      rethrow;
    }
  }

  Future<void> clearAuthToken() async {
    try {
      _log.info('Clearing auth token');

      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);

      _log.info('Clearing auth token finished');

      _authTokenStreamController.add(null);
    } catch (e, stack) {
      _log.severe('Clearing auth token failed', e, stack);
      rethrow;
    }
  }

  void dispose() {
    _authTokenStreamController.close();
  }
}
