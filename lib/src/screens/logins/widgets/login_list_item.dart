import 'package:flutter/material.dart';

import '../../../enums/screens.dart';
import '../../../models/login_model.dart';
import '../../../rust/models/tags.dart';

class LoginListItem extends StatelessWidget {
  final LoginModel item;
  final ScreenSize screenSize;
  final bool isSelected;
  final Map<String, Tag> allTagsMap;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleFavorite;

  const LoginListItem({
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
    final uri = item.url != null ? Uri.tryParse(item.url!) : null;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildLeadingIcon(uri),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(theme),
                  const SizedBox(height: 4),
                  _buildSubtitle(theme),
                  if (item.tags != null && item.tags!.isNotEmpty)
                    _buildTags(context, theme),
                ],
              ),
            ),
            _buildTrailingIcon(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(Uri? uri) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildItemIcon(uri),
      ),
    );
  }

  Widget _buildTitleRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            item.name,
            style: theme.textTheme.titleMedium?.copyWith(
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

  Widget _buildSubtitle(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.username,
          style: theme.textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        if (item.url != null)
          Text(
            item.url!,
            style:
                theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );
  }

  Widget _buildTags(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: item.tags!.map((tag) {
          if (allTagsMap[tag] != null) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                allTagsMap[tag]!.name,
                style: TextStyle(fontSize: 12, color: theme.primaryColor),
              ),
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return InkResponse(
      borderRadius: BorderRadius.circular(20),
      onTap: onToggleFavorite,
      child: Icon(
        item.isFavorite ? Icons.favorite : Icons.favorite_border,
        color: item.isFavorite ? Colors.red : Colors.grey,
        size: 20,
      ),
    );
  }

  Widget _buildTrailingIcon(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: isSelected
          ? Icon(Icons.check_circle,
              size: 24, color: Theme.of(context).primaryColor)
          : const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
    );
  }

  Widget _buildItemIcon(Uri? uri) {
    return (uri != null && uri.hasScheme)
        ? Image.network(
            'https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=${uri.toString()}&size=256',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.web, size: 24, color: Colors.grey);
            },
          )
        : const Icon(Icons.web, size: 24, color: Colors.grey);
  }
}
