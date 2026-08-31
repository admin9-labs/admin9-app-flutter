import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_provider.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_repository.dart';
import 'package:admin9_app_flutter/app/appearance/app_theme_catalog.dart';
import 'package:admin9_app_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
