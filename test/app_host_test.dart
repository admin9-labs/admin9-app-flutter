import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/privacy_gate.dart';
import 'package:admin9_app_flutter/admin9_ui.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_theme.dart';
import 'package:admin9_app_flutter/core/preferences/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first launch is blocked until privacy consent', (tester) async {
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(supportsAnnounce: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();

    expect(find.text('隐私保护提示'), findsOneWidget);
    expect(find.text('暂无内容'), findsNothing);
    await tester.tap(find.byKey(const Key('privacy-accept-button')));
    await tester.pumpAndSettle();

    expect(find.text('暂无内容'), findsOneWidget);
    expect(preferences.getBool('admin9.privacy.accepted'), isTrue);
    expect(
      tester.takeAnnouncements().map((announcement) => announcement.message),
      ['已进入首页'],
    );
  });

  testWidgets('privacy persistence failure keeps the host locked', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final controller = PrivacyController(
      AppPreferences(sharedPreferences, (key, value) async => false),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          home: AppDesignScope(
            tokens: AppTheme.resolve(
              brightness: Brightness.light,
              highContrast: false,
              reduceMotion: false,
              boldText: false,
              brandPrimary: const Color(0xff2457a7),
              brandSecondary: const Color(0xff52606d),
            ).tokens,
            child: const PrivacyGate(child: Text('HOST')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(await controller.accept(), isFalse);
    await tester.pump();

    expect(controller.accepted, isFalse);
    expect(controller.saveFailed, isTrue);
    expect(find.text('HOST'), findsNothing);
    expect(find.text('隐私选择尚未保存，应用仍保持锁定。'), findsOneWidget);
    expect(sharedPreferences.getBool('admin9.privacy.accepted'), isNull);
  });

  testWidgets('accepted cold launch does not repeat the privacy announcement', (
    tester,
  ) async {
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(supportsAnnounce: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );
    SharedPreferences.setMockInitialValues({'admin9.privacy.accepted': true});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();

    expect(find.text('暂无内容'), findsOneWidget);
    expect(tester.takeAnnouncements(), isEmpty);
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

  testWidgets(
    'appearance preferences are applied and persisted',
    (tester) async {
      SharedPreferences.setMockInitialValues({'admin9.privacy.accepted': true});
      final preferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(Admin9App(preferences: preferences));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      final controller = context.read<AppAppearanceController>();
      final grayscaleFilter = tester.element(
        find.byKey(const Key('global-grayscale-filter')),
      );
      final lightSystemUi = tester
          .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.byKey(const Key('global-system-ui-style')),
          );
      expect(lightSystemUi.value.statusBarIconBrightness, Brightness.dark);
      expect(lightSystemUi.value.statusBarBrightness, Brightness.light);
      expect(
        lightSystemUi.value.systemNavigationBarIconBrightness,
        Brightness.dark,
      );
      expect(lightSystemUi.value.statusBarColor, Colors.transparent);
      expect(lightSystemUi.value.systemNavigationBarColor, Colors.transparent);
      expect(
        lightSystemUi.value.systemNavigationBarDividerColor,
        Colors.transparent,
      );
      expect(lightSystemUi.value.systemNavigationBarContrastEnforced, isTrue);
      await controller.setTheme(AppThemePreference.dark);
      await controller.setFontScale(AppFontScale.large);
      await controller.setGrayscale(true);
      await controller.setHighContrast(true);
      await controller.setReduceMotion(true);
      await tester.pump();

      final darkSystemUi = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byKey(const Key('global-system-ui-style')),
      );
      expect(darkSystemUi.value.statusBarIconBrightness, Brightness.light);
      expect(darkSystemUi.value.statusBarBrightness, Brightness.dark);
      expect(
        darkSystemUi.value.systemNavigationBarIconBrightness,
        Brightness.light,
      );
      expect(darkSystemUi.value.statusBarColor, Colors.transparent);
      expect(darkSystemUi.value.systemNavigationBarColor, Colors.transparent);
      expect(
        darkSystemUi.value.systemNavigationBarDividerColor,
        Colors.transparent,
      );
      expect(darkSystemUi.value.systemNavigationBarContrastEnforced, isTrue);
      expect(find.byKey(const Key('global-grayscale-filter')), findsOneWidget);
      expect(
        tester.element(find.byKey(const Key('global-grayscale-filter'))),
        same(grayscaleFilter),
        reason: 'grayscale must not replace the accessibility subtree',
      );
      expect(preferences.getString('admin9.appearance.theme_mode'), 'dark');
      expect(preferences.getString('admin9.appearance.font_scale'), 'large');
      expect(preferences.getBool('admin9.appearance.grayscale'), isTrue);
      expect(preferences.getBool('admin9.accessibility.high_contrast'), isTrue);
      expect(preferences.getBool('admin9.accessibility.reduce_motion'), isTrue);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );
}
