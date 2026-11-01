import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/app/session/session.dart';
import 'package:admin9_app_flutter/app/startup/startup_provider.dart';
import 'package:admin9_app_flutter/app/startup/startup_state.dart';
import 'package:admin9_app_flutter/features/authentication/domain/authentication_gateway.dart';
import 'package:admin9_app_flutter/features/authentication/presentation/providers/authentication_provider.dart';
import 'package:admin9_app_flutter/features/authentication/presentation/widgets/authentication_form.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/support/test_admin9_app.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  for (final register in [false, true]) {
    testWidgets(
      '${register ? 'registration' : 'login'} validates, reports failure and emits callbacks without a router',
      (tester) async {
        final gateway = _Gateway();
        var authenticated = 0;
        var switches = 0;
        await _pumpForm(
          tester,
          gateway,
          AuthenticationForm(
            register: register,
            onAuthenticated: () => authenticated++,
            onSwitchMode: () => switches++,
          ),
        );
        final submit = find.byKey(const ValueKey('authentication-submit'));
        final switchMode = find.byKey(
          const ValueKey('authentication-switch-mode'),
        );
        await tester.tap(switchMode);
        expect(switches, 1);
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('authentication-error')),
          findsOneWidget,
        );
        expect(gateway.calls, isEmpty);

        await tester.enterText(
          find.byKey(const ValueKey('authentication-identifier')),
          '  reader@example.com  ',
        );
        await tester.enterText(
          find.byKey(const ValueKey('authentication-password')),
          'test-password',
        );
        await tester.tap(submit);
        await tester.pump();
        expect(gateway.calls.single, register ? 'register' : 'login');
        expect(gateway.identifier, 'reader@example.com');
        expect(tester.widget<FButton>(submit).onPress, isNull);
        expect(tester.widget<FButton>(switchMode).onPress, isNull);
        gateway.pending.completeError(const AuthenticationFailure('rejected'));
        await tester.pumpAndSettle();
        expect(authenticated, 0);
        expect(find.text('认证失败，请检查输入后重试。'), findsOneWidget);

        gateway.pending = Completer<SessionSnapshot>();
        await tester.tap(submit);
        await tester.pump();
        gateway.pending.complete(
          const SessionSnapshot(
            accountId: 'reader',
            identifier: 'reader@example.com',
          ),
        );
        await tester.pumpAndSettle();
        expect(authenticated, 1);
        expect(gateway.calls.length, 2);
        expect(
          find.byKey(const ValueKey('authentication-error')),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('limited browsing cannot submit credentials', (tester) async {
    final gateway = _Gateway();
    await _pumpForm(
      tester,
      gateway,
      AuthenticationForm(
        register: false,
        onAuthenticated: () {},
        onSwitchMode: () {},
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AuthenticationForm)),
    );
    container.read(startupCoordinatorProvider.notifier).continueLimited();
    await tester.enterText(
      find.byKey(const ValueKey('authentication-identifier')),
      'reader@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('authentication-password')),
      'test-password',
    );
    await tester.tap(find.byKey(const ValueKey('authentication-submit')));
    await tester.pumpAndSettle();
    expect(gateway.calls, isEmpty);
  });

  testWidgets('withdrawal and renewed consent cancel an in-flight login', (
    tester,
  ) async {
    final gateway = _Gateway();
    var authenticated = false;
    await _pumpForm(
      tester,
      gateway,
      AuthenticationForm(
        register: false,
        onAuthenticated: () => authenticated = true,
        onSwitchMode: () {},
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AuthenticationForm)),
    );
    await tester.enterText(
      find.byKey(const ValueKey('authentication-identifier')),
      'reader@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('authentication-password')),
      'test-password',
    );
    await tester.tap(find.byKey(const ValueKey('authentication-submit')));
    await tester.pump();
    container.read(startupCoordinatorProvider.notifier).continueLimited();
    final logout = container.read(authenticationProvider.notifier).logout();
    await container
        .read(startupCoordinatorProvider.notifier)
        .begin(launchReason: LaunchReason.deepLink);
    gateway.pending.complete(
      const SessionSnapshot(
        accountId: 'reader',
        identifier: 'reader@example.com',
      ),
    );
    await logout;
    await tester.pumpAndSettle();
    expect(authenticated, isFalse);
    expect(container.read(authenticationProvider).session, isNull);
    expect(gateway.logoutCalls, 1);
  });
}

Future<void> _pumpForm(
  WidgetTester tester,
  AuthenticationGateway gateway,
  Widget form,
) async {
  tester.view
    ..physicalSize = const Size(320, 640)
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      assetLoader: const _Translations(),
      saveLocale: false,
      child: ProviderScope(
        overrides: [
          authenticationGatewayProvider.overrideWithValue(gateway),
          startupPreferencesRepositoryProvider.overrideWithValue(
            FakeCompletedStartupRepository(),
          ),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: [
              ...context.localizationDelegates,
              ...GlobalMaterialLocalizations.delegates,
              FLocalizations.delegate,
            ],
            theme: lightTheme.toApproximateMaterialTheme(),
            home: FTheme(
              data: lightTheme,
              child: FScaffold(child: form),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await ProviderScope.containerOf(
        tester.element(find.byType(AuthenticationForm)),
      )
      .read(startupCoordinatorProvider.notifier)
      .begin(launchReason: LaunchReason.deepLink);
  await tester.pumpAndSettle();
}

final class _Translations extends AssetLoader {
  const _Translations();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      jsonDecode(File('assets/translations/zh-CN.json').readAsStringSync())
          as Map<String, dynamic>;
}

final class _Gateway implements AuthenticationGateway {
  Completer<SessionSnapshot> pending = Completer<SessionSnapshot>();
  final List<String> calls = [];
  int logoutCalls = 0;
  String? identifier;

  @override
  Future<SessionSnapshot> login({
    required String identifier,
    required String password,
  }) {
    calls.add('login');
    this.identifier = identifier;
    return pending.future;
  }

  @override
  Future<SessionSnapshot> register({
    required String identifier,
    required String password,
  }) {
    calls.add('register');
    this.identifier = identifier;
    return pending.future;
  }

  @override
  Future<SessionSnapshot?> restore() async => null;

  @override
  Future<void> logout() async => logoutCalls++;
}
