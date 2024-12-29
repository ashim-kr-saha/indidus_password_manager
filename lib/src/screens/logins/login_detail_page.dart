import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../enums/screens.dart';
import '../../models/login_model.dart';
import '../../providers/login_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/detail_tile.dart';
import '../../widgets/tag_view.dart';
import 'login_form.dart';

class LoginDetailPage extends ConsumerStatefulWidget {
  final LoginModel login;
  final ScreenSize screenSize;
  final Map<String, Tag> allTagsMap;

  const LoginDetailPage({
    super.key,
    required this.login,
    required this.screenSize,
    required this.allTagsMap,
  });

  @override
  ConsumerState<LoginDetailPage> createState() => _LoginDetailPageState();
}

class _LoginDetailPageState extends ConsumerState<LoginDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailsList(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Row(
        children: [
          Text(
            widget.login.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: true,
            textAlign: TextAlign.left,
          ),
          const SizedBox(width: 8),
          if (widget.login.isFavorite)
            Icon(
              Icons.favorite,
              color: widget.login.isFavorite ? Colors.red : Colors.grey,
            ),
        ],
      ),
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.content_copy),
          onPressed: () => _copyAndCreateNew(context, ref),
          tooltip: 'Copy and create new',
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _openForm(
              context, widget.screenSize, widget.allTagsMap, widget.login),
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteConfirmation(context, ref),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Widget _buildDetailsList(BuildContext context) {
    final details = [
      {
        'title': 'Username',
        'content': widget.login.username,
        'icon': Icons.person,
      },
      {
        'title': 'Password',
        'content': widget.login.password ?? '',
        'icon': Icons.lock,
      },
      {
        'title': 'Password Hint',
        'content': widget.login.passwordHint ?? '',
        'icon': Icons.help_outline,
      },
      {
        'title': 'URL',
        'content': widget.login.url ?? '',
        'icon': Icons.link,
      },
      {
        'title': 'Note',
        'content': widget.login.note ?? '',
        'icon': Icons.note,
      },
    ];

    return Card(
      elevation: 1,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: details.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final detail = details[index];
              return DetailTile(
                title: detail['title'] as String,
                content: detail['content'] as String,
                icon: detail['icon'] as IconData,
              );
            },
          ),
          const Divider(),
          // const SizedBox(height: 24),
          _buildApiKeysSection(context),
          const Divider(),
          _buildTagsSection(context),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    if (widget.login.tags == null || widget.login.tags!.isEmpty) {
      return const DetailTile(
        title: 'Tags',
        content: 'No tags available',
        icon: Icons.label,
        isCopyable: false,
      );
    }

    return TagsView(
      tags: widget.login.tags,
      allTagsMap: widget.allTagsMap,
    );
  }

  Widget _buildApiKeysSection(BuildContext context) {
    if (widget.login.apiKeys == null || widget.login.apiKeys!.isEmpty) {
      return const DetailTile(
        title: 'API Keys',
        content: 'No API keys',
        icon: Icons.vpn_key,
        isCopyable: false,
      );
    }

    return ExpansionTile(
      leading:
          Icon(Icons.vpn_key, color: Theme.of(context).colorScheme.secondary),
      title: const Text('API Keys',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      children: widget.login.apiKeys!.map((key) {
        final keyName = key.name;
        final keyValue = key.value;

        return DetailTile(
          title: keyName,
          content: keyValue,
          icon: Icons.vpn_key,
        );
      }).toList(),
    );
  }

  void _copyAndCreateNew(BuildContext context, WidgetRef ref) {
    final newLogin = LoginModel(
      name: '${widget.login.name} (Copy)',
      username: widget.login.username,
      password: widget.login.password,
      passwordHint: widget.login.passwordHint,
      url: widget.login.url,
      note: widget.login.note,
      tags: widget.login.tags,
      apiKeys: widget.login.apiKeys,
      isFavorite: widget.login.isFavorite,
    );

    _openForm(context, widget.screenSize, widget.allTagsMap, newLogin);
  }

  void _openForm(
    BuildContext context,
    ScreenSize screenSize,
    Map<String, Tag> allTagsMap,
    LoginModel loginData,
  ) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginForm(
            login: loginData,
            allTagsMap: allTagsMap,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SizedBox(
            width: smallScreenWidth.toDouble(),
            child: LoginForm(
              login: loginData,
              allTagsMap: allTagsMap,
            ),
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this login?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteLogin(context, ref);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteLogin(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(loginNotifierProvider.notifier)
          .deleteLogin(widget.login.id!);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login deleted successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting login: $e')),
        );
      }
    }
  }
}
