import 'dart:ui' show Tristate;

import 'package:admin9_app_flutter/admin9_ui.dart';
import 'package:admin9_app_flutter/app/brand/app_brand_theme.dart';
import 'package:admin9_app_flutter/core/design_system/components/app_feedback.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'AppPage maps bars and actions without replacing route builders',
    (tester) async {
      var activations = 0;
      await _pump(
        tester,
        platform: TargetPlatform.android,
        child: AppPage(
          title: '子页面',
          navigationMode: AppPageNavigationMode.child,
          parentLabel: '我的',
          actions: [
            AppPageAction(
              label: '搜索',
              icon: AppIconRole.search,
              onPressed: () => activations += 1,
            ),
          ],
          body: const Text('正文'),
        ),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.widget<AppBar>(find.byType(AppBar)).centerTitle, isTrue);
      expect(find.byTooltip('搜索'), findsOneWidget);
      expect(
        tester.getSize(find.byTooltip('搜索')).shortestSide,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.byTooltip('搜索'));
      expect(activations, 1);

      await _pump(
        tester,
        platform: TargetPlatform.iOS,
        child: const AppPage(
          title: '子页面',
          navigationMode: AppPageNavigationMode.child,
          parentLabel: '我的',
          body: Text('正文'),
        ),
      );
      final bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.automaticallyImplyLeading, isFalse);
      expect(bar.centerTitle, isTrue);
      expect(find.byTooltip('返回我的'), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsNothing);
    },
  );

  testWidgets('AppPage follows responsive insets and safe-area ownership', (
    tester,
  ) async {
    for (final fixture in <(Size, double)>[
      (const Size(320, 720), 16),
      (const Size(390, 844), 20),
      (const Size(600, 960), 24),
    ]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = fixture.$1;
      await _pump(
        tester,
        platform: TargetPlatform.iOS,
        child: const AppPage(
          title: '响应式页面',
          navigationMode: AppPageNavigationMode.root,
          body: SizedBox(
            key: Key('page-body'),
            width: double.infinity,
            height: 20,
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('page-body'))).dx,
        fixture.$2,
      );
      expect(
        tester
            .widget<SafeArea>(find.byKey(const Key('app-page-body-safe-area')))
            .bottom,
        isFalse,
      );
    }
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pump(
      tester,
      platform: TargetPlatform.iOS,
      child: const AppPage(
        title: '子页',
        parentLabel: '我的',
        navigationMode: AppPageNavigationMode.child,
        body: Text('内容'),
      ),
    );
    expect(
      tester
          .widget<SafeArea>(find.byKey(const Key('app-page-body-safe-area')))
          .bottom,
      isTrue,
    );
  });

  testWidgets('AppBottomNavigation uses one branded control structure', (
    tester,
  ) async {
    const destinations = [
      AppNavigationDestination(
        label: '首页',
        icon: AppIconRole.home,
        selectedIcon: AppIconRole.homeSelected,
      ),
      AppNavigationDestination(
        label: '我的',
        icon: AppIconRole.account,
        selectedIcon: AppIconRole.accountSelected,
      ),
    ];
    var selected = -1;
    await _pump(
      tester,
      platform: TargetPlatform.android,
      child: Scaffold(
        bottomNavigationBar: AppBottomNavigation(
          destinations: destinations,
          selectedIndex: 0,
          onDestinationSelected: (value) => selected = value,
        ),
      ),
    );
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel(RegExp('^\u9996页')))
          .getSemanticsData()
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    await tester.tap(find.text('我的'));
    expect(selected, 1);

    await _pump(
      tester,
      platform: TargetPlatform.iOS,
      child: CupertinoPageScaffold(
        child: Column(
          children: [
            const Expanded(child: SizedBox()),
            AppBottomNavigation(
              destinations: destinations,
              selectedIndex: 0,
              onDestinationSelected: (value) => selected = value,
            ),
          ],
        ),
      ),
    );
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.byType(CupertinoTabBar), findsNothing);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel(RegExp('^\u9996页')))
          .getSemanticsData()
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    await tester.tap(find.text('我的'));
    expect(selected, 1);
  });

  testWidgets('AppProgressIndicator maps kind and exposes bounded semantics', (
    tester,
  ) async {
    await _pump(
      tester,
      platform: TargetPlatform.android,
      child: const AppProgressIndicator(
        label: '正在同步',
        kind: AppProgressKind.linear,
        value: 0.45,
      ),
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    final semantics = tester.getSemantics(find.byType(AppProgressIndicator));
    expect(semantics.label, '正在同步');
    expect(semantics.value, '45%');

    await _pump(
      tester,
      platform: TargetPlatform.iOS,
      child: const AppProgressIndicator(label: '正在加载'),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
    expect(find.bySemanticsLabel('正在加载'), findsOneWidget);
  });

  testWidgets('iOS determinate progress is bounded for every declared kind', (
    tester,
  ) async {
    for (final kind in AppProgressKind.values) {
      for (final value in <double>[0, 0.45, 1]) {
        await _pump(
          tester,
          platform: TargetPlatform.iOS,
          child: Align(
            child: SizedBox(
              width: 240,
              child: AppProgressIndicator(
                label: '已处理',
                kind: kind,
                value: value,
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSemantics(find.byType(AppProgressIndicator)).value,
          '${(value * 100).round()}%',
        );
        expect(
          tester.getSize(find.byType(AppProgressIndicator)).width,
          lessThanOrEqualTo(240),
        );
      }
    }
  });

  testWidgets('AppFeedback applies transient and persistent lifecycles', (
    tester,
  ) async {
    final controller = AppFeedbackPresenterController();
    await _pumpFeedback(tester, controller: controller);

    for (final entry in const [
      (AppTone.info, '信息', Duration(seconds: 3)),
      (AppTone.success, '成功', Duration(seconds: 3)),
      (AppTone.warning, '警告', Duration(seconds: 5)),
      (AppTone.error, '错误', Duration(seconds: 5)),
    ]) {
      controller.show(AppFeedbackRequest(message: entry.$2, tone: entry.$1));
      await tester.pump();
      await tester.pump(entry.$3 - const Duration(milliseconds: 1));
      expect(find.text(entry.$2), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(find.text(entry.$2), findsNothing);
    }

    var actions = 0;
    controller.show(
      AppFeedbackRequest(
        message: '可撤销',
        tone: AppTone.info,
        actionLabel: '撤销',
        onAction: () => actions += 1,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('可撤销'), findsOneWidget);
    await tester.tap(find.text('撤销'));
    await tester.tap(find.text('撤销'));
    await tester.pumpAndSettle();
    expect(actions, 1);
    expect(find.text('可撤销'), findsNothing);
  });

  testWidgets('AppFeedback persists for accessible navigation and replaces', (
    tester,
  ) async {
    final controller = AppFeedbackPresenterController();
    await _pumpFeedback(
      tester,
      controller: controller,
      accessibleNavigation: true,
    );
    controller.show(
      const AppFeedbackRequest(message: '第一条', tone: AppTone.success),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('第一条'), findsOneWidget);

    controller.show(
      const AppFeedbackRequest(message: '第二条', tone: AppTone.error),
    );
    await tester.pump();
    expect(find.text('第一条'), findsNothing);
    expect(find.text('第二条'), findsOneWidget);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pump();
    expect(find.text('第二条'), findsNothing);
  });

  testWidgets('feedback replacement cancels the old transient timer', (
    tester,
  ) async {
    final controller = AppFeedbackPresenterController();
    await _pumpFeedback(tester, controller: controller);
    controller.show(
      const AppFeedbackRequest(message: '旧消息', tone: AppTone.success),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    controller.show(
      const AppFeedbackRequest(message: '新消息', tone: AppTone.error),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('旧消息'), findsNothing);
    expect(find.text('新消息'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('新消息'), findsNothing);
  });

  testWidgets('Android persistent feedback actions meet 48dp bounds', (
    tester,
  ) async {
    final controller = AppFeedbackPresenterController();
    await _pumpFeedback(tester, controller: controller);
    controller.show(
      AppFeedbackRequest(
        message: '可撤销操作',
        tone: AppTone.info,
        actionLabel: '撤销',
        onAction: () {},
      ),
    );
    await tester.pump();
    expect(
      tester.getSize(find.widgetWithText(TextButton, '撤销')).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byTooltip('关闭')).shortestSide,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('iOS feedback uses the shared branded persistent surface', (
    tester,
  ) async {
    final controller = AppFeedbackPresenterController();
    await _pumpFeedback(
      tester,
      controller: controller,
      platform: TargetPlatform.iOS,
      mediaPadding: const EdgeInsets.only(top: 20),
      child: const AppPage(
        title: '当前页面',
        navigationMode: AppPageNavigationMode.child,
        parentLabel: '上一级',
        body: Text('页面内容'),
      ),
    );
    controller.show(
      AppFeedbackRequest(
        message: '操作结果',
        tone: AppTone.info,
        actionLabel: '撤销',
        onAction: () {},
      ),
    );
    await tester.pump();
    expect(find.bySemanticsLabel('操作结果'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('操作结果')),
      matchesSemantics(label: '操作结果', isLiveRegion: true),
    );
    final action = find.bySemanticsLabel('撤销');
    final close = find.bySemanticsLabel('关闭');
    expect(action, findsOneWidget);
    expect(close, findsOneWidget);
    final actionData = tester.getSemantics(action).getSemanticsData();
    final closeData = tester.getSemantics(close).getSemanticsData();
    expect(actionData.label, '撤销');
    expect(actionData.flagsCollection.isButton, isTrue);
    expect(actionData.hasAction(SemanticsAction.tap), isTrue);
    expect(closeData.label, '关闭');
    expect(closeData.flagsCollection.isButton, isTrue);
    expect(closeData.hasAction(SemanticsAction.tap), isTrue);
    expect(
      tester.getSemantics(find.bySemanticsLabel('操作结果')).sortKey,
      const OrdinalSortKey(1),
    );
    expect(tester.getSemantics(action).sortKey, const OrdinalSortKey(2));
    expect(tester.getSemantics(close).sortKey, const OrdinalSortKey(3));
    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(find.byType(CupertinoButton), findsNothing);
    expect(
      tester.getSize(find.widgetWithText(TextButton, '撤销')).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byTooltip('关闭')).shortestSide,
      greaterThanOrEqualTo(48),
    );
    expect(
      find.ancestor(
        of: find.bySemanticsLabel('操作结果'),
        matching: find.byType(Overlay),
      ),
      findsOneWidget,
    );
  });

  testWidgets('persistent feedback semantics actions execute once', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      final controller = AppFeedbackPresenterController();
      var actionCalls = 0;
      await _pumpFeedback(tester, controller: controller, platform: platform);
      controller.show(
        AppFeedbackRequest(
          message: '可撤销操作',
          tone: AppTone.info,
          actionLabel: '撤销',
          onAction: () => actionCalls += 1,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final action = find.bySemanticsLabel('撤销');
      final close = find.bySemanticsLabel('关闭');
      expect(
        tester
            .getSemantics(action)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      expect(
        tester
            .getSemantics(close)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      tester.semantics.tap(find.semantics.byLabel('撤销'));
      await tester.pumpAndSettle();
      expect(actionCalls, 1);
      expect(find.text('可撤销操作'), findsNothing);

      controller.show(
        AppFeedbackRequest(
          message: '可关闭操作',
          tone: AppTone.info,
          actionLabel: '撤销',
          onAction: () => actionCalls += 1,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      tester.semantics.tap(find.semantics.byLabel('关闭'));
      await tester.pumpAndSettle();
      expect(actionCalls, 1);
      expect(find.text('可关闭操作'), findsNothing);
    }
    semantics.dispose();
  });

  testWidgets(
    'feedback follows accessible navigation changes and keeps focus',
    (tester) async {
      final controller = AppFeedbackPresenterController();
      final navigatorKey = GlobalKey<NavigatorState>();
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await _pumpFeedback(
        tester,
        controller: controller,
        navigatorKey: navigatorKey,
        child: TextButton(
          focusNode: focusNode,
          onPressed: () {},
          child: const Text('保持焦点'),
        ),
      );
      focusNode.requestFocus();
      await tester.pump();
      controller.show(
        const AppFeedbackRequest(message: '运行时切换', tone: AppTone.info),
      );
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);

      await _pumpFeedback(
        tester,
        controller: controller,
        navigatorKey: navigatorKey,
        accessibleNavigation: true,
        child: TextButton(
          focusNode: focusNode,
          onPressed: () {},
          child: const Text('保持焦点'),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(MaterialBanner), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await tester.pump(const Duration(seconds: 30));
      expect(find.text('运行时切换'), findsOneWidget);
      expect(focusNode.hasFocus, isTrue);

      await _pumpFeedback(
        tester,
        controller: controller,
        navigatorKey: navigatorKey,
        child: TextButton(
          focusNode: focusNode,
          onPressed: () {},
          child: const Text('保持焦点'),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('运行时切换'), findsNothing);
    },
  );

  for (final row in _matrix) {
    testWidgets('Phase 2 A-L layout row ${row.name}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = row.size;
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final feedback = AppFeedbackPresenterController();
      final navigatorKey = GlobalKey<NavigatorState>();
      await _pump(
        tester,
        platform: row.platform,
        brightness: row.brightness,
        highContrast: row.highContrast,
        textScaler: TextScaler.linear(row.systemScale * row.appScale),
        navigatorKey: navigatorKey,
        child: AppFeedback(
          controller: feedback,
          navigatorKey: navigatorKey,
          child: const _Phase2MatrixShell(),
        ),
      );
      feedback.show(
        AppFeedbackRequest(
          message: '当前状态可撤销',
          tone: AppTone.info,
          actionLabel: '撤销',
          onAction: () {},
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('最长中文说明'), findsOneWidget);
      expect(find.text('当前状态可撤销'), findsOneWidget);
      const minimum = 48.0;
      final homeDestination = find.text('首页');
      final accountDestination = find.text('我的');
      expect(homeDestination, findsOneWidget);
      expect(accountDestination, findsOneWidget);
      final navigationSize = tester.getSize(find.byType(AppBottomNavigation));
      expect(navigationSize.height, greaterThanOrEqualTo(minimum));
      expect(navigationSize.width / 2, greaterThanOrEqualTo(minimum));
      expect(
        tester.getSemantics(find.byType(AppProgressIndicator)).value,
        '45%',
      );
      final feedbackAction = find.bySemanticsLabel('撤销');
      expect(feedbackAction, findsOneWidget);
      final actionControl = find.widgetWithText(TextButton, '撤销');
      expect(
        tester.getSize(actionControl).height,
        greaterThanOrEqualTo(minimum),
      );
      await tester.tap(accountDestination);
      await tester.pump();
      expect(
        tester
            .widget<AppBottomNavigation>(find.byType(AppBottomNavigation))
            .selectedIndex,
        1,
      );
      feedback.dismiss();
      await tester.pump();
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -800),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required TargetPlatform platform,
  required Widget child,
  Brightness brightness = Brightness.light,
  bool highContrast = false,
  TextScaler textScaler = TextScaler.noScaling,
  GlobalKey<NavigatorState>? navigatorKey,
}) async {
  final resolved = AppTheme.resolve(
    brightness: brightness,
    platform: platform,
    highContrast: highContrast,
    reduceMotion: false,
    boldText: false,
    brandPrimary: brightness == Brightness.dark
        ? appBrandTheme.primaryDark
        : appBrandTheme.primaryLight,
    brandSecondary: brightness == Brightness.dark
        ? appBrandTheme.secondaryDark
        : appBrandTheme.secondaryLight,
  );
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      theme: resolved.material,
      home: MediaQuery(
        data: MediaQueryData(
          size: tester.view.physicalSize,
          devicePixelRatio: 1,
          textScaler: textScaler,
          highContrast: highContrast,
        ),
        child: Theme(
          data: resolved.material,
          child: AppDesignScope(tokens: resolved.tokens, child: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _pumpFeedback(
  WidgetTester tester, {
  required AppFeedbackPresenterController controller,
  TargetPlatform platform = TargetPlatform.android,
  bool accessibleNavigation = false,
  EdgeInsets mediaPadding = EdgeInsets.zero,
  Widget child = const Scaffold(body: Text('内容')),
  GlobalKey<NavigatorState>? navigatorKey,
}) async {
  final resolved = AppTheme.resolve(
    brightness: Brightness.light,
    platform: platform,
    highContrast: false,
    reduceMotion: false,
    boldText: false,
    brandPrimary: appBrandTheme.primaryLight,
    brandSecondary: appBrandTheme.secondaryLight,
  );
  final effectiveNavigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: effectiveNavigatorKey,
      theme: resolved.material,
      home: MediaQuery(
        data: MediaQueryData(
          accessibleNavigation: accessibleNavigation,
          padding: mediaPadding,
        ),
        child: Theme(
          data: resolved.material,
          child: AppDesignScope(
            tokens: resolved.tokens,
            child: AppFeedback(
              controller: controller,
              navigatorKey: effectiveNavigatorKey,
              child: Scaffold(body: child),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

class _Phase2MatrixShell extends StatefulWidget {
  const _Phase2MatrixShell();

  @override
  State<_Phase2MatrixShell> createState() => _Phase2MatrixShellState();
}

class _Phase2MatrixShellState extends State<_Phase2MatrixShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final navigation = AppBottomNavigation(
      destinations: const [
        AppNavigationDestination(
          label: '首页',
          icon: AppIconRole.home,
          selectedIcon: AppIconRole.homeSelected,
        ),
        AppNavigationDestination(
          label: '我的',
          icon: AppIconRole.account,
          selectedIcon: AppIconRole.accountSelected,
        ),
      ],
      selectedIndex: _selectedIndex,
      onDestinationSelected: (value) => setState(() => _selectedIndex = value),
    );
    const page = AppPage(
      title: '最长页面标题与内容增长验证',
      navigationMode: AppPageNavigationMode.root,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('这是一段用于验证窄屏、横屏和大字号内容增长的最长中文说明文字。'),
          SizedBox(height: 16),
          AppProgressIndicator(
            label: '正在处理当前任务，请保持页面开启',
            kind: AppProgressKind.linear,
            value: 0.45,
          ),
        ],
      ),
    );
    return Scaffold(body: page, bottomNavigationBar: navigation);
  }
}

final _matrix = <_MatrixRow>[
  _MatrixRow(
    'A',
    TargetPlatform.android,
    Size(320, 720),
    Brightness.light,
    false,
    1,
    1,
  ),
  _MatrixRow(
    'B',
    TargetPlatform.iOS,
    Size(320, 720),
    Brightness.light,
    false,
    1.24,
    1,
  ),
  _MatrixRow(
    'C',
    TargetPlatform.android,
    Size(360, 800),
    Brightness.dark,
    false,
    1.12,
    1,
  ),
  _MatrixRow(
    'D',
    TargetPlatform.iOS,
    Size(360, 800),
    Brightness.dark,
    false,
    1,
    1,
  ),
  _MatrixRow(
    'E',
    TargetPlatform.android,
    Size(390, 844),
    Brightness.light,
    false,
    1.24,
    1,
  ),
  _MatrixRow(
    'F',
    TargetPlatform.iOS,
    Size(390, 844),
    Brightness.dark,
    false,
    1.24,
    1,
  ),
  _MatrixRow(
    'G',
    TargetPlatform.android,
    Size(600, 960),
    Brightness.dark,
    true,
    1,
    1,
  ),
  _MatrixRow(
    'H',
    TargetPlatform.iOS,
    Size(600, 960),
    Brightness.light,
    true,
    1.12,
    1,
  ),
  _MatrixRow(
    'I',
    TargetPlatform.android,
    Size(844, 390),
    Brightness.light,
    false,
    1.12,
    1,
  ),
  _MatrixRow(
    'J',
    TargetPlatform.iOS,
    Size(844, 390),
    Brightness.dark,
    false,
    1.24,
    1,
  ),
  _MatrixRow(
    'K',
    TargetPlatform.android,
    Size(390, 844),
    Brightness.light,
    true,
    1.24,
    2,
  ),
  _MatrixRow(
    'L',
    TargetPlatform.iOS,
    Size(390, 844),
    Brightness.dark,
    true,
    1.24,
    3,
  ),
];

final class _MatrixRow {
  const _MatrixRow(
    this.name,
    this.platform,
    this.size,
    this.brightness,
    this.highContrast,
    this.appScale,
    this.systemScale,
  );

  final String name;
  final TargetPlatform platform;
  final Size size;
  final Brightness brightness;
  final bool highContrast;
  final double appScale;
  final double systemScale;
}
