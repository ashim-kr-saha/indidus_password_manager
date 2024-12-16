import 'package:freezed_annotation/freezed_annotation.dart';

import '../rust/models/identity_cards.dart';

part 'identity_card_model.freezed.dart';
part 'identity_card_model.g.dart';

@freezed
class IdentityCardModel with _$IdentityCardModel {
  const factory IdentityCardModel({
    String? id,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    required String name,
    String? note,
    String? country,
    String? expiryDate,
    required String identityCardNumber,
    String? identityCardType,
    String? issueDate,
    required String nameOnCard,
    String? state,
    bool? isFavorite,
    List<String>? tags,
  }) = _IdentityCardModel;

  factory IdentityCardModel.fromJson(Map<String, dynamic> json) =>
      _$IdentityCardModelFromJson(json);

  factory IdentityCardModel.fromIdentityCard(IdentityCard identityCard) {
    return IdentityCardModel(
      id: identityCard.id,
      createdAt: identityCard.createdAt,
      createdBy: identityCard.createdBy,
      updatedAt: identityCard.updatedAt,
      updatedBy: identityCard.updatedBy,
      name: identityCard.name,
      note: identityCard.note,
      country: identityCard.country,
      expiryDate: identityCard.expiryDate,
      identityCardNumber: identityCard.identityCardNumber,
      identityCardType: identityCard.identityCardType,
      issueDate: identityCard.issueDate,
      nameOnCard: identityCard.nameOnCard,
      state: identityCard.state,
      isFavorite: identityCard.isFavorite,
      tags: identityCard.tags?.split(',') ?? [],
    );
  }
}
