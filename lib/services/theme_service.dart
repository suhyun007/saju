import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _storageKey = 'theme_mode';
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedIndex = prefs.getInt(_storageKey);
      if (storedIndex != null && storedIndex >= 0 && storedIndex < ThemeMode.values.length) {
        themeModeNotifier.value = ThemeMode.values[storedIndex];
      }
    } catch (e) {
      // ignore read errors and keep default
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, mode.index);
    } catch (e) {
      // ignore write errors
    }
  }

  static ThemeMode get currentMode => themeModeNotifier.value;
}


