import 'dart:convert';

import 'app_appearance_preference.dart';
import 'app_appearance_service.dart';

abstract interface class AppAppearanceRepository {
  Future<AppAppearancePreference> load();

  Future<void> save(AppAppearancePreference preference);
}

final class SharedPreferencesAppAppearanceRepository
    implements AppAppearanceRepository {
  const SharedPreferencesAppAppearanceRepository(this._service);

  final AppAppearanceService _service;

  @override
  Future<AppAppearancePreference> load() async {
    final stored = await _service.read();
    if (stored == null) {
      return AppAppearancePreference.defaults;
    }

    try {
      final value = jsonDecode(stored);
      if (value is! Map<String, dynamic>) {
        return AppAppearancePreference.defaults;
      }
      return AppAppearancePreference(
        brightness: _enumByName(
          AppBrightnessPreference.values,
          value['brightness'],
          AppAppearancePreference.defaults.brightness,
        ),
        preset: _enumByName(
          AppThemePreset.values,
          value['preset'],
          AppAppearancePreference.defaults.preset,
        ),
        fontSize: _enumByName(
          AppFontSizePreference.values,
          value['fontSize'],
          AppAppearancePreference.defaults.fontSize,
        ),
        radius: _enumByName(
          AppRadiusPreference.values,
          value['radius'],
          AppAppearancePreference.defaults.radius,
        ),
      );
    } on FormatException {
      return AppAppearancePreference.defaults;
    }
  }

  @override
  Future<void> save(AppAppearancePreference preference) => _service.write(
    jsonEncode({
      'brightness': preference.brightness.name,
      'preset': preference.preset.name,
      'fontSize': preference.fontSize.name,
      'radius': preference.radius.name,
    }),
  );
}

T _enumByName<T extends Enum>(Iterable<T> values, Object? name, T fallback) {
  if (name is! String) return fallback;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
