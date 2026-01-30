import 'package:get_it/get_it.dart';
import 'package:flutter_reactive_logout_example/config/dio/app_dio.dart';
import 'package:flutter_reactive_logout_example/data/core/app_signals.dart';
import 'package:flutter_reactive_logout_example/data/repositories/auth_repository.dart';
import 'package:flutter_reactive_logout_example/data/services/auth_service.dart';
import 'package:flutter_reactive_logout_example/data/storage/secure_storage.dart';

abstract class DependencyManager {
  static final GetIt _injector = GetIt.instance;

  static T get<T extends Object>() => _injector.get<T>();

  static Future<void> setup() async {
    _registerCore();
    _registerDataLayer();

    await _injector.allReady();
  }

  static void _registerCore() {
    _injector.registerSingleton<AppSignals>(AppSignals());
    _injector.registerSingleton<SecureStorage>(SecureStorage());
  }

  static void _registerDataLayer() {
    _injector.registerLazySingleton<AppDio>(
      () => AppDio(
        storage: _injector<SecureStorage>(),
        appSignals: _injector<AppSignals>(),
      ),
    );

    _injector.registerLazySingleton<AuthService>(
      () => AuthServiceRemote(dio: _injector<AppDio>()),
    );

    _injector.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryRemote(
        authService: _injector<AuthService>(),
        secureStorage: _injector<SecureStorage>(),
        appSignals: _injector<AppSignals>(),
      ),
    );
  }
}
