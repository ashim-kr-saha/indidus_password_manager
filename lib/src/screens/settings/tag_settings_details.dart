import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/tag_provider.dart';
import '../../rust/models/tags.dart';

class TagSettingsDetail extends ConsumerWidget {
  const TagSettingsDetail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagList = ref.watch(tagListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
      ),
      body: tagList.when(
        data: (tags) => TagList(tags: tags),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTagDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTagDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddTagDialog(
        onAdd: (tag) {
          ref.read(tagNotifierProvider.notifier).addTag(tag);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class TagList extends ConsumerWidget {
  final List<Tag> tags;

  const TagList({super.key, required this.tags});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return ListTile(
          title: Text(tag.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditTagDialog(context, ref, tag),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteTagDialog(context, ref, tag),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditTagDialog(
    BuildContext context,
    WidgetRef ref,
    Tag tag,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditTagDialog(
        tag: tag,
        onEdit: (tag) {
          ref.read(tagNotifierProvider.notifier).updateTag(tag.id!, tag);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showDeleteTagDialog(BuildContext context, WidgetRef ref, Tag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Are you sure you want to delete "${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tagNotifierProvider.notifier).deleteTag(tag.id!);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AddTagDialog extends StatelessWidget {
  final Function(Tag) onAdd;

  AddTagDialog({super.key, required this.onAdd});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Tag'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Tag Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => onAdd(
            Tag(
              name: _controller.text,
            ),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class EditTagDialog extends StatelessWidget {
  final Tag tag;
  final Function(Tag) onEdit;

  EditTagDialog({super.key, required this.tag, required this.onEdit});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = tag.name;

    return AlertDialog(
      title: const Text('Edit Tag'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Tag Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => onEdit(tag.copyWith(name: _controller.text)),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
