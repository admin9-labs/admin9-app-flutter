import 'dart:ui' as ui;

import 'package:admin9_ui/admin9_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_content.dart';
import '../support/test_theme.dart';

List<ABannerItem> banners(List<int> ids, {List<int>? opened}) => [
  for (final id in ids)
    ABannerItem(
      id: id,
      child: Text('图片$id'),
      semanticsLabel: '横幅$id',
      onPress: () => opened?.add(id),
    ),
];
void main() {
  testWidgets('empty, single and stacked banners retain optional actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final opened = <int>[];
    await pumpContent(tester, const ABanner(items: []));
    expect(find.byType(PageView), findsNothing);
    await pumpContent(tester, ABanner(items: banners([1, 2], opened: opened)));
    await tester.tap(find.bySemanticsLabel('横幅2'));
    await tester.pumpAndSettle();
    expect(opened, [2]);
    await pumpContent(
      tester,
      ABanner(items: banners([1]), display: ABannerDisplay.rotating),
    );
    await tester.pump(const Duration(seconds: 20));
    expect(find.bySemanticsLabel('横幅1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });
  testWidgets(
    'vertical rotation loops and preserves selected identity after reorder',
    (tester) async {
      final changed = <int>[];
      Widget banner(List<int> ids) => ABanner(
        items: banners(ids),
        display: ABannerDisplay.rotating,
        interval: const Duration(seconds: 1),
        onChanged: changed.add,
      );
      await pumpContent(tester, banner([1, 2]));
      expect(
        tester.widget<PageView>(find.byType(PageView)).scrollDirection,
        Axis.vertical,
      );
      await advanceContent(tester);
      expect(find.text('图片2'), findsOneWidget);
      await pumpContent(tester, banner([2, 1]));
      expect(find.text('图片2'), findsOneWidget);
      expect(changed, [1, 0]);
      await advanceContent(tester);
      expect(find.text('图片1'), findsOneWidget);
      await advanceContent(tester);
      expect(find.text('图片2'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'banner vertical drag scrolls parent and taps still open content',
    (tester) async {
      final opened = <int>[];
      await pumpContent(
        tester,
        Column(
          children: [
            ABanner(
              items: banners([1, 2], opened: opened),
              display: ABannerDisplay.rotating,
            ),
            const SizedBox(height: 1600),
          ],
        ),
      );
      await tester.tap(find.byType(PageView));
      await tester.pumpAndSettle();
      expect(opened, [1]);
      await tester.drag(find.byType(PageView), const Offset(0, -150));
      await tester.pumpAndSettle();
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        greaterThan(0),
      );
      expect(find.text('图片1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'motion and accessible navigation expose all destinations in dark RTL',
    (tester) async {
      final semantics = tester.ensureSemantics();
      for (final accessible in [false, true]) {
        final opened = <int>[];
        await pumpContent(
          tester,
          ABanner(
            items: banners([1, 2, 3], opened: opened),
            display: ABannerDisplay.rotating,
          ),
          reduceMotion: !accessible,
          accessibleNavigation: accessible,
          theme: darkTheme,
          width: 320,
          scale: 2,
          direction: TextDirection.rtl,
        );
        expect(find.byType(PageView), findsNothing);
        for (var i = 1; i <= 3; i++) {
          await tester.tap(find.bySemanticsLabel('横幅$i'));
          await tester.pumpAndSettle();
        }
        expect(opened, [1, 2, 3]);
        expect(tester.takeException(), isNull);
      }
      semantics.dispose();
    },
  );
  testWidgets(
    'hidden and background banners pause for a full resume interval',
    (tester) async {
      Widget banner({bool active = true}) => ABanner(
        items: banners([1, 2]),
        display: ABannerDisplay.rotating,
        interval: const Duration(seconds: 1),
        active: active,
      );
      for (final mode in ['active', 'ticker', 'background']) {
        await pumpContent(tester, banner());
        if (mode == 'background') {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
        }
        await pumpContent(
          tester,
          banner(active: mode != 'active'),
          visible: mode != 'ticker',
        );
        await tester.pump(const Duration(seconds: 4));
        expect(find.text('图片1'), findsOneWidget);
        if (mode == 'background') {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
        }
        await pumpContent(tester, banner());
        await tester.pump(const Duration(milliseconds: 999));
        expect(find.text('图片1'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
  testWidgets(
    'hiding during automatic motion settles without completing a stale turn',
    (tester) async {
      Widget banner(bool active) => ABanner(
        items: banners([1, 2]),
        display: ABannerDisplay.rotating,
        interval: const Duration(seconds: 1),
        active: active,
      );
      await pumpContent(tester, banner(true));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 30));
      await pumpContent(tester, banner(false));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('图片1'), findsOneWidget);
      await pumpContent(tester, banner(true));
      await tester.pump(const Duration(milliseconds: 999));
      expect(find.text('图片1'), findsOneWidget);
      await advanceContent(tester);
      expect(find.text('图片2'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('wide image ratios retain theme-owned minimum touch height', (
    tester,
  ) async {
    for (final display in ABannerDisplay.values) {
      await pumpContent(
        tester,
        ABanner(items: banners([1]), aspectRatio: 100, display: display),
      );
      final height = tester.getSize(find.byType(AspectRatio)).height;
      expect(height, greaterThanOrEqualTo(lightTheme.style.sizes.item));
      await tester.pumpWidget(const SizedBox());
    }
  });
  testWidgets(
    'focused keyboard users can page banners while automatic rotation pauses',
    (tester) async {
      final opened = <int>[], changed = <int>[];
      await pumpContent(
        tester,
        ABanner(
          items: banners([1, 2], opened: opened),
          display: ABannerDisplay.rotating,
          interval: const Duration(seconds: 1),
          onChanged: changed.add,
        ),
      );
      final focus = tester
          .widget<Focus>(
            find
                .descendant(
                  of: find
                      .byWidgetPredicate((widget) => widget is FTappable)
                      .first,
                  matching: find.byWidgetPredicate(
                    (widget) => widget is Focus && widget.focusNode != null,
                  ),
                )
                .first,
          )
          .focusNode!;
      focus.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(changed, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(opened, [1]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.text('图片2'), findsOneWidget);
      expect(changed, [1]);
      await tester.pump(const Duration(seconds: 3));
      expect(changed, [1]);
      expect(
        tester
            .widgetList<FFocusedOutline>(find.byType(FFocusedOutline))
            .any((outline) => outline.focused),
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(find.text('图片1'), findsOneWidget);
      expect(changed, [1, 0]);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(opened, [1, 1]);
      FocusManager.instance.primaryFocus!.unfocus();
      await tester.pump();
      await advanceContent(tester);
      expect(changed, [1, 0, 1]);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'separate passive banners remain separate readable semantic units',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpContent(
        tester,
        const ABanner(
          items: [
            ABannerItem(
              id: 1,
              child: SizedBox.expand(),
              semanticsLabel: '第一条静态横幅',
            ),
            ABannerItem(
              id: 2,
              child: SizedBox.expand(),
              semanticsLabel: '第二条静态横幅',
            ),
          ],
        ),
      );
      expect(find.bySemanticsLabel('第一条静态横幅'), findsOneWidget);
      expect(find.bySemanticsLabel('第二条静态横幅'), findsOneWidget);
      semantics.dispose();
    },
  );
  testWidgets('passive banners are readable rather than disabled buttons', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpContent(
      tester,
      const ABanner(
        items: [
          ABannerItem(id: 1, child: SizedBox.expand(), semanticsLabel: '静态横幅'),
        ],
      ),
    );
    final data = tester
        .getSemantics(find.bySemanticsLabel('静态横幅'))
        .getSemanticsData();
    expect(data.flagsCollection.isEnabled, ui.Tristate.none);
    expect(data.flagsCollection.isButton, isFalse);
    semantics.dispose();
  });
}
