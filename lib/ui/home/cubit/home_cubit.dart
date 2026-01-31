import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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
    emit(state.copyWith(status: HomeStatus.loading, appError: ValueWrapper(null)));
    try {
      final user = await _authRepository.getUserProfile();
      emit(state.copyWith(status: HomeStatus.success, user: user));
    } catch (e) {
      final appError = e is AppError ? e : AppError(message: 'Failed to load profile');
      emit(state.copyWith(status: HomeStatus.error, appError: ValueWrapper(appError)));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }

  @override
  Future<void> close() {
    _authStatusSubscription?.cancel();
    return super.close();
  }
}