import 'package:admin9_app_flutter/app/brand/app_brand_theme.dart';
import 'package:admin9_app_flutter/core/design_system/components/app_form_components.dart';
import 'package:admin9_app_flutter/core/design_system/components/app_interaction.dart';
import 'package:admin9_app_flutter/core/design_system/components/app_notice.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_contracts.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_design_tokens.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dialog and action-menu declarations reject invalid shapes', () {
    expect(
      () => AppDialog(
        variant: AppDialogVariant.information,
        title: '信息',
        body: const Text('正文'),
        confirmLabel: '知道了',
        cancelLabel: '取消',
      ),
      throwsAssertionError,
    );
    expect(
      () => AppActionMenu<int>(
        items: const [AppActionMenuItem(value: 1, label: '唯一操作')],
        onSelected: (_) {},
      ),
      throwsAssertionError,
    );
  });

  testWidgets('AppNotice exposes tone and adaptive action semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      for (final entry in const [
        (AppTone.info, '信息'),
        (AppTone.success, '成功'),
        (AppTone.warning, '警告'),
        (AppTone.error, '错误'),
      ]) {
        var calls = 0;
        await _pumpNotice(
          tester,
          platform,
          AppNotice(
            key: const Key('notice'),
            tone: entry.$1,
            title: '状态标题',
            message: '状态说明',
            actionLabel: '重试',
            onAction: () => calls += 1,
          ),
        );
        final noticeSemantics = tester.getSemantics(
          find.byKey(const Key('notice')),
        );
        expect(noticeSemantics.label, contains(entry.$2));
        expect(noticeSemantics.label, contains('状态标题'));
        expect(noticeSemantics.label, contains('状态说明'));
        expect(find.byType(TextButton), findsOneWidget);
        expect(find.byType(CupertinoButton), findsNothing);
        final action = find.byType(AppButton);
        expect(tester.getSemantics(action).label, contains('重试'));
        expect(tester.getSize(action).shortestSide, greaterThanOrEqualTo(48));
        await tester.tap(action);
        expect(calls, 1);
      }
    }
    semantics.dispose();
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('$platform action menu dispatches at most once', (
      tester,
    ) async {
      var calls = 0;
      await _pumpInteractionFixture(
        tester,
        row: _InteractionMatrixRow(
          'single-dispatch',
          platform,
          const Size(390, 844),
          1,
          1,
        ),
        child: AppActionMenu<int>(
          items: const [
            AppActionMenuItem(value: 1, label: '第一项'),
            AppActionMenuItem(value: 2, label: '第二项'),
          ],
          onSelected: (_) => calls += 1,
        ),
      );

      final action = find.text('第一项');
      await tester.tap(action);
      await tester.tap(action);
      expect(calls, 1);
    });
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('$platform dialog maps results and restores trigger focus', (
      tester,
    ) async {
      final harness = await _pumpHarness(tester, platform);
      harness.focusNode.requestFocus();
      await tester.pump();

      final confirmation = harness.controller.showConfirmation(
        title: '确认操作',
        message: '继续执行吗？',
        confirmLabel: '继续',
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(CupertinoAlertDialog), findsNothing);
      await tester.tap(find.text('取消'));
      expect(await confirmation, isFalse);
      await tester.pump();
      expect(harness.focusNode.hasFocus, isTrue);

      final barrierCancelled = harness.controller.showConfirmation(
        title: '确认操作',
        message: '点击遮罩取消。',
        confirmLabel: '继续',
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(1, 1));
      await tester.pumpAndSettle();
      expect(await barrierCancelled, isFalse);

      final destructive = harness.controller.showDestructive(
        title: '删除资料',
        message: '此操作不可撤销。',
        confirmLabel: '删除',
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(1, 1));
      await tester.pump();
      expect(find.text('删除资料'), findsOneWidget);
      await tester.tap(find.text('删除'));
      expect(await destructive, isTrue);

      final information = harness.controller.showInformation(
        title: '处理结果',
        message: '服务尚未接入。',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('知道了'));
      await information;
    });

    testWidgets('$platform action menu maps values, disabled and dismissal', (
      tester,
    ) async {
      final harness = await _pumpHarness(tester, platform);
      harness.focusNode.requestFocus();
      await tester.pump();
      final selected = harness.controller.showActionMenu<int>(
        title: '选择操作',
        items: const [
          AppActionMenuItem(value: 2, label: '不可用', enabled: false),
          AppActionMenuItem(
            value: 3,
            label: '删除',
            destructive: true,
            icon: AppIconRole.warning,
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(CupertinoActionSheet), findsNothing);
      await tester.tap(find.text('不可用'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('选择操作'), findsOneWidget);
      await tester.tap(find.text('删除'));
      expect(await selected, 3);
      await tester.pump();
      expect(harness.focusNode.hasFocus, isTrue);

      final dismissed = harness.controller.showActionMenu<int>(
        items: const [
          AppActionMenuItem(value: 1, label: '第一项'),
          AppActionMenuItem(value: 2, label: '第二项'),
          AppActionMenuItem(value: 3, label: '第三项'),
          AppActionMenuItem(value: 4, label: '第四项'),
          AppActionMenuItem(value: 5, label: '第五项'),
          AppActionMenuItem(value: 6, label: '第六项'),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('第六项'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      expect(await dismissed, isNull);

      final systemDismissed = harness.controller.showActionMenu<int>(
        items: const [
          AppActionMenuItem(value: 1, label: '第一项'),
          AppActionMenuItem(value: 2, label: '第二项'),
        ],
      );
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(await systemDismissed, isNull);
      expect(harness.focusNode.hasFocus, isTrue);
    });
  }

  for (final row in _interactionMatrix) {
    testWidgets('interaction components responsive row ${row.name}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = row.size;
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await _pumpInteractionFixture(
        tester,
        row: row,
        child: AppDialog(
          variant: AppDialogVariant.confirmation,
          title: '确认继续当前操作',
          body: const Text('长说明必须随字号和窗口宽度完整增长，且取消与确认操作始终保持可达。'),
          cancelLabel: '取消',
          confirmLabel: '确认继续',
        ),
      );
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('确认继续'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _pumpInteractionFixture(
        tester,
        row: row,
        child: AppActionMenu<int>(
          title: '选择一个需要执行的操作',
          items: const [
            AppActionMenuItem(value: 1, label: '查看完整账户资料'),
            AppActionMenuItem(value: 2, label: '暂时不可使用的操作', enabled: false),
            AppActionMenuItem(
              value: 3,
              label: '删除当前资料且无法撤销',
              destructive: true,
              icon: AppIconRole.warning,
            ),
          ],
          onSelected: (_) {},
        ),
      );
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('删除当前资料且无法撤销'), findsOneWidget);
      const minimum = 48.0;
      final cancelTarget = find.widgetWithText(ListTile, '取消');
      expect(
        tester.getSize(cancelTarget).height,
        greaterThanOrEqualTo(minimum),
      );
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _pumpNotice(
  WidgetTester tester,
  TargetPlatform platform,
  Widget notice,
) async {
  final resolved = AppTheme.resolve(
    brightness: Brightness.light,
    highContrast: false,
    reduceMotion: false,
    boldText: false,
    platform: platform,
    brandPrimary: appBrandTheme.primaryLight,
    brandSecondary: appBrandTheme.secondaryLight,
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: resolved.material,
      home: AppDesignScope(
        tokens: resolved.tokens,
        child: Scaffold(body: Center(child: notice)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<_Harness> _pumpHarness(
  WidgetTester tester,
  TargetPlatform platform,
) async {
  final navigatorKey = GlobalKey<NavigatorState>();
  final focusNode = FocusNode();
  addTearDown(focusNode.dispose);
  final controller = AppInteractionPresenterController(
    navigatorKey: navigatorKey,
  );
  final resolved = AppTheme.resolve(
    brightness: Brightness.light,
    highContrast: false,
    reduceMotion: false,
    boldText: false,
    platform: platform,
    brandPrimary: appBrandTheme.primaryLight,
    brandSecondary: appBrandTheme.secondaryLight,
  );
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      theme: resolved.material.copyWith(platform: platform),
      home: AppDesignScope(
        tokens: resolved.tokens,
        child: AppInteractionHost(
          controller: controller,
          child: Scaffold(body: TextField(focusNode: focusNode)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _Harness(controller: controller, focusNode: focusNode);
}

Future<void> _pumpInteractionFixture(
  WidgetTester tester, {
  required _InteractionMatrixRow row,
  required Widget child,
}) async {
  final resolved = AppTheme.resolve(
    brightness: row.brightness,
    highContrast: row.highContrast,
    reduceMotion: false,
    boldText: false,
    platform: row.platform,
    brandPrimary: row.brightness == Brightness.dark
        ? appBrandTheme.primaryDark
        : appBrandTheme.primaryLight,
    brandSecondary: row.brightness == Brightness.dark
        ? appBrandTheme.secondaryDark
        : appBrandTheme.secondaryLight,
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: resolved.material.copyWith(platform: row.platform),
      home: MediaQuery(
        data: MediaQueryData(
          size: row.size,
          devicePixelRatio: 1,
          textScaler: TextScaler.linear(row.systemScale * row.appScale),
          highContrast: row.highContrast,
        ),
        child: AppDesignScope(
          tokens: resolved.tokens,
          child: Material(type: MaterialType.transparency, child: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

final class _Harness {
  const _Harness({required this.controller, required this.focusNode});

  final AppInteractionPresenterController controller;
  final FocusNode focusNode;
}

final _interactionMatrix = <_InteractionMatrixRow>[
  _InteractionMatrixRow('A', TargetPlatform.android, Size(320, 720), 1, 1),
  _InteractionMatrixRow('B', TargetPlatform.iOS, Size(320, 720), 1, 1.24),
  _InteractionMatrixRow(
    'C',
    TargetPlatform.android,
    Size(360, 800),
    1,
    1.12,
    brightness: Brightness.dark,
  ),
  _InteractionMatrixRow(
    'D',
    TargetPlatform.iOS,
    Size(360, 800),
    1,
    1,
    brightness: Brightness.dark,
  ),
  _InteractionMatrixRow('E', TargetPlatform.android, Size(390, 844), 1, 1.24),
  _InteractionMatrixRow(
    'F',
    TargetPlatform.iOS,
    Size(390, 844),
    1,
    1.24,
    brightness: Brightness.dark,
  ),
  _InteractionMatrixRow(
    'G',
    TargetPlatform.android,
    Size(600, 960),
    1,
    1,
    brightness: Brightness.dark,
    highContrast: true,
  ),
  _InteractionMatrixRow(
    'H',
    TargetPlatform.iOS,
    Size(600, 960),
    1,
    1.12,
    highContrast: true,
  ),
  _InteractionMatrixRow('I', TargetPlatform.android, Size(844, 390), 1, 1.12),
  _InteractionMatrixRow(
    'J',
    TargetPlatform.iOS,
    Size(844, 390),
    1,
    1.24,
    brightness: Brightness.dark,
  ),
  _InteractionMatrixRow(
    'K',
    TargetPlatform.android,
    Size(390, 844),
    2,
    1.24,
    highContrast: true,
  ),
  _InteractionMatrixRow(
    'L',
    TargetPlatform.iOS,
    Size(390, 844),
    3,
    1.24,
    brightness: Brightness.dark,
    highContrast: true,
  ),
];

final class _InteractionMatrixRow {
  const _InteractionMatrixRow(
    this.name,
    this.platform,
    this.size,
    this.systemScale,
    this.appScale, {
    this.brightness = Brightness.light,
    this.highContrast = false,
  });

  final String name;
  final TargetPlatform platform;
  final Size size;
  final double systemScale;
  final double appScale;
  final Brightness brightness;
  final bool highContrast;
}
