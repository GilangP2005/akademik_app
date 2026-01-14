import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  static const _kTheme = 'theme_mode'; // 'dark' | 'light'

  static Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_kTheme) ?? 'dark';
    themeMode.value = (v == 'light') ? ThemeMode.light : ThemeMode.dark;
  }

  static Future<void> toggleTheme() async {
    final sp = await SharedPreferences.getInstance();
    final next = themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    themeMode.value = next;
    await sp.setString(_kTheme, next == ThemeMode.light ? 'light' : 'dark');
  }
}
