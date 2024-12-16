import 'package:freezed_annotation/freezed_annotation.dart';

import '../rust/models/financial_cards.dart';

part 'financial_card_model.freezed.dart';
part 'financial_card_model.g.dart';

@freezed
class FinancialCardModel with _$FinancialCardModel {
  const factory FinancialCardModel({
    String? id,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    required String cardHolderName,
    required String cardNumber,
    String? cardProviderName,
    String? cardType,
    String? cvv,
    String? expiryDate,
    String? issueDate,
    required String name,
    String? note,
    String? pin,
    bool? isFavorite,
    List<String>? tags,
  }) = _FinancialCardModel;

  factory FinancialCardModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialCardModelFromJson(json);

  factory FinancialCardModel.fromFinancialCard(FinancialCard financialCard) {
    return FinancialCardModel(
      id: financialCard.id,
      createdAt: financialCard.createdAt,
      createdBy: financialCard.createdBy,
      updatedAt: financialCard.updatedAt,
      updatedBy: financialCard.updatedBy,
      cardHolderName: financialCard.cardHolderName,
      cardNumber: financialCard.cardNumber,
      cardProviderName: financialCard.cardProviderName,
      cardType: financialCard.cardType,
      cvv: financialCard.cvv,
      expiryDate: financialCard.expiryDate,
      issueDate: financialCard.issueDate,
      name: financialCard.name,
      note: financialCard.note,
      pin: financialCard.pin,
      isFavorite: financialCard.isFavorite,
      tags: financialCard.tags?.split(',') ?? [],
    );
  }
}
