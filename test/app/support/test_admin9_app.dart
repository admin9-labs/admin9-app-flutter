import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_provider.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_repository.dart';
import 'package:admin9_app_flutter/app/startup/startup_preferences.dart';
import 'package:admin9_app_flutter/app/startup/startup_preferences_repository.dart';
import 'package:admin9_app_flutter/app/startup/startup_provider.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/repositories/startup_ad_repository.dart';
import 'package:admin9_app_flutter/features/startup_ad/presentation/providers/startup_ad_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpTestAdmin9App(
  WidgetTester tester, {
  AppAppearanceRepository? repository,
  StartupPreferencesRepository? startupRepository,
  StartupAdRepository? startupAdRepository,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  final translations = jsonDecode(
    File('assets/translations/zh-CN.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      assetLoader: _InMemoryAssetLoader(translations),
      saveLocale: false,
      child: ProviderScope(
        overrides: [
          appAppearanceRepositoryProvider.overrideWithValue(
            repository ?? FakeAppAppearanceRepository(),
          ),
          startupPreferencesRepositoryProvider.overrideWithValue(
            startupRepository ?? FakeCompletedStartupRepository(),
          ),
          if (startupAdRepository != null)
            startupAdRepositoryProvider.overrideWithValue(startupAdRepository),
        ],
        child: const Admin9App(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final class FakeCompletedStartupRepository
    implements StartupPreferencesRepository {
  FakeCompletedStartupRepository({StartupPreferences? preferences})
    : value =
          preferences ??
          StartupPreferences(
            privacyConsent: PrivacyConsentRecord(
              policyVersion: currentPrivacyPolicyVersion,
              acceptedAt: DateTime.utc(2026, 9, 1),
            ),
            onboardingVersion: currentOnboardingVersion,
          );

  StartupPreferences value;

  @override
  Future<StartupPreferences> load() async => value;

  @override
  Future<void> save(StartupPreferences preferences) async {
    value = preferences;
  }
}

final class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      Map.of(translations);
}

final class FakeAppAppearanceRepository implements AppAppearanceRepository {
  FakeAppAppearanceRepository({
    this.preference = AppAppearancePreference.defaults,
    this.loadError,
    this.saveError,
  });

  AppAppearancePreference preference;
  Object? loadError;
  Object? saveError;
  int loadCalls = 0;
  final List<AppAppearancePreference> savedPreferences = [];

  @override
  Future<AppAppearancePreference> load() async {
    loadCalls++;
    if (loadError case final error?) {
      throw error;
    }
    return preference;
  }

  @override
  Future<void> save(AppAppearancePreference value) async {
    savedPreferences.add(value);
    if (saveError case final error?) {
      throw error;
    }
    preference = value;
  }
}
