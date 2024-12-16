import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../enums/logins.dart';
import '../models/login_model.dart';
import '../repositories/login_repository.dart';

final loginRepositoryProvider = Provider<LoginRepository?>((ref) {
  return LoginRepository(Database.instance);
});

final loginListProvider = FutureProvider<List<LoginModel>>((ref) async {
  final repository = ref.watch(loginRepositoryProvider);

  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return await repository.listLogins("{}");
});

final loginProvider = FutureProvider.family<LoginModel, String>((
  ref,
  id,
) async {
  final repository = ref.watch(loginRepositoryProvider);
  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return await repository.getLogin(id);
});

final loginSelectedDetailsProvider = StateProvider<LoginModel?>((ref) => null);

class LoginNotifier extends StateNotifier<AsyncValue<List<LoginModel>>> {
  final LoginRepository _repository;

  LoginNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadLogins();
  }

  Future<void> loadLogins() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.listLogins("{}"));
  }

  Future<void> addLogin(LoginModel login) async {
    await _repository.addLogin(login);
    loadLogins();
  }

  Future<void> updateLogin(String id, LoginModel login) async {
    await _repository.updateLogin(id, login);
    loadLogins();
  }

  Future<void> deleteLogin(String id) async {
    await _repository.deleteLogin(id);
    loadLogins();
  }
}

final loginNotifierProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<List<LoginModel>>>((
  ref,
) {
  final repository = ref.watch(loginRepositoryProvider);
  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return LoginNotifier(repository);
});

final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

final loginSortOptionProvider =
    StateProvider<LoginSortOption>((ref) => LoginSortOption.createdAtDesc);

final selectedLoginsProvider = StateProvider<Set<String>>((ref) => {});

final loginSearchQueryProvider = StateProvider<String>((ref) => '');
