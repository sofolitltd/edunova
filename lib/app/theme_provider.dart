import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../shared/services/secure_storage_service.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SecureStorageService _storage;

  ThemeNotifier({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService(),
        super(ThemeMode.light);

  Future<void> init() async {
    final mode = await _storage.readTheme();
    if (mode == 'dark') {
      state = ThemeMode.dark;
    } else if (mode == 'light') {
      state = ThemeMode.light;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _storage.saveTheme(mode == ThemeMode.dark ? 'dark' : 'light');
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _storage.saveTheme(state == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier());