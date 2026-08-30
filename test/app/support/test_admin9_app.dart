import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/features/settings/data/models/theme_preference.dart';
import 'package:admin9_app_flutter/features/settings/data/repositories/theme_preference_repository.dart';
import 'package:admin9_app_flutter/features/settings/presentation/providers/theme_preference_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpTestAdmin9App(
  WidgetTester tester, {
  ThemePreferenceRepository? repository,
}) async {
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();

  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      saveLocale: false,
      child: ProviderScope(
        overrides: [
          themePreferenceRepositoryProvider.overrideWithValue(
            repository ?? FakeThemePreferenceRepository(),
          ),
        ],
        child: const Admin9App(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final class FakeThemePreferenceRepository implements ThemePreferenceRepository {
  FakeThemePreferenceRepository({
    this.preference = ThemePreference.system,
    this.loadError,
    this.saveError,
  });

  ThemePreference preference;
  Object? loadError;
  Object? saveError;
  int loadCalls = 0;
  final List<ThemePreference> savedPreferences = [];

  @override
  Future<ThemePreference> load() async {
    loadCalls++;
    if (loadError case final error?) {
      throw error;
    }
    return preference;
  }

  @override
  Future<void> save(ThemePreference value) async {
    savedPreferences.add(value);
    if (saveError case final error?) {
      throw error;
    }
    preference = value;
  }
}
