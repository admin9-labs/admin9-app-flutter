import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/empty_state_view.dart';
import 'package:admin9_app_flutter/shared/ui/error_state_view.dart';
import 'package:admin9_app_flutter/shared/ui/loading_state_view.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

void main() {
  testWidgets('responsive body caps wide content and fits narrow content', (
    tester,
  ) async {
    const contentKey = Key('content');

    await tester.pumpWidget(
      _Harness(
        size: const Size(1000, 800),
        child: ResponsivePageBody(
          children: [SizedBox(key: contentKey, height: 20)],
        ),
      ),
    );

    expect(tester.getSize(find.byKey(contentKey)).width, 720);

    await tester.pumpWidget(
      _Harness(
        size: const Size(320, 640),
        child: ResponsivePageBody(
          children: [SizedBox(key: contentKey, height: 20)],
        ),
      ),
    );

    expect(tester.getSize(find.byKey(contentKey)).width, 288);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state renders its action and invokes it', (tester) async {
    var actionCalls = 0;
    await tester.pumpWidget(
      _Harness(
        child: EmptyStateView(
          title: '暂无内容',
          message: '完成创建后，内容会显示在这里。',
          actionLabel: '创建',
          onAction: () => actionCalls++,
        ),
      ),
    );

    expect(find.text('暂无内容'), findsOneWidget);
    expect(find.text('完成创建后，内容会显示在这里。'), findsOneWidget);

    await tester.tap(find.text('创建'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(actionCalls, 1);
  });

  testWidgets('error state renders and invokes retry', (tester) async {
    var retryCalls = 0;
    await tester.pumpWidget(
      _Harness(
        child: ErrorStateView(
          title: '暂时无法加载',
          message: '请稍后重试。',
          retryLabel: '重试',
          onRetry: () => retryCalls++,
        ),
      ),
    );

    expect(find.text('暂时无法加载'), findsOneWidget);
    expect(find.text('请稍后重试。'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(retryCalls, 1);
  });

  testWidgets('loading state renders progress and its label', (tester) async {
    await tester.pumpWidget(
      const _Harness(child: LoadingStateView(label: '正在加载')),
    );

    expect(find.byType(FCircularProgress), findsOneWidget);
    expect(find.text('正在加载'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('example section renders its documented content slots', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _Harness(
        child: ComponentExampleSection(
          title: '主题模式',
          description: '选择应用的显示方式。',
          child: Text('示例内容'),
        ),
      ),
    );

    expect(find.text('主题模式'), findsOneWidget);
    expect(find.text('选择应用的显示方式。'), findsOneWidget);
    expect(find.text('示例内容'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Harness extends StatelessWidget {
  const _Harness({required this.child, this.size = const Size(390, 844)});

  final Widget child;
  final Size size;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: SizedBox.fromSize(
      size: size,
      child: MediaQuery(
        data: MediaQueryData(size: size),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: FTheme(data: lightTheme, child: child),
        ),
      ),
    ),
  );
}
