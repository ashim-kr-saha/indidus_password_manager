import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../data/database.dart';
import '../../enums/entity_types.dart';
import '../../enums/note.dart';
import '../../enums/screens.dart';
import '../../models/note_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/screen_size_provider.dart';
import '../../providers/tag_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/search_field.dart';
import '../../widgets/tag_selector.dart';
import 'note_detail_page.dart';
import 'note_form.dart';
import 'widgets/note_list_item.dart';

class NoteList extends ConsumerWidget {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final selectedNotes = ref.watch(selectedNotesProvider);
    final tags = _getTags(ref);

    return Scaffold(
      body: _buildBody(context, ref, screenSize, selectedNotes, tags),
      floatingActionButton:
          _buildFloatingActionButton(context, screenSize, selectedNotes, tags),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ScreenSize screenSize,
      Set<String> selectedNotes, List<Tag> tags) {
    final filteredNoteItems = _getFilteredNoteItems(ref);
    final selectedDetails = ref.watch(noteSelectedDetailsProvider);
    final allTagsMap = _createAllTagsMap(tags);

    return screenSize == ScreenSize.small
        ? _buildRefreshableNoteListView(context, screenSize, ref,
            filteredNoteItems, selectedNotes, tags, allTagsMap)
        : _buildSplitView(context, screenSize, ref, filteredNoteItems,
            selectedDetails, selectedNotes, tags, allTagsMap);
  }

  Widget _buildSplitView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<NoteModel> filteredNoteItems,
      NoteModel? selectedDetails,
      Set<String> selectedNotes,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return Row(
      children: [
        Expanded(
          flex: screenSize == ScreenSize.large ? 1 : 2,
          child: _buildRefreshableNoteListView(context, screenSize, ref,
              filteredNoteItems, selectedNotes, tags, allTagsMap),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: _buildDetailView(selectedDetails, screenSize, allTagsMap),
        )
      ],
    );
  }

  Widget _buildRefreshableNoteListView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<NoteModel> filteredNoteItems,
      Set<String> selectedNotes,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return RefreshIndicator(
      onRefresh: () => _refreshNoteList(ref),
      child: _buildNoteListView(context, screenSize, ref, filteredNoteItems,
          selectedNotes, tags, allTagsMap),
    );
  }

  Widget _buildNoteListView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<NoteModel> filteredNoteItems,
      Set<String> selectedNotes,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, ref, selectedNotes, screenSize),
        _buildSearchField(),
        _buildTagSelector(tags),
        _buildNoteItemsList(context, screenSize, ref, filteredNoteItems,
            selectedNotes, allTagsMap),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref,
      Set<String> selectedNotes, ScreenSize screenSize) {
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);

    return SliverAppBar(
      title: selectedNotes.isEmpty
          ? const Text('Note List')
          : Text('${selectedNotes.length} selected'),
      floating: true,
      actions: [
        if (selectedNotes.isEmpty) ...[
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptionsDialog(context, ref),
          ),
          const SizedBox(width: 8),
          _buildFavoriteToggle(ref, showFavoritesOnly),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshNoteList(ref),
          ),
        ],
        if (selectedNotes.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteSelectedNotes(context, ref, selectedNotes),
          ),
        if (screenSize == ScreenSize.small && selectedNotes.isEmpty)
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
      ],
    );
  }

  Widget _buildFavoriteToggle(WidgetRef ref, bool showFavoritesOnly) {
    return InkResponse(
      borderRadius: BorderRadius.circular(20),
      radius: 20,
      child: Icon(
        showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
        color: showFavoritesOnly ? Colors.red : null,
      ),
      onTap: () => ref.read(showFavoritesOnlyProvider.notifier).state =
          !showFavoritesOnly,
    );
  }

  Widget _buildSearchField() {
    return const SliverToBoxAdapter(
      child: SearchField(entityType: EntityType.note),
    );
  }

  Widget _buildTagSelector(List<Tag> tags) {
    return SliverToBoxAdapter(
      child: TagSelector(allTags: tags),
    );
  }

  Widget _buildNoteItemsList(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<NoteModel> filteredNoteItems,
      Set<String> selectedNotes,
      Map<String, Tag> allTagsMap) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildNoteListItem(context, screenSize, ref,
            filteredNoteItems[index], selectedNotes, allTagsMap),
        childCount: filteredNoteItems.length,
      ),
    );
  }

  Widget _buildNoteListItem(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      NoteModel item,
      Set<String> selectedNotes,
      Map<String, Tag> allTagsMap) {
    return NoteListItem(
      item: item,
      screenSize: screenSize,
      isSelected: selectedNotes.contains(item.id),
      allTagsMap: allTagsMap,
      onTap: () => _handleItemTap(
          context, item, screenSize, allTagsMap, ref, selectedNotes),
      onLongPress: () => _toggleSelection(ref, item.id!),
      onToggleFavorite: () => _toggleFavorite(ref, item),
    );
  }

  void _handleItemTap(
      BuildContext context,
      NoteModel item,
      ScreenSize screenSize,
      Map<String, Tag> allTagsMap,
      WidgetRef ref,
      Set<String> selectedNotes) {
    if (selectedNotes.isEmpty) {
      _navigateToDetail(context, item, screenSize, allTagsMap, ref);
    } else {
      _toggleSelection(ref, item.id!);
    }
  }

  Widget _buildDetailView(NoteModel? selectedDetails, ScreenSize screenSize,
      Map<String, Tag> allTags) {
    return Center(
      child: selectedDetails == null
          ? const Text('Select an item to see details',
              style: TextStyle(fontSize: 16, color: Colors.grey))
          : NoteDetailPage(
              note: selectedDetails,
              screenSize: screenSize,
              allTagsMap: allTags),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context,
      ScreenSize screenSize, Set<String> selectedNotes, List<Tag> tags) {
    if (selectedNotes.isNotEmpty) return null;

    return FloatingActionButton(
      onPressed: () => _openForm(context, screenSize, _createAllTagsMap(tags)),
      child: const Icon(Icons.add),
    );
  }

  List<NoteModel> _filterAndSortNoteItems(
    List<NoteModel> items,
    String query,
    bool showFavoritesOnly,
    Set<Tag> selectedTags,
    NoteSortOption sortOption,
  ) {
    Set<String> selectedTagIds = selectedTags.map((tag) => tag.id!).toSet();
    var filteredItems = items.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query.toLowerCase());
      final matchesTags = selectedTagIds.isEmpty ||
          (item.tags?.any((tag) => selectedTagIds.contains(tag)) ?? false);
      return matchesQuery &&
          (!showFavoritesOnly || item.isFavorite) &&
          matchesTags;
    }).toList();

    filteredItems.sort((a, b) {
      switch (sortOption) {
        case NoteSortOption.createdAtDesc:
          return (b.createdAt ?? 0).compareTo(a.createdAt ?? 0);
        case NoteSortOption.createdAtAsc:
          return (a.createdAt ?? 0).compareTo(b.createdAt ?? 0);
        case NoteSortOption.lastModifiedDesc:
          return (b.updatedAt ?? 0).compareTo(a.updatedAt ?? 0);
        case NoteSortOption.lastModifiedAsc:
          return (a.updatedAt ?? 0).compareTo(b.updatedAt ?? 0);
        case NoteSortOption.nameAsc:
          return a.name.compareTo(b.name);
        case NoteSortOption.nameDesc:
          return b.name.compareTo(a.name);
      }
    });

    return filteredItems;
  }

  void _showSortOptionsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort By'),
          content: SingleChildScrollView(
            child: ListBody(
              children: NoteSortOption.values.map((option) {
                return RadioListTile<NoteSortOption>(
                  title: Text(_getSortOptionLabel(option)),
                  value: option,
                  groupValue: ref.watch(noteSortOptionProvider),
                  activeColor: Colors.deepPurple,
                  onChanged: (NoteSortOption? value) {
                    if (value != null) {
                      ref.read(noteSortOptionProvider.notifier).state = value;
                      Navigator.of(context).pop();
                    }
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getSortOptionLabel(NoteSortOption option) {
    switch (option) {
      case NoteSortOption.createdAtDesc:
        return 'Created (Newest)';
      case NoteSortOption.createdAtAsc:
        return 'Created (Oldest)';
      case NoteSortOption.lastModifiedDesc:
        return 'Modified (Newest)';
      case NoteSortOption.lastModifiedAsc:
        return 'Modified (Oldest)';
      case NoteSortOption.nameAsc:
        return 'Name (A-Z)';
      case NoteSortOption.nameDesc:
        return 'Name (Z-A)';
    }
  }

  void _toggleSelection(WidgetRef ref, String id) {
    ref.read(selectedNotesProvider.notifier).update((state) {
      if (state.contains(id)) {
        return state.difference({id});
      } else {
        return state.union({id});
      }
    });
  }

  void _deleteSelectedNotes(
      BuildContext context, WidgetRef ref, Set<String> selectedNotes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete ${selectedNotes.length} selected note(s)?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _performDeletion(context, ref, selectedNotes);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeletion(
      BuildContext context, WidgetRef ref, Set<String> selectedNotes) async {
    final notifier = ref.read(selectedNotesProvider.notifier);
    for (final id in selectedNotes.toList()) {
      try {
        await Database.instance.deleteNote(id);
        notifier.update((state) => state.difference({id}));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Note $id deleted successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting note $id: $e')),
          );
        }
      }
    }
    ref.read(noteNotifierProvider.notifier).loadNotes();
  }

  void _navigateToDetail(
    BuildContext context,
    NoteModel details,
    ScreenSize screenSize,
    Map<String, Tag> allTags,
    WidgetRef ref,
  ) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteDetailPage(
            note: details,
            screenSize: screenSize,
            allTagsMap: allTags,
          ),
        ),
      );
    } else {
      ref.read(noteSelectedDetailsProvider.notifier).state = details;
    }
  }

  void _openForm(
      BuildContext context, ScreenSize screenSize, Map<String, Tag> allTagsMap,
      {NoteModel? noteData}) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NoteForm(note: noteData, allTagsMap: allTagsMap),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SizedBox(
            width: smallScreenWidth.toDouble(),
            child: NoteForm(note: noteData, allTagsMap: allTagsMap),
          ),
        ),
      );
    }
  }

  Future<void> _refreshNoteList(WidgetRef ref) async {
    await ref.read(noteNotifierProvider.notifier).loadNotes();
  }

  void _toggleFavorite(WidgetRef ref, NoteModel note) async {
    final updatedNote = note.copyWith(isFavorite: !(note.isFavorite));
    ref.read(noteNotifierProvider.notifier).updateNote(
          note.id!,
          updatedNote,
        );
    await _refreshNoteList(ref);
  }

  List<NoteModel> _getFilteredNoteItems(WidgetRef ref) {
    final noteState = ref.watch(noteNotifierProvider);
    final searchQuery = ref.watch(noteSearchQueryProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);
    final selectedTags = ref.watch(selectedTagsProvider);
    final sortOption = ref.watch(noteSortOptionProvider);

    final List<NoteModel> noteItems = noteState.when(
      data: (items) => items,
      loading: () => [],
      error: (_, __) => [],
    );

    return _filterAndSortNoteItems(
      noteItems,
      searchQuery,
      showFavoritesOnly,
      selectedTags,
      sortOption,
    );
  }

  List<Tag> _getTags(WidgetRef ref) {
    return ref.watch(tagListProvider).when(
          data: (items) => items,
          loading: () => [],
          error: (_, __) => [],
        );
  }

  Map<String, Tag> _createAllTagsMap(List<Tag> tags) {
    return Map.fromEntries(tags.map((tag) => MapEntry(tag.id!, tag)));
  }
}
