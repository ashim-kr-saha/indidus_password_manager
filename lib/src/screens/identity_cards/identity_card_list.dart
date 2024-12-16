import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../data/database.dart';
import '../../enums/entity_types.dart';
import '../../enums/identity_card.dart';
import '../../enums/screens.dart';
import '../../models/identity_card_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/identity_card_provider.dart';
import '../../providers/screen_size_provider.dart';
import '../../providers/tag_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/search_field.dart';
import '../../widgets/tag_selector.dart';
import 'identity_card_details.dart';
import 'identity_card_form.dart';
import 'widgets/identity_card_list_item.dart';

class IdentityCardList extends ConsumerWidget {
  const IdentityCardList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final selectedIdentityCards = ref.watch(selectedIdentityCardsProvider);
    final tags = _getTags(ref);

    return Scaffold(
      body: _buildBody(context, ref, screenSize, selectedIdentityCards, tags),
      floatingActionButton: _buildFloatingActionButton(
          context, screenSize, selectedIdentityCards, tags),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ScreenSize screenSize,
      Set<String> selectedIdentityCards, List<Tag> tags) {
    final filteredIdentityCardItems = _getFilteredIdentityCardItems(ref);
    final selectedDetails = ref.watch(identityCardSelectedDetailsProvider);
    final allTagsMap = _createAllTagsMap(tags);

    return screenSize == ScreenSize.small
        ? _buildRefreshableIdentityCardListView(context, screenSize, ref,
            filteredIdentityCardItems, selectedIdentityCards, tags, allTagsMap)
        : _buildSplitView(context, screenSize, ref, filteredIdentityCardItems,
            selectedDetails, selectedIdentityCards, tags, allTagsMap);
  }

  Widget _buildSplitView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<IdentityCardModel> filteredIdentityCardItems,
      IdentityCardModel? selectedDetails,
      Set<String> selectedIdentityCards,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return Row(
      children: [
        Expanded(
          flex: screenSize == ScreenSize.large ? 1 : 2,
          child: _buildRefreshableIdentityCardListView(
              context,
              screenSize,
              ref,
              filteredIdentityCardItems,
              selectedIdentityCards,
              tags,
              allTagsMap),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: _buildDetailView(selectedDetails, screenSize, allTagsMap),
        )
      ],
    );
  }

  Widget _buildRefreshableIdentityCardListView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<IdentityCardModel> filteredIdentityCardItems,
      Set<String> selectedIdentityCards,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return RefreshIndicator(
      onRefresh: () => _refreshIdentityCardList(ref),
      child: _buildIdentityCardListView(context, screenSize, ref,
          filteredIdentityCardItems, selectedIdentityCards, tags, allTagsMap),
    );
  }

  Widget _buildIdentityCardListView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<IdentityCardModel> filteredIdentityCardItems,
      Set<String> selectedIdentityCards,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, ref, selectedIdentityCards, screenSize),
        _buildSearchField(),
        _buildTagSelector(tags),
        _buildIdentityCardItemsList(context, screenSize, ref,
            filteredIdentityCardItems, selectedIdentityCards, allTagsMap),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref,
      Set<String> selectedIdentityCards, ScreenSize screenSize) {
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);

    return SliverAppBar(
      title: selectedIdentityCards.isEmpty
          ? const Text('Identity Card List')
          : Text('${selectedIdentityCards.length} selected'),
      floating: true,
      actions: [
        if (selectedIdentityCards.isEmpty) ...[
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptionsDialog(context, ref),
          ),
          const SizedBox(width: 8),
          _buildFavoriteToggle(ref, showFavoritesOnly),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshIdentityCardList(ref),
          ),
        ],
        if (selectedIdentityCards.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteSelectedIdentityCards(
                context, ref, selectedIdentityCards),
          ),
        if (screenSize == ScreenSize.small && selectedIdentityCards.isEmpty)
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
      child: SearchField(entityType: EntityType.identityCard),
    );
  }

  Widget _buildTagSelector(List<Tag> tags) {
    return SliverToBoxAdapter(
      child: TagSelector(allTags: tags),
    );
  }

  Widget _buildIdentityCardItemsList(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<IdentityCardModel> filteredIdentityCardItems,
      Set<String> selectedIdentityCards,
      Map<String, Tag> allTagsMap) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildIdentityCardListItem(
            context,
            screenSize,
            ref,
            filteredIdentityCardItems[index],
            selectedIdentityCards,
            allTagsMap),
        childCount: filteredIdentityCardItems.length,
      ),
    );
  }

  Widget _buildIdentityCardListItem(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      IdentityCardModel item,
      Set<String> selectedIdentityCards,
      Map<String, Tag> allTagsMap) {
    return IdentityCardListItem(
      item: item,
      screenSize: screenSize,
      isSelected: selectedIdentityCards.contains(item.id),
      allTagsMap: allTagsMap,
      onTap: () => _handleItemTap(
          context, item, screenSize, allTagsMap, ref, selectedIdentityCards),
      onLongPress: () => _toggleSelection(ref, item.id!),
      onToggleFavorite: () => _toggleFavorite(ref, item),
    );
  }

  void _handleItemTap(
      BuildContext context,
      IdentityCardModel item,
      ScreenSize screenSize,
      Map<String, Tag> allTagsMap,
      WidgetRef ref,
      Set<String> selectedIdentityCards) {
    if (selectedIdentityCards.isEmpty) {
      _navigateToDetail(context, item, screenSize, allTagsMap, ref);
    } else {
      _toggleSelection(ref, item.id!);
    }
  }

  Widget _buildDetailView(IdentityCardModel? selectedDetails,
      ScreenSize screenSize, Map<String, Tag> allTags) {
    return Center(
      child: selectedDetails == null
          ? const Text('Select an item to see details',
              style: TextStyle(fontSize: 16, color: Colors.grey))
          : IdentityCardDetailPage(
              data: selectedDetails,
              screenSize: screenSize,
              allTagsMap: allTags),
    );
  }

  Widget? _buildFloatingActionButton(
      BuildContext context,
      ScreenSize screenSize,
      Set<String> selectedIdentityCards,
      List<Tag> tags) {
    if (selectedIdentityCards.isNotEmpty) return null;

    return FloatingActionButton(
      onPressed: () => _openForm(context, screenSize, _createAllTagsMap(tags)),
      child: const Icon(Icons.add),
    );
  }

  List<IdentityCardModel> _filterAndSortIdentityCardItems(
    List<IdentityCardModel> items,
    String query,
    bool showFavoritesOnly,
    Set<Tag> selectedTags,
    IdentityCardSortOption sortOption,
  ) {
    Set<String> selectedTagIds = selectedTags.map((tag) => tag.id!).toSet();
    var filteredItems = items.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query.toLowerCase());
      final matchesTags = selectedTagIds.isEmpty ||
          (item.tags?.any((tag) => selectedTagIds.contains(tag)) ?? false);
      return matchesQuery &&
          (!showFavoritesOnly || (item.isFavorite ?? false)) &&
          matchesTags;
    }).toList();

    filteredItems.sort((a, b) {
      switch (sortOption) {
        case IdentityCardSortOption.createdAtDesc:
          return (b.createdAt ?? 0).compareTo(a.createdAt ?? 0);
        case IdentityCardSortOption.createdAtAsc:
          return (a.createdAt ?? 0).compareTo(b.createdAt ?? 0);
        case IdentityCardSortOption.lastModifiedDesc:
          return (b.updatedAt ?? 0).compareTo(a.updatedAt ?? 0);
        case IdentityCardSortOption.lastModifiedAsc:
          return (a.updatedAt ?? 0).compareTo(b.updatedAt ?? 0);
        case IdentityCardSortOption.nameAsc:
          return a.name.compareTo(b.name);
        case IdentityCardSortOption.nameDesc:
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
              children: IdentityCardSortOption.values.map((option) {
                return RadioListTile<IdentityCardSortOption>(
                  title: Text(_getSortOptionLabel(option)),
                  value: option,
                  groupValue: ref.watch(identityCardSortOptionProvider),
                  activeColor: Colors.deepPurple,
                  onChanged: (IdentityCardSortOption? value) {
                    if (value != null) {
                      ref.read(identityCardSortOptionProvider.notifier).state =
                          value;
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

  String _getSortOptionLabel(IdentityCardSortOption option) {
    switch (option) {
      case IdentityCardSortOption.createdAtDesc:
        return 'Created (Newest)';
      case IdentityCardSortOption.createdAtAsc:
        return 'Created (Oldest)';
      case IdentityCardSortOption.lastModifiedDesc:
        return 'Modified (Newest)';
      case IdentityCardSortOption.lastModifiedAsc:
        return 'Modified (Oldest)';
      case IdentityCardSortOption.nameAsc:
        return 'Name (A-Z)';
      case IdentityCardSortOption.nameDesc:
        return 'Name (Z-A)';
    }
  }

  void _toggleSelection(WidgetRef ref, String id) {
    ref.read(selectedIdentityCardsProvider.notifier).update((state) {
      if (state.contains(id)) {
        return state.difference({id});
      } else {
        return state.union({id});
      }
    });
  }

  void _deleteSelectedIdentityCards(
      BuildContext context, WidgetRef ref, Set<String> selectedIdentityCards) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete ${selectedIdentityCards.length} selected identity card(s)?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _performDeletion(context, ref, selectedIdentityCards);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeletion(BuildContext context, WidgetRef ref,
      Set<String> selectedIdentityCards) async {
    final notifier = ref.read(selectedIdentityCardsProvider.notifier);
    for (final id in selectedIdentityCards.toList()) {
      try {
        await Database.instance.deleteIdentityCard(id);
        notifier.update((state) => state.difference({id}));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Identity card $id deleted successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting identity card $id: $e')),
          );
        }
      }
    }
    ref.read(identityCardNotifierProvider.notifier).loadIdentityCards();
  }

  void _navigateToDetail(
    BuildContext context,
    IdentityCardModel details,
    ScreenSize screenSize,
    Map<String, Tag> allTags,
    WidgetRef ref,
  ) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdentityCardDetailPage(
            data: details,
            screenSize: screenSize,
            allTagsMap: allTags,
          ),
        ),
      );
    } else {
      ref.read(identityCardSelectedDetailsProvider.notifier).state = details;
    }
  }

  void _openForm(
      BuildContext context, ScreenSize screenSize, Map<String, Tag> allTagsMap,
      {IdentityCardModel? identityCardData}) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdentityCardForm(
              identityCardData: identityCardData, allTagsMap: allTagsMap),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SizedBox(
            width: smallScreenWidth.toDouble(),
            child: IdentityCardForm(
                identityCardData: identityCardData, allTagsMap: allTagsMap),
          ),
        ),
      );
    }
  }

  Future<void> _refreshIdentityCardList(WidgetRef ref) async {
    await ref.read(identityCardNotifierProvider.notifier).loadIdentityCards();
  }

  void _toggleFavorite(WidgetRef ref, IdentityCardModel identityCard) async {
    final updatedIdentityCard =
        identityCard.copyWith(isFavorite: !(identityCard.isFavorite ?? false));
    ref.read(identityCardNotifierProvider.notifier).updateIdentityCard(
          identityCard.id!,
          updatedIdentityCard,
        );
    await _refreshIdentityCardList(ref);
  }

  List<IdentityCardModel> _getFilteredIdentityCardItems(WidgetRef ref) {
    final identityCardState = ref.watch(identityCardNotifierProvider);
    final searchQuery = ref.watch(identityCardSearchQueryProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);
    final selectedTags = ref.watch(selectedTagsProvider);
    final sortOption = ref.watch(identityCardSortOptionProvider);

    final List<IdentityCardModel> identityCardItems = identityCardState.when(
      data: (items) => items,
      loading: () => [],
      error: (_, __) => [],
    );

    return _filterAndSortIdentityCardItems(
      identityCardItems,
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
