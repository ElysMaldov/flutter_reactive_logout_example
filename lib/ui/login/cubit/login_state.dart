part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final AppError? appError;

  const LoginState({this.status = LoginStatus.initial, this.appError});

  @override
  List<Object?> get props => [status, appError];

  LoginState copyWith({
    LoginStatus? status,
    ValueWrapper<AppError?>? appError,
  }) {
    return LoginState(
      status: status ?? this.status,
      appError: appError != null ? appError.value : this.appError,
    );
  }
}