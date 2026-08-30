import 'dart:convert';

import 'package:admin9_app_flutter/app/routing/app_router.dart';
import 'package:admin9_app_flutter/features/foundation/presentation/pages/foundation_interaction_page.dart';
import 'package:admin9_app_flutter/features/foundation/presentation/pages/foundation_layout_page.dart';
import 'package:admin9_app_flutter/features/foundation/presentation/pages/foundation_navigation_page.dart';
import 'package:admin9_app_flutter/features/foundation/presentation/pages/foundation_page.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Map<String, dynamic> _translations;

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    _translations = jsonDecode(
      await rootBundle.loadString('assets/translations/zh-CN.json'),
    ) as Map<String, dynamic>;
  });

  testWidgets('foundation catalog opens a typed detail route', (tester) async {
    final router = AppRouter();
    addTearDown(router.dispose);
    await _pumpRouter(tester, router);

    expect(find.byType(FoundationPage), findsOneWidget);

    await tester.tap(find.text('布局与主题'));
    await tester.pumpAndSettle();

    expect(find.byType(FoundationLayoutPage), findsOneWidget);
    expect(find.text('分隔线'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tabs switch between the foundation navigation examples', (
    tester,
  ) async {
    await _pumpPage(tester, const FoundationNavigationPage());

    expect(find.byType(FTabs), findsOneWidget);
    expect(find.text('正文排版'), findsOneWidget);

    await tester.tap(find.text('输入'));
    await tester.pumpAndSettle();

    expect(find.text('输入内容会随屏幕和字号自然调整。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('header action has semantics and observable behavior', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const FoundationLayoutPage());

    final search = find.bySemanticsLabel('搜索示例');
    expect(search, findsOneWidget);
    await tester.tap(search);
    await tester.pump();

    expect(find.text('已搜索 1 次'), findsOneWidget);
    await tester.pumpAndSettle();
    semantics.dispose();
  });

  testWidgets('collapsible and tappable expose runnable touch behavior', (
    tester,
  ) async {
    await _pumpPage(tester, const FoundationInteractionPage());

    expect(tester.widget<FCollapsible>(find.byType(FCollapsible)).value, 0);
    expect(find.text('展开内容'), findsOneWidget);

    await tester.tap(find.byType(FButton).first);
    await tester.pumpAndSettle();

    expect(tester.widget<FCollapsible>(find.byType(FCollapsible)).value, 1);
    expect(find.text('收起内容'), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('标签'));
    await tester.pumpAndSettle();

    expect(find.text('已点击 1 次'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tappable describes its counter action to assistive tech', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const FoundationInteractionPage());

    final tappable = find.semantics.byHint('点按以增加计数');
    expect(tappable, findsOne);
    expect(tappable.evaluate().single.label, '标签，已点击 0 次');

    await tester.tap(find.text('标签'));
    await tester.pumpAndSettle();

    expect(tappable.evaluate().single.label, '标签，已点击 1 次');
    semantics.dispose();
  });

  testWidgets('interaction page disables custom motion when requested', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      const FoundationInteractionPage(),
      accessibility: const FAccessibility(
        accessibleNavigation: false,
        motion: FAccessibilityMotion.disabled,
        focusHighlight: false,
      ),
    );

    await tester.tap(find.byType(FButton).first);
    await tester.pump();

    expect(tester.widget<FCollapsible>(find.byType(FCollapsible)).value, 1);
    expect(find.text('收起内容'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'foundation pages fit mobile widths, large text, dark theme, and insets',
    (tester) async {
      const pages = <({Widget page, String title})>[
        (page: FoundationPage(), title: '基础'),
        (page: FoundationLayoutPage(), title: '布局与主题'),
        (page: FoundationNavigationPage(), title: '导航'),
        (page: FoundationInteractionPage(), title: '触摸交互'),
      ];
      const sizes = [Size(320, 844), Size(360, 800), Size(390, 844)];
      const insets = EdgeInsets.only(top: 44, bottom: 34);

      for (final size in sizes) {
        for (final (:page, :title) in pages) {
          await _pumpPage(
            tester,
            page,
            size: size,
            textScale: 2,
            theme: darkTheme,
            padding: insets,
          );

          expect(find.text(title), findsWidgets);
          expect(
            tester.getTopLeft(find.text(title).first).dy,
            greaterThanOrEqualTo(insets.top),
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '$title at ${size.width}px',
          );
        }
      }
    },
  );
}

Future<void> _pumpRouter(WidgetTester tester, AppRouter router) async {
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      assetLoader: _InMemoryAssetLoader(_translations),
      saveLocale: false,
      child: _LocalizedApp.router(router: router),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  Size size = const Size(390, 844),
  double textScale = 1,
  FThemeData? theme,
  EdgeInsets padding = EdgeInsets.zero,
  FAccessibility? accessibility,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      assetLoader: _InMemoryAssetLoader(_translations),
      saveLocale: false,
      child: _LocalizedApp.page(
        page: page,
        textScale: textScale,
        theme: theme ?? lightTheme,
        padding: padding,
        accessibility: accessibility,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _LocalizedApp extends StatelessWidget {
  const _LocalizedApp.page({
    required this.page,
    required this.textScale,
    required this.theme,
    required this.padding,
    this.accessibility,
  }) : router = null;

  const _LocalizedApp.router({required this.router})
    : page = null,
      textScale = 1,
      theme = null,
      padding = EdgeInsets.zero,
      accessibility = null;

  final Widget? page;
  final AppRouter? router;
  final double textScale;
  final FThemeData? theme;
  final EdgeInsets padding;
  final FAccessibility? accessibility;

  @override
  Widget build(BuildContext context) {
    final delegates = [
      ...context.localizationDelegates,
      FLocalizations.delegate,
    ];

    if (router case final router?) {
      return MaterialApp.router(
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: delegates,
        routerConfig: router.config(),
        builder: _buildAppChild,
      );
    }

    return MaterialApp(
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: delegates,
      home: page,
      builder: _buildAppChild,
    );
  }

  Widget _buildAppChild(BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        padding: padding,
        viewPadding: padding,
      ),
      child: FTheme(
        data: theme ?? lightTheme,
        accessibility: accessibility,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      Future.value(Map.of(translations));
}
