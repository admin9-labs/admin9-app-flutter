import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/features/settings/data/models/theme_preference.dart';
import 'package:admin9_app_flutter/features/settings/data/repositories/theme_preference_repository.dart';
import 'package:admin9_app_flutter/features/settings/presentation/providers/theme_preference_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _locale = Locale('zh', 'CN');
late Map<String, dynamic> _translations;

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    _translations = jsonDecode(
      await File('assets/translations/zh-CN.json').readAsString(),
    ) as Map<String, dynamic>;
  });

  testWidgets('shows a load error and retries the repository', (tester) async {
    final repository = _ControlledThemePreferenceRepository(
      ThemePreference.system,
      loadError: Exception('load failed'),
    );
    await _pumpApp(tester, repository);
    await _openSettings(tester);

    expect(find.text('无法读取本地主题偏好。'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(repository.loadCalls, 1);

    repository
      ..loadError = null
      ..preference = ThemePreference.light;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(repository.loadCalls, 2);
    expect(find.text('无法读取本地主题偏好。'), findsNothing);
    expect(find.text('浅色'), findsOneWidget);
    expect(_materialApp(tester).themeMode, ThemeMode.light);
  });

  testWidgets('keeps the old theme and shows a destructive toast on failure', (
    tester,
  ) async {
    final repository = _ControlledThemePreferenceRepository(
      ThemePreference.dark,
      saveError: Exception('save failed'),
    );
    await _pumpApp(tester, repository);
    await _openSettings(tester);

    expect(_materialApp(tester).themeMode, ThemeMode.dark);

    await tester.tap(find.text('浅色'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(repository.savedPreferences, [ThemePreference.light]);
    expect(_materialApp(tester).themeMode, ThemeMode.dark);
    expect(_selectGroup(tester).enabled, isTrue);

    final toast = find.ancestor(
      of: find.text('设置保存失败，请重试。'),
      matching: find.byType(FToast),
    );
    expect(toast, findsOneWidget);
    expect(tester.widget<FToast>(toast).variant, FToastVariant.destructive);
    _expectToastAboveNavigation(tester, toast);

    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('disables selection while saving and publishes success', (
    tester,
  ) async {
    final repository = _ControlledThemePreferenceRepository(
      ThemePreference.system,
    );
    await _pumpApp(tester, repository);
    await _openSettings(tester);

    final pendingSave = Completer<void>();
    repository.pendingSave = pendingSave;

    await tester.tap(find.text('浅色'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(_selectGroup(tester).enabled, isFalse);
    expect(_materialApp(tester).themeMode, ThemeMode.system);

    pendingSave.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(repository.savedPreferences, [ThemePreference.light]);
    expect(_selectGroup(tester).enabled, isTrue);
    expect(_materialApp(tester).themeMode, ThemeMode.light);
    expect(find.text('设置已保存'), findsOneWidget);
    _expectToastAboveNavigation(
      tester,
      find.ancestor(of: find.text('设置已保存'), matching: find.byType(FToast)),
    );

    await tester.pump(const Duration(seconds: 6));
  });
}

Future<void> _openSettings(WidgetTester tester) async {
  final navigation = find.byType(FBottomNavigationBar);
  await tester.tap(find.descendant(of: navigation, matching: find.text('设置')));
  await tester.pumpAndSettle();
}

Future<void> _pumpApp(
  WidgetTester tester,
  ThemePreferenceRepository repository,
) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [_locale],
      fallbackLocale: _locale,
      startLocale: _locale,
      path: 'assets/translations',
      assetLoader: _InMemoryAssetLoader(_translations),
      saveLocale: false,
      child: ProviderScope(
        overrides: [
          themePreferenceRepositoryProvider.overrideWithValue(repository),
        ],
        child: const Admin9App(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

MaterialApp _materialApp(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp));

FSelectTileGroup<ThemePreference> _selectGroup(WidgetTester tester) =>
    tester.widget<FSelectTileGroup<ThemePreference>>(
      find.byType(FSelectTileGroup<ThemePreference>),
    );

void _expectToastAboveNavigation(WidgetTester tester, Finder toast) {
  final navigation = find.byType(FBottomNavigationBar);
  expect(toast, findsOneWidget);
  expect(
    tester.getBottomLeft(toast).dy,
    lessThanOrEqualTo(tester.getTopLeft(navigation).dy),
  );
}

final class _ControlledThemePreferenceRepository
    implements ThemePreferenceRepository {
  _ControlledThemePreferenceRepository(
    this.preference, {
    this.loadError,
    this.saveError,
  });

  ThemePreference preference;
  Object? loadError;
  Object? saveError;
  Completer<void>? pendingSave;
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
    if (pendingSave case final pending?) {
      await pending.future;
    }
    preference = value;
  }
}

final class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      Future.value(Map.of(translations));
}
