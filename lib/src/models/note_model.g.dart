// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteModelImpl _$$NoteModelImplFromJson(Map<String, dynamic> json) =>
    _$NoteModelImpl(
      id: json['id'] as String?,
      name: json['name'] as String,
      isFavorite: json['isFavorite'] as bool,
      note: json['note'] as String?,
      createdAt: (json['createdAt'] as num?)?.toInt(),
      createdBy: json['createdBy'] as String?,
      updatedAt: (json['updatedAt'] as num?)?.toInt(),
      updatedBy: json['updatedBy'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$NoteModelImplToJson(_$NoteModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isFavorite': instance.isFavorite,
      'note': instance.note,
      'createdAt': instance.createdAt,
      'createdBy': instance.createdBy,
      'updatedAt': instance.updatedAt,
      'updatedBy': instance.updatedBy,
      'tags': instance.tags,
    };
