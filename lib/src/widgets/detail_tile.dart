import 'package:flutter/material.dart';

import '../utils/common_utils.dart';

class DetailTile extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool isCopyable;

  const DetailTile({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.isCopyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(content, style: const TextStyle(fontSize: 16)),
      trailing: isCopyable
          ? IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => {
                copyToClipboard(context, title, content),
              },
            )
          : null,
    );
  }
}
