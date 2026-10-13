import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:admin9_app_flutter/features/examples/presentation/pages/content/carousel/carousel_page.dart';
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
    'carousel configuration, actions and reset use the package public API',
    (tester) async {
      await _pumpPage(tester);
      expect(find.text('Admin9 轮播'), findsOneWidget);
      expect(
        tester.widget<ACarousel>(find.byType(ACarousel)).caption,
        ACarouselCaption.overlay,
      );
      await tester.tap(find.byType(ACarousel));
      await tester.pump();
      expect(find.textContaining('已打开：'), findsOneWidget);
      final caption = find.byKey(const ValueKey('carousel-caption-below'));
      await tester.ensureVisible(caption);
      await tester.tap(caption);
      await tester.pumpAndSettle();
      expect(
        tester.widget<ACarousel>(find.byType(ACarousel)).caption,
        ACarouselCaption.below,
      );
      final autoplay = find.byKey(const ValueKey('carousel-autoplay'));
      await tester.ensureVisible(autoplay);
      await tester.tap(autoplay);
      await tester.pump();
      expect(tester.widget<ACarousel>(find.byType(ACarousel)).autoplay, isTrue);
      final interval = find.byKey(const ValueKey('carousel-interval'));
      await tester.ensureVisible(interval);
      await tester.tap(interval);
      await tester.pump();
      expect(
        tester.widget<ACarousel>(find.byType(ACarousel)).interval,
        const Duration(seconds: 2),
      );
      final reset = find.byKey(const ValueKey('playground-reset'));
      await tester.ensureVisible(reset);
      await tester.tap(reset);
      await tester.pumpAndSettle();
      final component = tester.widget<ACarousel>(find.byType(ACarousel));
      expect(component.autoplay, isFalse);
      expect(component.caption, ACarouselCaption.overlay);
      expect(component.interval, const Duration(seconds: 5));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'carousel example preserves long Chinese, dark theme, RTL and large text at 320px',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpPage(
        tester,
        size: const Size(320, 844),
        textScale: 2,
        textDirection: ui.TextDirection.rtl,
        theme: darkTheme,
      );
      expect(find.bySemanticsLabel('阅读：发现值得关注的内容'), findsOneWidget);
      final below = find.byKey(const ValueKey('carousel-caption-below'));
      await tester.ensureVisible(below);
      await tester.tap(below);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
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
      assetLoader: _CarouselTranslations(_translations),
      saveLocale: false,
      child: _CarouselApp(
        size: size,
        textScale: textScale,
        textDirection: textDirection,
        theme: theme ?? lightTheme,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _CarouselApp extends StatelessWidget {
  const _CarouselApp({
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
        child: const CarouselPage(),
      ),
    ),
  );
}

class _CarouselTranslations extends AssetLoader {
  const _CarouselTranslations(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      translations;
}
