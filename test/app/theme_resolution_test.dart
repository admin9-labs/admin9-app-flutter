import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_provider.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_repository.dart';
import 'package:admin9_app_flutter/app/appearance/app_theme_catalog.dart';
import 'package:admin9_app_flutter/app/startup/startup_provider.dart';
import 'package:admin9_app_flutter/features/home/presentation/pages/home_page.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'package:shared_preferences/shared_preferences.dart';

import 'support/test_admin9_app.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  test('G01 registers only the consumed AGrid Theme extension', () {
    expect(
      File('lib/theme/colors.dart').readAsStringSync(),
      isNot(contains(RegExp(r'\bextensions\s*:'))),
    );
    for (final preset in AppThemePreset.values) {
      for (final fontSize in AppFontSizePreference.values) {
        for (final radius in AppRadiusPreference.values) {
          final pair = AppThemeCatalog.resolve(
            preset: preset,
            fontSize: fontSize,
            radius: radius,
          );
          for (final theme in [pair.light, pair.dark]) {
            expect(theme.colors.extensions, isEmpty);
            expect(theme.style.extensions, hasLength(1));
            expect(theme.style.extensions.single, isA<AGridStyle>());
            expect(
              theme.style.aGrid.minimumTouchSize,
              greaterThanOrEqualTo(44),
            );
          }
        }
      }
    }
  });

  testWidgets('resolves every appearance axis for both theme layers', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final repository = _FakeRepository(
      AppAppearancePreference.defaults.copyWith(
        brightness: AppBrightnessPreference.light,
      ),
    );
    await _pumpApp(tester, repository);

    _expectBrightness(tester, Brightness.light);
    final context = tester.element(find.byType(HomePage));
    final container = ProviderScope.containerOf(context);
    final next = const AppAppearancePreference(
      brightness: AppBrightnessPreference.dark,
      preset: AppThemePreset.forest,
      fontSize: AppFontSizePreference.extraLarge,
      radius: AppRadiusPreference.large,
    );

    await container.read(appAppearanceProvider.notifier).savePreference(next);
    expect(container.read(appAppearanceProvider).requireValue.preference, next);
    await tester.pumpAndSettle();

    _expectBrightness(tester, Brightness.dark);
    final expected = AppThemeCatalog.resolve(
      preset: next.preset,
      fontSize: next.fontSize,
      radius: next.radius,
    ).dark;
    expect(FTheme.of(context).colors.primary, expected.colors.primary);
    expect(
      FTheme.of(context).style.borderRadius.md,
      expected.style.borderRadius.md,
    );
    expect(
      FTheme.of(context).typography.body.sm.fontSize,
      expected.typography.body.sm.fontSize,
    );
    expect(
      material.Theme.of(context).textTheme.bodyMedium?.fontSize,
      expected.typography.body.sm.fontSize,
    );

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await container
        .read(appAppearanceProvider.notifier)
        .savePreference(
          next.copyWith(brightness: AppBrightnessPreference.system),
        );
    await tester.pumpAndSettle();
    _expectBrightness(tester, Brightness.dark);
  });
}

Future<void> _pumpApp(
  WidgetTester tester,
  AppAppearanceRepository repository,
) async {
  final translations = jsonDecode(
    File('assets/translations/zh-CN.json').readAsStringSync(),
  ) as Map<String, dynamic>;
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
      assetLoader: _InMemoryAssetLoader(translations),
      saveLocale: false,
      child: ProviderScope(
        overrides: [
          appAppearanceRepositoryProvider.overrideWithValue(repository),
          startupPreferencesRepositoryProvider.overrideWithValue(
            FakeCompletedStartupRepository(),
          ),
        ],
        child: const Admin9App(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      Map.of(translations);
}

void _expectBrightness(WidgetTester tester, Brightness expected) {
  final context = tester.element(find.byType(HomePage));
  expect(material.Theme.of(context).brightness, expected);
  expect(FTheme.of(context).colors.brightness, expected);
}

final class _FakeRepository implements AppAppearanceRepository {
  _FakeRepository(this.value);

  AppAppearancePreference value;

  @override
  Future<AppAppearancePreference> load() async => value;

  @override
  Future<void> save(AppAppearancePreference preference) async {
    value = preference;
  }
}
