import 'package:dio/dio.dart';
import 'package:flutter_reactive_logout_example/config/api_routes.dart';
import 'package:flutter_reactive_logout_example/data/models/login_response_dto.dart';
import 'package:flutter_reactive_logout_example/data/models/register_response_dto.dart';
import 'package:flutter_reactive_logout_example/data/models/user_profile_dto.dart';
import 'package:flutter_reactive_logout_example/domain/models/login_request.dart';
import 'package:flutter_reactive_logout_example/domain/models/register_request.dart';

abstract class AuthService {
  Future<RegisterResponseDto> register(RegisterRequest registerRequest);
  Future<LoginResponseDto> login(LoginRequest loginRequest);
  Future<UserProfileDto> getUserProfile();
}

class AuthServiceRemote implements AuthService {
  final Dio _dio;

  AuthServiceRemote({required Dio dio}) : _dio = dio;

  @override
  Future<LoginResponseDto> login(LoginRequest loginRequest) async {
    try {
      final response = await _dio.post(
        ApiRoutes.login,
        data: loginRequest.toJson(),
      );
      return LoginResponseDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RegisterResponseDto> register(RegisterRequest registerRequest) async {
    try {
      final response = await _dio.post(
        ApiRoutes.register,
        data: registerRequest.toJson(),
      );
      return RegisterResponseDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserProfileDto> getUserProfile() async {
    try {
      final response = await _dio.get(ApiRoutes.userProfile);
      return UserProfileDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
