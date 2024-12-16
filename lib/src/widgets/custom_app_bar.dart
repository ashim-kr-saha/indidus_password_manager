import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showFavorite;
  final bool isFavorite;
  final VoidCallback? onEditPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showFavorite = false,
    this.isFavorite = false,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        if (showFavorite)
          Icon(
            Icons.favorite,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
        if (onEditPressed != null)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEditPressed,
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
