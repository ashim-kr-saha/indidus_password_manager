import '../data/database.dart';
import '../models/financial_card_model.dart';
import '../rust/models/financial_cards.dart';

class FinancialCardRepository {
  final Database _db;

  FinancialCardRepository(this._db);

  Future<FinancialCardModel> getFinancialCard(String id) async {
    return FinancialCardModel.fromFinancialCard(await _db.getFinancialCard(id));
  }

  Future<List<FinancialCardModel>> listFinancialCards(String query) async {
    return (await _db.listFinancialCard(query))
        .map((l) => FinancialCardModel.fromFinancialCard(l))
        .toList();
  }

  Future<FinancialCardModel> addFinancialCard(
    FinancialCardModel financialCard,
  ) async {
    final data = FinancialCard.fromFinancialCardModel(financialCard);
    final newFinancialCard = await _db.postFinancialCard(data);
    return FinancialCardModel.fromFinancialCard(newFinancialCard);
  }

  Future<FinancialCardModel> updateFinancialCard(
      String id, FinancialCardModel financialCard) async {
    final data = FinancialCard.fromFinancialCardModel(financialCard);
    final updatedFinancialCard = await _db.putFinancialCard(id, data);
    return FinancialCardModel.fromFinancialCard(updatedFinancialCard);
  }

  Future<FinancialCardModel> deleteFinancialCard(String id) async {
    final deletedFinancialCard = await _db.deleteFinancialCard(id);
    return FinancialCardModel.fromFinancialCard(deletedFinancialCard);
  }
}
