import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tag_provider.dart';
import '../rust/models/tags.dart';

class TagSelector extends ConsumerWidget {
  final List<Tag> allTags;

  const TagSelector({super.key, required this.allTags});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(selectedTagsProvider);

    return SingleChildScrollView(
      // Added SingleChildScrollView
      scrollDirection: Axis.horizontal, // Set scroll direction to horizontal
      child: Row(
        // Changed from Wrap to Row
        children: allTags.map((tag) {
          final isSelected = selectedTags.contains(tag);
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: FilterChip(
              label: Text(tag.name, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              onSelected: (bool selected) {
                ref.read(selectedTagsProvider.notifier).update((state) {
                  if (selected) {
                    return {...state, tag};
                  } else {
                    return state.where((t) => t != tag).toSet();
                  }
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
