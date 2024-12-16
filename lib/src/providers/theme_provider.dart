import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../constants.dart';
import 'share_pref_provider.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  int? build() {
    return null;
  }

  void setThemeColorCode(int color) async {
    state = color;
    await _saveColorCode(color);
  }

  Future<int?> getThemeColorCode() async {
    int? color = await _loadSavedThemeColorCode();
    state = color;
    return state;
  }

  Future<bool> _saveColorCode(int color) async {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    return await preferences.setInt(themeColorKey, color);
  }

  Future<int?> _loadSavedThemeColorCode() async {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    int? color = preferences.getInt(themeColorKey);

    return color;
  }
}
