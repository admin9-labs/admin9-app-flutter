import '../models/theme_preference.dart';
import '../services/theme_preference_service.dart';

abstract interface class ThemePreferenceRepository {
  Future<ThemePreference> load();

  Future<void> save(ThemePreference preference);
}

final class SharedPreferencesThemePreferenceRepository
    implements ThemePreferenceRepository {
  const SharedPreferencesThemePreferenceRepository(this._service);

  final ThemePreferenceService _service;

  @override
  Future<ThemePreference> load() async => switch (await _service.read()) {
    'light' => ThemePreference.light,
    'dark' => ThemePreference.dark,
    _ => ThemePreference.system,
  };

  @override
  Future<void> save(ThemePreference preference) =>
      _service.write(preference.name);
}
