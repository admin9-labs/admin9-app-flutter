import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:admin9_app_flutter/features/examples/presentation/pages/content/feed/content_feed_page.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:admin9_ui/admin9_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'package:shared_preferences/shared_preferences.dart';

late Map<String, dynamic> _translations;
void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    _translations = jsonDecode(
      File('assets/translations/zh-CN.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  });
  testWidgets(
    'feed scenario configures three public components, actions and reset',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpPage(tester);
      expect(find.text('信息流、公告与 Banner'), findsOneWidget);
      expect(
        tester.widget<AFeedCard>(find.byType(AFeedCard)).images,
        hasLength(3),
      );
      expect(
        tester.widget<AAnnouncement>(find.byType(AAnnouncement)).autoplay,
        isFalse,
      );
      expect(
        tester.widget<ABanner>(find.byType(ABanner)).display,
        ABannerDisplay.stacked,
      );
      await tester.ensureVisible(find.byType(AFeedCard));
      await tester.tap(find.byType(AFeedCard));
      await tester.pumpAndSettle();
      expect(find.textContaining('已打开：'), findsOneWidget);
      await tester.ensureVisible(find.byType(AAnnouncement));
      await tester.tap(
        find.descendant(
          of: find.byType(AAnnouncement),
          matching: find.byType(FButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('公告已切换到第 2 条'), findsOneWidget);
      await tester.ensureVisible(find.bySemanticsLabel('协作活动：参与社区共建'));
      await tester.tap(find.bySemanticsLabel('协作活动：参与社区共建'));
      await tester.pumpAndSettle();
      expect(find.text('已打开：协作活动：参与社区共建'), findsOneWidget);
      for (final id in [
        'feed-layout-largeImage',
        'feed-image-count',
        'content-notice-autoplay',
        'content-banner-rotating',
        'content-interval',
      ]) {
        final control = find.byKey(ValueKey(id));
        await tester.ensureVisible(control);
        await tester.tap(control);
        await tester.pump();
      }
      expect(
        tester.widget<AFeedCard>(find.byType(AFeedCard)).layout,
        AFeedCardLayout.largeImage,
      );
      expect(tester.widget<AFeedCard>(find.byType(AFeedCard)).images, isEmpty);
      expect(
        tester.widget<AAnnouncement>(find.byType(AAnnouncement)).autoplay,
        isTrue,
      );
      expect(
        tester.widget<ABanner>(find.byType(ABanner)).display,
        ABannerDisplay.rotating,
      );
      expect(
        tester.widget<ABanner>(find.byType(ABanner)).interval,
        const Duration(seconds: 2),
      );
      final reset = find.byKey(const ValueKey('playground-reset'));
      await tester.ensureVisible(reset);
      await tester.tap(reset);
      await tester.pumpAndSettle();
      expect(tester.widget<AFeedCard>(find.byType(AFeedCard)).layout, isNull);
      expect(
        tester.widget<AFeedCard>(find.byType(AFeedCard)).images,
        hasLength(3),
      );
      expect(
        tester.widget<AAnnouncement>(find.byType(AAnnouncement)).autoplay,
        isFalse,
      );
      expect(
        tester.widget<ABanner>(find.byType(ABanner)).display,
        ABannerDisplay.stacked,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
  testWidgets(
    'complete feed scenario supports narrow dark RTL and large Chinese copy',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpPage(
        tester,
        size: const Size(320, 844),
        textScale: 2,
        textDirection: ui.TextDirection.rtl,
        theme: darkTheme,
      );
      final next = find.descendant(
        of: find.byType(AAnnouncement),
        matching: find.byType(FButton),
      );
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('便民提醒：线上服务持续开放，欢迎查看办理指南。'), findsOneWidget);
      for (final layout in AFeedCardLayout.values) {
        final control = find.byKey(ValueKey('feed-layout-${layout.name}'));
        await tester.ensureVisible(control);
        await tester.tap(control);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      semantics.dispose();
    },
  );
}

Future<void> _pumpPage(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  ui.TextDirection textDirection = ui.TextDirection.ltr,
  FThemeData? theme,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      assetLoader: _ContentFeedTranslations(_translations),
      saveLocale: false,
      child: _ContentFeedApp(
        size: size,
        textScale: textScale,
        textDirection: textDirection,
        theme: theme ?? lightTheme,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _ContentFeedApp extends StatelessWidget {
  const _ContentFeedApp({
    required this.size,
    required this.textScale,
    required this.textDirection,
    required this.theme,
  });

  final Size size;
  final double textScale;
  final ui.TextDirection textDirection;
  final FThemeData theme;

  @override
  Widget build(BuildContext context) => material.MaterialApp(
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: [
      ...context.localizationDelegates,
      ...material.GlobalMaterialLocalizations.delegates,
      FLocalizations.delegate,
    ],
    builder: (context, child) => FTheme(
      data: theme,
      child: FToaster(child: child!),
    ),
    home: Directionality(
      textDirection: textDirection,
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: const ContentFeedPage(),
      ),
    ),
  );
}

class _ContentFeedTranslations extends AssetLoader {
  const _ContentFeedTranslations(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      translations;
}
