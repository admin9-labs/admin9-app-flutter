import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/features/feedback/presentation/pages/alerts_progress_page.dart';
import 'package:admin9_app_flutter/features/feedback/presentation/pages/dialogs_page.dart';
import 'package:admin9_app_flutter/features/feedback/presentation/pages/feedback_page.dart';
import 'package:admin9_app_flutter/features/feedback/presentation/pages/popovers_page.dart';
import 'package:admin9_app_flutter/features/feedback/presentation/pages/sheets_page.dart';
import 'package:admin9_app_flutter/features/feedback/presentation/pages/toasts_tooltips_page.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _locale = Locale('zh', 'CN');
late Map<String, dynamic> _translations;

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    _translations = jsonDecode(
      await File('assets/translations/zh-CN.json').readAsString(),
    ) as Map<String, dynamic>;
  });

  testWidgets('alerts and progress render with finite frame pumping', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const AlertsProgressPage());

    expect(find.byType(FAlert), findsNWidgets(2));
    for (final alert in tester.widgetList<FAlert>(find.byType(FAlert))) {
      expect(alert.liveRegion, isFalse);
    }
    for (var index = 0; index < 2; index++) {
      expect(
        tester
            .getSemantics(find.byType(FAlert).at(index))
            .flagsCollection
            .isLiveRegion,
        isFalse,
      );
    }
    expect(find.byType(FCircularProgress), findsOneWidget);
    expect(find.byType(FDeterminateProgress), findsOneWidget);
    expect(find.byType(FProgress), findsOneWidget);
    expect(
      tester
          .widget<FDeterminateProgress>(find.byType(FDeterminateProgress))
          .value,
      0.65,
    );

    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('feedback catalog fits a narrow screen at 2x text scale', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      const FeedbackPage(),
      size: const Size(320, 844),
      textScale: 2,
    );

    expect(find.text('打开提示条与工具提示'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dialog opens and dismisses through its action', (tester) async {
    await _pumpPage(tester, const DialogsPage());

    await tester.tap(find.text('打开对话框'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('确认操作需要确认。'), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('确认操作需要确认。'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('modal and persistent sheets close and dispose safely', (
    tester,
  ) async {
    await _pumpPage(tester, const SheetsPage());

    await tester.tap(find.text('打开模态面板'));
    await tester.pumpAndSettle();
    expect(find.text('模态面板操作需要确认。'), findsOneWidget);
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();
    expect(find.text('模态面板操作需要确认。'), findsNothing);

    await tester.tap(find.text('切换常驻面板'));
    await tester.pumpAndSettle();
    expect(find.text('常驻面板操作需要确认。'), findsOneWidget);
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();
    expect(find.text('常驻面板操作需要确认。'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });

  testWidgets('popover and menu open and update the selected value', (
    tester,
  ) async {
    await _pumpPage(tester, const PopoversPage());

    await tester.tap(find.text('打开浮层'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('浮层内容'), findsWidgets);
    await tester.tap(find.text('确认'));
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('打开菜单'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('第二项'), findsOneWidget);
    await tester.tap(find.text('第二项'));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('已选择：第二项'), findsOneWidget);
    expect(find.text('第二项'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('repeated toasts expire after leaving the page', (tester) async {
    final page = await _pumpPage(tester, const ToastsTooltipsPage());

    expect(find.byType(FToast), findsOneWidget);
    await tester.tap(find.text('显示'));
    await tester.tap(find.text('显示'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('操作成功'), findsNWidgets(2));
    expect(find.byType(FToast), findsNWidgets(3));

    page.value = const SizedBox.shrink();
    await tester.pump();
    expect(find.text('操作成功'), findsNWidgets(2));

    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('操作成功'), findsNothing);
    expect(find.byType(FToast), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tooltip button is named and supports tap and long press', (
    tester,
  ) async {
    final page = await _pumpPage(tester, const ToastsTooltipsPage());

    var tooltipButton = find.descendant(
      of: find.byType(FTooltip),
      matching: find.byType(FButton),
    );
    expect(tester.widget<FButton>(tooltipButton).semanticsLabel, '移动端组件示例');

    await tester.tap(tooltipButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('移动端组件示例'), findsOneWidget);

    page.value = const SizedBox.shrink();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('移动端组件示例'), findsNothing);

    page.value = const ToastsTooltipsPage(key: ValueKey('long-press'));
    await tester.pump(const Duration(milliseconds: 300));
    tooltipButton = find.descendant(
      of: find.byType(FTooltip),
      matching: find.byType(FButton),
    );
    await tester.longPress(tooltipButton);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('移动端组件示例'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));
  });
}

Future<ValueNotifier<Widget>> _pumpPage(
  WidgetTester tester,
  Widget page, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final pageListenable = ValueNotifier<Widget>(const SizedBox.shrink());
  addTearDown(pageListenable.dispose);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [_locale],
      fallbackLocale: _locale,
      startLocale: _locale,
      path: 'assets/translations',
      assetLoader: _InMemoryAssetLoader(_translations),
      saveLocale: false,
      child: _TestHost(page: pageListenable),
    ),
  );
  await tester.pumpAndSettle();
  pageListenable.value = page;
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return pageListenable;
}

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      Future.value(Map.of(translations));
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.page});

  final ValueListenable<Widget> page;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: [
      ...context.localizationDelegates,
      FLocalizations.delegate,
    ],
    home: ValueListenableBuilder(
      valueListenable: page,
      builder: (_, page, _) => FScaffold(childPad: false, child: page),
    ),
    builder: (context, child) => FTheme(
      data: lightTheme,
      child: FToaster(
        child: FTooltipGroup(child: child ?? const SizedBox.shrink()),
      ),
    ),
  );
}
