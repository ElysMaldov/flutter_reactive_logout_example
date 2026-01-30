import 'package:json_annotation/json_annotation.dart';

part 'register_response_dto.g.dart';

@JsonSerializable(createJsonSchema: true)
class RegisterResponseDto {
  final String email;
  final String password;
  final String name;
  final String avatar;
  final String role;
  final int id;

  const RegisterResponseDto({
    required this.email,
    required this.password,
    required this.name,
    required this.avatar,
    required this.role,
    required this.id,
  });

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseDtoToJson(this);

  static const jsonSchema = _$RegisterResponseDtoJsonSchema;
}