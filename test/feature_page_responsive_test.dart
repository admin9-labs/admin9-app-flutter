import 'dart:ui' show Tristate;

import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final row in _matrix) {
    testWidgets('feature pages satisfy responsive row ${row.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = row.platform;
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = row.size;
      tester.platformDispatcher.textScaleFactorTestValue = row.systemScale;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      try {
        await _pumpStarter(tester, row);
        await tester.tap(find.text('我的').last);
        await tester.pumpAndSettle();
        expect(find.text('游客'), findsOneWidget);
        expect(find.text('当前没有用户会话'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('关于'),
          240,
          scrollable: _accountScrollable,
        );
        expect(find.text('关于'), findsOneWidget);
        expect(find.text('账号资料'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(
          find.text('注册'),
          -240,
          scrollable: _accountScrollable,
        );
        await tester.tap(find.text('注册'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('auth-account-field')), findsOneWidget);
        expect(find.byKey(const Key('auth-password-field')), findsOneWidget);
        await tester.ensureVisible(find.byKey(const Key('auth-submit-button')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('auth-submit-button')), findsOneWidget);
        await _verifyRegistrationStress(tester, row);
        expect(tester.takeException(), isNull);

        await _pumpStarter(tester, row);
        await tester.tap(find.text('我的').last);
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('设置'),
          240,
          scrollable: _accountScrollable,
        );
        await tester.ensureVisible(find.text('设置'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('设置'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('settings-theme')), findsOneWidget);
        await tester.scrollUntilVisible(
          find.byKey(const Key('settings-reduce-motion')),
          240,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.byKey(const Key('settings-reduce-motion')), findsOneWidget);
        await _verifySettingsStress(tester, row);
        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}

Future<void> _verifyRegistrationStress(
  WidgetTester tester,
  _MatrixRow row,
) async {
  final submit = find.byKey(const Key('auth-submit-button'));
  switch (row.name) {
    case 'B':
      expect(submit.hitTestable(), findsOneWidget);
    case 'C':
    case 'G':
    case 'J':
      await tester.tap(submit);
      await tester.pump();
      expect(find.text('请输入手机号或邮箱'), findsOneWidget);
      expect(find.text('请输入密码'), findsNWidgets(2));
      await tester.ensureVisible(submit);
      expect(submit.hitTestable(), findsOneWidget);
      final firstEditable = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      expect(firstEditable.focusNode.hasFocus, isTrue);
    case 'H':
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final primaryFocus = FocusManager.instance.primaryFocus;
      expect(primaryFocus, isNotNull);
      expect(primaryFocus!.hasFocus, isTrue);
      final renderBox = primaryFocus.context!.findRenderObject()! as RenderBox;
      final focusRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
      expect(
        (Offset.zero & tester.view.physicalSize).contains(focusRect.center),
        isTrue,
      );
    case 'I':
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.tap(find.byKey(const Key('auth-account-field')));
      await tester.pump();
      await tester.ensureVisible(submit);
      await tester.pump();
      expect(submit.hitTestable(), findsOneWidget);
      expect(find.byType(Scrollable), findsWidgets);
      tester.view.resetViewInsets();
      await tester.pump();
    case 'K':
      final scaler = MediaQuery.textScalerOf(tester.element(submit));
      expect(scaler.scale(16), greaterThanOrEqualTo(39.68));
    case 'L':
      final scaler = MediaQuery.textScalerOf(tester.element(submit));
      expect(scaler.scale(16), closeTo(59.52, 0.001));
    default:
      expect(submit, findsOneWidget);
  }
}

Future<void> _verifySettingsStress(WidgetTester tester, _MatrixRow row) async {
  switch (row.name) {
    case 'A':
      expect(find.text('App 字号'), findsOneWidget);
      expect(find.text('标准'), findsOneWidget);
      expect(find.text('减少动态效果'), findsOneWidget);
      expect(
        tester
            .getRect(find.text('App 字号'))
            .overlaps(tester.getRect(find.text('标准'))),
        isFalse,
      );
    case 'D':
      await tester.ensureVisible(find.byKey(const Key('settings-theme')));
      await tester.tap(find.byKey(const Key('settings-theme')));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.selected == true,
        ),
        findsWidgets,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    case 'E':
    case 'F':
      final scaler = MediaQuery.textScalerOf(
        tester.element(find.byKey(const Key('settings-theme'))),
      );
      expect(scaler.scale(16), closeTo(19.84, 0.001));
    case 'G':
      expect(tester.view.physicalSize.width, 600);
      final highContrast = tester.getSemantics(
        find.byKey(const Key('settings-high-contrast')),
      );
      expect(highContrast.flagsCollection.isToggled, Tristate.isTrue);
      expect(find.text('高对比度'), findsOneWidget);
    case 'H':
      await tester.tap(find.byKey(const Key('settings-high-contrast')));
      await tester.pump();
      expect(
        find.byKey(const Key('settings-high-contrast')).hitTestable(),
        findsOneWidget,
      );
    default:
      expect(find.byKey(const Key('settings-theme')), findsOneWidget);
  }
}

Finder get _accountScrollable => find.descendant(
  of: find.byKey(const Key('account-page-list')),
  matching: find.byType(Scrollable),
);

Future<void> _pumpStarter(WidgetTester tester, _MatrixRow row) async {
  SharedPreferences.setMockInitialValues({
    'admin9.privacy.accepted': true,
    'admin9.appearance.theme_mode': row.brightness == Brightness.dark
        ? 'dark'
        : 'light',
    'admin9.appearance.font_scale': row.appScale,
    'admin9.accessibility.high_contrast': row.highContrast,
  });
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    Admin9App(key: UniqueKey(), preferences: preferences),
  );
  await tester.pumpAndSettle();
}

const _matrix = <_MatrixRow>[
  _MatrixRow('A', TargetPlatform.android, Size(320, 720), 1, 'standard'),
  _MatrixRow('B', TargetPlatform.iOS, Size(320, 720), 1, 'extraLarge'),
  _MatrixRow(
    'C',
    TargetPlatform.android,
    Size(360, 800),
    1,
    'large',
    brightness: Brightness.dark,
  ),
  _MatrixRow(
    'D',
    TargetPlatform.iOS,
    Size(360, 800),
    1,
    'standard',
    brightness: Brightness.dark,
  ),
  _MatrixRow('E', TargetPlatform.android, Size(390, 844), 1, 'extraLarge'),
  _MatrixRow(
    'F',
    TargetPlatform.iOS,
    Size(390, 844),
    1,
    'extraLarge',
    brightness: Brightness.dark,
  ),
  _MatrixRow(
    'G',
    TargetPlatform.android,
    Size(600, 960),
    1,
    'standard',
    brightness: Brightness.dark,
    highContrast: true,
  ),
  _MatrixRow(
    'H',
    TargetPlatform.iOS,
    Size(600, 960),
    1,
    'large',
    highContrast: true,
  ),
  _MatrixRow('I', TargetPlatform.android, Size(844, 390), 1, 'large'),
  _MatrixRow(
    'J',
    TargetPlatform.iOS,
    Size(844, 390),
    1,
    'extraLarge',
    brightness: Brightness.dark,
  ),
  _MatrixRow(
    'K',
    TargetPlatform.android,
    Size(390, 844),
    2,
    'extraLarge',
    highContrast: true,
  ),
  _MatrixRow(
    'L',
    TargetPlatform.iOS,
    Size(390, 844),
    3,
    'extraLarge',
    brightness: Brightness.dark,
    highContrast: true,
  ),
];

final class _MatrixRow {
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
  final String appScale;
  final Brightness brightness;
  final bool highContrast;
}
