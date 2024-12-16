import 'package:flutter/material.dart';

import '../../../enums/screens.dart';
import '../../../models/financial_card_model.dart';
import '../../../rust/models/tags.dart';

class FinancialCardListItem extends StatelessWidget {
  final FinancialCardModel item;
  final ScreenSize screenSize;
  final bool isSelected;
  final Map<String, Tag> allTagsMap;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleFavorite;

  const FinancialCardListItem({
    super.key,
    required this.item,
    required this.screenSize,
    required this.isSelected,
    required this.allTagsMap,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use more distinct colors for selected and unselected states
    final Color itemColor = isSelected
        ? colorScheme.primary
        : theme.textTheme.titleMedium?.color ?? colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: isSelected ? colorScheme.primaryContainer : null,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildLeadingIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(theme, itemColor),
                  const SizedBox(height: 4),
                  _buildSubtitle(theme, itemColor),
                  if (item.tags != null && item.tags!.isNotEmpty)
                    _buildTags(theme),
                ],
              ),
            ),
            _buildTrailingIcon(itemColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: const Icon(Icons.credit_card),
      ),
    );
  }

  Widget _buildTitleRow(ThemeData theme, Color itemColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            item.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: itemColor,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _buildFavoriteButton(),
      ],
    );
  }

  Widget _buildSubtitle(ThemeData theme, Color itemColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.cardHolderName,
          style: theme.textTheme.bodyMedium?.copyWith(color: itemColor),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          item.cardNumber,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: itemColor.withOpacity(0.7)),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildTags(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: item.tags!.map((tag) {
          if (allTagsMap[tag] != null) {
            return Chip(
              label: Text(
                allTagsMap[tag]!.name,
                style: const TextStyle(fontSize: 10),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return InkResponse(
      radius: 20,
      onTap: onToggleFavorite,
      child: Icon(
        item.isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
        color: item.isFavorite ?? false ? Colors.red : null,
        size: 20,
      ),
    );
  }

  Widget _buildTrailingIcon(Color itemColor) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconTheme(
        data: IconThemeData(color: itemColor),
        child: isSelected
            ? const Icon(Icons.check_circle)
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
