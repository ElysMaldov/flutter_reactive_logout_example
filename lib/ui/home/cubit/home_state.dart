part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, error, unauthenticated }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.user,
    this.appError,
  });

  final HomeStatus status;
  final User? user;
  final AppError? appError;

  @override
  List<Object?> get props => [status, user, appError];

  HomeState copyWith({HomeStatus? status, User? user, ValueWrapper<AppError?>? appError}) {
    return HomeState(
      status: status ?? this.status,
      user: user ?? this.user,
      appError: appError != null ? appError.value : this.appError,
    );
  }
}