import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/admin9_shell.dart';
import 'package:admin9_app_flutter/app/app_route_names.dart';
import 'package:admin9_app_flutter/admin9_ui.dart';
import 'package:admin9_app_flutter/ui/features/account/view_models/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final textInputCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.textInput,
      (call) async {
        textInputCalls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.textInput,
        null,
      ),
    );
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('服务尚未接入，当前操作不会提交或保存。'), findsOneWidget);
    expect(shellContext.read<SessionController>().status, SessionStatus.guest);
    expect(
      preferences.getKeys(),
      isNot(containsAll(<String>['token', 'user', 'session'])),
    );
    expect(
      textInputCalls.where(
        (call) => call.method == 'TextInput.finishAutofillContext',
      ),
      hasLength(1),
    );
    expect(
      textInputCalls
          .singleWhere(
            (call) => call.method == 'TextInput.finishAutofillContext',
          )
          .arguments,
      isFalse,
    );
  });

  testWidgets('auth flows expose the correct existing or new password role', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'admin9.privacy.accepted': true});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();
    final shellContext = tester.element(find.byType(Admin9Shell));
    const cases = <String, String>{
      AppRoutes.login: AutofillHints.password,
      AppRoutes.register: AutofillHints.newPassword,
      AppRoutes.resetPassword: AutofillHints.newPassword,
      AppRoutes.changePassword: AutofillHints.newPassword,
    };

    for (final entry in cases.entries) {
      Navigator.of(shellContext).pushNamed(entry.key);
      await tester.pumpAndSettle();
      final field = tester.widget<AppTextField>(
        find.byKey(const Key('auth-password-field')),
      );
      expect(field.autofillHints, contains(entry.value));
      Navigator.of(
        tester.element(find.byKey(const Key('auth-password-field'))),
      ).pop();
      await tester.pumpAndSettle();
    }
  });
}
