import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_code_panel.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_catalog_tile.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

void main() {
  testWidgets(
    'playground structure exposes preview, summary, copy, and reset',
    (tester) async {
      var copied = false;
      var reset = false;

      await tester.pumpWidget(
        _Harness(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const PlaygroundPreview(
                title: '实时预览',
                status: '保存成功',
                child: Text('预览内容'),
              ),
              const PlaygroundCodePanel(
                title: '当前参数',
                summary: 'enabled: true',
                code: 'FButton(onPress: save)',
              ),
              PlaygroundActionBar(
                copyLabel: '复制',
                resetLabel: '重置',
                onCopy: () => copied = true,
                onReset: () => reset = true,
              ),
            ],
          ),
        ),
      );

      expect(find.byKey(const ValueKey('playground-status')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('playground-parameter-summary')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('playground-code')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('playground-copy')));
      await tester.tap(find.byKey(const ValueKey('playground-reset')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(copied, isTrue);
      expect(reset, isTrue);
    },
  );

  testWidgets('action bar wraps at 320px with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _Harness(
        textScaler: const TextScaler.linear(2),
        child: PlaygroundActionBar(
          copyLabel: '复制当前参数摘要',
          resetLabel: '恢复这个实验台默认值',
          onCopy: () {},
          onReset: () {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog tile exposes scenario summary and semantic callback', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      _Harness(
        child: Align(
          alignment: Alignment.topCenter,
          child: PlaygroundCatalogTile(
            icon: FLucideIcons.layoutGrid,
            title: '布局实验台',
            description: '配置并观察真实页面布局。',
            capabilitySummary: '覆盖 4 项能力',
            onPress: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('覆盖 4 项能力'), findsOneWidget);
    await tester.tap(find.byType(FTile));
    await tester.pump(const Duration(milliseconds: 200));
    expect(opened, isTrue);
  });

  testWidgets('catalog tile wraps complete copy at 320px', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _Harness(
        child: Align(
          alignment: Alignment.topCenter,
          child: PlaygroundCatalogTile(
            icon: FLucideIcons.panelTop,
            title: '移动页面框架实验台',
            description: '在同一移动页面中验证头部、底栏、响应式与安全区。',
            capabilitySummary: 'Scaffold、Header、Bottom bar、Responsive',
            onPress: () {},
          ),
        ),
      ),
    );

    expect(find.byType(FBadge), findsNWidgets(4));
    for (final text in [
      '在同一移动页面中验证头部、底栏、响应式与安全区。',
      'Scaffold',
      'Header',
      'Bottom bar',
      'Responsive',
    ]) {
      expect(
        tester.renderObject<RenderParagraph>(find.text(text)).didExceedMaxLines,
        isFalse,
        reason: '$text must render without ellipsis',
      );
    }
    expect(tester.takeException(), isNull);
  });
}

class _Harness extends StatelessWidget {
  const _Harness({required this.child, this.textScaler = TextScaler.noScaling});

  final Widget child;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: FTheme(data: lightTheme, child: child),
      ),
    ),
  );
}
