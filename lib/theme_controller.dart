import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  // Method to update theme mode with immediate notification
  static void updateThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
    // Force a rebuild of all listeners
    // ignore: invalid_use_of_protected_member
    themeModeNotifier.notifyListeners();
  }
}
