import 'package:admin9_app_flutter/app/startup/startup_preferences.dart';
import 'package:admin9_app_flutter/app/startup/startup_preferences_repository.dart';
import 'package:admin9_app_flutter/app/startup/startup_preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late SharedPreferencesAsyncPlatform? previousPlatform;
  late SharedPreferencesStartupRepository repository;

  setUp(() {
    previousPlatform = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    repository = SharedPreferencesStartupRepository(
      StartupPreferencesService(SharedPreferencesAsync()),
    );
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = previousPlatform;
  });

  test(
    'persists versioned consent, onboarding, and exposure timestamps',
    () async {
      final acceptedAt = DateTime.utc(2026, 9, 1, 8);
      final exposure = DateTime.utc(2026, 9, 1, 9);
      await repository.save(
        StartupPreferences(
          privacyConsent: PrivacyConsentRecord(
            policyVersion: 2,
            acceptedAt: acceptedAt,
          ),
          onboardingVersion: 3,
          exposures: {
            'campaign:creative': [exposure],
          },
        ),
      );

      final restored = await repository.load();

      expect(restored.privacyConsent?.policyVersion, 2);
      expect(restored.privacyConsent?.acceptedAt, acceptedAt);
      expect(restored.onboardingVersion, 3);
      expect(restored.exposures['campaign:creative'], [exposure]);
    },
  );

  test('treats corrupt and legacy unversioned values as no consent', () async {
    final preferences = SharedPreferencesAsync();
    await preferences.setString(
      StartupPreferencesService.key,
      '{"privacyConsent":true,"onboardingVersion":"done"}',
    );

    final restored = await repository.load();

    expect(restored.privacyConsent, isNull);
    expect(restored.onboardingVersion, isNull);
    expect(restored.exposures, isEmpty);
  });
}
