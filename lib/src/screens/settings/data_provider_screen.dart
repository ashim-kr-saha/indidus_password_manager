// NOTE: This file is not used yet
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database_type.dart';

class DataProviderSettingsDetail extends ConsumerWidget {
  const DataProviderSettingsDetail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProvider = ref.watch(dataProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Data Provider',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Local'),
            leading: Radio<DatabaseType>(
              value: DatabaseType.local,
              groupValue: currentProvider,
              onChanged: (value) {
                ref.read(dataProvider.notifier).setProvider(value!);
              },
            ),
          ),
          ListTile(
            title: const Text('Server'),
            leading: Radio<DatabaseType>(
              value: DatabaseType.server,
              groupValue: currentProvider,
              onChanged: (value) {
                ref.read(dataProvider.notifier).setProvider(value!);
              },
            ),
          ),
          if (currentProvider == DatabaseType.server)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                ),
                onChanged: (url) {
                  ref.read(dataProvider.notifier).setServerUrl(url);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Provider for managing data provider state
final dataProvider = StateNotifierProvider<DataProviderNotifier, DatabaseType>(
  (ref) => DataProviderNotifier(),
);

class DataProviderNotifier extends StateNotifier<DatabaseType> {
  DataProviderNotifier() : super(DatabaseType.local);

  void setProvider(DatabaseType provider) {
    state = provider;
  }

  void setServerUrl(String url) {
    // Save the server URL
  }
}
