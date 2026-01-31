import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_logout_example/config/api_routes.dart';
import 'package:flutter_reactive_logout_example/config/dependencies.dart';
import 'package:flutter_reactive_logout_example/config/dio/app_dio.dart';
import 'package:flutter_reactive_logout_example/data/core/app_error.dart';
import 'package:flutter_reactive_logout_example/data/repositories/auth_repository.dart';
import 'package:flutter_reactive_logout_example/domain/enums/auth_status.dart';
import 'package:flutter_reactive_logout_example/domain/models/user.dart';
import 'package:flutter_reactive_logout_example/utils/value_wrapper.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AuthRepository _authRepository;
  StreamSubscription<AuthStatus>? _authStatusSubscription;

  HomeCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const HomeState()) {
    _listenToAuthStatus();
  }

  void _listenToAuthStatus() {
    _authStatusSubscription = _authRepository.authStatusStream.listen((
      authStatus,
    ) {
      if (authStatus == AuthStatus.unauthenticated) {
        emit(state.copyWith(status: HomeStatus.unauthenticated));
      }
    });
  }

  Future<void> getUserProfile() async {
    emit(
      state.copyWith(status: HomeStatus.loading, appError: ValueWrapper(null)),
    );
    try {
      final user = await _authRepository.getUserProfile();
      emit(state.copyWith(status: HomeStatus.success, user: user));
    } catch (e) {
      final appError = e is AppError
          ? e
          : AppError(message: 'Failed to load profile');
      emit(
        state.copyWith(
          status: HomeStatus.error,
          appError: ValueWrapper(appError),
        ),
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }

  // TODO: Remove this method in prod. For demo purposes only to test logout behavior
  Future<void> trigger401Error() async {
    final dio = DependencyManager.get<AppDio>();
    try {
      // Make a request to the user profile endpoint with throw401Error option
      // This will trigger a 401 error and test the logout behavior
      await dio.get(
        ApiRoutes.userProfile,
        options: Options(extra: {'throw401Error': true}),
      );
    } on DioException catch (e) {
      // The interceptor will handle the 401 and trigger logout
      // Emit error to show snackbar
      final appError = AppError.from(e);
      emit(
        state.copyWith(
          status: HomeStatus.error,
          appError: ValueWrapper(appError),
        ),
      );
    } catch (e) {
      // Handle other errors if needed
      final appError = e is AppError
          ? e
          : AppError(message: 'An error occurred');
      emit(
        state.copyWith(
          status: HomeStatus.error,
          appError: ValueWrapper(appError),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _authStatusSubscription?.cancel();
    return super.close();
  }
}
