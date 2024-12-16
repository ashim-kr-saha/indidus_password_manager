import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../enums/screens.dart';
import '../../models/login_model.dart';
import '../../providers/login_provider.dart';
import '../../providers/screen_size_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/tag_input.dart';
import 'widgets/api_key_input.dart';

class LoginForm extends ConsumerStatefulWidget {
  final LoginModel? login;
  final Map<String, Tag> allTagsMap;

  const LoginForm({
    super.key,
    this.login,
    required this.allTagsMap,
  });

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController passwordHintController;
  late TextEditingController noteController;
  late TextEditingController urlController;
  late bool isFavorite;
  late List<Tag> tags;
  late List<APIKey> apiKeys;

  @override
  void initState() {
    super.initState();
    final loginData = widget.login;
    nameController = TextEditingController(text: loginData?.name ?? '');
    usernameController = TextEditingController(text: loginData?.username ?? '');
    passwordController = TextEditingController(text: loginData?.password ?? '');
    passwordHintController =
        TextEditingController(text: loginData?.passwordHint ?? '');
    noteController = TextEditingController(text: loginData?.note ?? '');
    urlController = TextEditingController(text: loginData?.url ?? '');
    isFavorite = loginData?.isFavorite ?? false;
    tags = loginData?.tags?.map((e) => widget.allTagsMap[e]!).toList() ?? [];
    apiKeys = loginData?.apiKeys ?? [];
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    passwordHintController.dispose();
    noteController.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      appBar: screenSize == ScreenSize.small
          ? AppBar(
              title: Text(
                _isEditing() ? 'Edit Login' : 'New Login',
              ),
            )
          : null,
      body: Column(
        children: [
          screenSize == ScreenSize.small
              ? Container()
              : Text(
                  _isEditing() ? "Edit Login" : "New Login",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(nameController, 'Name', Icons.person),
                    _buildTextField(urlController, 'URL', Icons.link),
                    _buildTextField(
                        usernameController, 'Username', Icons.person_outline),
                    _buildTextField(passwordController, 'Password', Icons.lock,
                        obscureText: true),
                    _buildTextField(passwordHintController, 'Password Hint',
                        Icons.help_outline),
                    const SizedBox(height: 24),
                    APIKeysInput(
                      apiKeys: apiKeys,
                      onAddApiKey: (newApiKey) {
                        setState(() {
                          apiKeys.add(newApiKey);
                        });
                      },
                      onUpdateApiKey: (index, apiKey) {
                        setState(() {
                          apiKeys[index] = apiKey;
                        });
                      },
                      onRemoveApiKey: (index) {
                        setState(() {
                          apiKeys.removeAt(index);
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    TagInput(
                      initialTags: tags,
                      onTagsChanged: (data) {
                        setState(() {
                          tags = data;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text(
                        'Favorite',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      value: isFavorite,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        setState(() {
                          isFavorite = value;
                        });
                      },
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
                      onPressed: _saveLogin,
                      child: Text(_isEditing() ? 'Update' : 'Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isEditing() {
    return widget.login != null && widget.login?.id != null;
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        obscureText: obscureText,
      ),
    );
  }

  void _saveLogin() async {
    final loginData = LoginModel(
      id: widget.login?.id,
      createdAt:
          widget.login?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      createdBy: widget.login?.createdBy,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      updatedBy: widget.login?.updatedBy,
      name: nameController.text,
      username: usernameController.text,
      password: passwordController.text,
      passwordHint: passwordHintController.text,
      apiKeys: apiKeys,
      note: noteController.text,
      url: urlController.text,
      isFavorite: isFavorite,
      tags: tags.map((e) => e.id!).toList(),
    );
    try {
      if (!_isEditing()) {
        ref.read(loginNotifierProvider.notifier).addLogin(loginData);
      } else {
        ref.read(loginNotifierProvider.notifier).updateLogin(
              widget.login!.id!,
              loginData,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Login ${_isEditing() ? 'updated' : 'added'} successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving login: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this login?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteLogin();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteLogin() async {
    try {
      await Database.instance.deleteLogin(widget.login!.id!);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting login: $e')),
        );
      }
    }
  }
}
