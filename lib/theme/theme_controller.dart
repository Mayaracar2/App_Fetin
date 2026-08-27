import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  ThemeController._();

  static const _preferenceKey = 'theme_mode';
  static final mode = ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_preferenceKey);
    mode.value = saved == ThemeMode.dark.name
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  static Future<void> toggle() async {
    final dark = mode.value != ThemeMode.dark;
    mode.value = dark ? ThemeMode.dark : ThemeMode.light;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, mode.value.name);
  }

  static Future<void> setMode(ThemeMode newMode) async {
    mode.value = newMode;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, newMode.name);
  }
}
