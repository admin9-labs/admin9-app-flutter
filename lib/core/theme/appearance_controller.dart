import 'package:flutter/foundation.dart';

import '../preferences/app_preferences.dart';
import 'app_appearance.dart';

class AppearanceController extends ChangeNotifier {
  AppearanceController(this._preferences)
    : _appearance = AppAppearance(
        theme: AppThemePreference.parse(_preferences.themeMode),
        fontScale: AppFontScale.parse(_preferences.fontScale),
        grayscale: _preferences.grayscale,
        highContrast: _preferences.highContrast,
        reduceMotion: _preferences.reduceMotion,
      );

  final AppPreferences _preferences;
  AppAppearance _appearance;

  AppAppearance get appearance => _appearance;

  Future<void> setTheme(AppThemePreference value) async {
    _appearance = _appearance.copyWith(theme: value);
    notifyListeners();
    await _preferences.setThemeMode(value.name);
  }

  Future<void> setFontScale(AppFontScale value) async {
    _appearance = _appearance.copyWith(fontScale: value);
    notifyListeners();
    await _preferences.setFontScale(value.name);
  }

  Future<void> setGrayscale(bool value) async {
    _appearance = _appearance.copyWith(grayscale: value);
    notifyListeners();
    await _preferences.setGrayscale(value);
  }

  Future<void> setHighContrast(bool value) async {
    _appearance = _appearance.copyWith(highContrast: value);
    notifyListeners();
    await _preferences.setHighContrast(value);
  }

  Future<void> setReduceMotion(bool value) async {
    _appearance = _appearance.copyWith(reduceMotion: value);
    notifyListeners();
    await _preferences.setReduceMotion(value);
  }
}
