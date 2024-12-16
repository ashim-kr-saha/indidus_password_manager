import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../enums/screens.dart';
import '../../models/identity_card_model.dart';
import '../../providers/identity_card_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/detail_tile.dart';
import '../../widgets/tag_view.dart';
import 'identity_card_form.dart';

class IdentityCardDetailPage extends ConsumerWidget {
  final IdentityCardModel data;
  final ScreenSize screenSize;
  final Map<String, Tag> allTagsMap;

  const IdentityCardDetailPage({
    super.key,
    required this.data,
    required this.screenSize,
    required this.allTagsMap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(context, data.isFavorite ?? false, ref),
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

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    bool isFavorite,
    WidgetRef ref,
  ) {
    return AppBar(
      title: Row(
        children: [
          Text(
            data.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: true,
            textAlign: TextAlign.left,
          ),
          const SizedBox(width: 8),
          if (isFavorite)
            Icon(
              Icons.favorite,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
        ],
      ),
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.content_copy),
          onPressed: () => _copyAndCreateNew(context),
          tooltip: 'Copy and create new',
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _openForm(context, screenSize, allTagsMap, data),
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

  void _copyAndCreateNew(BuildContext context) {
    final newData = IdentityCardModel(
      name: '${data.name} (Copy)',
      nameOnCard: data.nameOnCard,
      identityCardNumber: data.identityCardNumber,
      identityCardType: data.identityCardType,
      expiryDate: data.expiryDate,
      issueDate: data.issueDate,
      country: data.country,
      state: data.state,
      note: data.note,
      tags: data.tags,
      isFavorite: data.isFavorite,
    );
    _openForm(context, screenSize, allTagsMap, newData);
  }

  void _openForm(
    BuildContext context,
    ScreenSize screenSize,
    Map<String, Tag> allTagsMap,
    IdentityCardModel identityCardData,
  ) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdentityCardForm(
            identityCardData: identityCardData,
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
            child: IdentityCardForm(
              identityCardData: identityCardData,
              allTagsMap: allTagsMap,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildDetailsList(BuildContext context) {
    final details = [
      {
        'title': 'Name on Card',
        'content': data.nameOnCard,
        'icon': Icons.person,
      },
      {
        'title': 'Card Number',
        'content': data.identityCardNumber,
        'icon': Icons.credit_card,
      },
      {
        'title': 'Card Type',
        'content': data.identityCardType,
        'icon': Icons.card_travel,
      },
      {
        'title': 'Expiry Date',
        'content': data.expiryDate,
        'icon': Icons.calendar_month,
      },
      {
        'title': 'Issue Date',
        'content': data.issueDate,
        'icon': Icons.calendar_month,
      },
      {
        'title': 'Country',
        'content': data.country,
        'icon': Icons.location_pin,
      },
      {
        'title': 'State',
        'content': data.state,
        'icon': Icons.location_pin,
      },
      {
        'title': 'Note',
        'content': data.note,
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
                content: (detail['content'] ?? '') as String,
                icon: detail['icon'] as IconData,
              );
            },
          ),
          const Divider(),
          TagsView(tags: data.tags, allTagsMap: allTagsMap),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Identity Card'),
        content:
            const Text('Are you sure you want to delete this identity card?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteIdentityCard(context, ref);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteIdentityCard(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(identityCardNotifierProvider.notifier)
          .deleteIdentityCard(data.id!);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identity card deleted successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting identity card: $e')),
        );
      }
    }
  }
}
