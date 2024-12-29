import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../data/database.dart';
import '../../enums/entity_types.dart';
import '../../enums/logins.dart';
import '../../enums/screens.dart';
import '../../models/login_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/login_provider.dart';
import '../../providers/screen_size_provider.dart';
import '../../providers/tag_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/password_generator_dialog.dart';
import '../../widgets/search_field.dart';
import '../../widgets/tag_selector.dart';
import 'login_detail_page.dart';
import 'login_form.dart';
import 'widgets/login_list_item.dart';

class LoginList extends ConsumerWidget {
  const LoginList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final selectedLogins = ref.watch(selectedLoginsProvider);
    final tags = _getTags(ref);

    return Scaffold(
      body: _buildBody(context, ref, screenSize, selectedLogins, tags),
      floatingActionButton:
          _buildFloatingActionButton(context, screenSize, selectedLogins, tags),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ScreenSize screenSize,
      Set<String> selectedLogins, List<Tag> tags) {
    final filteredLoginItems = _getFilteredLoginItems(ref);
    final selectedDetails = ref.watch(loginSelectedDetailsProvider);
    final allTagsMap = _createAllTagsMap(tags);

    return screenSize == ScreenSize.small
        ? _buildRefreshableLoginListView(context, screenSize, ref,
            filteredLoginItems, selectedLogins, tags, allTagsMap)
        : _buildSplitView(context, screenSize, ref, filteredLoginItems,
            selectedDetails, selectedLogins, tags, allTagsMap);
  }

  Widget _buildSplitView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<LoginModel> filteredLoginItems,
      LoginModel? selectedDetails,
      Set<String> selectedLogins,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return Row(
      children: [
        Expanded(
          flex: screenSize == ScreenSize.large ? 1 : 2,
          child: _buildRefreshableLoginListView(context, screenSize, ref,
              filteredLoginItems, selectedLogins, tags, allTagsMap),
        ),
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 20),
          builder: (context, double value, child) {
            return SizedBox(width: value);
          },
        ),
        Expanded(
          flex: 2,
          child: _buildDetailView(selectedDetails, screenSize, allTagsMap),
        ),
      ],
    );
  }

  Widget _buildRefreshableLoginListView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<LoginModel> filteredLoginItems,
      Set<String> selectedLogins,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return RefreshIndicator(
      onRefresh: () => _refreshLoginList(ref),
      child: _buildLoginListView(context, screenSize, ref, filteredLoginItems,
          selectedLogins, tags, allTagsMap),
    );
  }

  Widget _buildLoginListView(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<LoginModel> filteredLoginItems,
      Set<String> selectedLogins,
      List<Tag> tags,
      Map<String, Tag> allTagsMap) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, ref, selectedLogins, screenSize),
        _buildSearchField(),
        _buildTagSelector(tags),
        _buildLoginItemsList(context, screenSize, ref, filteredLoginItems,
            selectedLogins, allTagsMap),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref,
      Set<String> selectedLogins, ScreenSize screenSize) {
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);

    return SliverAppBar(
      title: selectedLogins.isEmpty
          ? const Text('Login List')
          : Text('${selectedLogins.length} selected'),
      floating: true,
      actions: [
        if (selectedLogins.isEmpty) ...[
          IconButton(
            icon: const Icon(Icons.password),
            onPressed: () => _showPasswordGeneratorDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptionsDialog(context, ref),
          ),
          const SizedBox(width: 8),
          _buildFavoriteToggle(ref, showFavoritesOnly),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshLoginList(ref),
          ),
        ],
        if (selectedLogins.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                _deleteSelectedLogins(context, ref, selectedLogins),
          ),
        if (screenSize == ScreenSize.small && selectedLogins.isEmpty)
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
      child: SearchField(entityType: EntityType.login),
    );
  }

  Widget _buildTagSelector(List<Tag> tags) {
    return SliverToBoxAdapter(
      child: TagSelector(allTags: tags),
    );
  }

  Widget _buildLoginItemsList(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      List<LoginModel> filteredLoginItems,
      Set<String> selectedLogins,
      Map<String, Tag> allTagsMap) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildAnimatedLoginListItem(context, screenSize,
            ref, filteredLoginItems[index], selectedLogins, allTagsMap, index),
        childCount: filteredLoginItems.length,
      ),
    );
  }

  Widget _buildAnimatedLoginListItem(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      LoginModel item,
      Set<String> selectedLogins,
      Map<String, Tag> allTagsMap,
      int index) {
    return AnimatedLoginListItem(
      key: ValueKey(item.id),
      index: index,
      child: _buildLoginListItem(
          context, screenSize, ref, item, selectedLogins, allTagsMap),
    );
  }

  Widget _buildLoginListItem(
      BuildContext context,
      ScreenSize screenSize,
      WidgetRef ref,
      LoginModel item,
      Set<String> selectedLogins,
      Map<String, Tag> allTagsMap) {
    return LoginListItem(
      item: item,
      screenSize: screenSize,
      isSelected: selectedLogins.contains(item.id),
      allTagsMap: allTagsMap,
      onTap: () => _handleItemTap(
          context, item, screenSize, allTagsMap, ref, selectedLogins),
      onLongPress: () => _toggleSelection(ref, item.id!),
      onToggleFavorite: () => _toggleFavorite(ref, item),
    );
  }

  void _handleItemTap(
      BuildContext context,
      LoginModel item,
      ScreenSize screenSize,
      Map<String, Tag> allTagsMap,
      WidgetRef ref,
      Set<String> selectedLogins) {
    if (selectedLogins.isEmpty) {
      _navigateToDetail(context, item, screenSize, allTagsMap, ref);
    } else {
      _toggleSelection(ref, item.id!);
    }
  }

  Widget _buildDetailView(
    LoginModel? selectedDetails,
    ScreenSize screenSize,
    Map<String, Tag> allTags,
  ) {
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
              child: Text(
                'Select an item to see details',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : LoginDetailPage(
              key: ValueKey(selectedDetails.id),
              login: selectedDetails,
              screenSize: screenSize,
              allTagsMap: allTags,
            ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context,
      ScreenSize screenSize, Set<String> selectedLogins, List<Tag> tags) {
    if (selectedLogins.isNotEmpty) return null;

    return FloatingActionButton(
      onPressed: () => _openForm(context, screenSize, _createAllTagsMap(tags)),
      child: const Icon(Icons.add),
    );
  }

  List<LoginModel> _filterAndSortLoginItems(
    List<LoginModel> items,
    String query,
    bool showFavoritesOnly,
    Set<Tag> selectedTags,
    LoginSortOption sortOption,
  ) {
    Set<String> selectedTagIds = selectedTags.map((tag) => tag.id!).toSet();
    var filteredItems = items.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.username.toLowerCase().contains(query.toLowerCase()) ||
          (item.url?.toLowerCase().contains(query.toLowerCase()) ?? false);
      final matchesTags = selectedTagIds.isEmpty ||
          (item.tags?.any((tag) => selectedTagIds.contains(tag)) ?? false);
      return matchesQuery &&
          (!showFavoritesOnly || item.isFavorite) &&
          matchesTags;
    }).toList();

    filteredItems.sort((a, b) {
      switch (sortOption) {
        case LoginSortOption.createdAtDesc:
          return (b.createdAt ?? 0).compareTo(a.createdAt ?? 0);
        case LoginSortOption.createdAtAsc:
          return (a.createdAt ?? 0).compareTo(b.createdAt ?? 0);
        case LoginSortOption.lastModifiedDesc:
          return (b.updatedAt ?? 0).compareTo(a.updatedAt ?? 0);
        case LoginSortOption.lastModifiedAsc:
          return (a.updatedAt ?? 0).compareTo(b.updatedAt ?? 0);
        case LoginSortOption.nameAsc:
          return a.name.compareTo(b.name);
        case LoginSortOption.nameDesc:
          return b.name.compareTo(a.name);
        case LoginSortOption.usernameAsc:
          return a.username.compareTo(b.username);
        case LoginSortOption.usernameDesc:
          return b.username.compareTo(a.username);
        case LoginSortOption.urlAsc:
          return (a.url ?? '').compareTo(b.url ?? '');
        case LoginSortOption.urlDesc:
          return (b.url ?? '').compareTo(a.url ?? '');
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
              children: LoginSortOption.values.map((option) {
                return RadioListTile<LoginSortOption>(
                  title: Text(_getSortOptionLabel(option)),
                  value: option,
                  groupValue: ref.watch(loginSortOptionProvider),
                  activeColor: Colors.deepPurple,
                  onChanged: (LoginSortOption? value) {
                    if (value != null) {
                      ref.read(loginSortOptionProvider.notifier).state = value;
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

  String _getSortOptionLabel(LoginSortOption option) {
    switch (option) {
      case LoginSortOption.createdAtDesc:
        return 'Created (Newest)';
      case LoginSortOption.createdAtAsc:
        return 'Created (Oldest)';
      case LoginSortOption.lastModifiedDesc:
        return 'Modified (Newest)';
      case LoginSortOption.lastModifiedAsc:
        return 'Modified (Oldest)';
      case LoginSortOption.nameAsc:
        return 'Name (A-Z)';
      case LoginSortOption.nameDesc:
        return 'Name (Z-A)';
      case LoginSortOption.usernameAsc:
        return 'Username (A-Z)';
      case LoginSortOption.usernameDesc:
        return 'Username (Z-A)';
      case LoginSortOption.urlAsc:
        return 'URL (A-Z)';
      case LoginSortOption.urlDesc:
        return 'URL (Z-A)';
    }
  }

  void _toggleSelection(WidgetRef ref, String id) {
    ref.read(selectedLoginsProvider.notifier).update((state) {
      if (state.contains(id)) {
        return state.difference({id});
      } else {
        return state.union({id});
      }
    });
  }

  void _deleteSelectedLogins(
      BuildContext context, WidgetRef ref, Set<String> selectedLogins) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete ${selectedLogins.length} selected login(s)?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _performDeletion(context, ref, selectedLogins);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeletion(
    BuildContext context,
    WidgetRef ref,
    Set<String> selectedLogins,
  ) async {
    final notifier = ref.read(selectedLoginsProvider.notifier);
    for (final id in selectedLogins.toList()) {
      try {
        await Database.instance.deleteLogin(id);
        notifier.update((state) => state.difference({id}));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login $id deleted successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting login $id: $e')),
          );
        }
      }
    }
    ref.read(loginNotifierProvider.notifier).loadLogins();
  }

  void _navigateToDetail(
    BuildContext context,
    LoginModel details,
    ScreenSize screenSize,
    Map<String, Tag> allTags,
    WidgetRef ref,
  ) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginDetailPage(
            login: details,
            screenSize: screenSize,
            allTagsMap: allTags,
          ),
        ),
      );
    } else {
      ref.read(loginSelectedDetailsProvider.notifier).state = details;
    }
  }

  void _openForm(
    BuildContext context,
    ScreenSize screenSize,
    Map<String, Tag> allTagsMap, {
    LoginModel? loginData,
  }) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LoginForm(login: loginData, allTagsMap: allTagsMap),
        ),
      );
    } else {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale:
                  Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: AlertDialog(
                content: SizedBox(
                  width: smallScreenWidth.toDouble(),
                  child: LoginForm(login: loginData, allTagsMap: allTagsMap),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _refreshLoginList(WidgetRef ref) async {
    await ref.read(loginNotifierProvider.notifier).loadLogins();
  }

  void _toggleFavorite(WidgetRef ref, LoginModel login) async {
    final updatedLogin = login.copyWith(isFavorite: !login.isFavorite);
    ref.read(loginNotifierProvider.notifier).updateLogin(
          login.id!,
          updatedLogin,
        );
    await _refreshLoginList(ref);
  }

  List<LoginModel> _getFilteredLoginItems(WidgetRef ref) {
    final loginState = ref.watch(loginNotifierProvider);
    final searchQuery = ref.watch(loginSearchQueryProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);
    final selectedTags = ref.watch(selectedTagsProvider);
    final sortOption = ref.watch(loginSortOptionProvider);

    final List<LoginModel> loginItems = loginState.when(
      data: (items) => items,
      loading: () => [],
      error: (_, __) => [],
    );

    return _filterAndSortLoginItems(
      loginItems,
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

  void _showPasswordGeneratorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const PasswordGeneratorDialog();
      },
    );
  }
}

class AnimatedLoginListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const AnimatedLoginListItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<AnimatedLoginListItem> createState() => _AnimatedLoginListItemState();
}

class _AnimatedLoginListItemState extends State<AnimatedLoginListItem>
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

    // Delay the animation start based on the item's index
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
