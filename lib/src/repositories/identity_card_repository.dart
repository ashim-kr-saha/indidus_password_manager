import '../data/database.dart';
import '../models/identity_card_model.dart';
import '../rust/models/identity_cards.dart';

class IdentityCardRepository {
  final Database _db;

  IdentityCardRepository(this._db);

  Future<IdentityCardModel> getIdentityCard(String id) async {
    return IdentityCardModel.fromIdentityCard(await _db.getIdentityCard(id));
  }

  Future<List<IdentityCardModel>> listIdentityCards(String query) async {
    return (await _db.listIdentityCard(query))
        .map((l) => IdentityCardModel.fromIdentityCard(l))
        .toList();
  }

  Future<IdentityCardModel> addIdentityCard(
    IdentityCardModel identityCard,
  ) async {
    final data = IdentityCard.fromIdentityCardModel(identityCard);
    final newIdentityCard = await _db.postIdentityCard(data);
    return IdentityCardModel.fromIdentityCard(newIdentityCard);
  }

  Future<IdentityCardModel> updateIdentityCard(
      String id, IdentityCardModel identityCard) async {
    final data = IdentityCard.fromIdentityCardModel(identityCard);
    final updatedIdentityCard = await _db.putIdentityCard(id, data);
    return IdentityCardModel.fromIdentityCard(updatedIdentityCard);
  }

  Future<IdentityCardModel> deleteIdentityCard(String id) async {
    final deletedIdentityCard = await _db.deleteIdentityCard(id);
    return IdentityCardModel.fromIdentityCard(deletedIdentityCard);
  }
}
