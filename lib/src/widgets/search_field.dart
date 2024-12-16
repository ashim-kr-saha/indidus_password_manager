import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/entity_types.dart';
import '../providers/financial_card_provider.dart';
import '../providers/identity_card_provider.dart';
import '../providers/login_provider.dart';
import '../providers/note_provider.dart';

class SearchField extends ConsumerWidget {
  final EntityType entityType;

  const SearchField({super.key, required this.entityType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search',
          suffixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          hintText: 'Type to search...',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 10,
          ),
        ),
        onChanged: (value) {
          if (entityType == EntityType.login) {
            ref.read(loginSearchQueryProvider.notifier).state = value;
          } else if (entityType == EntityType.note) {
            ref.read(noteSearchQueryProvider.notifier).state = value;
          } else if (entityType == EntityType.financialCard) {
            ref.read(financialCardSearchQueryProvider.notifier).state = value;
          } else if (entityType == EntityType.identityCard) {
            ref.read(identityCardSearchQueryProvider.notifier).state = value;
          }
        },
      ),
    );
  }
}
