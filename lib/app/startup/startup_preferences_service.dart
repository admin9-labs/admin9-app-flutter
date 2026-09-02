import 'package:shared_preferences/shared_preferences.dart';

final class StartupPreferencesService {
  const StartupPreferencesService(this._preferences);

  static const key = 'admin9.startup.preferences.v1';

  final SharedPreferencesAsync _preferences;

  Future<String?> read() => _preferences.getString(key);

  Future<void> write(String value) => _preferences.setString(key, value);
}
