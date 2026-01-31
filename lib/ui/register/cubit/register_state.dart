part of 'register_cubit.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  const RegisterState({
    this.status = RegisterStatus.initial,
    this.appError,
  });

  final RegisterStatus status;
  final AppError? appError;

  @override
  List<Object?> get props => [status, appError];
  
  RegisterState copyWith({
    RegisterStatus? status,
    ValueWrapper<AppError?>? appError,
  }) {
    return RegisterState(
      status: status ?? this.status,
      appError: appError != null ? appError.value : this.appError,
    );
  }
}