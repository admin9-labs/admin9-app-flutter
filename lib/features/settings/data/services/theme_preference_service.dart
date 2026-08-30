import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferenceService {
  ThemePreferenceService(this._preferences);

  static const key = 'admin9.starter.theme_mode.v1';

  final SharedPreferencesAsync _preferences;

  Future<String?> read() => _preferences.getString(key);

  Future<void> write(String value) => _preferences.setString(key, value);
}
