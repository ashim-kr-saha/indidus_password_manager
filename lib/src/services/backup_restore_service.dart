import 'dart:io';

import '../rust/api/simple.dart';

class BackupRestoreService {
  static Future<void> backupToJSON(String destinationPath) async {
    // Create file if not exists
    final jsonFile = File(destinationPath);
    if (!await jsonFile.exists()) {
      await jsonFile.create();
    }
    final jsonData = await exportAllDataToJson();
    await jsonFile.writeAsString(jsonData);
  }

  static Future<void> restoreFromJSON(String sourcePath) async {
    final jsonData = await File(sourcePath).readAsString();
    await restoreDataFromJson(data: jsonData);
  }

  static Future<String> generateBackupData() async {
    return await exportAllDataToJson();
  }

  static Future<void> restoreFromData(String backupData) async {
    await restoreDataFromJson(data: backupData);
  }
}
