import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/settings_options.dart';

final selectedSettingProvider =
    StateProvider<SettingOptionEnum?>((ref) => null);
