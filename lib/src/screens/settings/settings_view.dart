import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums/screens.dart';
import '../../enums/settings_options.dart';
import '../../providers/auth_provider.dart';
import '../../providers/screen_size_provider.dart';
import '../../providers/settings_providers.dart';
import 'backup_restore_screen.dart';
import 'master_password_settings_details.dart';
import 'tag_settings_details.dart'; // Add this import
import 'theme_settings_details.dart'; // Add this import

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSetting = ref.watch(selectedSettingProvider);

    final screenSize = ref.watch(screenSizeProvider);

    return LayoutBuilder(
      builder: (context, _) {
        return Scaffold(
          // appBar: PreferredSize(
          //   preferredSize: const Size.fromHeight(kToolbarHeight),
          //   child: _buildAppBar(context, ref, screenSize),
          // ),
          appBar: AppBar(
            title: const Text('Settings'),
            actions: screenSize == ScreenSize.large
                ? [
                    IconButton(
                      onPressed: () => ref.read(authProvider.notifier).logout(),
                      icon: const Icon(Icons.logout),
                    ),
                  ]
                : null,
          ),
          body: screenSize == ScreenSize.small
              ? SettingsList(
                  screenSize: screenSize,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: screenSize == ScreenSize.large ? 1 : 2,
                      child: SettingsList(
                        screenSize: screenSize,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SettingsDetailScreen(
                        selectedSetting: selectedSetting,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class SettingsList extends ConsumerWidget {
  const SettingsList({super.key, required this.screenSize});

  final ScreenSize screenSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        for (final setting in SettingOptionEnum.values)
          SettingsTile(setting: setting, screenSize: screenSize),
      ],
    );
  }
}

class SettingsTile extends ConsumerWidget {
  final SettingOptionEnum setting;
  final ScreenSize screenSize;
  const SettingsTile({
    super.key,
    required this.setting,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(setting.icon),
      title: Text(setting.title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _handleSettingTap(context, ref, screenSize),
    );
  }

  void _handleSettingTap(
    BuildContext context,
    WidgetRef ref,
    ScreenSize screenSize,
  ) {
    if (screenSize == ScreenSize.small) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsDetailScreen(selectedSetting: setting),
        ),
      );
    } else {
      ref.read(selectedSettingProvider.notifier).state = setting;
    }
  }
}

class SettingsDetailScreen extends StatelessWidget {
  final SettingOptionEnum? selectedSetting;

  const SettingsDetailScreen({super.key, required this.selectedSetting});

  @override
  Widget build(BuildContext context) {
    if (selectedSetting == null) {
      return const Center(
        child: Text('Select a setting to view details'),
      );
    }
    switch (selectedSetting) {
      case SettingOptionEnum.theme:
        return ThemeSettingsDetail();
      case SettingOptionEnum.tags:
        return const TagSettingsDetail();
      case SettingOptionEnum.masterPassword:
        return const MasterPasswordSettingsDetail();
      case SettingOptionEnum.backupRestore:
        return const BackupRestoreSettings();
      default:
        return Scaffold(
          appBar: AppBar(
            title: Text(selectedSetting!.title),
          ),
          body: switch (selectedSetting) {
            SettingOptionEnum.theme => ThemeSettingsDetail(),
            SettingOptionEnum.tags => const TagSettingsDetail(),
            _ => Center(
                child: Text('Details for ${selectedSetting!.title}'),
              ),
          },
        );
    }
  }
}
