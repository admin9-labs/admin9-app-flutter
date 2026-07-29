import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/core/lifecycle/app_lifecycle_controller.dart';
import 'package:admin9_app_flutter/admin9_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first launch is blocked until privacy consent', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();

    expect(find.text('隐私保护提示'), findsOneWidget);
    expect(find.text('暂无内容'), findsNothing);
    expect(
      tester.element(find.byType(MaterialApp)).read<AppLifecycleController>(),
      isA<AppLifecycleController>(),
    );

    await tester.tap(find.byKey(const Key('privacy-accept-button')));
    await tester.pumpAndSettle();

    expect(find.text('暂无内容'), findsOneWidget);
    expect(preferences.getBool('admin9.privacy.accepted'), isTrue);
  });

  testWidgets(
    'privacy decline uses global iOS feedback inside token scope',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(Admin9App(preferences: preferences));
      await tester.pumpAndSettle();
      await tester.tap(find.text('暂不同意'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('未同意前无法进入应用。'), findsOneWidget);
      expect(find.bySemanticsLabel('关闭'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('appearance preferences are applied and persisted', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'admin9.privacy.accepted': true});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MaterialApp));
    final controller = context.read<AppAppearanceController>();
    await controller.setTheme(AppThemePreference.dark);
    await controller.setFontScale(AppFontScale.large);
    await controller.setGrayscale(true);
    await controller.setHighContrast(true);
    await controller.setReduceMotion(true);
    await tester.pump();

    expect(find.byKey(const Key('global-grayscale-filter')), findsOneWidget);
    expect(preferences.getString('admin9.appearance.theme_mode'), 'dark');
    expect(preferences.getString('admin9.appearance.font_scale'), 'large');
    expect(preferences.getBool('admin9.appearance.grayscale'), isTrue);
    expect(preferences.getBool('admin9.accessibility.high_contrast'), isTrue);
    expect(preferences.getBool('admin9.accessibility.reduce_motion'), isTrue);
  });
}
