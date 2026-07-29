import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/admin9_shell.dart';
import 'package:admin9_app_flutter/app/app_route_names.dart';
import 'package:admin9_app_flutter/app/app_routes.dart';
import 'package:admin9_app_flutter/admin9_ui.dart';
import 'package:admin9_app_flutter/app/brand/app_brand_theme.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_theme.dart';
import 'package:admin9_app_flutter/ui/features/account/views/account_page.dart';
import 'package:admin9_app_flutter/ui/features/account/view_models/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'guest registration, legal and about flow preserves business boundaries',
    (tester) async {
      final semantics = tester.ensureSemantics();
      SharedPreferences.setMockInitialValues({'admin9.privacy.accepted': true});
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(Admin9App(preferences: preferences));
      await tester.pumpAndSettle();

      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      expect(find.text('游客'), findsOneWidget);
      expect(find.text('账号资料'), findsNothing);
      expect(find.text('账号安全'), findsNothing);
      expect(find.text('退出登录'), findsNothing);

      await tester.tap(find.text('注册'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('auth-submit-button')));
      await tester.pump();
      expect(find.text('请输入手机号或邮箱'), findsOneWidget);
      expect(find.text('请输入密码'), findsNWidgets(2));
      final accountElement = tester.element(
        find.byKey(const Key('auth-account-field')),
      );
      var focusIsInsideAccountField = false;
      FocusManager.instance.primaryFocus?.context?.visitAncestorElements((
        element,
      ) {
        focusIsInsideAccountField = identical(element, accountElement);
        return !focusIsInsideAccountField;
      });
      expect(focusIsInsideAccountField, isTrue);
      if (Theme.of(accountElement).platform == TargetPlatform.iOS) {
        final accountError = tester.getSemantics(
          find.bySemanticsLabel('请输入手机号或邮箱'),
        );
        expect(accountError.flagsCollection.isLiveRegion, isTrue);
        for (final passwordError in find.bySemanticsLabel('请输入密码').evaluate()) {
          expect(
            tester
                .getSemantics(find.byWidget(passwordError.widget))
                .flagsCollection
                .isLiveRegion,
            isFalse,
          );
        }
      }

      await tester.enterText(
        find.byKey(const Key('auth-account-field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('auth-password-field')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('auth-confirmation-field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('auth-submit-button')));
      await tester.pumpAndSettle();
      expect(find.text('服务尚未接入，当前操作不会提交或保存。'), findsOneWidget);
      final shellContext = tester.element(
        find.byType(Admin9Shell, skipOffstage: false),
      );
      expect(shellContext.read<SessionController>().isAuthenticated, isFalse);
      expect(
        preferences.getKeys(),
        isNot(containsAll(<String>['token', 'user', 'session'])),
      );

      await tester.tap(find.text('返回登录'));
      await tester.pumpAndSettle();
      expect(find.text('忘记密码'), findsOneWidget);
      Navigator.of(tester.element(find.text('忘记密码'))).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('用户协议'));
      await tester.pumpAndSettle();
      expect(find.text('正式内容尚未提供'), findsOneWidget);
      Navigator.of(tester.element(find.text('正式内容尚未提供'))).pop();
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('关于'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('关于'));
      await tester.pumpAndSettle();
      expect(find.text('联系方式'), findsOneWidget);
      await tester.tap(find.text('联系方式'));
      await tester.pumpAndSettle();
      expect(find.text('正式联系方式尚未提供'), findsOneWidget);
      semantics.dispose();
    },
    variant: TargetPlatformVariant(const {
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets('single-field auth uses Done and deletion refocuses its error', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'admin9.privacy.accepted': true});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();
    final shellContext = tester.element(find.byType(Admin9Shell));

    for (final route in [AppRoutes.forgotPassword, AppRoutes.accountRecovery]) {
      Navigator.of(shellContext).pushNamed(route);
      await tester.pumpAndSettle();
      final accountField = tester.widget<AppTextField>(
        find.byKey(const Key('auth-account-field')),
      );
      expect(accountField.textInputAction, TextInputAction.done);
      Navigator.of(
        tester.element(find.byKey(const Key('auth-account-field'))),
      ).pop();
      await tester.pumpAndSettle();
    }

    Navigator.of(shellContext).pushNamed(AppRoutes.accountDeletion);
    await tester.pumpAndSettle();
    await tester.tap(find.text('申请注销'));
    await tester.pump();
    expect(find.text('请输入“确认注销”'), findsOneWidget);
    final fieldElement = tester.element(
      find.byKey(const Key('account-deletion-confirmation-field')),
    );
    var focusIsInsideField = false;
    FocusManager.instance.primaryFocus?.context?.visitAncestorElements((
      element,
    ) {
      focusIsInsideField = identical(element, fieldElement);
      return !focusIsInsideField;
    });
    expect(focusIsInsideField, isTrue);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('$platform authenticated account keeps a single session exit', (
      tester,
    ) async {
      final session = SessionController(
        initialStatus: SessionStatus.authenticated,
      );
      final interaction = _TestInteractionController();
      addTearDown(session.dispose);
      await _pumpAccountPage(
        tester,
        platform: platform,
        session: session,
        interaction: interaction,
      );

      expect(find.text('已登录'), findsOneWidget);
      expect(find.text('登录'), findsNothing);
      expect(find.text('注册'), findsNothing);
      expect(find.text('账号资料'), findsOneWidget);
      expect(find.text('账号安全'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
      await tester.drag(
        find.byKey(const Key('account-page-list')),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(find.text('会话'), findsOneWidget);
      expect(find.text('退出登录'), findsOneWidget);

      interaction.confirmationResult = false;
      await tester.tap(find.text('退出登录'));
      await tester.pump();
      expect(session.isAuthenticated, isTrue);
      expect(interaction.confirmationCalls, 1);

      interaction.confirmationResult = true;
      await tester.tap(find.text('退出登录'));
      await tester.pump();
      expect(session.isAuthenticated, isFalse);
      expect(interaction.confirmationCalls, 2);
      expect(find.text('游客'), findsOneWidget);
      expect(find.text('退出登录'), findsNothing);
    });
  }

  testWidgets(
    'iOS child bars identify the actual route source',
    (tester) async {
      final session = SessionController(
        initialStatus: SessionStatus.authenticated,
      );
      final interaction = _TestInteractionController();
      addTearDown(session.dispose);
      await _pumpAccountPage(
        tester,
        platform: TargetPlatform.iOS,
        session: session,
        interaction: interaction,
      );

      await tester.tap(find.text('账号安全'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar))
            .previousPageTitle,
        '我的',
      );
      await tester.tap(find.text('修改密码'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar))
            .previousPageTitle,
        '账号安全',
      );

      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(Admin9App(preferences: preferences));
      await tester.pumpAndSettle();
      await tester.tap(find.text('用户协议'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar))
            .previousPageTitle,
        '隐私保护提示',
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets(
      '$platform guest actions stack at 320 logical pixels',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 720);
        addTearDown(() {
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
        });
        SharedPreferences.setMockInitialValues({
          'admin9.privacy.accepted': true,
        });
        final preferences = await SharedPreferences.getInstance();
        await tester.pumpWidget(Admin9App(preferences: preferences));
        await tester.pumpAndSettle();
        await tester.tap(find.text('我的'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('guest-actions-column')), findsOneWidget);
        expect(find.byKey(const Key('guest-actions-row')), findsNothing);
        expect(tester.getSize(find.text('登录')).height, greaterThan(0));
        expect(tester.getSize(find.text('注册')).height, greaterThan(0));
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant(<TargetPlatform>{platform}),
    );
  }
}

Future<void> _pumpAccountPage(
  WidgetTester tester, {
  required TargetPlatform platform,
  required SessionController session,
  required _TestInteractionController interaction,
}) async {
  final resolved = AppTheme.resolve(
    brightness: Brightness.light,
    highContrast: false,
    reduceMotion: false,
    boldText: false,
    platform: platform,
    brandPrimary: appBrandTheme.primaryLight,
    brandSecondary: appBrandTheme.secondaryLight,
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: resolved.material.copyWith(platform: platform),
      onGenerateRoute: AppRouteFactory.onGenerateRoute,
      builder: (context, child) =>
          ChangeNotifierProvider<SessionController>.value(
            value: session,
            child: AppDesignScope(
              tokens: resolved.tokens,
              child: AppInteractionHost(controller: interaction, child: child!),
            ),
          ),
      home: const AccountPage(),
    ),
  );
  await tester.pumpAndSettle();
}

final class _TestInteractionController implements AppInteractionController {
  bool confirmationResult = false;
  int confirmationCalls = 0;

  @override
  Future<T?> showActionMenu<T extends Object>({
    String? title,
    required List<AppActionMenuItem<T>> items,
    String cancelLabel = '取消',
  }) async => null;

  @override
  Future<bool> showConfirmation({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    confirmationCalls += 1;
    return confirmationResult;
  }

  @override
  Future<bool> showDestructive({
    required String title,
    required String message,
    required String confirmLabel,
  }) async => false;

  @override
  Future<void> showInformation({
    required String title,
    required String message,
  }) async {}
}
