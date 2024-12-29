import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../data/database.dart';
import '../../enums/entity_types.dart';
import '../../enums/financial_card.dart';
import '../../enums/screens.dart';
import '../../models/financial_card_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/financial_card_provider.dart';
import '../../providers/screen_size_provider.dart';
import '../../providers/tag_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/search_field.dart';
import '../../widgets/tag_selector.dart';
import 'financial_card_details.dart';
import 'financial_card_form.dart';
import 'widgets/financial_card_list_item.dart';

class FinancialCardList extends ConsumerWidget {
  const FinancialCardList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final selectedFinancialCards = ref.watch(selectedFinancialCardsProvider);
    final tags = _getTags(ref);

    return Scaffold(
      body: _buildBody(context, ref, screenSize, selectedFinancialCards, tags),
      floatingActionButton: _buildFloatingActionButton(
          context, screenSize, selectedFinancialCards, tags),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ScreenSize screenSize,
      Set<String> selectedFinancialCards, List<Tag> tags) {
    final filteredFinancialCardItems = _getFilteredFinancialCardItems(ref);
    final selectedDetails = ref.watch(financialCardSelectedDetailsProvider);
    final allTagsMap = _createAllTagsMap(tags);

    return screenSize == ScreenSize.small
        ? _buildRefreshableFinancialCardListView(
            context,
            screenSize,
            ref,
            filteredFinancialCardItems,
            selectedFinancialCards,
            tags,
            allTagsMap)
        : _buildSplitView(context, screenSize, ref, filteredFinancialCardItems,
            selectedDetails, selectedFinancialCards, tags, allTagsMap);
  }

  Widget _buildSplitView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<FinancialCardModel> filteredFinancialCardItems,
      FinancialCardModel? selectedDetails,
      Set<String> selectedFinancialCards,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return Row(
      children: [
        Expanded(
          flex: screenSize == ScreenSize.large ? 1 : 2,
          child: _buildRefreshableFinancialCardListView(
              context,
              screenSize,
              ref,
              filteredFinancialCardItems,
              selectedFinancialCards,
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

  Widget _buildRefreshableFinancialCardListView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<FinancialCardModel> filteredFinancialCardItems,
      Set<String> selectedFinancialCards,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return RefreshIndicator(
      onRefresh: () => _refreshFinancialCardList(ref),
      child: _buildFinancialCardListView(context, screenSize, ref,
          filteredFinancialCardItems, selectedFinancialCards, tags, allTagsMap),
    );
  }

  Widget _buildFinancialCardListView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<FinancialCardModel> filteredFinancialCardItems,
      Set<String> selectedFinancialCards,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, ref, selectedFinancialCards, screenSize),
        _buildSearchField(),
        _buildTagSelector(tags),
        _buildFinancialCardItemsList(context, screenSize, ref,
            filteredFinancialCardItems, selectedFinancialCards, allTagsMap),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref,
      Set<String> selectedFinancialCards, ScreenSize screenSize) {
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);

    return SliverAppBar(
      title: selectedFinancialCards.isEmpty
          ? const Text('Financial Card List')
          : Text('${selectedFinancialCards.length} selected'),
      floating: true,
      actions: [
        if (selectedFinancialCards.isEmpty) ...[
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptionsDialog(context, ref),
          ),
          const SizedBox(width: 8),
          _buildFavoriteToggle(ref, showFavoritesOnly),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshFinancialCardList(ref),
          ),
        ],
        if (selectedFinancialCards.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteSelectedFinancialCards(
                context, ref, selectedFinancialCards),
          ),
        if (screenSize == ScreenSize.small && selectedFinancialCards.isEmpty)
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
      child: SearchField(entityType: EntityType.financialCard),
    );
  }

  Widget _buildTagSelector(List<Tag> tags) {
    return SliverToBoxAdapter(
      child: TagSelector(allTags: tags),
    );
  }

  Widget _buildFinancialCardItemsList(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<FinancialCardModel> filteredFinancialCardItems,
      Set<String> selectedFinancialCards,
      Map<String, Tag> allTagsMap) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildAnimatedFinancialCardListItem(
            context,
            screenSize,
            ref,
            filteredFinancialCardItems[index],
            selectedFinancialCards,
            allTagsMap,
            index),
        childCount: filteredFinancialCardItems.length,
      ),
    );
  }

  Widget _buildAnimatedFinancialCardListItem(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      FinancialCardModel item,
      Set<String> selectedFinancialCards,
      Map<String, Tag> allTagsMap,
      int index) {
    return AnimatedFinancialCardListItem(
      key: ValueKey(item.id),
      index: index,
      child: _buildFinancialCardListItem(
          context, screenSize, ref, item, selectedFinancialCards, allTagsMap),
    );
  }

  Widget _buildFinancialCardListItem(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      FinancialCardModel item,
      Set<String> selectedFinancialCards,
      Map<String, Tag> allTagsMap) {
    return FinancialCardListItem(
      item: item,
      screenSize: screenSize,
      isSelected: selectedFinancialCards.contains(item.id),
      allTagsMap: allTagsMap,
      onTap: () => _handleItemTap(
          context, item, screenSize, allTagsMap, ref, selectedFinancialCards),
      onLongPress: () => _toggleSelection(ref, item.id!),
      onToggleFavorite: () => _toggleFavorite(ref, item),
    );
  }

  void _handleItemTap(
      BuildContext context,
      FinancialCardModel item,
      ScreenSize screenSize,
      Map<String, Tag> allTagsMap,
      WidgetRef ref,
      Set<String> selectedFinancialCards) {
    if (selectedFinancialCards.isEmpty) {
      _navigateToDetail(context, item, screenSize, allTagsMap, ref);
    } else {
      _toggleSelection(ref, item.id!);
    }
  }

  Widget _buildDetailView(FinancialCardModel? selectedDetails,
      ScreenSize screenSize, Map<String, Tag> allTags) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: selectedDetails == null
          ? const Center(
              key: ValueKey('empty'),
              child: Text('Select an item to see details',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          : FinancialCardDetailPage(
              key: ValueKey(selectedDetails.id),
              data: selectedDetails,
              screenSize: screenSize,
              allTagsMap: allTags),
    );
  }

  Widget? _buildFloatingActionButton(
      BuildContext context,
      ScreenSize screenSize,
      Set<String> selectedFinancialCards,
      List<Tag> tags) {
    if (selectedFinancialCards.isNotEmpty) return null;

    return FloatingActionButton(
      onPressed: () => _openForm(context, screenSize, _createAllTagsMap(tags)),
      child: const Icon(Icons.add),
    );
  }

  List<FinancialCardModel> _filterAndSortFinancialCardItems(
    List<FinancialCardModel> items,
    String query,
    bool showFavoritesOnly,
    Set<Tag> selectedTags,
    FinancialCardSortOption sortOption,
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
        case FinancialCardSortOption.createdAtDesc:
          return (b.createdAt ?? 0).compareTo(a.createdAt ?? 0);
        case FinancialCardSortOption.createdAtAsc:
          return (a.createdAt ?? 0).compareTo(b.createdAt ?? 0);
        case FinancialCardSortOption.lastModifiedDesc:
          return (b.updatedAt ?? 0).compareTo(a.updatedAt ?? 0);
        case FinancialCardSortOption.lastModifiedAsc:
          return (a.updatedAt ?? 0).compareTo(b.updatedAt ?? 0);
        case FinancialCardSortOption.nameAsc:
          return a.name.compareTo(b.name);
        case FinancialCardSortOption.nameDesc:
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
              children: FinancialCardSortOption.values.map((option) {
                return RadioListTile<FinancialCardSortOption>(
                  title: Text(_getSortOptionLabel(option)),
                  value: option,
                  groupValue: ref.watch(financialCardSortOptionProvider),
                  activeColor: Colors.deepPurple,
                  onChanged: (FinancialCardSortOption? value) {
                    if (value != null) {
                      ref.read(financialCardSortOptionProvider.notifier).state =
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

  String _getSortOptionLabel(FinancialCardSortOption option) {
    switch (option) {
      case FinancialCardSortOption.createdAtDesc:
        return 'Created (Newest)';
      case FinancialCardSortOption.createdAtAsc:
        return 'Created (Oldest)';
      case FinancialCardSortOption.lastModifiedDesc:
        return 'Modified (Newest)';
      case FinancialCardSortOption.lastModifiedAsc:
        return 'Modified (Oldest)';
      case FinancialCardSortOption.nameAsc:
        return 'Name (A-Z)';
      case FinancialCardSortOption.nameDesc:
        return 'Name (Z-A)';
    }
  }

  void _toggleSelection(WidgetRef ref, String id) {
    ref.read(selectedFinancialCardsProvider.notifier).update((state) {
      if (state.contains(id)) {
        return state.difference({id});
      } else {
        return state.union({id});
      }
    });
  }

  void _deleteSelectedFinancialCards(
      BuildContext context, WidgetRef ref, Set<String> selectedFinancialCards) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete ${selectedFinancialCards.length} selected financialCard(s)?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _performDeletion(context, ref, selectedFinancialCards);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeletion(BuildContext context, WidgetRef ref,
      Set<String> selectedFinancialCards) async {
    final notifier = ref.read(selectedFinancialCardsProvider.notifier);
    for (final id in selectedFinancialCards.toList()) {
      try {
        await Database.instance.deleteFinancialCard(id);
        notifier.update((state) => state.difference({id}));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Financial Card $id deleted successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting financial card $id: $e')),
          );
        }
      }
    }
    ref.read(financialCardNotifierProvider.notifier).loadFinancialCards();
  }

  void _navigateToDetail(
    BuildContext context,
    FinancialCardModel details,
    ScreenSize screenSize,
    Map<String, Tag> allTags,
    WidgetRef ref,
  ) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinancialCardDetailPage(
            data: details,
            screenSize: screenSize,
            allTagsMap: allTags,
          ),
        ),
      );
    } else {
      ref.read(financialCardSelectedDetailsProvider.notifier).state = details;
    }
  }

  void _openForm(
      BuildContext context, ScreenSize screenSize, Map<String, Tag> allTagsMap,
      {FinancialCardModel? financialCardData}) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinancialCardForm(
              financialCardData: financialCardData, allTagsMap: allTagsMap),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SizedBox(
            width: smallScreenWidth.toDouble(),
            child: FinancialCardForm(
                financialCardData: financialCardData, allTagsMap: allTagsMap),
          ),
        ),
      );
    }
  }

  Future<void> _refreshFinancialCardList(WidgetRef ref) async {
    await ref.read(financialCardNotifierProvider.notifier).loadFinancialCards();
  }

  void _toggleFavorite(WidgetRef ref, FinancialCardModel financialCard) async {
    final updatedFinancialCard = financialCard.copyWith(
        isFavorite: !(financialCard.isFavorite ?? false));
    ref.read(financialCardNotifierProvider.notifier).updateFinancialCard(
          financialCard.id!,
          updatedFinancialCard,
        );
    await _refreshFinancialCardList(ref);
  }

  List<FinancialCardModel> _getFilteredFinancialCardItems(WidgetRef ref) {
    final financialCardState = ref.watch(financialCardNotifierProvider);
    final searchQuery = ref.watch(financialCardSearchQueryProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);
    final selectedTags = ref.watch(selectedTagsProvider);
    final sortOption = ref.watch(financialCardSortOptionProvider);

    final List<FinancialCardModel> financialCardItems = financialCardState.when(
      data: (items) => items,
      loading: () => [],
      error: (_, __) => [],
    );

    return _filterAndSortFinancialCardItems(
      financialCardItems,
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

class AnimatedFinancialCardListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const AnimatedFinancialCardListItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<AnimatedFinancialCardListItem> createState() =>
      _AnimatedFinancialCardListItemState();
}

class _AnimatedFinancialCardListItemState
    extends State<AnimatedFinancialCardListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    Future.delayed(Duration(milliseconds: 30 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
