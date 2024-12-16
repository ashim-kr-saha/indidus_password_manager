import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums/screens.dart';
import '../../providers/screen_size_provider.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsDetail extends ConsumerWidget {
  ThemeSettingsDetail({super.key});

  final List<ThemeOption> themeOptions = [
    ThemeOption('Red', Colors.red),
    ThemeOption('Pink', Colors.pink),
    ThemeOption('Purple', Colors.purple),
    ThemeOption('DeepPurple', Colors.deepPurple),
    ThemeOption('Indigo', Colors.indigo),
    ThemeOption('LightBlue', Colors.lightBlue),
    ThemeOption('Blue', Colors.blue),
    ThemeOption('Teal', Colors.teal),
    ThemeOption('Cyan', Colors.cyan),
    ThemeOption('Green', Colors.green),
    ThemeOption('LightGreen', Colors.lightGreen),
    ThemeOption('Lime', Colors.lime),
    ThemeOption('LimeAccent', Colors.limeAccent),
    ThemeOption('Yellow', Colors.yellow),
    ThemeOption('Amber', Colors.amber),
    ThemeOption('Orange', Colors.orange),
    ThemeOption('DeepOrange', Colors.deepOrange),
    ThemeOption('Brown', Colors.brown),
    ThemeOption('Grey', Colors.grey),
    ThemeOption('BlueGrey', Colors.blueGrey),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedColorValue = ref.watch(themeNotifierProvider);
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      appBar: screenSize == ScreenSize.small
          ? AppBar(
              title: const Text('Theme Settings'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a theme',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: themeOptions.map((theme) {
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(themeNotifierProvider.notifier)
                          .setThemeColorCode(theme.color.value);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 20,
                            decoration: BoxDecoration(
                              color: theme.color,
                              border: Border.all(
                                color: selectedColorValue == theme.color.value
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(theme.name),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeOption {
  final String name;
  final Color color;

  ThemeOption(this.name, this.color);
}
