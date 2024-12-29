import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums/screens.dart';
import '../../models/note_model.dart';
import '../../providers/note_provider.dart';
import '../../providers/screen_size_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/tag_input.dart';

class NoteForm extends ConsumerStatefulWidget {
  final NoteModel? note;
  final Map<String, Tag> allTagsMap;

  const NoteForm({super.key, this.note, required this.allTagsMap});

  @override
  ConsumerState<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends ConsumerState<NoteForm>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late List<Tag> _selectedTags;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.name ?? '');
    _contentController = TextEditingController(text: widget.note?.note ?? '');
    _selectedTags =
        widget.note?.tags?.map((e) => widget.allTagsMap[e]!).toList() ?? [];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
    _titleController.dispose();
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      appBar: screenSize == ScreenSize.small
          ? AppBar(title: Text(_isEditing() ? 'Edit Note' : 'Add Note'))
          : null,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              screenSize == ScreenSize.small
                  ? Container()
                  : Text(
                      _isEditing() ? "Edit Note" : "New Note",
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.title),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _contentController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Content',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.note),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TagInput(
                            initialTags: _selectedTags,
                            onTagsChanged: (tags) {
                              setState(() {
                                _selectedTags = tags;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 20, thickness: 2, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_isEditing())
                      TextButton(
                        onPressed: () => _showDeleteConfirmation(context),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _saveNote,
                          child: Text(_isEditing() ? 'Update' : 'Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isEditing() {
    return widget.note != null && widget.note?.id != null;
  }

  void _saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and content')),
      );
      return;
    }

    if (!_isEditing()) {
      final newNote = NoteModel(
        name: title,
        note: content,
        tags: _selectedTags.map((tag) => tag.id!).toList(),
        isFavorite: false,
      );
      await ref.read(noteNotifierProvider.notifier).addNote(newNote);
    } else {
      final updatedNote = widget.note!.copyWith(
        name: title,
        note: content,
        tags: _selectedTags.map((tag) => tag.id!).toList(),
      );
      await ref
          .read(noteNotifierProvider.notifier)
          .updateNote(widget.note!.id!, updatedNote);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved successfully!')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteNote(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNote(BuildContext context) async {
    try {
      await ref
          .read(noteNotifierProvider.notifier)
          .deleteNote(widget.note!.id!);
      if (mounted) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note deleted successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting note: $e')),
          );
        }
      }
    }
  }
}
