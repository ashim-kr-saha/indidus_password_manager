// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_cards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FinancialCardImpl _$$FinancialCardImplFromJson(Map<String, dynamic> json) =>
    _$FinancialCardImpl(
      id: json['id'] as String?,
      createdAt: (json['createdAt'] as num?)?.toInt(),
      createdBy: json['createdBy'] as String?,
      updatedAt: (json['updatedAt'] as num?)?.toInt(),
      updatedBy: json['updatedBy'] as String?,
      cardHolderName: json['cardHolderName'] as String,
      cardNumber: json['cardNumber'] as String,
      cardProviderName: json['cardProviderName'] as String?,
      cardType: json['cardType'] as String?,
      cvv: json['cvv'] as String?,
      expiryDate: json['expiryDate'] as String?,
      issueDate: json['issueDate'] as String?,
      name: json['name'] as String,
      note: json['note'] as String?,
      pin: json['pin'] as String?,
      isFavorite: json['isFavorite'] as bool?,
      tags: json['tags'] as String?,
    );

Map<String, dynamic> _$$FinancialCardImplToJson(_$FinancialCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'createdBy': instance.createdBy,
      'updatedAt': instance.updatedAt,
      'updatedBy': instance.updatedBy,
      'cardHolderName': instance.cardHolderName,
      'cardNumber': instance.cardNumber,
      'cardProviderName': instance.cardProviderName,
      'cardType': instance.cardType,
      'cvv': instance.cvv,
      'expiryDate': instance.expiryDate,
      'issueDate': instance.issueDate,
      'name': instance.name,
      'note': instance.note,
      'pin': instance.pin,
      'isFavorite': instance.isFavorite,
      'tags': instance.tags,
    };