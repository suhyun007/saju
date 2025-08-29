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
    print('=== 테마 변경 시도 ===');
    print('이전 테마: ${themeModeNotifier.value}');
    print('새 테마: $mode');
    themeModeNotifier.value = mode;
    print('테마 변경 완료: ${themeModeNotifier.value}');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, mode.index);
      print('테마 저장 완료: ${mode.index}');
    } catch (e) {
      print('테마 저장 실패: $e');
      // ignore write errors
    }
  }

  static ThemeMode get currentMode => themeModeNotifier.value;
}


