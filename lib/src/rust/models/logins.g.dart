// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logins.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginImpl _$$LoginImplFromJson(Map<String, dynamic> json) => _$LoginImpl(
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
      isFavorite: json['isFavorite'] as bool?,
      tags: json['tags'] as String?,
      apiKeys: json['apiKeys'] as String?,
    );

Map<String, dynamic> _$$LoginImplToJson(_$LoginImpl instance) =>
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
