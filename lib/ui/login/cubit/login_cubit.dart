import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_logout_example/data/core/app_error.dart';
import 'package:flutter_reactive_logout_example/data/repositories/auth_repository.dart';
import 'package:flutter_reactive_logout_example/domain/models/login_request.dart';
import 'package:flutter_reactive_logout_example/utils/value_wrapper.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState());

  Future<void> login(String email, String password) async {
    emit(
      state.copyWith(status: LoginStatus.loading, appError: ValueWrapper(null)),
    );
    try {
      await _authRepository.login(
        LoginRequest(email: email, password: password),
      );
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      final appError = e is AppError ? e : AppError(message: 'Login failed');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          appError: ValueWrapper(appError),
        ),
      );
    }
  }
}