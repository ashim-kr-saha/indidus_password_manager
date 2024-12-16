import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../enums/financial_card.dart';
import '../models/financial_card_model.dart';
import '../repositories/financial_card_repository.dart';

final financialCardRepositoryProvider =
    Provider<FinancialCardRepository?>((ref) {
  return FinancialCardRepository(Database.instance);
});

final financialCardListProvider =
    FutureProvider<List<FinancialCardModel>>((ref) async {
  final repository = ref.watch(financialCardRepositoryProvider);

  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return await repository.listFinancialCards("{}");
});

final financialCardProvider =
    FutureProvider.family<FinancialCardModel, String>((
  ref,
  id,
) async {
  final repository = ref.watch(financialCardRepositoryProvider);
  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return await repository.getFinancialCard(id);
});

final financialCardSelectedDetailsProvider =
    StateProvider<FinancialCardModel?>((ref) => null);

class FinancialCardNotifier
    extends StateNotifier<AsyncValue<List<FinancialCardModel>>> {
  final FinancialCardRepository _repository;

  FinancialCardNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFinancialCards();
  }

  Future<void> loadFinancialCards() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.listFinancialCards("{}"));
  }

  Future<void> addFinancialCard(FinancialCardModel financialCard) async {
    await _repository.addFinancialCard(financialCard);
    loadFinancialCards();
  }

  Future<void> updateFinancialCard(
      String id, FinancialCardModel financialCard) async {
    await _repository.updateFinancialCard(id, financialCard);
    loadFinancialCards();
  }

  Future<void> deleteFinancialCard(String id) async {
    await _repository.deleteFinancialCard(id);
    loadFinancialCards();
  }
}

final financialCardNotifierProvider = StateNotifierProvider<
    FinancialCardNotifier, AsyncValue<List<FinancialCardModel>>>((
  ref,
) {
  final repository = ref.watch(financialCardRepositoryProvider);
  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return FinancialCardNotifier(repository);
});

final selectedFinancialCardsProvider = StateProvider<Set<String>>((ref) => {});

final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

final financialCardSortOptionProvider = StateProvider<FinancialCardSortOption>(
    (ref) => FinancialCardSortOption.createdAtDesc);

final financialCardSearchQueryProvider = StateProvider<String>((ref) => '');
