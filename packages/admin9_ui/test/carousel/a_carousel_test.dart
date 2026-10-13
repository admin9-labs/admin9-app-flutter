import 'dart:ui' as ui;

import 'package:admin9_ui/admin9_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import '../support/test_theme.dart';

void main() {
  testWidgets(
    'empty and single content do not rotate or expose paging actions',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(tester, const ACarousel(items: []));
      expect(find.byType(PageView), findsNothing);
      await _pump(
        tester,
        ACarousel(items: _items([1]), autoplay: true, loop: true),
      );
      await tester.pump(const Duration(seconds: 10));
      expect(_page(tester), 0);
      expect(find.text('图片1'), findsOneWidget);
      expect(
        find.semantics.byPredicate(
          (node) =>
              node.getSemanticsData().hasAction(ui.SemanticsAction.increase) ||
              node.getSemanticsData().hasAction(ui.SemanticsAction.decrease),
        ),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    },
  );

  testWidgets(
    'caption variants preserve full semantics and execute the selected action',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final opened = <int>[];
      for (final caption in ACarouselCaption.values) {
        await _pump(
          tester,
          ACarousel(
            items: _items([1, 2], opened: opened),
            caption: caption,
          ),
        );
        expect(
          find.text('图片1'),
          caption == ACarouselCaption.none ? findsNothing : findsOneWidget,
        );
        await tester.drag(find.byType(PageView), const Offset(-320, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('完整图片2'));
        expect(opened.last, 2);
        expect(find.bySemanticsLabel('完整图片2'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'loop wraps in both directions and finite pages stop at the ends',
    (tester) async {
      await _pump(tester, ACarousel(items: _items([1, 2, 3]), loop: true));
      await tester.drag(find.byType(PageView), const Offset(320, 0));
      await tester.pumpAndSettle();
      expect(find.text('图片3'), findsOneWidget);
      await tester.drag(find.byType(PageView), const Offset(-320, 0));
      await tester.pumpAndSettle();
      expect(find.text('图片1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await _pump(
        tester,
        ACarousel(
          items: _items([1, 2]),
          autoplay: true,
          interval: const Duration(seconds: 1),
        ),
      );
      await _advance(tester);
      expect(_page(tester), 1);
      await tester.pump(const Duration(seconds: 5));
      expect(_page(tester), 1);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'autoplay pauses on pointer hold and dragging and restarts a full interval',
    (tester) async {
      await _pump(
        tester,
        ACarousel(
          items: _items([1, 2, 3]),
          autoplay: true,
          loop: true,
          interval: const Duration(seconds: 1),
        ),
      );
      final first = _page(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PageView)),
      );
      await tester.pump(const Duration(seconds: 3));
      expect(_page(tester), first);
      await gesture.moveBy(const Offset(-40, 0));
      await tester.pump();
      final held = _page(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(_page(tester), held);
      await gesture.up();
      await tester.pumpAndSettle();
      final settled = _page(tester);
      await tester.pump(const Duration(milliseconds: 999));
      expect(_page(tester), settled);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(_page(tester), closeTo(settled + 1, .01));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('background, hidden host and reduced motion pause autoplay', (
    tester,
  ) async {
    Widget carousel({bool active = true}) => ACarousel(
      items: _items([1, 2, 3]),
      autoplay: true,
      loop: true,
      active: active,
      interval: const Duration(seconds: 1),
    );
    await _pump(tester, carousel());
    final first = _page(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 3));
    expect(_page(tester), first);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _advance(tester);
    expect(_page(tester), closeTo(first + 1, .01));
    for (final mode in ['active', 'ticker', 'motion']) {
      await _pump(
        tester,
        carousel(active: mode != 'active'),
        visible: mode != 'ticker',
        reduceMotion: mode == 'motion',
      );
      final paused = _page(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(_page(tester), paused, reason: mode);
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'content updates retain selected identity and reconcile removed or empty items',
    (tester) async {
      await _pump(tester, ACarousel(items: _items([1, 2, 3])));
      await tester.drag(find.byType(PageView), const Offset(-320, 0));
      await tester.pumpAndSettle();
      expect(find.text('图片2'), findsOneWidget);
      await _pump(tester, ACarousel(items: _items([3, 1, 2])));
      await tester.pumpAndSettle();
      expect(_page(tester), 2);
      expect(find.text('图片2'), findsOneWidget);
      await _pump(tester, ACarousel(items: _items([3, 1])));
      await tester.pumpAndSettle();
      expect(_page(tester), 0);
      await _pump(tester, const ACarousel(items: []));
      await _pump(tester, ACarousel(items: _items([4])));
      await tester.pumpAndSettle();
      expect(find.text('图片4'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unrelated host rebuilds do not postpone autoplay', (
    tester,
  ) async {
    final changes = <int>[];
    Widget carousel() => ACarousel(
      items: _items([1, 2, 3]),
      autoplay: true,
      interval: const Duration(seconds: 1),
      onChanged: changes.add,
    );
    await _pump(tester, carousel());
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      await _pump(tester, carousel());
    }
    await tester.pump(const Duration(seconds: 1));
    expect(changes, [1]);
    expect(find.text('图片2'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'selection survives simultaneous content, theme and motion updates',
    (tester) async {
      final changes = <int>[];
      await _pump(
        tester,
        ACarousel(items: _items([1, 2, 3]), onChanged: changes.add),
      );
      await tester.drag(find.byType(PageView), const Offset(-320, 0));
      await tester.pumpAndSettle();
      expect(changes, [1]);
      await _pump(
        tester,
        ACarousel(items: _items([3, 1, 2]), onChanged: changes.add),
        theme: darkTheme,
        reduceMotion: true,
      );
      await tester.pumpAndSettle();
      expect(find.text('图片2'), findsOneWidget);
      expect(changes, [1, 2]);
      await _pump(
        tester,
        ACarousel(items: _items([3, 1]), onChanged: changes.add),
      );
      await tester.pumpAndSettle();
      expect(find.text('图片3'), findsOneWidget);
      expect(changes, [1, 2, 0]);
    },
  );

  testWidgets(
    'passive content has a readable name without disabled control semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(
        tester,
        const ACarousel(
          items: [
            ACarouselItem(
              id: 'passive',
              child: SizedBox.expand(),
              semanticsLabel: '完整图片说明',
            ),
          ],
        ),
      );
      final data = tester
          .getSemantics(find.bySemanticsLabel('完整图片说明'))
          .getSemanticsData();
      expect(data.flagsCollection.isEnabled, ui.Tristate.none);
      expect(data.flagsCollection.isButton, isFalse);
      expect(data.hasAction(ui.SemanticsAction.tap), isFalse);
      semantics.dispose();
    },
  );

  testWidgets('focused keyboard actions pause autoplay until focus leaves', (
    tester,
  ) async {
    final opened = <int>[];
    final changed = <int>[];
    await _pump(
      tester,
      ACarousel(
        items: _items([1, 2], opened: opened),
        autoplay: true,
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
    expect(focus.hasFocus, isTrue);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
    expect(changed, isEmpty);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(opened, [1]);
    focus.unfocus();
    await tester.pump();
    await _advance(tester);
    expect(changed, [1]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('accessible navigation leaves paging under user control', (
    tester,
  ) async {
    final changed = <int>[];
    await _pump(
      tester,
      ACarousel(
        items: _items([1, 2]),
        autoplay: true,
        interval: const Duration(seconds: 1),
        onChanged: changed.add,
      ),
      accessibleNavigation: true,
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
    expect(changed, isEmpty);
    await tester.drag(find.byType(PageView), const Offset(-320, 0));
    await tester.pumpAndSettle();
    expect(changed, [1]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('updates to the same content list retain the selected ID', (
    tester,
  ) async {
    final items = _items([1, 2, 3]);
    await _pump(tester, ACarousel(items: items));
    await tester.drag(find.byType(PageView), const Offset(-320, 0));
    await tester.pumpAndSettle();
    items.replaceRange(0, items.length, _items([3, 1, 2]));
    await _pump(tester, ACarousel(items: items));
    await tester.pumpAndSettle();
    expect(find.text('图片2'), findsOneWidget);
    expect(_page(tester), 2);
  });

  testWidgets(
    'accessible paging announces the next value and respects finite ends',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final changed = <int>[];
      await _pump(
        tester,
        ACarousel(items: _items([1, 2]), onChanged: changed.add),
      );
      final first = find.semantics
          .byPredicate((node) => node.value == '1/2')
          .evaluate()
          .single;
      expect(first.getSemanticsData().increasedValue, '2/2');
      expect(
        first.getSemanticsData().hasAction(ui.SemanticsAction.decrease),
        isFalse,
      );
      tester.binding.performSemanticsAction(
        ui.SemanticsActionEvent(
          nodeId: first.id,
          viewId: tester.view.viewId,
          type: ui.SemanticsAction.increase,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('图片2'), findsOneWidget);
      expect(changed, [1]);
      final last = find.semantics
          .byPredicate((node) => node.value == '2/2')
          .evaluate()
          .single;
      expect(
        last.getSemanticsData().hasAction(ui.SemanticsAction.increase),
        isFalse,
      );
      tester.binding.performSemanticsAction(
        ui.SemanticsActionEvent(
          nodeId: last.id,
          viewId: tester.view.viewId,
          type: ui.SemanticsAction.decrease,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('图片1'), findsOneWidget);
      expect(changed, [1, 0]);
      semantics.dispose();
    },
  );

  testWidgets('focused arrow paging follows horizontal reading direction', (
    tester,
  ) async {
    for (final direction in TextDirection.values) {
      final changed = <int>[];
      await _pump(
        tester,
        ACarousel(items: _items([1, 2]), loop: true, onChanged: changed.add),
        direction: direction,
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
      await tester.sendKeyEvent(
        direction == TextDirection.ltr
            ? LogicalKeyboardKey.arrowRight
            : LogicalKeyboardKey.arrowLeft,
      );
      await tester.pumpAndSettle();
      expect(find.text('图片2'), findsOneWidget);
      expect(changed, [1]);
      await tester.sendKeyEvent(
        direction == TextDirection.ltr
            ? LogicalKeyboardKey.arrowLeft
            : LogicalKeyboardKey.arrowRight,
      );
      await tester.pumpAndSettle();
      expect(find.text('图片1'), findsOneWidget);
      expect(changed, [1, 0]);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets(
    'theme, RTL, large copy and finite indicator window stay readable',
    (tester) async {
      final semantics = tester.ensureSemantics();
      for (final theme in [lightTheme, darkTheme]) {
        for (final direction in TextDirection.values) {
          await _pump(
            tester,
            ACarousel(
              items: [
                for (var id = 0; id < 10; id++)
                  ACarouselItem(
                    id: id,
                    child: const SizedBox.expand(),
                    title: '较长的中文轮播标题需要保持完整的无障碍名称',
                    semanticsLabel: '完整名称$id',
                  ),
              ],
              caption: ACarouselCaption.below,
            ),
            width: 320,
            scale: 2,
            theme: theme,
            direction: direction,
          );
          expect(find.bySemanticsLabel('完整名称0'), findsOneWidget);
          expect(find.byType(AnimatedContainer), findsNWidgets(5));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        }
      }
      semantics.dispose();
    },
  );
}

List<ACarouselItem> _items(List<int> ids, {List<int>? opened}) => [
  for (final id in ids)
    ACarouselItem(
      id: id,
      title: '图片$id',
      semanticsLabel: '完整图片$id',
      onPress: () => opened?.add(id),
      child: const SizedBox.expand(),
    ),
];
double _page(WidgetTester tester) =>
    tester.widget<PageView>(find.byType(PageView)).controller!.page!;
Future<void> _advance(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 390,
  double scale = 1,
  bool visible = true,
  bool reduceMotion = false,
  bool accessibleNavigation = false,
  FThemeData? theme,
  TextDirection direction = TextDirection.ltr,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: Size(width, 844),
        textScaler: TextScaler.linear(scale),
        disableAnimations: reduceMotion,
        accessibleNavigation: accessibleNavigation,
      ),
      child: Directionality(
        textDirection: direction,
        child: FTheme(
          data: theme ?? lightTheme,
          child: TickerMode(
            enabled: visible,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}
