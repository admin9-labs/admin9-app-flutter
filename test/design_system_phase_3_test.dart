import 'dart:async';
import 'dart:ui' as ui;

import 'package:admin9_app_flutter/admin9_ui.dart';
import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/app_route_names.dart';
import 'package:admin9_app_flutter/app/brand/app_brand_theme.dart';
import 'package:admin9_app_flutter/core/design_system/components/app_feedback.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_theme.dart';
import 'package:admin9_app_flutter/core/preferences/app_preferences.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/appearance_controller.dart';
import 'package:admin9_app_flutter/ui/features/settings/views/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppSwitch maps platforms and dispatches one controlled change', (
    tester,
  ) async {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      var calls = 0;
      bool? nextValue;
      await _pumpDesign(
        tester,
        platform: platform,
        child: AppSwitch(
          label: '高对比度',
          value: false,
          onChanged: (value) {
            calls += 1;
            nextValue = value;
          },
        ),
      );
      expect(
        find.byType(platform == TargetPlatform.iOS ? CupertinoSwitch : Switch),
        findsOneWidget,
      );
      await tester.tap(find.text('高对比度'));
      await tester.pump();
      expect(calls, 1);
      expect(nextValue, isTrue);
      final control = platform == TargetPlatform.iOS
          ? find.byType(CupertinoListTile)
          : find.byType(SwitchListTile);
      expect(
        tester.getSize(control).shortestSide,
        greaterThanOrEqualTo(platform == TargetPlatform.iOS ? 44 : 48),
      );
    }
  });

  testWidgets('AppSwitch disabled state never dispatches', (tester) async {
    var calls = 0;
    await _pumpDesign(
      tester,
      platform: TargetPlatform.android,
      child: AppSwitch(
        label: '禁用设置',
        value: false,
        enabled: false,
        onChanged: (_) => calls += 1,
      ),
    );
    await tester.tap(find.text('禁用设置'));
    expect(calls, 0);
  });

  testWidgets(
    'AppListTile moves current value below the label under pressure',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 720);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      await _pumpDesign(
        tester,
        platform: TargetPlatform.iOS,
        textScaler: TextScaler.linear(1.24),
        child: const AppListTile(
          title: 'App 字号',
          currentValue: '特大',
          disclosure: true,
        ),
      );
      expect(
        tester.getTopLeft(find.text('特大')).dy,
        greaterThan(tester.getTopLeft(find.text('App 字号')).dy),
      );
      expect(
        tester
            .renderObject<RenderParagraph>(find.text('App 字号'))
            .didExceedMaxLines,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('iOS switch label grows instead of truncating under pressure', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await _pumpDesign(
      tester,
      platform: TargetPlatform.iOS,
      textScaler: TextScaler.linear(3.72),
      child: AppSwitch(label: '高对比度', value: false, onChanged: (_) {}),
    );
    expect(
      tester.renderObject<RenderParagraph>(find.text('高对比度')).didExceedMaxLines,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppSection and choice list use unique platform mappings', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      var selected = AppThemePreference.system;
      await _pumpDesign(
        tester,
        platform: platform,
        child: AppSingleChoiceList<AppThemePreference>(
          title: '主题',
          value: selected,
          choices: const [
            AppChoice(value: AppThemePreference.system, label: '跟随系统'),
            AppChoice(value: AppThemePreference.dark, label: '深色'),
          ],
          onChanged: (value) => selected = value,
        ),
      );
      if (platform == TargetPlatform.iOS) {
        expect(find.byType(CupertinoListSection), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
      } else {
        expect(find.byType(RadioGroup<AppThemePreference>), findsOneWidget);
        expect(
          find.byType(RadioListTile<AppThemePreference>),
          findsNWidgets(2),
        );
      }
      final selectedSemantics = tester.getSemantics(
        find.bySemanticsLabel('跟随系统'),
      );
      if (platform == TargetPlatform.iOS) {
        expect(
          selectedSemantics,
          matchesSemantics(
            label: '跟随系统',
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasSelectedState: true,
            isSelected: true,
            hasTapAction: true,
          ),
        );
      } else {
        expect(
          selectedSemantics.flagsCollection.isChecked,
          ui.CheckedState.isTrue,
        );
      }
      await tester.tap(find.text('深色'));
      await tester.pump();
      expect(selected, AppThemePreference.dark);
    }
    semantics.dispose();
  });

  testWidgets('settings task persists across App host reconstruction', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'admin9.privacy.accepted': true});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('account-page-list')),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-theme')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('深色'));
    await tester.pumpAndSettle();
    expect(preferences.getString('admin9.appearance.theme_mode'), 'dark');
    Navigator.of(tester.element(find.text('主题').last)).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-font-scale')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('特大'));
    await tester.pumpAndSettle();
    expect(preferences.getString('admin9.appearance.font_scale'), 'extraLarge');
    Navigator.of(tester.element(find.text('App 字号').last)).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('高对比度'));
    await tester.pumpAndSettle();
    expect(preferences.getBool('admin9.accessibility.high_contrast'), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();
    final restored = tester
        .element(find.byType(MaterialApp))
        .read<AppAppearanceController>()
        .appearance;
    expect(restored.theme, AppThemePreference.dark);
    expect(restored.fontScale, AppFontScale.extraLarge);
    expect(restored.highContrast, isTrue);
  });

  test('rapid appearance writes are serialized and last choice wins', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppearanceController(AppPreferences(preferences));
    final first = controller.setTheme(AppThemePreference.light);
    final second = controller.setTheme(AppThemePreference.dark);
    await Future.wait([first, second]);
    expect(controller.appearance.theme, AppThemePreference.dark);
    expect(preferences.getString('admin9.appearance.theme_mode'), 'dark');
    expect(controller.persistenceFailed, isFalse);
  });

  test('appearance persistence failures become observable state', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppearanceController(
      _FailingAppPreferences(preferences),
    );
    await controller.setTheme(AppThemePreference.dark);
    expect(controller.appearance.theme, AppThemePreference.dark);
    expect(controller.persistenceFailed, isTrue);
    await controller.setHighContrast(true);
    expect(controller.persistenceFailed, isTrue);
    await controller.retryPersistence();
    expect(controller.persistenceFailed, isFalse);
    expect(preferences.getString('admin9.appearance.theme_mode'), 'dark');
  });

  test('stale retry cannot overwrite a newer preference value', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controlled = _ControlledThemePreferences(preferences);
    final controller = AppearanceController(controlled);

    await controller.setTheme(AppThemePreference.dark);
    expect(controller.persistenceFailed, isTrue);

    final latestWrite = controller.setTheme(AppThemePreference.light);
    final staleRetry = controller.retryPersistence();
    controlled.completeLatestWrite();
    await Future.wait([latestWrite, staleRetry]);

    expect(controller.appearance.theme, AppThemePreference.light);
    expect(controller.persistenceFailed, isFalse);
    expect(preferences.getString('admin9.appearance.theme_mode'), 'light');
    expect(controlled.themeWriteCalls, 2);
  });

  testWidgets('settings retry feedback persists across repeated failures', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppearanceController(
      _FailingAppPreferences(preferences, themeFailures: 2),
    );
    final feedback = AppFeedbackPresenterController();
    final navigatorKey = GlobalKey<NavigatorState>();
    final resolved = AppTheme.resolve(
      brightness: Brightness.light,
      platform: TargetPlatform.android,
      highContrast: false,
      reduceMotion: false,
      boldText: false,
      brandPrimary: appBrandTheme.primaryLight,
      brandSecondary: appBrandTheme.secondaryLight,
    );
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        theme: resolved.material,
        home: AppDesignScope(
          tokens: resolved.tokens,
          child: ChangeNotifierProvider<AppAppearanceController>.value(
            value: controller,
            child: AppFeedback(
              controller: feedback,
              navigatorKey: navigatorKey,
              child: const SettingsThemePage(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('深色'));
    await tester.pumpAndSettle();
    expect(find.text('设置暂未保存。'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(controller.persistenceFailed, isTrue);
    expect(find.text('设置暂未保存。'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(controller.persistenceFailed, isFalse);
    expect(find.text('设置暂未保存。'), findsNothing);
    expect(preferences.getString('admin9.appearance.theme_mode'), 'dark');
  });

  testWidgets('failed choice remains recoverable after its route is popped', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final delayed = _DelayedFailurePreferences(preferences);
    final controller = AppearanceController(delayed);
    final feedback = AppFeedbackPresenterController();
    final navigatorKey = GlobalKey<NavigatorState>();
    final resolved = AppTheme.resolve(
      brightness: Brightness.light,
      platform: TargetPlatform.iOS,
      highContrast: false,
      reduceMotion: false,
      boldText: false,
      brandPrimary: appBrandTheme.primaryLight,
      brandSecondary: appBrandTheme.secondaryLight,
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<AppAppearanceController>.value(
        value: controller,
        child: AppDesignScope(
          tokens: resolved.tokens,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            theme: resolved.material,
            routes: {AppRoutes.theme: (_) => const SettingsThemePage()},
            home: AppFeedback(
              controller: feedback,
              navigatorKey: navigatorKey,
              child: const SettingsPage(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('settings-theme')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('深色'));
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    delayed.failFirstWrite();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-retry-persistence')), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings-retry-persistence')));
    await tester.pumpAndSettle();
    expect(controller.persistenceFailed, isFalse);
    expect(find.byKey(const Key('settings-retry-persistence')), findsNothing);
    expect(preferences.getString('admin9.appearance.theme_mode'), 'dark');
  });

  for (final row in _matrix) {
    testWidgets('Phase 3 A-L settings row ${row.name}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = row.size;
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      SharedPreferences.setMockInitialValues({});
      var listCalls = 0;
      var switchCalls = 0;
      await _pumpDesign(
        tester,
        platform: row.platform,
        brightness: row.brightness,
        highContrast: row.highContrast,
        textScaler: TextScaler.linear(row.systemScale * row.appScale),
        child: Scaffold(
          body: ListView(
            key: const Key('phase3-matrix-list'),
            children: [
              AppSection(
                title: '用于验证分组标题在最长中文内容下仍然完整可达',
                footer: '分组说明会随内容增长，并且不能遮挡最后一个操作入口。',
                children: [
                  AppListTile(
                    key: const Key('matrix-list-tile'),
                    title: '这是用于验证最长中文设置名称与尾部当前值重排的项目',
                    subtitle: '说明文字允许增长，不截断关键状态。',
                    currentValue: '这是一个需要移到主标签下方的较长当前值',
                    disclosure: true,
                    onTap: () => listCalls += 1,
                  ),
                  AppListTile(
                    key: const Key('matrix-selected-tile'),
                    title: '当前已选择的设置项目',
                    selected: true,
                    onTap: () => listCalls += 1,
                  ),
                  AppSwitch(
                    key: const Key('matrix-switch'),
                    label: '这是用于验证最长中文布尔设置名称的高对比度偏好',
                    value: true,
                    onChanged: (_) => switchCalls += 1,
                  ),
                  const AppSwitch(
                    key: Key('matrix-disabled-switch'),
                    label: '不可修改的系统辅助功能要求',
                    value: true,
                    enabled: false,
                    onChanged: _testBoolNoop,
                  ),
                ],
              ),
              const SizedBox(key: Key('phase3-matrix-end'), height: 24),
            ],
          ),
        ),
      );
      expect(find.byType(AppSection), findsOneWidget);
      expect(find.byType(AppSwitch), findsNWidgets(2));
      expect(find.byType(AppListTile), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      final minimum = row.platform == TargetPlatform.iOS ? 44.0 : 48.0;
      for (final key in const [
        Key('matrix-list-tile'),
        Key('matrix-selected-tile'),
        Key('matrix-switch'),
        Key('matrix-disabled-switch'),
      ]) {
        expect(
          tester.getSize(find.byKey(key)).height,
          greaterThanOrEqualTo(minimum),
        );
      }
      expect(
        tester
            .renderObject<RenderParagraph>(
              find.text('这是用于验证最长中文设置名称与尾部当前值重排的项目'),
            )
            .didExceedMaxLines,
        isFalse,
      );
      expect(
        tester
            .getSemantics(find.byKey(const Key('matrix-selected-tile')))
            .flagsCollection
            .isSelected,
        ui.Tristate.isTrue,
      );
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('这是用于验证最长中文布尔设置名称的高对比度偏好'))
            .flagsCollection
            .isToggled,
        ui.Tristate.isTrue,
      );
      await tester.ensureVisible(find.byKey(const Key('matrix-list-tile')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('matrix-list-tile')));
      await tester.ensureVisible(find.byKey(const Key('matrix-switch')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('matrix-switch')));
      await tester.pump();
      expect(listCalls, 1);
      expect(switchCalls, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(FocusManager.instance.primaryFocus, isNotNull);
      await tester.scrollUntilVisible(
        find.byKey(const Key('phase3-matrix-end')),
        300,
        scrollable: find.descendant(
          of: find.byKey(const Key('phase3-matrix-list')),
          matching: find.byType(Scrollable),
        ),
      );
      final viewportBottom = tester.getBottomRight(find.byType(Scaffold)).dy;
      expect(
        tester.getBottomRight(find.byKey(const Key('phase3-matrix-end'))).dy,
        lessThanOrEqualTo(viewportBottom),
      );
      expect(tester.takeException(), isNull);

      await _pumpDesign(
        tester,
        platform: row.platform,
        brightness: row.brightness,
        highContrast: row.highContrast,
        textScaler: TextScaler.linear(row.systemScale * row.appScale),
        child: AppSingleChoiceList<AppThemePreference>(
          title: '主题',
          value: AppThemePreference.dark,
          choices: const [
            AppChoice(value: AppThemePreference.system, label: '跟随系统'),
            AppChoice(
              value: AppThemePreference.dark,
              label: '始终使用深色外观并保持系统辅助设置优先',
            ),
          ],
          onChanged: (_) {},
        ),
      );
      for (final label in const ['跟随系统', '始终使用深色外观并保持系统辅助设置优先']) {
        final choice = find.bySemanticsLabel(label);
        expect(tester.getSize(choice).height, greaterThanOrEqualTo(minimum));
      }
      expect(
        tester
            .renderObject<RenderParagraph>(find.text('始终使用深色外观并保持系统辅助设置优先'))
            .didExceedMaxLines,
        isFalse,
      );
      final choiceFlags = tester
          .getSemantics(find.bySemanticsLabel('始终使用深色外观并保持系统辅助设置优先'))
          .flagsCollection;
      if (row.platform == TargetPlatform.iOS) {
        expect(choiceFlags.isSelected, ui.Tristate.isTrue);
      } else {
        expect(choiceFlags.isChecked, ui.CheckedState.isTrue);
      }
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _pumpDesign(
  WidgetTester tester, {
  required TargetPlatform platform,
  required Widget child,
  Brightness brightness = Brightness.light,
  bool highContrast = false,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  final resolved = AppTheme.resolve(
    brightness: brightness,
    platform: platform,
    highContrast: highContrast,
    reduceMotion: false,
    boldText: false,
    brandPrimary: brightness == Brightness.dark
        ? appBrandTheme.primaryDark
        : appBrandTheme.primaryLight,
    brandSecondary: brightness == Brightness.dark
        ? appBrandTheme.secondaryDark
        : appBrandTheme.secondaryLight,
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: resolved.material,
      home: MediaQuery(
        data: MediaQueryData(
          size: tester.view.physicalSize,
          devicePixelRatio: 1,
          textScaler: textScaler,
          highContrast: highContrast,
        ),
        child: Theme(
          data: resolved.material,
          child: AppDesignScope(
            tokens: resolved.tokens,
            child: Material(child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

final _matrix = <_MatrixRow>[
  _MatrixRow('A', TargetPlatform.android, Size(320, 720), 1, 1),
  _MatrixRow('B', TargetPlatform.iOS, Size(320, 720), 1, 1.24),
  _MatrixRow(
    'C',
    TargetPlatform.android,
    Size(360, 800),
    1,
    1.12,
    brightness: Brightness.dark,
  ),
  _MatrixRow(
    'D',
    TargetPlatform.iOS,
    Size(360, 800),
    1,
    1,
    brightness: Brightness.dark,
  ),
  _MatrixRow('E', TargetPlatform.android, Size(390, 844), 1, 1.24),
  _MatrixRow(
    'F',
    TargetPlatform.iOS,
    Size(390, 844),
    1,
    1.24,
    brightness: Brightness.dark,
  ),
  _MatrixRow(
    'G',
    TargetPlatform.android,
    Size(600, 960),
    1,
    1,
    brightness: Brightness.dark,
    highContrast: true,
  ),
  _MatrixRow(
    'H',
    TargetPlatform.iOS,
    Size(600, 960),
    1,
    1.12,
    highContrast: true,
  ),
  _MatrixRow('I', TargetPlatform.android, Size(844, 390), 1, 1.12),
  _MatrixRow(
    'J',
    TargetPlatform.iOS,
    Size(844, 390),
    1,
    1.24,
    brightness: Brightness.dark,
  ),
  _MatrixRow(
    'K',
    TargetPlatform.android,
    Size(390, 844),
    2,
    1.24,
    highContrast: true,
  ),
  _MatrixRow(
    'L',
    TargetPlatform.iOS,
    Size(390, 844),
    3,
    1.24,
    brightness: Brightness.dark,
    highContrast: true,
  ),
];

class _MatrixRow {
  const _MatrixRow(
    this.name,
    this.platform,
    this.size,
    this.systemScale,
    this.appScale, {
    this.brightness = Brightness.light,
    this.highContrast = false,
  });

  final String name;
  final TargetPlatform platform;
  final Size size;
  final double systemScale;
  final double appScale;
  final Brightness brightness;
  final bool highContrast;
}

class _FailingAppPreferences extends AppPreferences {
  _FailingAppPreferences(super.preferences, {int themeFailures = 1})
    : _themeFailuresRemaining = themeFailures;

  int _themeFailuresRemaining;

  @override
  Future<bool> setThemeMode(String value) async {
    if (_themeFailuresRemaining == 0) return super.setThemeMode(value);
    _themeFailuresRemaining -= 1;
    return false;
  }
}

class _ControlledThemePreferences extends AppPreferences {
  _ControlledThemePreferences(super.preferences);

  final _latestWrite = Completer<void>();
  var themeWriteCalls = 0;

  @override
  Future<bool> setThemeMode(String value) async {
    themeWriteCalls += 1;
    if (themeWriteCalls == 1) return false;
    await _latestWrite.future;
    return super.setThemeMode(value);
  }

  void completeLatestWrite() => _latestWrite.complete();
}

class _DelayedFailurePreferences extends AppPreferences {
  _DelayedFailurePreferences(super.preferences);

  final _firstWrite = Completer<bool>();
  var _themeWriteCalls = 0;

  @override
  Future<bool> setThemeMode(String value) {
    _themeWriteCalls += 1;
    if (_themeWriteCalls == 1) return _firstWrite.future;
    return super.setThemeMode(value);
  }

  void failFirstWrite() => _firstWrite.complete(false);
}

void _testBoolNoop(bool _) {}
