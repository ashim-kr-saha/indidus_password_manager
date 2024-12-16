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

class _APIKeysInputState extends State<APIKeysInput> {
  @override
  void dispose() {
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
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API Key Name: ${widget.apiKeys[index].name}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'API Key Value: ${widget.apiKeys[index].value}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            final nameController = TextEditingController(
                                text: widget.apiKeys[index].name);
                            final valueController = TextEditingController(
                                text: widget.apiKeys[index].value);
                            return AlertDialog(
                              title: const Text('Edit API Key'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                          labelText: 'API Key Name',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      controller: valueController,
                                      decoration: const InputDecoration(
                                          labelText: 'API Key Value',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final newApiKey = APIKey(
                                      name: nameController.text,
                                      value: valueController.text,
                                    );
                                    final newApiKeys =
                                        List<APIKey>.from(widget.apiKeys);
                                    newApiKeys[index] = newApiKey;
                                    widget.onUpdateApiKey(index, newApiKey);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Update'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        widget.onRemoveApiKey(index);
                      },
                    )
                  ],
                ),
              ],
            ),
          );
        }),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final nameController = TextEditingController();
                final valueController = TextEditingController();
                return AlertDialog(
                  title: const Text('Add API Key'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'API Key Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: valueController,
                          decoration: const InputDecoration(
                            labelText: 'API Key Value',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final newApiKey = APIKey(
                          name: nameController.text,
                          value: valueController.text,
                        );
                        widget.onAddApiKey(newApiKey);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add),
              SizedBox(width: 4),
              Text('Add API Key'),
            ],
          ),
        ),
      ],
    );
  }
}
