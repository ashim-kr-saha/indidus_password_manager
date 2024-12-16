import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../enums/identity_card.dart';
import '../models/identity_card_model.dart';
import '../repositories/identity_card_repository.dart';

final identityCardRepositoryProvider = Provider<IdentityCardRepository?>((ref) {
  return IdentityCardRepository(Database.instance);
});

final identityCardListProvider =
    FutureProvider<List<IdentityCardModel>>((ref) async {
  final repository = ref.watch(identityCardRepositoryProvider);

  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return await repository.listIdentityCards("{}");
});

final identityCardProvider = FutureProvider.family<IdentityCardModel, String>((
  ref,
  id,
) async {
  final repository = ref.watch(identityCardRepositoryProvider);
  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return await repository.getIdentityCard(id);
});

final identityCardSelectedDetailsProvider =
    StateProvider<IdentityCardModel?>((ref) => null);

class IdentityCardNotifier
    extends StateNotifier<AsyncValue<List<IdentityCardModel>>> {
  final IdentityCardRepository _repository;

  IdentityCardNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadIdentityCards();
  }

  Future<void> loadIdentityCards() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.listIdentityCards("{}"));
  }

  Future<void> addIdentityCard(IdentityCardModel identityCard) async {
    await _repository.addIdentityCard(identityCard);
    loadIdentityCards();
  }

  Future<void> updateIdentityCard(
      String id, IdentityCardModel identityCard) async {
    await _repository.updateIdentityCard(id, identityCard);
    loadIdentityCards();
  }

  Future<void> deleteIdentityCard(String id) async {
    await _repository.deleteIdentityCard(id);
    loadIdentityCards();
  }
}

final identityCardNotifierProvider = StateNotifierProvider<IdentityCardNotifier,
    AsyncValue<List<IdentityCardModel>>>((
  ref,
) {
  final repository = ref.watch(identityCardRepositoryProvider);
  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return IdentityCardNotifier(repository);
});

final identityCardSearchQueryProvider = StateProvider<String>((ref) => '');

final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

final identityCardSortOptionProvider = StateProvider<IdentityCardSortOption>(
    (ref) => IdentityCardSortOption.createdAtDesc);

final selectedIdentityCardsProvider = StateProvider<Set<String>>((ref) => {});
