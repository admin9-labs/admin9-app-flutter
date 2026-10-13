import 'dart:ui' as ui;

import 'package:admin9_ui/admin9_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_content.dart';
import '../support/test_theme.dart';

void main() {
  testWidgets('layouts select and degrade from image count', (tester) async {
    for (final layout in [null, ...AFeedCardLayout.values]) {
      for (var count = 0; count <= 4; count++) {
        await pumpContent(
          tester,
          AFeedCard(
            title: '新闻标题',
            semanticsLabel: '完整新闻',
            layout: layout,
            images: [for (var i = 0; i < count; i++) const SizedBox.expand()],
          ),
        );
        final expected = count == 0 || layout == AFeedCardLayout.textOnly
            ? 0
            : (layout == null || layout == AFeedCardLayout.threeImages) &&
                  count >= 3
            ? 3
            : 1;
        expect(find.byType(AspectRatio), findsNWidgets(expected));
        expect(tester.takeException(), isNull);
      }
    }
  });
  testWidgets(
    'one accessible action excludes decorative content and passive cards stay readable',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var opened = 0;
      await pumpContent(
        tester,
        AFeedCard(
          title: '新闻',
          semanticsLabel: '新闻，视频，时长02:30',
          images: const [Text('装饰图片')],
          mediaBadge: const Text('02:30'),
          onPress: () => opened++,
        ),
      );
      expect(find.bySemanticsLabel('装饰图片'), findsNothing);
      await tester.tap(find.bySemanticsLabel('新闻，视频，时长02:30'));
      await tester.pumpAndSettle();
      expect(opened, 1);
      await pumpContent(
        tester,
        const AFeedCard(title: '新闻', semanticsLabel: '静态新闻'),
      );
      final data = tester
          .getSemantics(find.bySemanticsLabel('静态新闻'))
          .getSemanticsData();
      expect(data.flagsCollection.isEnabled, ui.Tristate.none);
      expect(data.hasAction(ui.SemanticsAction.tap), isFalse);
      semantics.dispose();
    },
  );
  testWidgets('long metadata reflows below trailing cover without truncation', (
    tester,
  ) async {
    const metadata = '2026年10月13日 12:30 来源：完整的新闻来源名称';
    await pumpContent(
      tester,
      const AFeedCard(
        title: '新闻',
        semanticsLabel: '完整新闻',
        metadata: metadata,
        images: [SizedBox.expand(key: ValueKey('image'))],
      ),
      width: 320,
      scale: 2,
    );
    expect(
      tester.getTopLeft(find.text(metadata)).dy,
      greaterThan(tester.getBottomLeft(find.byKey(const ValueKey('image'))).dy),
    );
    expect(tester.widget<Text>(find.text(metadata)).maxLines, isNull);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'all layouts preserve long copy in both themes, narrow widths, RTL and large text',
    (tester) async {
      const title = '较长的中文新闻标题在大字体下仍然完整换行，并保留所有内容';
      for (final layout in AFeedCardLayout.values) {
        for (final theme in [lightTheme, darkTheme]) {
          for (final width in [320.0, 390.0]) {
            for (final direction in TextDirection.values) {
              await pumpContent(
                tester,
                AFeedCard(
                  title: title,
                  semanticsLabel: title,
                  layout: layout,
                  metadata: '2026年10月13日 来源名称',
                  mediaBadge: const Text('01:23:45 完整视频时长'),
                  images: const [
                    SizedBox.expand(),
                    SizedBox.expand(),
                    SizedBox.expand(),
                  ],
                ),
                theme: theme,
                width: width,
                scale: 2,
                direction: direction,
              );
              expect(tester.widget<Text>(find.text(title)).maxLines, isNull);
              expect(find.text('01:23:45 完整视频时长'), findsOneWidget);
              expect(tester.takeException(), isNull);
            }
          }
        }
      }
    },
  );
}
