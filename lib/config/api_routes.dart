abstract final class ApiRoutes {
  static const baseUrl = 'https://api.escuelajs.co/api/v1';

  static const login = "$baseUrl/auth/login";
  static const userProfile = "$baseUrl/auth/profile";
  static const refreshToken = "$baseUrl/auth/refresh-token";
  static const register =
      "$baseUrl/users"; // Not exactly register, but it's close enough
}
