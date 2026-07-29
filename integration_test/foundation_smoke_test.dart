import 'dart:io';

import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/admin9_shell.dart';
import 'package:admin9_app_flutter/app/app_route_names.dart';
import 'package:admin9_app_flutter/core/theme/app_appearance.dart';
import 'package:admin9_app_flutter/core/theme/appearance_controller.dart';
import 'package:admin9_app_flutter/ui/features/account/view_models/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final platform = Platform.isIOS ? 'ios' : 'android';

  testWidgets('Admin9 mobile foundation smoke', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();

    expect(find.text('隐私保护提示'), findsOneWidget);
    expect(find.text('暂无内容'), findsNothing);
    await _screenshot(binding, '${platform}_01_privacy_gate');

    await tester.tap(find.text('用户协议'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '用户协议'), findsOneWidget);
    expect(find.text('正式内容尚未提供'), findsOneWidget);
    await _systemBack(tester);

    await tester.tap(find.text('隐私政策'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '隐私政策'), findsOneWidget);
    await _systemBack(tester);

    await tester.tap(find.byKey(const Key('privacy-accept-button')));
    await tester.pumpAndSettle();
    expect(find.text('暂无内容'), findsOneWidget);
    expect(preferences.getBool('admin9.privacy.accepted'), isTrue);
    await _screenshot(binding, '${platform}_02_home');

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('游客'), findsOneWidget);
    expect(find.text('当前没有用户会话'), findsOneWidget);

    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('auth-account-field')),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.pump(const Duration(milliseconds: 800));
    await _screenshot(binding, '${platform}_03_login_form');
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();
    expect(find.text('服务尚未接入，当前操作不会提交或保存。'), findsOneWidget);
    expect(
      tester.element(find.byType(MaterialApp)).read<SessionController>().status,
      SessionStatus.guest,
    );
    expect(preferences.getKeys().where(_looksLikeAuthState), isEmpty);
    await _systemBack(tester);

    await _openAndReturn(tester, AppRoutes.register, '注册');
    await _openAndReturn(tester, AppRoutes.forgotPassword, '忘记密码');
    await _openAndReturn(tester, AppRoutes.resetPassword, '重置密码');
    await _openAndReturn(tester, AppRoutes.profile, '账号资料');
    await _openAndReturn(tester, AppRoutes.accountRecovery, '账号找回');
    await _openAndReturn(tester, AppRoutes.accountSecurity, '账号安全');
    await _openAndReturn(tester, AppRoutes.changePassword, '修改密码');
    await _openAndReturn(tester, AppRoutes.accountDeletion, '账号注销');

    await _openSettingsAndChangeAppearance(tester, binding, platform);

    await _openAndReturn(tester, AppRoutes.about, '关于');
    await _openAndReturn(tester, AppRoutes.contact, '联系方式');

    Navigator.of(
      tester.element(find.byType(Admin9Shell)),
    ).pushNamed(AppRoutes.about);
    await tester.pumpAndSettle();
    expect(find.text('1.0.0'), findsOneWidget);
    await _iosEdgeBackOrSystemBack(tester);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    final restartedPreferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(Admin9App(preferences: restartedPreferences));
    await tester.pumpAndSettle();
    expect(find.text('隐私保护提示'), findsNothing);
    expect(find.text('暂无内容'), findsOneWidget);
    final appearance = tester
        .element(find.byType(MaterialApp))
        .read<AppearanceController>()
        .appearance;
    expect(appearance.theme, AppThemePreference.dark);
    expect(appearance.fontScale, AppFontScale.extraLarge);
    expect(appearance.grayscale, isTrue);
    expect(appearance.highContrast, isTrue);
    expect(appearance.reduceMotion, isTrue);
    expect(
      tester.element(find.byType(MaterialApp)).read<SessionController>().status,
      SessionStatus.guest,
    );
    expect(restartedPreferences.getKeys().where(_looksLikeAuthState), isEmpty);
    await _screenshot(binding, '${platform}_05_restart_preferences');
    expect(tester.takeException(), isNull);
  });
}

Future<void> _openAndReturn(
  WidgetTester tester,
  String route,
  String title,
) async {
  Navigator.of(tester.element(find.byType(Admin9Shell))).pushNamed(route);
  await tester.pumpAndSettle();
  expect(find.widgetWithText(AppBar, title), findsOneWidget);
  expect(tester.takeException(), isNull);
  await _systemBack(tester);
}

Future<void> _openSettingsAndChangeAppearance(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String platform,
) async {
  Navigator.of(
    tester.element(find.byType(Admin9Shell)),
  ).pushNamed(AppRoutes.settings);
  await tester.pumpAndSettle();
  expect(find.widgetWithText(AppBar, '设置'), findsOneWidget);

  await tester.tap(find.text('深色'));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownButton<AppFontScale>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('特大').last);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(SwitchListTile, '全局灰度'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(SwitchListTile, '增强对比度'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(SwitchListTile, '减少动态效果'));
  await tester.pumpAndSettle();

  final appearance = tester
      .element(find.byType(MaterialApp))
      .read<AppearanceController>()
      .appearance;
  expect(appearance.theme, AppThemePreference.dark);
  expect(appearance.fontScale, AppFontScale.extraLarge);
  expect(appearance.grayscale, isTrue);
  expect(appearance.highContrast, isTrue);
  expect(appearance.reduceMotion, isTrue);
  await _screenshot(binding, '${platform}_04_settings_accessibility');
  await _systemBack(tester);
}

Future<void> _iosEdgeBackOrSystemBack(WidgetTester tester) async {
  if (Platform.isIOS) {
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.timedDragFrom(
      Offset(2, size.height / 2),
      Offset(size.width * 0.8, 0),
      const Duration(milliseconds: 600),
    );
    await tester.pump(const Duration(milliseconds: 800));
    if (find.byType(Admin9Shell).evaluate().isEmpty) await _systemBack(tester);
    return;
  }
  await _systemBack(tester);
}

Future<void> _systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

Future<void> _screenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  if (Platform.isAndroid) return;
  final bytes = await binding.takeScreenshot(name);
  expect(bytes, isNotEmpty);
}

bool _looksLikeAuthState(String key) {
  final normalized = key.toLowerCase();
  return normalized.contains('token') ||
      normalized.contains('user') ||
      normalized.contains('session');
}
