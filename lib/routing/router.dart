import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_logout_example/domain/enums/auth_status.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_reactive_logout_example/config/dependencies.dart';
import 'package:flutter_reactive_logout_example/data/repositories/auth_repository.dart';
import 'package:flutter_reactive_logout_example/ui/home/cubit/home_cubit.dart';
import 'package:flutter_reactive_logout_example/ui/home/widgets/home_screen.dart';
import 'package:flutter_reactive_logout_example/ui/login/cubit/login_cubit.dart';
import 'package:flutter_reactive_logout_example/ui/login/widgets/login_screen.dart';
import 'package:flutter_reactive_logout_example/ui/register/cubit/register_cubit.dart';
import 'package:flutter_reactive_logout_example/ui/register/widgets/register_screen.dart';
import 'package:flutter_reactive_logout_example/ui/splash/splash_screen.dart';
import 'routes.dart';

/// AppRouter class that configures go_router with authentication guard and reactive navigation
class AppRouter extends ChangeNotifier {
  AppRouter() {
    _setupAuthListener();
  }

  final AuthRepository _authRepository =
      DependencyManager.get<AuthRepository>();

  /// Listen to any stream from any repositories to reactively update the user's navigation
  void _setupAuthListener() {
    _authRepository.authStatusStream.listen((_) {
      notifyListeners();
    });
  }

  /// Creates the GoRouter instance with auth guard and route configuration
  GoRouter get router {
    return GoRouter(
      initialLocation: Routes.splashScreen,
      redirect: _handleRedirect,
      routes: _routes,
      refreshListenable: this,
    );
  }

  /// Auth guard redirect logic
  /// Listens to authStatusStream and redirects based on authentication state
  Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final authRepository = DependencyManager.get<AuthRepository>();
    final authStatus = authRepository.currentAuthStatus;

    final location = state.uri.toString();

    // Define public routes that don't require authentication
    final isPublicRoute =
        location == Routes.login || location == Routes.register;

    // Handle redirect based on auth status
    switch (authStatus) {
      case AuthStatus.authenticated:
        if (location == Routes.splashScreen || isPublicRoute) {
          return Routes.home;
        }
        break;

      case AuthStatus.unauthenticated:
        if (!isPublicRoute) {
          return Routes.login;
        }
        break;

      case AuthStatus.unknown:
        break;
    }

    return null;
  }

  /// Route definitions
  List<GoRoute> get _routes => [
    GoRoute(
      path: Routes.splashScreen,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) => BlocProvider(
        create: (context) =>
            LoginCubit(authRepository: DependencyManager.get<AuthRepository>()),
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: Routes.register,
      name: 'register',
      builder: (context, state) => BlocProvider(
        create: (context) => RegisterCubit(
          authRepository: DependencyManager.get<AuthRepository>(),
        ),
        child: const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: Routes.home,
      name: 'home',
      builder: (context, state) => BlocProvider(
        create: (context) =>
            HomeCubit(authRepository: DependencyManager.get<AuthRepository>()),
        child: const HomeScreen(),
      ),
    ),
  ];
}
