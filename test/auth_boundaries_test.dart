import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/admin9_shell.dart';
import 'package:admin9_app_flutter/core/navigation/app_routes.dart';
import 'package:admin9_app_flutter/ui/features/account/view_models/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login validates locally and never creates a session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'admin9.privacy.accepted': true});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();

    final shellContext = tester.element(find.byType(Admin9Shell));
    Navigator.of(shellContext).pushNamed(AppRoutes.login);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pump();
    expect(find.text('请输入手机号或邮箱'), findsOneWidget);
    expect(find.text('请输入密码'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('auth-account-field')),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('服务尚未接入，当前操作不会提交或保存。'), findsOneWidget);
    expect(shellContext.read<SessionController>().status, SessionStatus.guest);
    expect(
      preferences.getKeys(),
      isNot(containsAll(<String>['token', 'user', 'session'])),
    );
  });
}
