import 'package:flutter/material.dart';

enum SettingOptionEnum {
  account('Account', Icons.person),
  security('Security', Icons.security),
  notifications('Notifications', Icons.notifications),
  language('Language', Icons.language),
  theme('Theme', Icons.palette),
  tags('Tags', Icons.label),
  masterPassword('Master Password', Icons.lock),
  backupRestore('Backup & Restore', Icons.backup),
  helpSupport('Help & Support', Icons.help),
  about('About', Icons.info);

  final String title;
  final IconData icon;

  const SettingOptionEnum(this.title, this.icon);
}
