import 'package:shared_preferences/shared_preferences.dart';

final class AppAppearanceService {
  const AppAppearanceService(this._preferences);

  static const key = 'admin9.starter.appearance.v1';

  final SharedPreferencesAsync _preferences;

  Future<String?> read() => _preferences.getString(key);

  Future<void> write(String value) => _preferences.setString(key, value);
}
