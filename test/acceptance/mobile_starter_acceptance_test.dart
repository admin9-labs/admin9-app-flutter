import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/routing/starter_shell_page.dart';
import 'package:admin9_app_flutter/features/content/presentation/pages/content_page.dart';
import 'package:admin9_app_flutter/features/feedback/presentation/pages/dialogs_page.dart';
import 'package:admin9_app_flutter/features/feedback/presentation/pages/feedback_page.dart';
import 'package:admin9_app_flutter/features/feedback/presentation/pages/sheets_page.dart';
import 'package:admin9_app_flutter/features/feedback/presentation/pages/toasts_tooltips_page.dart';
import 'package:admin9_app_flutter/features/forms/presentation/pages/forms_page.dart';
import 'package:admin9_app_flutter/features/foundation/presentation/pages/foundation_page.dart';
import 'package:admin9_app_flutter/features/settings/data/models/theme_preference.dart';
import 'package:admin9_app_flutter/features/settings/data/repositories/theme_preference_repository.dart';
import 'package:admin9_app_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:admin9_app_flutter/features/settings/presentation/providers/theme_preference_provider.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' as material_ui;
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

  for (final scenario in [
    const _ThemeScenario(
      name: 'explicit light ignores a dark platform',
      preference: ThemePreference.light,
      platformBrightness: Brightness.dark,
      expectedBrightness: Brightness.light,
    ),
    const _ThemeScenario(
      name: 'explicit dark ignores a light platform',
      preference: ThemePreference.dark,
      platformBrightness: Brightness.light,
      expectedBrightness: Brightness.dark,
    ),
    const _ThemeScenario(
      name: 'system follows a light platform',
      preference: ThemePreference.system,
      platformBrightness: Brightness.light,
      expectedBrightness: Brightness.light,
    ),
    const _ThemeScenario(
      name: 'system follows a dark platform',
      preference: ThemePreference.system,
      platformBrightness: Brightness.dark,
      expectedBrightness: Brightness.dark,
    ),
  ]) {
    testWidgets('theme mapping: ${scenario.name}', (tester) async {
      await _pumpStarter(
        tester,
        preference: scenario.preference,
        platformBrightness: scenario.platformBrightness,
      );

      final shell = find.byType(StarterShellPage);
      final context = tester.element(shell);
      final foruiTheme = tester.widget<FTheme>(
        find.ancestor(of: shell, matching: find.byType(FTheme)),
      );
      final expectedTheme = scenario.expectedBrightness == Brightness.light
          ? lightTheme
          : darkTheme;

      expect(
        material_ui.Theme.of(context).brightness,
        scenario.expectedBrightness,
      );
      expect(
        foruiTheme.data.colors.background,
        expectedTheme.colors.background,
      );
      expect(
        foruiTheme.data.colors.foreground,
        expectedTheme.colors.foreground,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final scenario in [
    const (
      size: Size(320, 844),
      preference: ThemePreference.light,
      platformBrightness: Brightness.dark,
      bottomInset: 24.0,
    ),
    const (
      size: Size(390, 844),
      preference: ThemePreference.dark,
      platformBrightness: Brightness.light,
      bottomInset: 34.0,
    ),
  ]) {
    testWidgets(
      'bottom navigation geometry at ${scenario.size.width.toInt()}px',
      (tester) async {
        await _pumpStarter(
          tester,
          preference: scenario.preference,
          platformBrightness: scenario.platformBrightness,
          size: scenario.size,
          viewPadding: FakeViewPadding(top: 24, bottom: scenario.bottomInset),
        );

        final bar = find.byType(FBottomNavigationBar);
        final items = find.byType(FBottomNavigationBarItem);
        final barRect = tester.getRect(bar);
        final itemRects = [
          for (var index = 0; index < 5; index++)
            tester.getRect(items.at(index)),
        ];
        final labelRects = [
          for (final label in ['基础', '表单', '内容', '反馈', '设置'])
            tester.getRect(
              find.descendant(of: bar, matching: find.text(label)),
            ),
        ];
        final selectedStyle = DefaultTextStyle.of(
          tester.element(find.descendant(of: bar, matching: find.text('基础'))),
        ).style;
        final unselectedStyle = DefaultTextStyle.of(
          tester.element(find.descendant(of: bar, matching: find.text('表单'))),
        ).style;

        expect(
          tester.widget<FBottomNavigationBar>(bar).safeAreaBottom,
          isFalse,
        );
        expect(items, findsNWidgets(5));
        for (var index = 1; index < itemRects.length; index++) {
          expect(itemRects[index].width, closeTo(itemRects.first.width, 0.01));
          expect(
            itemRects[index].left,
            closeTo(itemRects[index - 1].right, 0.01),
          );
          expect(labelRects[index].top, closeTo(labelRects.first.top, 0.01));
          expect(
            labelRects[index].bottom,
            closeTo(labelRects.first.bottom, 0.01),
          );
        }
        for (var index = 0; index < itemRects.length; index++) {
          expect(
            labelRects[index].left,
            greaterThanOrEqualTo(itemRects[index].left),
          );
          expect(
            labelRects[index].right,
            lessThanOrEqualTo(itemRects[index].right),
          );
          expect(
            labelRects[index].bottom,
            lessThanOrEqualTo(itemRects[index].bottom),
          );
        }
        expect(selectedStyle.color, isNot(unselectedStyle.color));
        expect(
          barRect.bottom - itemRects.first.bottom,
          closeTo(5 + (scenario.bottomInset * 2 / 3), 0.01),
        );
        expect(
          tester.getRect(find.byType(FoundationPage)).bottom,
          lessThanOrEqualTo(barRect.top),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final scenario in [
    const _LayoutScenario(
      size: Size(320, 844),
      textScale: 2,
      viewPadding: FakeViewPadding(top: 24, bottom: 34),
      viewInsets: FakeViewPadding.zero,
    ),
    const _LayoutScenario(
      size: Size(360, 800),
      textScale: 1.3,
      viewPadding: FakeViewPadding(top: 24, bottom: 24),
      viewInsets: FakeViewPadding(bottom: 240),
    ),
    const _LayoutScenario(
      size: Size(390, 844),
      textScale: 1,
      viewPadding: FakeViewPadding(top: 24, bottom: 34),
      viewInsets: FakeViewPadding.zero,
    ),
  ]) {
    testWidgets('five destinations fit ${scenario.size.width.toInt()}px at '
        '${scenario.textScale}x text', (tester) async {
      await _pumpStarter(
        tester,
        size: scenario.size,
        textScale: scenario.textScale,
        viewPadding: scenario.viewPadding,
        viewInsets: scenario.viewInsets,
      );

      expect(find.byType(FoundationPage), findsOneWidget);
      expect(find.text('能力目录的移动端交互示例。'), findsOneWidget);
      _expectInsets(tester, find.byType(FoundationPage), scenario);
      _expectResponsiveSafeArea(tester);
      expect(tester.takeException(), isNull);

      await _selectDestination(tester, '表单');
      expect(find.byType(FormsPage), findsOneWidget);
      expect(find.text('能力目录的移动端交互示例。'), findsOneWidget);
      _expectInsets(tester, find.byType(FormsPage), scenario);
      expect(tester.takeException(), isNull);

      await _selectDestination(tester, '内容');
      expect(find.byType(ContentPage), findsOneWidget);
      expect(find.text('能力目录的移动端交互示例。'), findsOneWidget);
      _expectInsets(tester, find.byType(ContentPage), scenario);
      expect(tester.takeException(), isNull);

      await _selectDestination(tester, '反馈');
      expect(find.byType(FeedbackPage), findsOneWidget);
      _expectInsets(tester, find.byType(FeedbackPage), scenario);
      expect(tester.takeException(), isNull);

      await _selectDestination(tester, '设置');
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('选择应用使用系统、浅色或暗色主题。'), findsOneWidget);
      _expectInsets(tester, find.byType(SettingsPage), scenario);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dialog and sheet restore focus to their trigger', (
    tester,
  ) async {
    await _pumpStarter(tester);
    await _selectDestination(tester, '反馈');

    await _openFeedbackDetail(tester, '打开对话框', DialogsPage);
    final dialogTrigger = find.text('打开对话框');
    final dialogFocus = Focus.of(tester.element(dialogTrigger));
    dialogFocus.requestFocus();
    await tester.pump();
    expect(dialogFocus.hasFocus, isTrue);

    await tester.tap(dialogTrigger);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('确认操作需要确认。'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('确认操作需要确认。'), findsNothing);
    expect(dialogFocus.hasFocus, isTrue);
    expect(tester.takeException(), isNull);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    await _openFeedbackDetail(tester, '打开面板', SheetsPage);
    final sheetTrigger = find.text('打开模态面板');
    final sheetFocus = Focus.of(tester.element(sheetTrigger));
    sheetFocus.requestFocus();
    await tester.pump();
    expect(sheetFocus.hasFocus, isTrue);

    await tester.tap(sheetTrigger);
    await tester.pumpAndSettle();
    expect(find.text('模态面板操作需要确认。'), findsOneWidget);
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(find.text('模态面板操作需要确认。'), findsNothing);
    expect(sheetFocus.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a toast does not steal focus from its trigger', (tester) async {
    await _pumpStarter(tester);
    await _selectDestination(tester, '反馈');
    await _openFeedbackDetail(tester, '打开提示条与工具提示', ToastsTooltipsPage);

    final trigger = find.text('显示');
    final focus = Focus.of(tester.element(trigger));
    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isTrue);

    await tester.tap(trigger);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('操作成功'), findsOneWidget);
    expect(focus.hasFocus, isTrue);
    _expectToastAboveNavigation(tester, find.text('操作成功'));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('关闭'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('操作成功'), findsNothing);
  });
}

Future<void> _pumpStarter(
  WidgetTester tester, {
  ThemePreference preference = ThemePreference.system,
  Brightness platformBrightness = Brightness.light,
  Size size = const Size(390, 844),
  double textScale = 1,
  FakeViewPadding viewPadding = FakeViewPadding.zero,
  FakeViewPadding viewInsets = FakeViewPadding.zero,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..viewPadding = viewPadding
    ..viewInsets = viewInsets;
  tester.platformDispatcher
    ..textScaleFactorTestValue = textScale
    ..platformBrightnessTestValue = platformBrightness;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

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
          themePreferenceRepositoryProvider.overrideWithValue(
            _FakeThemePreferenceRepository(preference),
          ),
        ],
        child: const Admin9App(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectDestination(WidgetTester tester, String label) async {
  final navigation = find.byType(FBottomNavigationBar);
  await tester.tap(find.descendant(of: navigation, matching: find.text(label)));
  await tester.pumpAndSettle();
}

Future<void> _openFeedbackDetail(
  WidgetTester tester,
  String catalogLabel,
  Type pageType,
) async {
  final entry = find.text(catalogLabel);
  await tester.ensureVisible(entry);
  await tester.tap(entry);
  await tester.pumpAndSettle();
  expect(find.byType(pageType), findsOneWidget);
}

void _expectInsets(WidgetTester tester, Finder page, _LayoutScenario scenario) {
  final mediaQuery = MediaQuery.of(tester.element(page));
  expect(mediaQuery.viewPadding.top, scenario.viewPadding.top);
  expect(mediaQuery.viewPadding.bottom, scenario.viewPadding.bottom);
  expect(mediaQuery.viewInsets.bottom, scenario.viewInsets.bottom);
}

void _expectResponsiveSafeArea(WidgetTester tester) {
  final body = find.byType(ResponsivePageBody);
  expect(body, findsOneWidget);
  final safeArea = tester.widget<SafeArea>(
    find.descendant(of: body, matching: find.byType(SafeArea)),
  );
  expect(safeArea.top, isFalse);
  expect(safeArea.bottom, isTrue);
}

void _expectToastAboveNavigation(WidgetTester tester, Finder content) {
  final toast = find.ancestor(of: content, matching: find.byType(FToast));
  final navigation = find.byType(FBottomNavigationBar);
  expect(toast, findsOneWidget);
  expect(
    tester.getBottomLeft(toast).dy,
    lessThanOrEqualTo(tester.getTopLeft(navigation).dy),
  );
}

final class _FakeThemePreferenceRepository
    implements ThemePreferenceRepository {
  _FakeThemePreferenceRepository(this.preference);

  ThemePreference preference;

  @override
  Future<ThemePreference> load() async => preference;

  @override
  Future<void> save(ThemePreference value) async {
    preference = value;
  }
}

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      Future.value(Map.of(translations));
}

final class _ThemeScenario {
  const _ThemeScenario({
    required this.name,
    required this.preference,
    required this.platformBrightness,
    required this.expectedBrightness,
  });

  final String name;
  final ThemePreference preference;
  final Brightness platformBrightness;
  final Brightness expectedBrightness;
}

final class _LayoutScenario {
  const _LayoutScenario({
    required this.size,
    required this.textScale,
    required this.viewPadding,
    required this.viewInsets,
  });

  final Size size;
  final double textScale;
  final FakeViewPadding viewPadding;
  final FakeViewPadding viewInsets;
}
