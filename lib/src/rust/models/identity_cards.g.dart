// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_cards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IdentityCardImpl _$$IdentityCardImplFromJson(Map<String, dynamic> json) =>
    _$IdentityCardImpl(
      id: json['id'] as String?,
      createdAt: (json['createdAt'] as num?)?.toInt(),
      createdBy: json['createdBy'] as String?,
      updatedAt: (json['updatedAt'] as num?)?.toInt(),
      updatedBy: json['updatedBy'] as String?,
      name: json['name'] as String,
      note: json['note'] as String?,
      country: json['country'] as String?,
      expiryDate: json['expiryDate'] as String?,
      identityCardNumber: json['identityCardNumber'] as String,
      identityCardType: json['identityCardType'] as String?,
      issueDate: json['issueDate'] as String?,
      nameOnCard: json['nameOnCard'] as String,
      state: json['state'] as String?,
      isFavorite: json['isFavorite'] as bool?,
      tags: json['tags'] as String?,
    );

Map<String, dynamic> _$$IdentityCardImplToJson(_$IdentityCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'createdBy': instance.createdBy,
      'updatedAt': instance.updatedAt,
      'updatedBy': instance.updatedBy,
      'name': instance.name,
      'note': instance.note,
      'country': instance.country,
      'expiryDate': instance.expiryDate,
      'identityCardNumber': instance.identityCardNumber,
      'identityCardType': instance.identityCardType,
      'issueDate': instance.issueDate,
      'nameOnCard': instance.nameOnCard,
      'state': instance.state,
      'isFavorite': instance.isFavorite,
      'tags': instance.tags,
    };
