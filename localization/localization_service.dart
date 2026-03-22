import 'dart:ui';
import 'package:flutter/material.dart';
import '../atomic_state/atom.dart';
import '../cache/local_cache.dart';

class LocalizationService {
  LocalizationService._internal();
  static final LocalizationService _singleton = LocalizationService._internal();
  factory LocalizationService() => _singleton;

  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('pt', ''), // Portuguese (Brazil)
    Locale('it', ''), // Italian
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'pt': 'Português',
    'it': 'Italiano',
  };

  /// Get the current locale from cache or system default
  Locale getCurrentLocale() {
    final cachedLocale = AppCache().getLocale();

    if (cachedLocale != null) {
      return Locale(cachedLocale);
    }

    // Fallback to system locale if supported, otherwise default to English
    final systemLocale = PlatformDispatcher.instance.locale;
    final isSupported = supportedLocales.any(
      (locale) => locale.languageCode == systemLocale.languageCode,
    );

    return isSupported ? systemLocale : const Locale('en');
  }

  /// Set the locale and save to cache
  Future<void> setLocale(String languageCode) async {
    await AppCache().setLocale(languageCode);
    // Trigger atom update to rebuild UI
    localeAtom.emit(Locale(languageCode));
  }

  /// Check if a locale is supported
  static bool isLocaleSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }
}

/// Atomic state for current locale
final localeAtom = Atom<Locale>(
  LocalizationService().getCurrentLocale(),
);
