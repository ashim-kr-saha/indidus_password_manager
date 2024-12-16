import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tag_provider.dart';
import '../rust/models/tags.dart';

class TagInput extends ConsumerStatefulWidget {
  final List<Tag> initialTags;
  final Function(List<Tag>) onTagsChanged;

  const TagInput({
    super.key,
    required this.initialTags,
    required this.onTagsChanged,
  });

  @override
  ConsumerState<TagInput> createState() => _TagInputState();
}

class _TagInputState extends ConsumerState<TagInput> {
  late List<Tag> _initialTags;
  late List<Tag> _allTags;
  final TextEditingController _controller =
      TextEditingController(); // {{ edit_1 }}

  @override
  void initState() {
    super.initState();
    _initialTags = List.from(widget.initialTags);
  }

  @override
  Widget build(BuildContext context) {
    final allTags = ref.watch(tagListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: _initialTags
              .map((tag) => Chip(
                    label: Text(tag.name),
                    onDeleted: () {
                      setState(() {
                        _initialTags.remove(tag);
                        widget.onTagsChanged(_initialTags);
                      });
                    },
                  ))
              .toList(),
        ),
        SizedBox(
          width: double.infinity, // Or specify a fixed width
          child: Autocomplete<Tag>(
            optionsMaxHeight: 200,
            displayStringForOption: (Tag option) => option.name,
            optionsBuilder: (TextEditingValue textEditingValue) {
              return allTags.when(
                data: (tags) {
                  _allTags = tags;
                  return tags
                      .where((tag) =>
                          tag.name
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()) &&
                          !_initialTags.contains(tag))
                      .map((tag) => tag)
                      .toList();
                },
                loading: () => [],
                error: (_, __) => [],
              );
            },
            onSelected: (Tag selectedTag) {
              setState(() {
                if (!_initialTags.contains(selectedTag)) {
                  _initialTags.add(selectedTag);
                  widget.onTagsChanged(_initialTags);
                }
              });
              _controller.clear();
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController fieldTextEditingController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return TextField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                decoration: InputDecoration(
                  labelText: 'Add Tag',
                  // prefixIcon: IconButton(
                  //   icon: const Icon(Icons.add),
                  //   onPressed: () {
                  //     final newTag = fieldTextEditingController.text;
                  //     for (var tag in _allTags) {
                  //       if (tag.name == newTag && !_initialTags.contains(tag)) {
                  //         setState(() {
                  //           _initialTags.add(tag);
                  //           widget.onTagsChanged(_initialTags);
                  //         });
                  //         fieldTextEditingController.clear();
                  //         return;
                  //       }
                  //     }
                  //   },
                  // ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      fieldTextEditingController.clear();
                      fieldFocusNode.unfocus();
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    for (var tag in _allTags) {
                      if (tag.name == value && !_initialTags.contains(tag)) {
                        setState(() {
                          _initialTags.add(tag);
                          widget.onTagsChanged(_initialTags);
                        });
                        fieldTextEditingController.clear();
                        return;
                      }
                    }
                    fieldTextEditingController.clear();
                  }
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxHeight: 200, maxWidth: 300),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Tag option = options.elementAt(index);
                        return ListTile(
                          title: Text(option.name),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
