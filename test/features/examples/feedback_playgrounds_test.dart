import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/features/examples/presentation/pages/feedback/playgrounds/async_status_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/feedback/playgrounds/confirmation_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/feedback/playgrounds/contextual_feedback_playground_page.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Map<String, dynamic> _translations;

void main() {
  final clipboardCalls = <MethodCall>[];

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    _translations = jsonDecode(
      File('assets/translations/zh-CN.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  });

  setUp(() {
    clipboardCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardCalls.add(call);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('WFB01/WFB02/WFB03/WFB04/WO07 cover async status and Toast', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const AsyncStatusPlaygroundPage());

    expect(find.byType(FAlert), findsOneWidget);
    expect(find.byType(FCircularProgress), findsWidgets);
    expect(find.byType(FDeterminateProgress), findsOneWidget);
    expect(find.byType(FProgress), findsOneWidget);
    expect(_summary(tester), contains('value: 0.35'));
    expect(find.text('同步配置可用'), findsOneWidget);
    expect(find.text('等待开始上传与同步。'), findsWidgets);
    expect(
      tester
          .widget<FAlert>(find.byKey(const ValueKey('async-alert')))
          .liveRegion,
      isFalse,
    );
    expect(find.semantics.byLabel('同步活动指示器'), findsOneWidget);
    expect(find.semantics.byLabel('后台同步进度'), findsOneWidget);
    expect(find.semantics.byLabel('上传完成进度').evaluate().single.value, '35%');
    final circularTransform = find.descendant(
      of: find.byKey(const ValueKey('async-circular-progress')),
      matching: find.byType(Transform),
    );
    final circularBefore = tester
        .widget<Transform>(circularTransform)
        .transform
        .storage
        .toList();
    final linearPosition = find.descendant(
      of: find.byKey(const ValueKey('async-indeterminate-progress')),
      matching: find.byType(PositionedDirectional),
    );
    final linearBefore = tester
        .widget<PositionedDirectional>(linearPosition)
        .start;
    await tester.pump(const Duration(milliseconds: 100));
    final circularAfter = tester
        .widget<Transform>(circularTransform)
        .transform
        .storage
        .toList();
    final linearAfter = tester
        .widget<PositionedDirectional>(linearPosition)
        .start;
    expect(circularAfter, isNot(circularBefore));
    expect(linearAfter, isNot(linearBefore));

    tester
        .widget<FSwitch>(
          find.byKey(const ValueKey('async-circular-size-control')),
        )
        .onChange!(true);
    await tester.pump();
    expect(
      tester
          .widget<FCircularProgress>(
            find.byKey(const ValueKey('async-circular-progress')),
          )
          .size,
      FCircularProgressSizeVariant.xl,
    );

    tester
        .widget<FSwitch>(find.byKey(const ValueKey('async-error-control')))
        .onChange!(true);
    await tester.pump();
    expect(
      tester.widget<FAlert>(find.byKey(const ValueKey('async-alert'))).variant,
      FAlertVariant.destructive,
    );
    expect(_summary(tester), contains('error: true'));

    tester
        .widget<FSwitch>(find.byKey(const ValueKey('async-enabled-control')))
        .onChange!(false);
    await tester.pump();
    expect(
      tester.widget<FButton>(find.byKey(const ValueKey('async-run'))).onPress,
      isNull,
    );

    tester
        .widget<FSwitch>(find.byKey(const ValueKey('async-enabled-control')))
        .onChange!(true);
    tester
        .widget<FSwitch>(find.byKey(const ValueKey('async-error-control')))
        .onChange!(false);
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('async-run')));
    final triggerFocus = tester
        .widget<FButton>(find.byKey(const ValueKey('async-run')))
        .focusNode!;
    await tester.tap(find.byKey(const ValueKey('async-run')));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('正在同步最新内容。'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('上传与同步已完成。'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester
          .widget<FDeterminateProgress>(
            find.byKey(const ValueKey('async-determinate-progress')),
          )
          .value,
      1,
    );
    var toast = find.byType(FToast);
    expect(toast, findsOneWidget);
    expect(tester.widget<FToast>(toast).variant, FToastVariant.primary);
    expect(tester.getCenter(toast).dy, greaterThan(844 / 2));
    await _pressButton(tester, const ValueKey('async-toast-dismiss'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(toast, findsNothing);
    expect(triggerFocus.hasFocus, isTrue);

    tester
        .widget<FSwitch>(find.byKey(const ValueKey('async-error-control')))
        .onChange!(true);
    tester
        .widget<FSwitch>(find.byKey(const ValueKey('async-toast-top-control')))
        .onChange!(true);
    tester
        .widget<FSwitch>(
          find.byKey(const ValueKey('async-toast-short-control')),
        )
        .onChange!(true);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('async-run')));
    await tester.pump(const Duration(milliseconds: 200));
    toast = find.byType(FToast);
    expect(toast, findsOneWidget);
    expect(tester.widget<FToast>(toast).variant, FToastVariant.destructive);
    expect(tester.getCenter(toast).dy, lessThan(844 / 2));
    expect(_summary(tester), contains('alignment: topCenter'));
    expect(_summary(tester), contains('duration: 1s'));
    await tester.pump(const Duration(milliseconds: 800));
    expect(toast, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 400));
    expect(toast, findsNothing);
    expect(triggerFocus.hasFocus, isTrue);

    await _copyAndExpect(tester, clipboardCalls);
    await _pressButton(tester, const ValueKey('playground-reset'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_summary(tester), contains('value: 0.35'));
    expect(_summary(tester), contains('alignment: bottomCenter'));
    expect(_summary(tester), contains('duration: 5s'));
    expect(find.text('等待开始上传与同步。'), findsWidgets);
    semantics.dispose();
    await _disposePage(tester);
  });

  testWidgets('reset invalidates an in-flight async status update', (
    tester,
  ) async {
    await _pumpPage(tester, const AsyncStatusPlaygroundPage());

    await _pressButton(tester, const ValueKey('async-run'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('正在同步最新内容。'), findsWidgets);

    await _pressButton(tester, const ValueKey('playground-reset'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(_summary(tester), contains('value: 0.35'));
    expect(find.text('等待开始上传与同步。'), findsWidgets);
    expect(find.byType(FToast), findsNothing);
    await _disposePage(tester);
  });

  testWidgets('WO02/WO03/WO06/WFD03 cover confirmation overlays', (
    tester,
  ) async {
    await _pumpPage(tester, const ConfirmationPlaygroundPage());
    final triggerFocus = tester
        .widget<FButton>(find.byKey(const ValueKey('confirmation-open')))
        .focusNode!;

    await tester.ensureVisible(find.byKey(const ValueKey('confirmation-open')));
    await tester.tap(find.byKey(const ValueKey('confirmation-open')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('confirmation-dialog')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('confirmation-dialog-vertical')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('confirmation-dialog-horizontal')),
      findsNothing,
    );
    await _pressButton(tester, const ValueKey('confirmation-cancel'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('本次操作已取消。'), findsOneWidget);
    expect(triggerFocus.hasFocus, isTrue);

    await _pressButton(tester, const ValueKey('confirmation-open'));
    await tester.pump(const Duration(milliseconds: 300));
    await _pressButton(tester, const ValueKey('confirmation-confirm'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('关键操作已经确认。'), findsOneWidget);
    expect(triggerFocus.hasFocus, isTrue);

    await _pressButton(tester, const ValueKey('confirmation-open'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(FModalBarrier), findsWidgets);
    await _dismissActiveBarrier(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('confirmation-dialog')), findsNothing);
    expect(find.text('本次操作已取消。'), findsOneWidget);
    expect(triggerFocus.hasFocus, isTrue);

    await tester.ensureVisible(find.text('编辑底部面板'));
    await tester.tap(find.text('编辑底部面板'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.byKey(const ValueKey('confirmation-open')));
    await tester.tap(find.byKey(const ValueKey('confirmation-open')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('confirmation-draft')),
        matching: find.byType(SafeArea),
      ),
      findsWidgets,
    );
    var editable = find.descendant(
      of: find.byKey(const ValueKey('confirmation-draft')),
      matching: find.byType(EditableText),
    );
    await tester.enterText(editable, '取消不应保存');
    await _pressButton(tester, const ValueKey('confirmation-sheet-cancel'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('本次操作已取消。'), findsOneWidget);
    expect(_summary(tester), contains('Admin9 Starter'));
    expect(_summary(tester), isNot(contains('取消不应保存')));
    expect(triggerFocus.hasFocus, isTrue);

    await _pressButton(tester, const ValueKey('confirmation-open'));
    await tester.pump(const Duration(milliseconds: 300));
    editable = find.descendant(
      of: find.byKey(const ValueKey('confirmation-draft')),
      matching: find.byType(EditableText),
    );
    await tester.enterText(editable, '遮罩不应保存');
    await _dismissActiveBarrier(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('本次操作已取消。'), findsOneWidget);
    expect(_summary(tester), contains('Admin9 Starter'));
    expect(_summary(tester), isNot(contains('遮罩不应保存')));

    await _pressButton(tester, const ValueKey('confirmation-open'));
    await tester.pump(const Duration(milliseconds: 300));
    editable = find.descendant(
      of: find.byKey(const ValueKey('confirmation-draft')),
      matching: find.byType(EditableText),
    );
    await tester.enterText(editable, '新的 Starter 名称');
    await _pressButton(tester, const ValueKey('confirmation-save'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('编辑内容已保存。'), findsOneWidget);
    expect(_summary(tester), contains('新的 Starter 名称'));
    expect(triggerFocus.hasFocus, isTrue);

    await tester.ensureVisible(find.text('持续显示的信息面板'));
    await tester.tap(find.text('持续显示的信息面板'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.byKey(const ValueKey('confirmation-open')));
    await tester.tap(find.byKey(const ValueKey('confirmation-open')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const ValueKey('confirmation-persistent-content')),
      findsOneWidget,
    );
    await _pressButton(
      tester,
      const ValueKey('confirmation-underlying-action'),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(_summary(tester), contains('underlyingPresses: 1'));
    expect(
      find.byKey(const ValueKey('confirmation-persistent-content')),
      findsOneWidget,
    );
    await _pressButton(tester, const ValueKey('confirmation-open'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const ValueKey('confirmation-persistent-content')),
      findsNothing,
    );
    await _pressButton(tester, const ValueKey('confirmation-open'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const ValueKey('confirmation-persistent-content')),
      findsOneWidget,
    );
    await _pressButton(tester, const ValueKey('confirmation-persistent-close'));
    await tester.pump(const Duration(milliseconds: 300));

    await _copyAndExpect(tester, clipboardCalls);
    await _pressButton(tester, const ValueKey('playground-reset'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_summary(tester), contains('mode: dialog'));
    expect(_summary(tester), contains('Admin9 Starter'));
    expect(_summary(tester), contains('underlyingPresses: 0'));
    await _disposePage(tester);
  });

  testWidgets('dialog adaptive layout uses horizontal content above sm', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      const ConfirmationPlaygroundPage(),
      size: const Size(800, 844),
    );
    final trigger = find.byKey(const ValueKey('confirmation-open'));
    final focus = tester.widget<FButton>(trigger).focusNode!;

    await _pressButton(tester, const ValueKey('confirmation-open'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const ValueKey('confirmation-dialog-horizontal')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('confirmation-dialog-vertical')),
      findsNothing,
    );
    await _pressButton(tester, const ValueKey('confirmation-cancel'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(focus.hasFocus, isTrue);
    await _disposePage(tester);
  });

  testWidgets('WO04/WO05/WO08/WFD05 cover contextual overlays', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const ContextualFeedbackPlaygroundPage());

    tester
        .widget<FSwitch>(
          find.byKey(const ValueKey('contextual-placement-control')),
        )
        .onChange!(true);
    await tester.pump();
    expect(_summary(tester), contains('placement: above'));
    final popover = tester.widget<FPopover>(
      find.byKey(const ValueKey('contextual-popover')),
    );
    expect(popover.popoverAnchor, AlignmentGeometry.bottomCenter);
    expect(popover.childAnchor, AlignmentGeometry.topCenter);
    expect(popover.overflow, FPortalOverflow.flip);
    final menu = tester.widget<FPopoverMenu>(
      find.byKey(const ValueKey('contextual-menu')),
    );
    expect(menu.menuAnchor, AlignmentGeometry.bottomCenter);
    expect(menu.childAnchor, AlignmentGeometry.topCenter);
    expect(menu.overflow, FPortalOverflow.flip);

    await tester.ensureVisible(
      find.byKey(const ValueKey('contextual-popover-open')),
    );
    await _pressButton(tester, const ValueKey('contextual-popover-open'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const ValueKey('contextual-popover-content')),
      findsOneWidget,
    );
    expect(find.byType(FPortal), findsWidgets);
    final contentRect = tester.getRect(
      find.byKey(const ValueKey('contextual-popover-content')),
    );
    expect(contentRect.top, greaterThanOrEqualTo(0));
    expect(contentRect.bottom, lessThanOrEqualTo(844));
    await _pressButton(tester, const ValueKey('contextual-popover-apply'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('上下文设置已应用。'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('contextual-popover-content')),
      findsNothing,
    );

    await _pressButton(tester, const ValueKey('contextual-menu-open'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('分享对象'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('对象已进入分享流程。'), findsOneWidget);
    expect(find.text('分享对象'), findsNothing);

    final tooltip = tester.widget<FTooltip>(
      find.byKey(const ValueKey('contextual-tooltip')),
    );
    expect(tooltip.longPress, isTrue);
    expect(find.semantics.byLabel('显示操作提示'), findsOneWidget);
    await _pressButton(tester, const ValueKey('contextual-tooltip-open'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('查看这个操作的简短说明'), findsOneWidget);
    await _pressButton(tester, const ValueKey('contextual-tooltip-open'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('查看这个操作的简短说明'), findsNothing);

    await tester.ensureVisible(
      find.byKey(const ValueKey('contextual-tooltip-open')),
    );
    await tester.longPress(
      find.byKey(const ValueKey('contextual-tooltip-open')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('查看这个操作的简短说明'), findsOneWidget);

    tester
        .widget<FSwitch>(
          find.byKey(const ValueKey('contextual-enabled-control')),
        )
        .onChange!(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester
          .widget<FButton>(
            find.byKey(const ValueKey('contextual-popover-open')),
          )
          .onPress,
      isNull,
    );
    expect(
      tester
          .widget<FTooltip>(find.byKey(const ValueKey('contextual-tooltip')))
          .longPress,
      isFalse,
    );
    expect(find.text('查看这个操作的简短说明'), findsNothing);

    await tester.longPress(
      find.byKey(const ValueKey('contextual-tooltip-open')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('查看这个操作的简短说明'), findsNothing);

    await _copyAndExpect(tester, clipboardCalls);
    await _pressButton(tester, const ValueKey('playground-reset'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 400));
    expect(_summary(tester), 'enabled: true, placement: below');
    expect(find.text('等待选择上下文操作。'), findsOneWidget);
    expect(find.text('查看这个操作的简短说明'), findsNothing);
    semantics.dispose();
    await _disposePage(tester);
    expect(find.text('查看这个操作的简短说明'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('playgrounds fit 320/390 widths with 2x text', (tester) async {
    const pages = <Widget>[
      AsyncStatusPlaygroundPage(),
      ConfirmationPlaygroundPage(),
      ContextualFeedbackPlaygroundPage(),
    ];

    for (final width in [320.0, 390.0]) {
      for (final page in pages) {
        await _pumpPage(tester, page, size: Size(width, 844), textScale: 2);
        expect(
          tester.takeException(),
          isNull,
          reason: '${page.runtimeType} at $width',
        );
      }
    }
  });
}

String _summary(WidgetTester tester) => tester
    .widget<Text>(find.byKey(const ValueKey('playground-parameter-summary')))
    .data!;

Future<void> _copyAndExpect(WidgetTester tester, List<MethodCall> calls) async {
  await tester.ensureVisible(find.byKey(const ValueKey('playground-copy')));
  await _pressButton(tester, const ValueKey('playground-copy'));
  await tester.pump(const Duration(milliseconds: 300));
  expect(calls, isNotEmpty);
  expect(calls.last.arguments, isA<Map<Object?, Object?>>());
  expect(find.text('代码已复制'), findsOneWidget);
}

Future<void> _pressButton(WidgetTester tester, Key key) async {
  final keyed = find.byKey(key);
  final widget = tester.widget(keyed);
  final button = widget is FButton
      ? widget
      : tester.widget<FButton>(
          find.descendant(of: keyed, matching: find.byType(FButton)).first,
        );
  button.onPress!();
  await tester.pump();
}

Future<void> _dismissActiveBarrier(WidgetTester tester) async {
  final barriers = find
      .byType(FModalBarrier)
      .evaluate()
      .map((element) => element.widget)
      .whereType<FModalBarrier>()
      .where((barrier) => barrier.onDismiss != null)
      .toList();
  expect(barriers, isNotEmpty);
  barriers.last.onDismiss!();
  await tester.pump();
}

Future<void> _disposePage(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 6));
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  Size size = const Size(390, 844),
  double textScale = 1,
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
      assetLoader: const _MapAssetLoader(),
      saveLocale: false,
      child: _LocalizedApp(page: page, textScale: textScale),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

class _LocalizedApp extends StatelessWidget {
  const _LocalizedApp({required this.page, required this.textScale});

  final Widget page;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: [
      ...context.localizationDelegates,
      FLocalizations.delegate,
    ],
    home: page,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: FTheme(
        data: lightTheme,
        accessibility: const FAccessibility(
          accessibleNavigation: false,
          motion: FAccessibilityMotion.all,
          focusHighlight: true,
        ),
        child: FToaster(
          child: FTooltipGroup(child: child ?? const SizedBox.shrink()),
        ),
      ),
    ),
  );
}

class _MapAssetLoader extends AssetLoader {
  const _MapAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      Future.value(Map<String, dynamic>.of(_translations));
}
