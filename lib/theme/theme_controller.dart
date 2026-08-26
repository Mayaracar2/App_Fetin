import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  ThemeController._();

  static const _preferenceKey = 'dark_mode';
  static final mode = ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    mode.value = (preferences.getBool(_preferenceKey) ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  static Future<void> toggle() async {
    final dark = mode.value != ThemeMode.dark;
    mode.value = dark ? ThemeMode.dark : ThemeMode.light;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_preferenceKey, dark);
  }
}
