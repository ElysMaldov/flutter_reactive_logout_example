// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    UserProfileDto(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String,
    );

Map<String, dynamic> _$UserProfileDtoToJson(UserProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'password': instance.password,
      'name': instance.name,
      'role': instance.role,
      'avatar': instance.avatar,
    };

const _$UserProfileDtoJsonSchema = {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    'id': {'type': 'integer'},
    'email': {'type': 'string'},
    'password': {'type': 'string'},
    'name': {'type': 'string'},
    'role': {'type': 'string'},
    'avatar': {'type': 'string'},
  },
  'required': ['id', 'email', 'password', 'name', 'role', 'avatar'],
};
