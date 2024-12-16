import 'package:flutter/material.dart';

class CustomListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleFavorite;

  const CustomListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.isSelected,
    required this.isFavorite,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemColor = isSelected
        ? colorScheme.primary
        : theme.textTheme.titleMedium?.color ?? colorScheme.onSurface;

    return ListTile(
      leading: leading,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: itemColor,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          InkResponse(
            radius: 20,
            onTap: onToggleFavorite,
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
              size: 20,
            ),
          ),
        ],
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: SizedBox(
        width: 40,
        height: 40,
        child: IconTheme(
          data: IconThemeData(color: itemColor),
          child: isSelected
              ? const Icon(Icons.check_circle)
              : const Icon(Icons.chevron_right),
        ),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
