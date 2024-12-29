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

class IdentityCardDetailPage extends ConsumerStatefulWidget {
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
  ConsumerState<IdentityCardDetailPage> createState() =>
      _IdentityCardDetailPageState();
}

class _IdentityCardDetailPageState extends ConsumerState<IdentityCardDetailPage>
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
          onPressed: () => _openForm(
              context, widget.screenSize, widget.allTagsMap, widget.data),
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
      name: '${widget.data.name} (Copy)',
      nameOnCard: widget.data.nameOnCard,
      identityCardNumber: widget.data.identityCardNumber,
      identityCardType: widget.data.identityCardType,
      expiryDate: widget.data.expiryDate,
      issueDate: widget.data.issueDate,
      country: widget.data.country,
      state: widget.data.state,
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
        'content': widget.data.nameOnCard,
        'icon': Icons.person,
      },
      {
        'title': 'Card Number',
        'content': widget.data.identityCardNumber,
        'icon': Icons.credit_card,
      },
      {
        'title': 'Card Type',
        'content': widget.data.identityCardType,
        'icon': Icons.card_travel,
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
        'title': 'Country',
        'content': widget.data.country,
        'icon': Icons.location_pin,
      },
      {
        'title': 'State',
        'content': widget.data.state,
        'icon': Icons.location_pin,
      },
      {
        'title': 'Note',
        'content': widget.data.note,
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
          .deleteIdentityCard(widget.data.id!);
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
