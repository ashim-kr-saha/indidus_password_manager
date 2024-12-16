// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginModelImpl _$$LoginModelImplFromJson(Map<String, dynamic> json) =>
    _$LoginModelImpl(
      id: json['id'] as String?,
      createdAt: (json['createdAt'] as num?)?.toInt(),
      createdBy: json['createdBy'] as String?,
      updatedAt: (json['updatedAt'] as num?)?.toInt(),
      updatedBy: json['updatedBy'] as String?,
      name: json['name'] as String,
      note: json['note'] as String?,
      username: json['username'] as String,
      url: json['url'] as String?,
      password: json['password'] as String?,
      passwordHint: json['passwordHint'] as String?,
      isFavorite: json['isFavorite'] as bool,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      apiKeys: (json['apiKeys'] as List<dynamic>?)
          ?.map((e) => APIKey.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LoginModelImplToJson(_$LoginModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'createdBy': instance.createdBy,
      'updatedAt': instance.updatedAt,
      'updatedBy': instance.updatedBy,
      'name': instance.name,
      'note': instance.note,
      'username': instance.username,
      'url': instance.url,
      'password': instance.password,
      'passwordHint': instance.passwordHint,
      'isFavorite': instance.isFavorite,
      'tags': instance.tags,
      'apiKeys': instance.apiKeys,
    };

_$APIKeyImpl _$$APIKeyImplFromJson(Map<String, dynamic> json) => _$APIKeyImpl(
      name: json['name'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$$APIKeyImplToJson(_$APIKeyImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
    };
