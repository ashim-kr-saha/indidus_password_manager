import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../repositories/tag_repository.dart';
import '../rust/models/tags.dart';

/// Tag provider
/// Uses Example:
/// ```dart
/// final tags = ref.watch(tagNotifierProvider);
/// ```
/// ```dart
/// final tag = ref.watch(tagProvider('1'));
/// ```
/// ```dart
/// final tagList = ref.watch(tagListProvider);
/// ```
/// ```dart
/// final selectedTag = ref.watch(selectedTagProvider);
/// ```
/// ```dart
/// ref.read(tagNotifierProvider.notifier).addTag('New Tag');
/// ```
/// ```dart
/// ref.read(tagNotifierProvider.notifier).updateTag('1', 'Updated Tag');
/// ```
/// ```dart
/// ref.read(tagNotifierProvider.notifier).deleteTag('1');
/// ```

// Repository provider
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository(Database.instance);
});

// Tag notifier
class TagNotifier extends StateNotifier<AsyncValue<List<Tag>>> {
  final TagRepository _repository;

  TagNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTags();
  }

  Future<void> loadTags() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.listTags("{}"));
  }

  Future<void> addTag(Tag tag) async {
    await _repository.addTag(tag);
    await loadTags();
  }

  Future<void> updateTag(String id, Tag tag) async {
    await _repository.updateTag(id, tag);
    await loadTags();
  }

  Future<void> deleteTag(String id) async {
    await _repository.deleteTag(id);
    await loadTags();
  }
}

// Tag notifier provider
final tagNotifierProvider =
    StateNotifierProvider<TagNotifier, AsyncValue<List<Tag>>>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return TagNotifier(repository);
});

// Selected tag provider
final selectedTagProvider = StateProvider<Tag?>((ref) => null);

// Single tag provider (idiomatic way to get a single tag)
final tagProvider = FutureProvider.family<Tag, String>((ref, id) async {
  final repository = ref.watch(tagRepositoryProvider);
  return await repository.getTag(id);
});

// Tag list provider (for convenience)
final tagListProvider = Provider<AsyncValue<List<Tag>>>((ref) {
  return ref.watch(tagNotifierProvider);
});

final allTagsMapProvider = Provider<Map<String, Tag>>((ref) {
  return ref.watch(tagListProvider).when(
        data: (tags) =>
            Map.fromEntries(tags.map((tag) => MapEntry(tag.id!, tag))),
        loading: () => {},
        error: (_, __) => {},
      );
});

final selectedTagsProvider = StateProvider<Set<Tag>>((ref) => {});
