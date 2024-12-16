import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/backup_restore_service.dart';

class BackupRestoreSettings extends ConsumerWidget {
  const BackupRestoreSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _backupToJSON(context),
              child: const Text('Backup Database to JSON'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _restoreFromJSON(context),
              child: const Text('Restore Database from JSON'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backupToJSON(BuildContext context) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save backup file',
        fileName: 'database_backup.json',
      );

      if (result != null) {
        await BackupRestoreService.backupToJSON(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Backup to JSON completed successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup to JSON failed: $e')),
        );
      }
    }
  }

  Future<void> _restoreFromJSON(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null) {
        await BackupRestoreService.restoreFromJSON(result.files.single.path!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Restore from JSON completed successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore from JSON failed: $e')),
        );
      }
    }
  }
}
