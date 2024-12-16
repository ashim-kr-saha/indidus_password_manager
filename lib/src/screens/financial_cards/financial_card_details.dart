import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../enums/screens.dart';
import '../../models/financial_card_model.dart';
import '../../providers/financial_card_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/detail_tile.dart';
import '../../widgets/tag_view.dart';
import 'financial_card_form.dart';

class FinancialCardDetailPage extends ConsumerWidget {
  final FinancialCardModel data;
  final ScreenSize screenSize;
  final Map<String, Tag> allTagsMap;

  const FinancialCardDetailPage({
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
          ),
          const SizedBox(width: 8),
          if (isFavorite)
            Icon(
              Icons.favorite,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.content_copy),
          onPressed: () => _copyAndCreateNew(context),
          tooltip: 'Copy and create new',
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _openForm(context, screenSize, allTagsMap, data),
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
    final newData = FinancialCardModel(
      name: '${data.name} (Copy)',
      cardHolderName: data.cardHolderName,
      cardNumber: data.cardNumber,
      cardProviderName: data.cardProviderName,
      cardType: data.cardType,
      cvv: data.cvv,
      pin: data.pin,
      expiryDate: data.expiryDate,
      issueDate: data.issueDate,
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
    FinancialCardModel financialCardData,
  ) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinancialCardForm(
            financialCardData: financialCardData,
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
            child: FinancialCardForm(
              financialCardData: financialCardData,
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
        'title': 'Card Holder Name',
        'content': data.cardHolderName,
        'icon': Icons.person,
      },
      {
        'title': 'Card Number',
        'content': data.cardNumber,
        'icon': Icons.numbers,
      },
      {
        'title': 'Card Provider Name',
        'content': data.cardProviderName,
        'icon': Icons.business,
      },
      {
        'title': 'Card Type',
        'content': data.cardType,
        'icon': Icons.credit_card,
      },
      {
        'title': 'CVV',
        'content': data.cvv,
        'icon': Icons.pin,
      },
      {
        'title': 'Pin',
        'content': data.pin,
        'icon': Icons.pin,
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
        'title': 'Note',
        'content': data.note ?? '',
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
        title: const Text('Delete Financial Card'),
        content:
            const Text('Are you sure you want to delete this financial card?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteFinancialCard(context, ref);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFinancialCard(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(financialCardNotifierProvider.notifier)
          .deleteFinancialCard(data.id!);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Financial card deleted successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting financial card: $e')),
        );
      }
    }
  }
}
