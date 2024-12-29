import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../enums/screens.dart';
import '../../models/financial_card_model.dart';
import '../../providers/financial_card_provider.dart';
import '../../providers/screen_size_provider.dart';
import '../../rust/models/tags.dart';
import '../../widgets/tag_input.dart';

class FinancialCardForm extends ConsumerStatefulWidget {
  final FinancialCardModel? financialCardData;
  final Map<String, Tag> allTagsMap;

  const FinancialCardForm({
    super.key,
    this.financialCardData,
    required this.allTagsMap,
  });

  @override
  ConsumerState<FinancialCardForm> createState() => _FinancialCardFormState();
}

class _FinancialCardFormState extends ConsumerState<FinancialCardForm>
    with SingleTickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController cardHolderNameController;
  late TextEditingController cardNumberController;
  late TextEditingController cardProviderNameController;
  late TextEditingController cardTypeController;
  late TextEditingController cvvController;
  late TextEditingController expiryDateController;
  late TextEditingController issueDateController;
  late TextEditingController pinController;
  late TextEditingController noteController;
  late bool isFavorite;
  late List<Tag> tags;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final financialCardData = widget.financialCardData;
    nameController = TextEditingController(text: financialCardData?.name ?? '');
    cardHolderNameController =
        TextEditingController(text: financialCardData?.cardHolderName ?? '');
    cardNumberController =
        TextEditingController(text: financialCardData?.cardNumber ?? '');
    cardProviderNameController =
        TextEditingController(text: financialCardData?.cardProviderName ?? '');
    cardTypeController =
        TextEditingController(text: financialCardData?.cardType ?? '');
    cvvController = TextEditingController(text: financialCardData?.cvv ?? '');
    expiryDateController =
        TextEditingController(text: financialCardData?.expiryDate ?? '');
    issueDateController =
        TextEditingController(text: financialCardData?.issueDate ?? '');
    pinController = TextEditingController(text: financialCardData?.pin ?? '');
    noteController = TextEditingController(text: financialCardData?.note ?? '');
    isFavorite = financialCardData?.isFavorite ?? false;
    tags =
        financialCardData?.tags?.map((e) => widget.allTagsMap[e]!).toList() ??
            [];

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
    nameController.dispose();
    cardHolderNameController.dispose();
    cardNumberController.dispose();
    cardProviderNameController.dispose();
    cardTypeController.dispose();
    cvvController.dispose();
    expiryDateController.dispose();
    issueDateController.dispose();
    pinController.dispose();
    noteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      appBar: screenSize == ScreenSize.small
          ? AppBar(
              title: Text(
                _isEditing() ? 'Edit Financial Card' : 'Add Financial Card',
              ),
            )
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
                      _isEditing()
                          ? "Edit Financial Card"
                          : "New Financial Card",
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
                          cardHolderNameController,
                          'Card Holder Name',
                          Icons.person,
                        ),
                        _buildTextField(
                          cardNumberController,
                          'Card Number',
                          Icons.credit_card,
                        ),
                        _buildTextField(
                          cardProviderNameController,
                          'Card Provider Name',
                          Icons.business,
                        ),
                        _buildTextField(
                          cardTypeController,
                          'Card Type',
                          Icons.credit_card,
                        ),
                        _buildTextField(
                          cvvController,
                          'CVV',
                          Icons.pin,
                        ),
                        _buildTextField(
                          pinController,
                          'PIN',
                          Icons.pin,
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
                          onPressed: _saveFinancialCard,
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
    return widget.financialCardData != null &&
        widget.financialCardData?.id != null;
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

  void _saveFinancialCard() async {
    final financialCardData = FinancialCardModel(
      id: widget.financialCardData?.id,
      createdAt: widget.financialCardData?.createdAt ??
          DateTime.now().millisecondsSinceEpoch,
      createdBy: widget.financialCardData?.createdBy,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      updatedBy: widget.financialCardData?.updatedBy,
      name: nameController.text,
      cardHolderName: cardHolderNameController.text,
      cardNumber: cardNumberController.text,
      cardProviderName: cardProviderNameController.text,
      cardType: cardTypeController.text,
      cvv: cvvController.text,
      expiryDate: expiryDateController.text,
      issueDate: issueDateController.text,
      pin: pinController.text,
      note: noteController.text,
      isFavorite: isFavorite,
      tags: tags.map((e) => e.id!).toList(),
    );
    if (!_isEditing()) {
      ref
          .read(financialCardNotifierProvider.notifier)
          .addFinancialCard(financialCardData);
    } else {
      ref.read(financialCardNotifierProvider.notifier).updateFinancialCard(
            widget.financialCardData!.id!,
            financialCardData,
          );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Financial Card ${_isEditing() ? 'updated' : 'added'} successfully!')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete this financial card?'),
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
                await _deleteFinancialCard();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFinancialCard() async {
    try {
      await Database.instance.deleteFinancialCard(
        widget.financialCardData!.id!,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Financial Card deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting financial card: $e')),
        );
      }
    }
  }
}
