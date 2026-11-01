import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_provider.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_repository.dart';
import 'package:admin9_app_flutter/app/appearance/app_theme_catalog.dart';
import 'package:admin9_app_flutter/app/startup/startup_provider.dart';
import 'package:admin9_app_flutter/app/page_configuration/page_configuration.dart';
import 'package:admin9_app_flutter/app/page_configuration/page_configuration_provider.dart';
import 'package:admin9_app_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/repositories/startup_ad_repository.dart';
import 'package:admin9_app_flutter/features/startup_ad/presentation/providers/startup_ad_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/support/test_admin9_app.dart';

void main() {
  late Map<String, dynamic> translations;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    translations = jsonDecode(
      await File('assets/translations/zh-CN.json').readAsString(),
    ) as Map<String, dynamic>;
  });

  testWidgets('updates the whole App immediately and completes persistence', (
    tester,
  ) async {
    final pending = Completer<void>();
    final repository = _FakeRepository(pendingSave: pending);
    await _pumpApp(tester, repository, translations);
    await _openSettings(tester);

    final ocean = find.byKey(const ValueKey('settings-preset-ocean'));
    await tester.ensureVisible(ocean);
    await tester.tap(ocean);
    await tester.pump();

    final material = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(
      material.theme?.colorScheme.primary,
      AppThemeCatalog.resolve(
        preset: AppThemePreset.ocean,
        fontSize: AppFontSizePreference.standard,
        radius: AppRadiusPreference.medium,
      ).light.colors.primary,
    );
    expect(repository.saved.single.preset, AppThemePreset.ocean);
    expect(
      tester
          .widget<FSelectTileGroup<AppThemePreset>>(
            find.byType(FSelectTileGroup<AppThemePreset>),
          )
          .enabled,
      isFalse,
    );

    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('设置已保存'), findsOneWidget);
  });

  testWidgets('font size updates both theme layers and persists immediately', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await _pumpApp(tester, repository, translations);
    await _openSettings(tester);

    final extraLarge = find.byKey(
      const ValueKey('settings-font-size-extraLarge'),
    );
    await tester.ensureVisible(extraLarge);
    await tester.tap(extraLarge);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(SettingsPage));
    expect(FTheme.of(context).typography.body.sm.fontSize, 20);
    expect(Theme.of(context).textTheme.bodyMedium?.fontSize, 20);
    expect(repository.value.fontSize, AppFontSizePreference.extraLarge);
  });

  testWidgets('rolls back a failed change and reports it', (tester) async {
    final repository = _FakeRepository(saveError: StateError('write failed'));
    await _pumpApp(tester, repository, translations);
    await _openSettings(tester);

    final dark = find.byKey(const ValueKey('settings-brightness-dark'));
    await tester.ensureVisible(dark);
    await tester.tap(dark);
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );
    expect(find.text('设置保存失败，请重试。'), findsOneWidget);
  });

  testWidgets('shows a read error and retries the same state source', (
    tester,
  ) async {
    final repository = _FakeRepository(loadError: StateError('read failed'));
    await _pumpApp(tester, repository, translations);
    await _openSettings(tester);

    expect(find.text('无法读取本地外观偏好。'), findsOneWidget);
    repository
      ..loadError = null
      ..value = AppAppearancePreference.defaults.copyWith(
        preset: AppThemePreset.forest,
      );
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(find.text('无法读取本地外观偏好。'), findsNothing);
    expect(repository.loadCalls, 2);
  });

  testWidgets('withdraws privacy consent and reports cache size', (
    tester,
  ) async {
    await _pumpApp(tester, _FakeRepository(), translations);
    await _openSettings(tester);

    final privacy = find.byKey(const ValueKey('settings-privacy-consent'));
    await tester.ensureVisible(privacy);
    expect(find.text('0 B'), findsOneWidget);
    await tester.tap(privacy);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('settings-privacy-withdraw-confirm')),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前处于有限浏览模式。'), findsOneWidget);
  });
}

Future<void> _pumpApp(
  WidgetTester tester,
  AppAppearanceRepository repository,
  Map<String, dynamic> translations,
) async {
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
          startupAdRepositoryProvider.overrideWithValue(
            const DisabledStartupAdRepository(),
          ),
          pageConfigurationProvider.overrideWith(
            (ref) async => _testPageConfiguration,
          ),
        ],
        child: const Admin9App(),
      ),
    ),
  );
  for (
    var i = 0;
    i < 50 && find.byType(FBottomNavigationBar).evaluate().isEmpty;
    i++
  ) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

const _testPageConfiguration = PageConfiguration(
  schemaVersion: 1,
  revision: 1,
  navigation: [
    NavigationEntry(
      pageId: 'home',
      pageType: 'home',
      label: '首页',
      icon: 'home',
    ),
    NavigationEntry(
      pageId: 'components',
      pageType: 'components',
      label: '组件',
      icon: 'blocks',
    ),
    NavigationEntry(
      pageId: 'media',
      pageType: 'media',
      label: '媒体',
      icon: 'play',
    ),
    NavigationEntry(
      pageId: 'settings',
      pageType: 'settings',
      label: '设置',
      icon: 'settings',
    ),
  ],
  pages: {
    'home': PageDefinition(pageId: 'home', pageType: 'home', title: '首页'),
    'components': PageDefinition(
      pageId: 'components',
      pageType: 'components',
      title: '组件',
    ),
    'media': PageDefinition(pageId: 'media', pageType: 'media', title: '媒体'),
    'settings': PageDefinition(
      pageId: 'settings',
      pageType: 'settings',
      title: '设置',
    ),
  },
);

final class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      Map.of(translations);
}

Future<void> _openSettings(WidgetTester tester) async {
  final navigation = find.byType(FBottomNavigationBar);
  await tester.tap(find.descendant(of: navigation, matching: find.text('设置')));
  await tester.pumpAndSettle();
}

final class _FakeRepository implements AppAppearanceRepository {
  _FakeRepository({this.loadError, this.saveError, this.pendingSave});

  AppAppearancePreference value = AppAppearancePreference.defaults;
  Object? loadError;
  Object? saveError;
  Completer<void>? pendingSave;
  int loadCalls = 0;
  final List<AppAppearancePreference> saved = [];

  @override
  Future<AppAppearancePreference> load() async {
    loadCalls++;
    if (loadError case final error?) throw error;
    return value;
  }

  @override
  Future<void> save(AppAppearancePreference preference) async {
    saved.add(preference);
    if (saveError case final error?) throw error;
    if (pendingSave case final pending?) await pending.future;
    value = preference;
  }
}
