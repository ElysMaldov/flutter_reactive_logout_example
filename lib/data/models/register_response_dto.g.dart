// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterResponseDto _$RegisterResponseDtoFromJson(Map<String, dynamic> json) =>
    RegisterResponseDto(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      role: json['role'] as String,
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$RegisterResponseDtoToJson(
  RegisterResponseDto instance,
) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'name': instance.name,
  'avatar': instance.avatar,
  'role': instance.role,
  'id': instance.id,
};

const _$RegisterResponseDtoJsonSchema = {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    'email': {'type': 'string'},
    'password': {'type': 'string'},
    'name': {'type': 'string'},
    'avatar': {'type': 'string'},
    'role': {'type': 'string'},
    'id': {'type': 'integer'},
  },
  'required': ['email', 'password', 'name', 'avatar', 'role', 'id'],
};
