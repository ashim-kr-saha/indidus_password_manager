import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/screens.dart';

final screenSizeProvider = StateProvider<ScreenSize>((ref) {
  return ScreenSize.small;
});
