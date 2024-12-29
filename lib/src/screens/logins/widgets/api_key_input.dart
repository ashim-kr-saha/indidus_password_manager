import 'package:flutter/material.dart';

import '../../../models/login_model.dart';

class APIKeysInput extends StatefulWidget {
  final List<APIKey> apiKeys;
  final Function(APIKey) onAddApiKey;
  final Function(int, APIKey) onUpdateApiKey;
  final Function(int) onRemoveApiKey;

  const APIKeysInput({
    required this.apiKeys,
    required this.onAddApiKey,
    required this.onUpdateApiKey,
    required this.onRemoveApiKey,
    super.key,
  });

  @override
  State<APIKeysInput> createState() => _APIKeysInputState();
}

class _APIKeysInputState extends State<APIKeysInput>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.apiKeys.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      )..forward(),
    );
  }

  @override
  void didUpdateWidget(APIKeysInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle controllers when items are added or removed
    if (widget.apiKeys.length > _controllers.length) {
      // New items were added
      _controllers.addAll(
        List.generate(
          widget.apiKeys.length - _controllers.length,
          (index) => AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
          )..forward(),
        ),
      );
    } else if (widget.apiKeys.length < _controllers.length) {
      // Items were removed
      for (var i = _controllers.length - 1; i >= widget.apiKeys.length; i--) {
        _controllers[i].dispose();
      }
      _controllers.removeRange(widget.apiKeys.length, _controllers.length);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.apiKeys.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 8.0),
            child: Text('No API keys added.'),
          ),
        ...List.generate(widget.apiKeys.length, (index) {
          return _buildAnimatedApiKeyItem(index);
        }),
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildAnimatedApiKeyItem(int index) {
    final animation = CurvedAnimation(
      parent: _controllers[index],
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.2, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: _buildApiKeyItem(index),
    );
  }

  Widget _buildApiKeyItem(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12.0),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () => _editApiKey(index),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.apiKeys[index].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.apiKeys[index].value,
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _editApiKey(index),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteApiKey(index),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => _addNewApiKey(context),
        icon: const Icon(Icons.add),
        label: const Text('Add API Key'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _addNewApiKey(BuildContext context) {
    _showApiKeyDialog(
      context: context,
      title: 'Add API Key',
      onSave: (name, value) {
        final newApiKey = APIKey(name: name, value: value);
        widget.onAddApiKey(newApiKey);
      },
    );
  }

  void _editApiKey(int index) {
    _showApiKeyDialog(
      context: context,
      title: 'Edit API Key',
      initialName: widget.apiKeys[index].name,
      initialValue: widget.apiKeys[index].value,
      onSave: (name, value) {
        final newApiKey = APIKey(name: name, value: value);
        widget.onUpdateApiKey(index, newApiKey);
      },
    );
  }

  void _deleteApiKey(int index) {
    _controllers[index].reverse().then((_) {
      widget.onRemoveApiKey(index);
    });
  }

  void _showApiKeyDialog({
    required BuildContext context,
    required String title,
    String? initialName,
    String? initialValue,
    required Function(String name, String value) onSave,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        final nameController = TextEditingController(text: initialName);
        final valueController = TextEditingController(text: initialValue);

        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'API Key Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'API Key Value',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  onSave(nameController.text, valueController.text);
                  Navigator.of(context).pop();
                },
                child: Text(initialName == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        );
      },
    );
  }
}
