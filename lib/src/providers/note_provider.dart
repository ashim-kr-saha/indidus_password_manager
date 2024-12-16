import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../enums/note.dart';
import '../models/note_model.dart';
import '../repositories/note_repository.dart';

final noteRepositoryProvider = Provider<NoteRepository?>((ref) {
  return NoteRepository(Database.instance);
});

final noteListProvider = FutureProvider<List<NoteModel>>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);

  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return await repository.listNotes("{}");
});

final noteProvider = FutureProvider.family<NoteModel, String>((
  ref,
  id,
) async {
  final repository = ref.watch(noteRepositoryProvider);
  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return await repository.getNote(id);
});

final noteSelectedDetailsProvider = StateProvider<NoteModel?>((ref) => null);

class NoteNotifier extends StateNotifier<AsyncValue<List<NoteModel>>> {
  final NoteRepository _repository;

  NoteNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.listNotes("{}"));
  }

  Future<void> addNote(NoteModel note) async {
    await _repository.addNote(note);
    loadNotes();
  }

  Future<void> updateNote(String id, NoteModel note) async {
    await _repository.updateNote(id, note);
    loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _repository.deleteNote(id);
    loadNotes();
  }
}

final noteNotifierProvider =
    StateNotifierProvider<NoteNotifier, AsyncValue<List<NoteModel>>>((
  ref,
) {
  final repository = ref.watch(noteRepositoryProvider);
  if (repository == null) {
    //throw an error
    throw Exception("Database not initialized");
  }
  return NoteNotifier(repository);
});

final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

final noteSortOptionProvider =
    StateProvider<NoteSortOption>((ref) => NoteSortOption.createdAtDesc);

final selectedNotesProvider = StateProvider<Set<String>>((ref) => {});

final noteSearchQueryProvider = StateProvider<String>((ref) => '');
