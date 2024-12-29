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

class FinancialCardDetailPage extends ConsumerStatefulWidget {
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
  ConsumerState<FinancialCardDetailPage> createState() =>
      _FinancialCardDetailPageState();
}

class _FinancialCardDetailPageState
    extends ConsumerState<FinancialCardDetailPage>
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
      appBar: _buildAppBar(context, widget.data.isFavorite ?? false, ref),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
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
            widget.data.name,
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
          onPressed: () => _openForm(
              context, widget.screenSize, widget.allTagsMap, widget.data),
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
      name: '${widget.data.name} (Copy)',
      cardHolderName: widget.data.cardHolderName,
      cardNumber: widget.data.cardNumber,
      cardProviderName: widget.data.cardProviderName,
      cardType: widget.data.cardType,
      cvv: widget.data.cvv,
      pin: widget.data.pin,
      expiryDate: widget.data.expiryDate,
      issueDate: widget.data.issueDate,
      note: widget.data.note,
      tags: widget.data.tags,
      isFavorite: widget.data.isFavorite,
    );
    _openForm(context, widget.screenSize, widget.allTagsMap, newData);
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
        'content': widget.data.cardHolderName,
        'icon': Icons.person,
      },
      {
        'title': 'Card Number',
        'content': widget.data.cardNumber,
        'icon': Icons.numbers,
      },
      {
        'title': 'Card Provider Name',
        'content': widget.data.cardProviderName,
        'icon': Icons.business,
      },
      {
        'title': 'Card Type',
        'content': widget.data.cardType,
        'icon': Icons.credit_card,
      },
      {
        'title': 'CVV',
        'content': widget.data.cvv,
        'icon': Icons.pin,
      },
      {
        'title': 'Pin',
        'content': widget.data.pin,
        'icon': Icons.pin,
      },
      {
        'title': 'Expiry Date',
        'content': widget.data.expiryDate,
        'icon': Icons.calendar_month,
      },
      {
        'title': 'Issue Date',
        'content': widget.data.issueDate,
        'icon': Icons.calendar_month,
      },
      {
        'title': 'Note',
        'content': widget.data.note ?? '',
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
          TagsView(tags: widget.data.tags, allTagsMap: widget.allTagsMap),
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
          .deleteFinancialCard(widget.data.id!);
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
