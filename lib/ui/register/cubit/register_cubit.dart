import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_logout_example/data/core/app_error.dart';
import 'package:flutter_reactive_logout_example/data/repositories/auth_repository.dart';
import 'package:flutter_reactive_logout_example/domain/models/register_request.dart';
import 'package:flutter_reactive_logout_example/utils/value_wrapper.dart';
import 'package:equatable/equatable.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const RegisterState());

  Future<void> register(String email, String password, String name) async {
    emit(
      state.copyWith(
        status: RegisterStatus.loading,
        appError: ValueWrapper(null),
      ),
    );
    try {
      // Generate a fake avatar URL using picsum
      final avatarUrl = 'https://picsum.photos/200/200';
      await _authRepository.register(
        RegisterRequest(
          email: email,
          password: password,
          name: name,
          avatar: avatarUrl,
        ),
      );
      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e) {
      final appError = e is AppError
          ? e
          : AppError(message: 'Registration failed');
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          appError: ValueWrapper(appError),
        ),
      );
    }
  }
}
