import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../enums/screens.dart';
import '../../models/note_model.dart';
import '../../providers/note_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/detail_tile.dart';
import '../../widgets/tag_view.dart';
import 'note_form.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  final NoteModel note;
  final ScreenSize screenSize;
  final Map<String, Tag> allTagsMap;

  const NoteDetailPage({
    super.key,
    required this.note,
    required this.screenSize,
    required this.allTagsMap,
  });

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage>
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
      appBar: _buildAppBar(context, ref),
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

  PreferredSizeWidget? _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Row(
        children: [
          Text(
            widget.note.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: true,
            textAlign: TextAlign.left,
          ),
          const SizedBox(width: 8),
          if (widget.note.isFavorite)
            Icon(
              Icons.favorite,
              color: widget.note.isFavorite ? Colors.red : Colors.grey,
            ),
        ],
      ),
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.content_copy),
          onPressed: () => _copyAndCreateNew(context, ref),
          tooltip: 'Copy and create new',
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _openForm(
              context, widget.screenSize, widget.allTagsMap, widget.note),
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

  void _copyAndCreateNew(BuildContext context, WidgetRef ref) {
    final newNote = NoteModel(
      name: '${widget.note.name} (Copy)',
      note: widget.note.note,
      tags: widget.note.tags,
      isFavorite: widget.note.isFavorite,
    );

    _openForm(context, widget.screenSize, widget.allTagsMap, newNote);
  }

  Widget _buildDetailsList(BuildContext context) {
    final details = [
      {
        'name': 'Name',
        'note': widget.note.name,
        'icon': Icons.note,
      },
      {
        'name': 'Content',
        'note': widget.note.note ?? '',
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
                title: detail['name'] as String,
                content: detail['note'] as String,
                icon: detail['icon'] as IconData,
              );
            },
          ),
          const Divider(),
          _buildTagsSection(context),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    if (widget.note.tags == null || widget.note.tags!.isEmpty) {
      return const DetailTile(
        title: 'Tags',
        content: 'No tags available',
        icon: Icons.label,
        isCopyable: false,
      );
    }

    return TagsView(
      tags: widget.note.tags,
      allTagsMap: widget.allTagsMap,
    );
  }

  void _openForm(
    BuildContext context,
    ScreenSize screenSize,
    Map<String, Tag> allTagsMap,
    NoteModel noteData,
  ) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteForm(
            note: noteData,
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
            child: NoteForm(
              note: noteData,
              allTagsMap: allTagsMap,
            ),
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
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
                await _deleteNote(context, ref);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNote(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(noteNotifierProvider.notifier).deleteNote(widget.note.id!);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting note: $e')),
        );
      }
    }
  }
}
