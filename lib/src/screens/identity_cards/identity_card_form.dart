import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../enums/screens.dart';
import '../../models/identity_card_model.dart';
import '../../providers/identity_card_provider.dart';
import '../../providers/screen_size_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/tag_input.dart';

class IdentityCardForm extends ConsumerStatefulWidget {
  final IdentityCardModel? identityCardData;
  final Map<String, Tag> allTagsMap;

  const IdentityCardForm({
    super.key,
    this.identityCardData,
    required this.allTagsMap,
  });

  @override
  ConsumerState<IdentityCardForm> createState() => _IdentityCardFormState();
}

class _IdentityCardFormState extends ConsumerState<IdentityCardForm> {
  late TextEditingController nameController;
  late TextEditingController nameOnCardController;
  late TextEditingController identityCardNumberController;
  late TextEditingController identityCardTypeController;
  late TextEditingController expiryDateController;
  late TextEditingController issueDateController;
  late TextEditingController countryController;
  late TextEditingController stateController;
  late TextEditingController noteController;
  late bool isFavorite;
  late List<Tag> tags;

  @override
  void initState() {
    super.initState();
    final identityCardData = widget.identityCardData;
    nameController = TextEditingController(text: identityCardData?.name ?? '');
    nameOnCardController =
        TextEditingController(text: identityCardData?.nameOnCard ?? '');
    identityCardNumberController =
        TextEditingController(text: identityCardData?.identityCardNumber ?? '');
    identityCardTypeController =
        TextEditingController(text: identityCardData?.identityCardType ?? '');
    expiryDateController =
        TextEditingController(text: identityCardData?.expiryDate ?? '');
    issueDateController =
        TextEditingController(text: identityCardData?.issueDate ?? '');
    countryController =
        TextEditingController(text: identityCardData?.country ?? '');
    stateController =
        TextEditingController(text: identityCardData?.state ?? '');
    noteController = TextEditingController(text: identityCardData?.note ?? '');
    isFavorite = identityCardData?.isFavorite ?? false;
    tags = identityCardData?.tags?.map((e) => widget.allTagsMap[e]!).toList() ??
        [];
  }

  @override
  void dispose() {
    nameController.dispose();
    nameOnCardController.dispose();
    identityCardNumberController.dispose();
    identityCardTypeController.dispose();
    expiryDateController.dispose();
    issueDateController.dispose();
    countryController.dispose();
    stateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      appBar: screenSize == ScreenSize.small
          ? AppBar(
              title: Text(
                _isEditing() ? 'Edit Identity Card' : 'Add Identity Card',
              ),
            )
          : null,
      body: Column(
        children: [
          screenSize == ScreenSize.small
              ? Container()
              : Text(
                  _isEditing() ? "Edit Identity Card" : "New Identity Card",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(
                      nameController,
                      'Name',
                      Icons.person,
                    ),
                    _buildTextField(
                      nameOnCardController,
                      'Name on Card',
                      Icons.person,
                    ),
                    _buildTextField(
                      identityCardNumberController,
                      'Card Number',
                      Icons.credit_card,
                    ),
                    _buildTextField(
                      identityCardTypeController,
                      'Card Type',
                      Icons.credit_card,
                    ),
                    _buildTextField(
                      expiryDateController,
                      'Expiry Date',
                      Icons.calendar_month,
                    ),
                    _buildTextField(
                      issueDateController,
                      'Issue Date',
                      Icons.calendar_month,
                    ),
                    _buildTextField(
                      countryController,
                      'Country',
                      Icons.location_pin,
                    ),
                    _buildTextField(
                      stateController,
                      'State',
                      Icons.location_pin,
                    ),
                    _buildTextField(
                      noteController,
                      'Note',
                      Icons.note,
                    ),
                    SwitchListTile(
                      title: const Text('Favorite'),
                      value: isFavorite,
                      onChanged: (value) {
                        setState(() {
                          isFavorite = value;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TagInput(
                        initialTags: tags,
                        onTagsChanged: (data) {
                          setState(() {
                            tags = data;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      onPressed: _saveIdentityCard,
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
    return widget.identityCardData != null &&
        widget.identityCardData?.id != null;
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

  void _saveIdentityCard() async {
    final identityCardData = IdentityCardModel(
      id: widget.identityCardData?.id,
      createdAt: widget.identityCardData?.createdAt!,
      createdBy: widget.identityCardData?.createdBy,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      updatedBy: widget.identityCardData?.updatedBy,
      name: nameController.text,
      nameOnCard: nameOnCardController.text,
      identityCardNumber: identityCardNumberController.text,
      identityCardType: identityCardTypeController.text,
      expiryDate: expiryDateController.text,
      issueDate: issueDateController.text,
      note: noteController.text,
      isFavorite: isFavorite,
      country: countryController.text,
      state: stateController.text,
      tags: tags.map((e) => e.id!).toList(),
    );
    // final token = ref.read(tokenProvider);
    if (!_isEditing()) {
      ref
          .read(identityCardNotifierProvider.notifier)
          .addIdentityCard(identityCardData);
    } else {
      ref.read(identityCardNotifierProvider.notifier).updateIdentityCard(
            widget.identityCardData!.id!,
            identityCardData,
          );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Identity Card ${_isEditing() ? 'updated' : 'added'} successfully!')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this identity card?'),
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
                await _deleteIdentityCard();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteIdentityCard() async {
    try {
      await Database.instance.deleteIdentityCard(
        widget.identityCardData!.id!,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identity Card deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting identity card: $e')),
        );
      }
    }
  }
}
