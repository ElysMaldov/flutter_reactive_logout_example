import 'package:json_annotation/json_annotation.dart';

part 'login_response_dto.g.dart';

@JsonSerializable(createJsonSchema: true)
class LoginResponseDto {
  final String? accessToken;
  final String? refreshToken;

  const LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);

  static const jsonSchema = _$LoginResponseDtoJsonSchema;
}
