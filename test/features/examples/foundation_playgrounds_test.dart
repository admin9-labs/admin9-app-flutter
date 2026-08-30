import 'dart:convert';
import 'dart:ui' as ui show TextDirection, Tristate;

import 'package:admin9_app_flutter/features/examples/presentation/pages/foundation/playgrounds/app_shell_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/foundation/playgrounds/interaction_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/reference/icons/icons_page.dart';
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

  testWidgets('app shell configuration changes preview and reset restores it', (
    tester,
  ) async {
    await _pumpPage(tester, const AppShellPlaygroundPage());

    final initialSummary = _summary(tester);
    await tester.ensureVisible(
      find.byKey(const ValueKey('app-shell-safe-area')),
    );
    await tester.tap(find.byKey(const ValueKey('app-shell-safe-area')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_summary(tester), isNot(initialSummary));

    await tester.ensureVisible(
      find.byKey(const ValueKey('app-shell-bottom-navigation')),
    );
    final items = find.byType(FBottomNavigationBarItem);
    await tester.tap(items.at(1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_summary(tester), contains('index: 1'));

    await tester.ensureVisible(find.byKey(const ValueKey('playground-reset')));
    await tester.tap(find.byKey(const ValueKey('playground-reset')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_summary(tester), contains('safeAreaBottom: true'));
    expect(_summary(tester), contains('index: 0'));
  });

  testWidgets(
    'C03/WL01/WL03/WN01/WN03 cover locale, shell, headers, divider, and scroll',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpPage(
        tester,
        const AppShellPlaygroundPage(),
        textDirection: ui.TextDirection.rtl,
      );

      final pageContext = tester.element(find.byType(AppShellPlaygroundPage));
      expect(Localizations.localeOf(pageContext), const Locale('zh', 'CN'));
      expect(FLocalizations.of(pageContext)?.localeName, 'zh');
      expect(
        find.byWidgetPredicate((widget) => widget is FHeader),
        findsNWidgets(2),
      );

      final search = find.byKey(const ValueKey('app-shell-search-action'));
      expect(search, findsOneWidget);
      await tester.tap(search);
      await tester.pump();
      expect(find.textContaining('搜索次数 1'), findsOneWidget);

      final horizontal = tester.widget<FDivider>(
        find.byKey(const ValueKey('app-shell-divider-horizontal')),
      );
      final resolved = horizontal.style(
        pageContext.theme.dividerStyles.horizontal,
      );
      final padding = resolved.padding.resolve(ui.TextDirection.rtl);
      expect(horizontal.axis, Axis.horizontal);
      expect(padding.left, 8);
      expect(padding.right, 24);
      expect(
        tester
            .widget<FDivider>(
              find.byKey(const ValueKey('app-shell-divider-vertical')),
            )
            .axis,
        Axis.vertical,
      );
      expect(
        tester
            .getSemantics(
              find.byKey(
                const ValueKey('app-shell-divider-horizontal-semantics'),
              ),
            )
            .label,
        '分隔线',
      );
      expect(
        tester
            .getSemantics(
              find.byKey(
                const ValueKey('app-shell-divider-vertical-semantics'),
              ),
            )
            .label,
        '分隔线',
      );

      final scrollable = find.descendant(
        of: find.byKey(const ValueKey('app-shell-scroll')),
        matching: find.byType(Scrollable),
      );
      final position = tester.state<ScrollableState>(scrollable).position;
      expect(position.maxScrollExtent, greaterThan(0));
      await tester.drag(
        find.byKey(const ValueKey('app-shell-scroll')),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(position.pixels, greaterThan(0));
      expect(
        find.byKey(const ValueKey('app-shell-content-end')),
        findsOneWidget,
      );
      semantics.dispose();
    },
  );

  testWidgets('C04 covers Android/iOS touch variants and 320/390 integration', (
    tester,
  ) async {
    for (final platform in const [
      FPlatformVariant.android,
      FPlatformVariant.iOS,
    ]) {
      for (final scenario in const [
        (size: Size(320, 844), scale: 2.0),
        (size: Size(390, 844), scale: 1.0),
      ]) {
        await _pumpPage(
          tester,
          const AppShellPlaygroundPage(),
          size: scenario.size,
          textScale: scenario.scale,
          platform: platform,
        );

        final page = find.byType(AppShellPlaygroundPage);
        final pageContext = tester.element(page);
        expect(pageContext.platformVariant, platform);
        expect(tester.takeException(), isNull);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('app-shell-width')))
              .data,
          contains('px · zh-CN'),
        );
      }
    }
  });

  testWidgets('interaction controls change tappable state and reset', (
    tester,
  ) async {
    await _pumpPage(tester, const InteractionPlaygroundPage());

    await tester.ensureVisible(
      find.byKey(const ValueKey('interaction-tappable')),
    );
    await tester.tap(find.byKey(const ValueKey('interaction-tappable')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_summary(tester), contains('presses: 1'));
    expect(_summary(tester), contains('selected: true'));

    await tester.ensureVisible(find.byKey(const ValueKey('playground-reset')));
    await tester.tap(find.byKey(const ValueKey('playground-reset')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_summary(tester), contains('presses: 0'));
    expect(_summary(tester), contains('selected: false'));
  });

  testWidgets(
    'C02/WN06 tabs expose managed, lifted, equal, scrollable, indicator, and swipe axes',
    (tester) async {
      await _pumpPage(tester, const InteractionPlaygroundPage());

      FTabs tabs() => tester.widget<FTabs>(
        find.descendant(
          of: find.byKey(const ValueKey('interaction-tabs')),
          matching: find.byType(FTabs),
        ),
      );

      expect(tabs().control, isNot(isA<FTabManagedControl>()));
      expect(tabs().scrollable, isFalse);
      expect(tabs().expands, isTrue);
      expect(tabs().contentPhysics, isA<BouncingScrollPhysics>());

      final managed = find.byKey(const ValueKey('interaction-control-managed'));
      await tester.ensureVisible(managed);
      await tester.tap(managed);
      await tester.pumpAndSettle();
      expect(tabs().control, isA<FTabManagedControl>());

      final scrollable = find.byKey(const ValueKey('interaction-scrollable'));
      tester.widget<FSwitch>(scrollable).onChange!(true);
      await tester.pumpAndSettle();
      expect(tabs().scrollable, isTrue);
      expect(
        tabs()
            .style(tester.element(find.byType(FTabs)).theme.tabsStyle)
            .indicatorSize,
        FTabBarIndicatorSize.label,
      );

      final tabRect = tester.getRect(find.byType(FTabs));
      await tester.dragFrom(
        Offset(tabRect.center.dx, tabRect.bottom - 32),
        const Offset(-260, 0),
      );
      await tester.pumpAndSettle();
      expect(_summary(tester), contains('tabIndex: 1'));

      final swipe = find.byKey(const ValueKey('interaction-swipe'));
      tester.widget<FSwitch>(swipe).onChange!(false);
      await tester.pumpAndSettle();
      expect(tabs().contentPhysics, isA<NeverScrollableScrollPhysics>());
    },
  );

  testWidgets(
    'WFD01/WFD02/WFD06 cover collapsible, pressed, disabled, focus, and semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpPage(tester, const InteractionPlaygroundPage());

      final disclosure = find.byKey(
        const ValueKey('interaction-disclosure-semantics'),
      );
      expect(tester.getSemantics(disclosure).label, '收起高级设置');
      expect(
        tester.getSemantics(disclosure).flagsCollection.isExpanded,
        ui.Tristate.isTrue,
      );
      expect(
        tester
            .getSize(
              find.byKey(const ValueKey('interaction-collapsible-vertical')),
            )
            .height,
        greaterThan(0),
      );
      expect(
        tester
            .getSize(
              find.byKey(const ValueKey('interaction-collapsible-horizontal')),
            )
            .width,
        greaterThan(0),
      );

      await tester.tap(find.byKey(const ValueKey('interaction-disclosure')));
      await tester.pumpAndSettle();
      expect(tester.getSemantics(disclosure).label, '展开高级设置');

      final tappable = find.byKey(const ValueKey('interaction-tappable'));
      await tester.ensureVisible(tappable);
      final beforeFocus = tester.getSize(tappable);
      final node = tester.widget<FTappable>(tappable).focusNode!;
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isTrue);
      expect(tester.getSize(tappable), beforeFocus);
      expect(
        find.descendant(of: tappable, matching: find.byType(FFocusedOutline)),
        findsOneWidget,
      );

      final gesture = await tester.startGesture(tester.getCenter(tappable));
      await tester.pump(const Duration(milliseconds: 120));
      expect(
        _decorationColor(
          tester,
          const ValueKey('interaction-tappable-surface'),
        ),
        lightTheme.colors.secondary,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      final enabled = find.byKey(const ValueKey('interaction-enabled'));
      tester.widget<FSwitch>(enabled).onChange!(false);
      await tester.pumpAndSettle();
      await tester.ensureVisible(tappable);
      await tester.pumpAndSettle();
      expect(tester.widget<FTappable>(tappable).onPress, isNull);
      final disabledSemantics = tester
          .widgetList<Semantics>(
            find.descendant(of: tappable, matching: find.byType(Semantics)),
          )
          .singleWhere((semantics) => semantics.properties.label == '应用当前设置');
      expect(disabledSemantics.properties.enabled, isFalse);
      semantics.dispose();
    },
  );

  testWidgets('G04/R02 icons search, size, source, copy, and reset', (
    tester,
  ) async {
    MethodCall? clipboardCall;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') clipboardCall = call;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _pumpPage(tester, const IconsPage());

    await tester.enterText(
      find.byKey(const ValueKey('icons-search')),
      'calendar',
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('icon-calendar')), findsOneWidget);
    expect(find.byKey(const ValueKey('icon-search')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('icons-size-36')));
    final mapping = find.byKey(const ValueKey('icons-theme-mapping'));
    await tester.ensureVisible(mapping);
    tester.widget<FSwitch>(mapping).onChange!(false);
    await tester.pump(const Duration(milliseconds: 200));
    expect(_summary(tester), contains('size: 36'));
    expect(_summary(tester), contains('themeMapping: false'));

    await tester.ensureVisible(find.byKey(const ValueKey('playground-copy')));
    await tester.tap(find.byKey(const ValueKey('playground-copy')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      (clipboardCall?.arguments as Map<String, dynamic>)['text'],
      contains('FLucideIcons'),
    );

    await tester.pump(const Duration(seconds: 6));
    await tester.ensureVisible(find.byKey(const ValueKey('playground-reset')));
    await tester.tap(find.byKey(const ValueKey('playground-reset')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_summary(tester), contains('size: 28'));
    expect(_summary(tester), contains('themeMapping: true'));
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const ValueKey('icons-search')),
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      isEmpty,
    );

    final home = find.byKey(const ValueKey('icon-home'));
    await tester.ensureVisible(home);
    await tester.tap(home);
    await tester.pump(const Duration(milliseconds: 200));
    expect(_summary(tester), contains('icon: home'));
    expect(_summary(tester), contains('themeMapping: false'));
    expect(tester.widget<FSwitch>(mapping).enabled, isFalse);
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey('icons-selected-preview')))
          .icon,
      FLucideIcons.house,
    );
    expect(find.textContaining('FLucideIcons.house'), findsOneWidget);
    expect(find.textContaining('context.theme.icons.home'), findsNothing);
  });

  testWidgets('foundation playgrounds fit 320px with 2x text', (tester) async {
    for (final page in const [
      AppShellPlaygroundPage(),
      InteractionPlaygroundPage(),
      IconsPage(),
    ]) {
      await _pumpPage(tester, page, size: const Size(320, 844), textScale: 2);
      expect(tester.takeException(), isNull, reason: '$page');
    }
  });
}

String _summary(WidgetTester tester) => tester
    .widget<Text>(find.byKey(const ValueKey('playground-parameter-summary')))
    .data!;

Color? _decorationColor(WidgetTester tester, Key key) =>
    (tester.widget<DecoratedBox>(find.byKey(key)).decoration as BoxDecoration)
        .color;

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  Size size = const Size(390, 844),
  double textScale = 1,
  ui.TextDirection textDirection = ui.TextDirection.ltr,
  FPlatformVariant? platform,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      assetLoader: _InMemoryAssetLoader(_translations),
      saveLocale: false,
      child: _TestHost(
        page: page,
        textScale: textScale,
        textDirection: textDirection,
        platform: platform,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      Future.value(Map.of(translations));
}

class _TestHost extends StatelessWidget {
  const _TestHost({
    required this.page,
    required this.textScale,
    required this.textDirection,
    required this.platform,
  });

  final Widget page;
  final double textScale;
  final ui.TextDirection textDirection;
  final FPlatformVariant? platform;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: [
      ...context.localizationDelegates,
      FLocalizations.delegate,
    ],
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Directionality(textDirection: textDirection, child: page),
    ),
    builder: (context, child) => FTheme(
      data: lightTheme,
      platform: platform,
      child: FToaster(
        child: FTooltipGroup(child: child ?? const SizedBox.shrink()),
      ),
    ),
  );
}
