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

class LoginDetailPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailsList(context),
              ],
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
            login.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: true,
            textAlign: TextAlign.left,
          ),
          const SizedBox(width: 8),
          if (login.isFavorite)
            Icon(
              Icons.favorite,
              color: login.isFavorite ? Colors.red : Colors.grey,
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
          onPressed: () => _openForm(context, screenSize, allTagsMap, login),
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
        'content': login.username,
        'icon': Icons.person,
      },
      {
        'title': 'Password',
        'content': login.password ?? '',
        'icon': Icons.lock,
      },
      {
        'title': 'Password Hint',
        'content': login.passwordHint ?? '',
        'icon': Icons.help_outline,
      },
      {
        'title': 'URL',
        'content': login.url ?? '',
        'icon': Icons.link,
      },
      {
        'title': 'Note',
        'content': login.note ?? '',
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
    if (login.tags == null || login.tags!.isEmpty) {
      return const DetailTile(
        title: 'Tags',
        content: 'No tags available',
        icon: Icons.label,
        isCopyable: false,
      );
    }

    return TagsView(
      tags: login.tags,
      allTagsMap: allTagsMap,
    );
  }

  Widget _buildApiKeysSection(BuildContext context) {
    if (login.apiKeys == null || login.apiKeys!.isEmpty) {
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
      children: login.apiKeys!.map((key) {
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
      name: '${login.name} (Copy)',
      username: login.username,
      password: login.password,
      passwordHint: login.passwordHint,
      url: login.url,
      note: login.note,
      tags: login.tags,
      apiKeys: login.apiKeys,
      isFavorite: login.isFavorite,
    );

    _openForm(context, screenSize, allTagsMap, newLogin);
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
      await ref.read(loginNotifierProvider.notifier).deleteLogin(login.id!);
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
