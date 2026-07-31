import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._preferences, [this._boolWriter]);

  static const _privacyAcceptedKey = 'admin9.privacy.accepted';
  static const _themeModeKey = 'admin9.appearance.theme_mode';
  static const _fontScaleKey = 'admin9.appearance.font_scale';
  static const _grayscaleKey = 'admin9.appearance.grayscale';
  static const _highContrastKey = 'admin9.accessibility.high_contrast';
  static const _reduceMotionKey = 'admin9.accessibility.reduce_motion';

  final SharedPreferences _preferences;
  final Future<bool> Function(String key, bool value)? _boolWriter;

  bool get privacyAccepted =>
      _preferences.getBool(_privacyAcceptedKey) ?? false;
  String? get themeMode => _preferences.getString(_themeModeKey);
  String? get fontScale => _preferences.getString(_fontScaleKey);
  bool get grayscale => _preferences.getBool(_grayscaleKey) ?? false;
  bool get highContrast => _preferences.getBool(_highContrastKey) ?? false;
  bool get reduceMotion => _preferences.getBool(_reduceMotionKey) ?? false;

  Future<bool> setPrivacyAccepted(bool value) =>
      _boolWriter?.call(_privacyAcceptedKey, value) ??
      _preferences.setBool(_privacyAcceptedKey, value);
  Future<bool> setThemeMode(String value) =>
      _preferences.setString(_themeModeKey, value);
  Future<bool> setFontScale(String value) =>
      _preferences.setString(_fontScaleKey, value);
  Future<bool> setGrayscale(bool value) =>
      _preferences.setBool(_grayscaleKey, value);
  Future<bool> setHighContrast(bool value) =>
      _preferences.setBool(_highContrastKey, value);
  Future<bool> setReduceMotion(bool value) =>
      _preferences.setBool(_reduceMotionKey, value);
}
