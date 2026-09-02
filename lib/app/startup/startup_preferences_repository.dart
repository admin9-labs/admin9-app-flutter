import 'dart:convert';

import 'startup_preferences.dart';
import 'startup_preferences_service.dart';

abstract interface class StartupPreferencesRepository {
  Future<StartupPreferences> load();

  Future<void> save(StartupPreferences preferences);
}

final class SharedPreferencesStartupRepository
    implements StartupPreferencesRepository {
  const SharedPreferencesStartupRepository(this._service);

  final StartupPreferencesService _service;

  @override
  Future<StartupPreferences> load() async {
    final stored = await _service.read();
    if (stored == null) return const StartupPreferences();

    try {
      final json = jsonDecode(stored);
      if (json is! Map<String, dynamic>) return const StartupPreferences();
      return StartupPreferences(
        privacyConsent: PrivacyConsentRecord.fromJson(json['privacyConsent']),
        onboardingVersion: json['onboardingVersion'] is int
            ? json['onboardingVersion'] as int
            : null,
        exposures: _decodeExposures(json['exposures']),
      );
    } on FormatException {
      return const StartupPreferences();
    }
  }

  @override
  Future<void> save(StartupPreferences preferences) => _service.write(
    jsonEncode({
      'privacyConsent': preferences.privacyConsent?.toJson(),
      'onboardingVersion': preferences.onboardingVersion,
      'exposures': {
        for (final entry in preferences.exposures.entries)
          entry.key: [
            for (final exposure in entry.value)
              exposure.toUtc().toIso8601String(),
          ],
      },
    }),
  );
}

Map<String, List<DateTime>> _decodeExposures(Object? value) {
  if (value is! Map<String, dynamic>) return const {};
  final result = <String, List<DateTime>>{};
  for (final entry in value.entries) {
    if (entry.value is! List<dynamic>) continue;
    final dates = <DateTime>[];
    for (final item in entry.value as List<dynamic>) {
      if (item is! String) continue;
      final date = DateTime.tryParse(item);
      if (date != null) dates.add(date.toUtc());
    }
    if (dates.isNotEmpty) result[entry.key] = dates;
  }
  return result;
}
