import 'dart:io';

import 'package:admin9_app_flutter/admin9_ui.dart';
import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/admin9_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('simulator smoke', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await preferences.setBool('admin9.privacy.accepted', true);
    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();

    expect(find.byType(Admin9Shell), findsOneWidget);
    expect(find.text('暂无内容'), findsOneWidget);

    final shellContext = tester.element(find.byType(Admin9Shell));
    final mediaQuery = MediaQuery.of(shellContext);
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    debugPrint(
      'ADMIN9_SMOKE_METRICS '
      'platform=${Platform.operatingSystem} '
      'size=${mediaQuery.size.width}x${mediaQuery.size.height} '
      'dpr=${mediaQuery.devicePixelRatio} '
      'padding=${mediaQuery.padding} '
      'viewPadding=${mediaQuery.viewPadding} '
      'viewInsets=${mediaQuery.viewInsets} '
      'navigation=app-bottom-navigation',
    );

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('游客'), findsOneWidget);

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.text('外观'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(find.text('游客'), findsOneWidget);
    expect(find.text('外观'), findsNothing);
    expect(tester.takeException(), isNull);

    debugPrint('ADMIN9_SMOKE_RESULT platform=${Platform.operatingSystem} Pass');
  });
}
