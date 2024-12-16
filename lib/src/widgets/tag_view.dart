import 'package:flutter/material.dart';

import '../rust/models/tags.dart';
import 'detail_tile.dart';

class TagsView extends StatelessWidget {
  final List<String>? tags;
  final Map<String, Tag> allTagsMap;

  const TagsView({
    super.key,
    required this.tags,
    required this.allTagsMap,
  });

  @override
  Widget build(BuildContext context) {
    if (tags == null || tags!.isEmpty) {
      return const DetailTile(
        title: 'Tags',
        content: 'No tags available',
        icon: Icons.label,
        isCopyable: false,
      );
    }

    return ListTile(
      leading:
          Icon(Icons.label, color: Theme.of(context).colorScheme.secondary),
      title: const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: tags!.map((tag) {
          if (allTagsMap[tag] == null) {
            return const SizedBox.shrink();
          }

          return Chip(
            label: Text(allTagsMap[tag]!.name),
          );
        }).toList(),
      ),
    );
  }
}
