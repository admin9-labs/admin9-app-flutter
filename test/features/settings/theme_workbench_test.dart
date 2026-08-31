import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui show TextDirection;

import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_provider.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_repository.dart';
import 'package:admin9_app_flutter/app/appearance/app_theme_catalog.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/concepts/themes/themes_page.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
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

  testWidgets('C01/G03 cover Theme axes, style delta, and replacement', (
    tester,
  ) async {
    final repository = _FakeRepository();
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _pumpPage(tester, repository, translations);

    final base = lightTheme.buttonStyles.primary.md;
    final delta = tester.widget<FButton>(
      find.byKey(const ValueKey('theme-style-delta')),
    );
    final deltaStyle = delta.style(base);
    expect(
      deltaStyle.contentStyle.padding.resolve(ui.TextDirection.ltr).left,
      base.contentStyle.padding.resolve(ui.TextDirection.ltr).left + 8,
    );
    final replacement = tester.widget<FButton>(
      find.byKey(const ValueKey('theme-style-replacement')),
    );
    expect(replacement.variant, FButtonVariant.destructive);
    expect(replacement.size, FButtonSizeVariant.lg);
    expect(replacement.style(base), lightTheme.buttonStyles.outline.sm);
    expect(
      base.decoration.resolve({FTappableVariant.selected}),
      isNot(base.decoration.resolve({})),
    );

    final forest = find.byKey(const ValueKey('theme-preset-forest'));
    await tester.ensureVisible(forest);
    await tester.tap(forest);
    await tester.pumpAndSettle();

    expect(repository.value.preset, AppThemePreset.forest);

    final extraLarge = find.byKey(const ValueKey('theme-font-size-extraLarge'));
    await tester.ensureVisible(extraLarge);
    await tester.tap(extraLarge);
    await tester.pumpAndSettle();

    expect(repository.value.fontSize, AppFontSizePreference.extraLarge);
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('playground-parameter-summary')),
          )
          .data,
      contains('preset=forest'),
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('playground-parameter-summary')),
          )
          .data,
      contains('fontSize=extraLarge'),
    );
    expect(find.byType(AGrid), findsOneWidget);
    expect(find.byType(FTextField), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    final copy = find.byKey(const ValueKey('playground-copy'));
    await tester.ensureVisible(copy);
    await tester.pumpAndSettle();
    await tester.tap(copy);
    await tester.pump(const Duration(milliseconds: 200));
    expect(copied, contains('AppThemePreset.forest'));
    expect(copied, contains('AppFontSizePreference.extraLarge'));
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('reset restores every axis and the dialog is interactive', (
    tester,
  ) async {
    final repository = _FakeRepository(
      value: const AppAppearancePreference(
        brightness: AppBrightnessPreference.dark,
        preset: AppThemePreset.ocean,
        fontSize: AppFontSizePreference.extraLarge,
        radius: AppRadiusPreference.large,
      ),
    );
    await _pumpPage(tester, repository, translations);

    final dialog = find.text(
      'examples.foundation.concepts.themes.open_dialog'.tr(),
    );
    await tester.ensureVisible(dialog);
    await tester.tap(dialog);
    await tester.pumpAndSettle();
    expect(find.byType(FDialog), findsOneWidget);
    await tester.tap(find.text('common.confirm'.tr()).last);
    await tester.pumpAndSettle();

    final previewButton = find.byKey(const ValueKey('theme-preview-primary'));
    await tester.ensureVisible(previewButton);
    await tester.tap(previewButton);
    await tester.pump();
    expect(tester.widget<FButton>(previewButton).selected, isFalse);

    final reset = find.byKey(const ValueKey('playground-reset'));
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(repository.value, AppAppearancePreference.defaults);
    expect(tester.widget<FButton>(previewButton).selected, isTrue);
  });

  testWidgets('clipboard failure shows destructive copy feedback', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          throw PlatformException(code: 'clipboard-unavailable');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _pumpPage(tester, _FakeRepository(), translations);

    final copy = find.byKey(const ValueKey('playground-copy'));
    await tester.ensureVisible(copy);
    await tester.tap(copy);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('复制失败'), findsOneWidget);
    expect(find.text('未能写入剪贴板，请重试。'), findsOneWidget);
    expect(
      tester.widget<FToast>(find.byType(FToast)).variant,
      FToastVariant.destructive,
    );
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('save failure rolls back and remains visible', (tester) async {
    final repository = _FakeRepository(saveError: StateError('write failed'));
    await _pumpPage(tester, repository, translations);

    final ocean = find.byKey(const ValueKey('theme-preset-ocean'));
    await tester.ensureVisible(ocean);
    await tester.tap(ocean);
    await tester.pumpAndSettle();

    expect(repository.value, AppAppearancePreference.defaults);
    expect(find.text('设置保存失败，请重试。'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('workbench has no overflow at 320 width and 2x text', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpPage(
      tester,
      _FakeRepository(
        value: AppAppearancePreference.defaults.copyWith(
          fontSize: AppFontSizePreference.extraLarge,
        ),
      ),
      translations,
      size: const Size(320, 700),
    );

    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  AppAppearanceRepository repository,
  Map<String, dynamic> translations, {
  Size size = const Size(390, 844),
}) async {
  tester.view
    ..physicalSize = size
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
        child: const _ThemePageHost(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _ThemePageHost extends ConsumerWidget {
  const _ThemePageHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference =
        ref.watch(appAppearanceProvider).value?.preference ??
        AppAppearancePreference.defaults;
    final theme = AppThemeCatalog.resolve(
      preset: preference.preset,
      fontSize: preference.fontSize,
      radius: preference.radius,
    ).light;
    return MaterialApp(
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: [
        ...context.localizationDelegates,
        ...GlobalMaterialLocalizations.delegates,
        FLocalizations.delegate,
      ],
      theme: theme.toApproximateMaterialTheme(),
      home: FTheme(
        data: theme,
        child: FToaster(child: const ThemesPage()),
      ),
    );
  }
}

final class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      Map.of(translations);
}

final class _FakeRepository implements AppAppearanceRepository {
  _FakeRepository({
    this.value = AppAppearancePreference.defaults,
    this.saveError,
  });

  AppAppearancePreference value;
  final Object? saveError;

  @override
  Future<AppAppearancePreference> load() async => value;

  @override
  Future<void> save(AppAppearancePreference preference) async {
    if (saveError case final error?) throw error;
    value = preference;
  }
}
