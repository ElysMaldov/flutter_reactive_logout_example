import 'package:json_annotation/json_annotation.dart';

part 'user_profile_dto.g.dart';

@JsonSerializable(createJsonSchema: true)
class UserProfileDto {
  final int id;
  final String email;
  final String password;
  final String name;
  final String role;
  final String avatar;

  const UserProfileDto({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    required this.avatar,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileDtoToJson(this);

  static const jsonSchema = _$UserProfileDtoJsonSchema;
}