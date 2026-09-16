import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/services/secure_storage_service.dart';

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier());

class LocaleNotifier extends StateNotifier<Locale> {
  final SecureStorageService _storage;

  LocaleNotifier({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService(),
        super(const Locale('bn'));

  Future<void> init() async {
    final code = await _storage.readLocale();
    if (code != null && (code == 'en' || code == 'bn')) {
      state = Locale(code);
    }
  }

  void setLocale(Locale locale) {
    state = locale;
    _storage.saveLocale(locale.languageCode);
  }

  void toggleLocale() {
    state =
        state.languageCode == 'bn' ? const Locale('en') : const Locale('bn');
    _storage.saveLocale(state.languageCode);
  }
}

extension LocaleX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
