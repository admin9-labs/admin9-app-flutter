import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/admin9_shell.dart';
import 'package:admin9_app_flutter/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shell exposes only Home and Account destinations', (
    tester,
  ) async {
    await _pumpAcceptedApp(tester);

    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.destinations, hasLength(2));
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('游客'), findsOneWidget);
    expect(find.text('登录'), findsOneWidget);
    expect(find.text('注册'), findsOneWidget);
  });

  testWidgets('all foundation routes open and return', (tester) async {
    await _pumpAcceptedApp(tester);
    final shellContext = tester.element(find.byType(Admin9Shell));
    const routes = <String, String>{
      AppRoutes.login: '登录',
      AppRoutes.register: '注册',
      AppRoutes.forgotPassword: '忘记密码',
      AppRoutes.resetPassword: '重置密码',
      AppRoutes.changePassword: '修改密码',
      AppRoutes.accountRecovery: '账号找回',
      AppRoutes.profile: '账号资料',
      AppRoutes.accountSecurity: '账号安全',
      AppRoutes.accountDeletion: '账号注销',
      AppRoutes.settings: '设置',
      AppRoutes.userAgreement: '用户协议',
      AppRoutes.privacyPolicy: '隐私政策',
      AppRoutes.about: '关于',
      AppRoutes.contact: '联系方式',
    };

    for (final entry in routes.entries) {
      Navigator.of(shellContext).pushNamed(entry.key);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, entry.value), findsOneWidget);
      Navigator.of(
        tester.element(find.widgetWithText(AppBar, entry.value)),
      ).pop();
      await tester.pumpAndSettle();
    }
  });
}

Future<void> _pumpAcceptedApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'admin9.privacy.accepted': true});
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(Admin9App(preferences: preferences));
  await tester.pumpAndSettle();
}
