import 'dart:convert';
import 'dart:ui' show Tristate;

import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_item.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_style.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

void main() {
  testWidgets(
    'AGrid applies columns, gaps, ratio, padding, and style override',
    (tester) async {
      const gridKey = Key('grid');
      final style = lightTheme.style.aGrid.copyWith(
        gridPadding: EdgeInsets.zero,
        horizontalGap: 8,
        verticalGap: 10,
        childAspectRatio: 2,
        gridDecoration: const BoxDecoration(color: Color(0xff123456)),
      );

      await _pump(
        tester,
        AGrid(
          key: gridKey,
          columns: 2,
          style: style,
          children: const [
            AGridItem(
              key: Key('one'),
              visual: SizedBox.shrink(),
              title: Text('一'),
            ),
            AGridItem(
              key: Key('two'),
              visual: SizedBox.shrink(),
              title: Text('二'),
            ),
            AGridItem(
              key: Key('three'),
              visual: SizedBox.shrink(),
              title: Text('三'),
            ),
            AGridItem(
              key: Key('four'),
              visual: SizedBox.shrink(),
              title: Text('四'),
            ),
          ],
        ),
        size: const Size(300, 600),
      );

      final one = tester.getRect(find.byKey(const Key('one')));
      final two = tester.getRect(find.byKey(const Key('two')));
      final three = tester.getRect(find.byKey(const Key('three')));
      expect(one.width, closeTo(146, 0.01));
      expect(one.width / one.height, lessThanOrEqualTo(2));
      expect(one.height, greaterThanOrEqualTo(48));
      expect(two.left - one.right, closeTo(8, 0.01));
      expect(three.top - one.bottom, closeTo(10, 0.01));

      final grid = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byKey(gridKey),
              matching: find.byType(DecoratedBox),
            ),
          )
          .singleWhere(
            (box) =>
                (box.decoration as BoxDecoration).color ==
                const Color(0xff123456),
          );
      expect((grid.decoration as BoxDecoration).color, const Color(0xff123456));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('AGrid constructor values override theme layout defaults', (
    tester,
  ) async {
    final style = lightTheme.style.aGrid.copyWith(
      gridPadding: EdgeInsets.zero,
      horizontalGap: 20,
      verticalGap: 20,
      childAspectRatio: 1,
    );

    await _pump(
      tester,
      AGrid(
        columns: 2,
        horizontalGap: 4,
        verticalGap: 6,
        childAspectRatio: 2,
        padding: const EdgeInsets.all(8),
        style: style,
        children: const [
          AGridItem(
            key: Key('one'),
            visual: SizedBox.shrink(),
            title: Text('一'),
          ),
          AGridItem(
            key: Key('two'),
            visual: SizedBox.shrink(),
            title: Text('二'),
          ),
          AGridItem(
            key: Key('three'),
            visual: SizedBox.shrink(),
            title: Text('三'),
          ),
        ],
      ),
      size: const Size(300, 600),
    );

    final one = tester.getRect(find.byKey(const Key('one')));
    final two = tester.getRect(find.byKey(const Key('two')));
    final three = tester.getRect(find.byKey(const Key('three')));
    expect(one.left, 8);
    expect(two.left - one.right, closeTo(4, 0.01));
    expect(three.top - one.bottom, closeTo(6, 0.01));
    expect(one.width / one.height, lessThanOrEqualTo(2));
    expect(one.height, greaterThanOrEqualTo(48));
  });

  testWidgets('AGrid preserves touch targets for narrow multi-column grids', (
    tester,
  ) async {
    await _pump(
      tester,
      AGrid(
        columns: 6,
        childAspectRatio: 8,
        children: const [
          AGridItem(
            key: Key('one'),
            visual: SizedBox.shrink(),
            title: Text('一'),
          ),
          AGridItem(
            key: Key('two'),
            visual: SizedBox.shrink(),
            title: Text('二'),
          ),
          AGridItem(
            key: Key('three'),
            visual: SizedBox.shrink(),
            title: Text('三'),
          ),
          AGridItem(
            key: Key('four'),
            visual: SizedBox.shrink(),
            title: Text('四'),
          ),
          AGridItem(
            key: Key('five'),
            visual: SizedBox.shrink(),
            title: Text('五'),
          ),
          AGridItem(
            key: Key('six'),
            visual: SizedBox.shrink(),
            title: Text('六'),
          ),
        ],
      ),
      size: const Size(320, 640),
    );

    final items = [
      for (final key in ['one', 'two', 'three', 'four', 'five', 'six'])
        tester.getRect(find.byKey(Key(key))),
    ];
    for (final item in items) {
      expect(item.width, greaterThanOrEqualTo(48));
      expect(item.height, greaterThanOrEqualTo(48));
    }
    expect(items.last.top, greaterThan(items.first.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets('AGrid adapts effective columns and height for large text', (
    tester,
  ) async {
    await _pump(
      tester,
      AGrid(
        columns: 4,
        childAspectRatio: 3,
        children: const [
          AGridItem(
            key: Key('one'),
            visual: SizedBox.shrink(),
            title: Text('一'),
          ),
          AGridItem(
            key: Key('two'),
            visual: SizedBox.shrink(),
            title: Text('二'),
          ),
          AGridItem(
            key: Key('three'),
            visual: SizedBox.shrink(),
            title: Text('三'),
          ),
          AGridItem(
            key: Key('four'),
            visual: SizedBox.shrink(),
            title: Text('四'),
          ),
        ],
      ),
      size: const Size(320, 640),
      textScale: 2,
    );

    final one = tester.getRect(find.byKey(const Key('one')));
    final two = tester.getRect(find.byKey(const Key('two')));
    final four = tester.getRect(find.byKey(const Key('four')));
    expect(one.height, greaterThanOrEqualTo(96));
    expect(two.top, one.top);
    expect(four.top, greaterThan(one.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'AGridItem exposes selected, disabled, focus, and press semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var enabledPresses = 0;

      await _pump(
        tester,
        AGrid(
          children: [
            AGridItem(
              key: const Key('enabled'),
              visual: const Icon(FLucideIcons.image),
              title: const Text('图片'),
              description: const Text('选择一张图片'),
              badge: FBadge(child: const Text('3')),
              selected: true,
              semanticsLabel: '图片入口',
              badgeSemanticsLabel: '3 条提醒',
              semanticsHint: '点按以打开',
              onPress: () => enabledPresses++,
            ),
            AGridItem(
              key: const Key('disabled'),
              visual: const Icon(FLucideIcons.lock),
              title: const Text('停用入口'),
              enabled: false,
              semanticsLabel: '停用入口',
            ),
          ],
        ),
      );

      final enabledNode = find.semantics
          .byLabel('图片入口，3 条提醒')
          .evaluate()
          .single;
      expect(enabledNode.hint, '点按以打开');
      expect(enabledNode.flagsCollection.isButton, isTrue);
      expect(enabledNode.flagsCollection.isSelected, Tristate.isTrue);
      expect(enabledNode.flagsCollection.isEnabled, Tristate.isTrue);

      final disabledNode = find.semantics.byLabel('停用入口').evaluate().single;
      expect(disabledNode.flagsCollection.isButton, isTrue);
      expect(disabledNode.flagsCollection.isEnabled, Tristate.isFalse);
      expect(
        find.descendant(
          of: find.byKey(const Key('enabled')),
          matching: find.byType(FFocusedOutline),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('enabled')));
      await tester.tap(find.byKey(const Key('disabled')));
      await tester.pumpAndSettle();
      expect(enabledPresses, 1);
      semantics.dispose();
    },
  );

  testWidgets(
    'AGridItem preserves child semantics when only badge semantics is provided',
    (tester) async {
      final semantics = tester.ensureSemantics();

      await _pump(
        tester,
        AGrid(
          children: [
            AGridItem(
              key: const Key('semantic-item'),
              visual: Semantics(
                label: '图片缩略图',
                child: const SizedBox.square(dimension: 24),
              ),
              title: const Text('图片'),
              description: const Text('选择一张图片'),
              badge: FBadge(child: const Text('未读')),
              badgeSemanticsLabel: '三条提醒',
              onPress: () {},
            ),
          ],
        ),
      );

      final label = find.semantics
          .byLabel(RegExp('图片缩略图'))
          .evaluate()
          .single
          .label;
      expect(label, contains('图片缩略图'));
      expect(label, contains('图片'));
      expect(label, contains('选择一张图片'));
      expect(label, contains('三条提醒'));
      expect(label, isNot(contains('未读')));
      expect(RegExp('三条提醒').allMatches(label), hasLength(1));

      semantics.dispose();
    },
  );

  testWidgets('AGridItem resolves pressed and selected Forui variants', (
    tester,
  ) async {
    const pressedColor = Color(0xff112233);
    const selectedColor = Color(0xff445566);
    final inherited = lightTheme.style.aGrid;
    final style = inherited.copyWith(
      itemDecoration: FVariants.from(
        const BoxDecoration(color: Color(0xffffffff)),
        variants: {
          [.pressed]: const .boxDelta(color: pressedColor),
          [.selected]: const .boxDelta(color: selectedColor),
        },
      ),
    );

    await _pump(
      tester,
      AGrid(
        style: style,
        children: [
          AGridItem(
            key: const Key('pressable'),
            visual: const Icon(FLucideIcons.hand),
            title: const Text('按压'),
            onPress: () {},
          ),
          AGridItem(
            key: const Key('selected'),
            visual: const Icon(FLucideIcons.check),
            title: const Text('选中'),
            selected: true,
            onPress: () {},
          ),
        ],
      ),
    );

    expect(_surfaceColor(tester, const Key('selected')), selectedColor);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('pressable'))),
    );
    await tester.pump(const Duration(milliseconds: 120));
    expect(_surfaceColor(tester, const Key('pressable')), pressedColor);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('AGridItem supports icon, image, custom visual, and badges', (
    tester,
  ) async {
    await _pump(
      tester,
      AGrid(
        children: [
          AGridItem(
            visual: const Icon(FLucideIcons.star),
            title: const Text('图标'),
            badge: FBadge(child: const Text('新')),
            onPress: () {},
          ),
          AGridItem(
            visual: Image.memory(_transparentPixel),
            title: const Text('图片'),
            badge: const Text('8'),
            onPress: () {},
          ),
          AGridItem(
            visual: const SizedBox(key: Key('custom-visual'), width: 24),
            title: const Text('自定义'),
            badge: const SizedBox(key: Key('dot'), width: 8, height: 8),
            onPress: () {},
          ),
        ],
      ),
    );

    expect(find.byType(Icon), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byKey(const Key('custom-visual')), findsOneWidget);
    expect(find.byType(FBadge), findsOneWidget);
    expect(find.byKey(const Key('dot')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('visual surface and badge stay inside the item in LTR and RTL', (
    tester,
  ) async {
    for (final direction in TextDirection.values) {
      await _pump(
        tester,
        AGrid(
          children: [
            AGridItem(
              key: const Key('item'),
              visual: const Icon(FLucideIcons.bell),
              title: const Text('提醒'),
              badge: FBadge(key: const Key('badge'), child: const Text('9')),
              selected: true,
              onPress: () {},
            ),
          ],
        ),
        textDirection: direction,
      );

      final item = tester.getRect(find.byKey(const Key('item')));
      final badge = tester.getRect(find.byKey(const Key('badge')));
      expect(item.contains(badge.topLeft), isTrue);
      expect(item.contains(badge.bottomRight), isTrue);
      expect(
        find.descendant(
          of: find.byKey(const Key('item')),
          matching: find.byKey(const Key('agrid-visual-surface')),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('directional layouts mirror in RTL', (tester) async {
    await _pump(
      tester,
      AGrid(
        columns: 1,
        childAspectRatio: 4,
        children: [
          AGridItem(
            key: const Key('start-item'),
            layout: AGridItemLayout.horizontalStart,
            visual: const SizedBox(key: Key('start-visual'), width: 24),
            title: const Text('起始', key: Key('start-title')),
            onPress: () {},
          ),
          AGridItem(
            key: const Key('end-item'),
            layout: AGridItemLayout.horizontalEnd,
            visual: const SizedBox(key: Key('end-visual'), width: 24),
            title: const Text('结束', key: Key('end-title')),
            onPress: () {},
          ),
        ],
      ),
      textDirection: TextDirection.rtl,
    );

    expect(
      tester.getCenter(find.byKey(const Key('start-visual'))).dx,
      greaterThan(tester.getCenter(find.byKey(const Key('start-title'))).dx),
    );
    expect(
      tester.getCenter(find.byKey(const Key('end-visual'))).dx,
      lessThan(tester.getCenter(find.byKey(const Key('end-title'))).dx),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile widths, large text, and both themes do not overflow', (
    tester,
  ) async {
    for (final size in [const Size(320, 640), const Size(390, 844)]) {
      for (final theme in [lightTheme, darkTheme]) {
        await _pump(
          tester,
          AGrid(
            children: [
              AGridItem(
                key: const Key('touch-target'),
                visual: const Icon(FLucideIcons.layoutGrid),
                title: const Text('较长的中文标题'),
                description: const Text('用于验证大字体和窄屏布局'),
                badge: FBadge(child: const Text('12')),
                onPress: () {},
              ),
              AGridItem(
                visual: const Icon(FLucideIcons.settings),
                title: const Text('设置'),
                description: const Text('保持稳定触摸区域'),
                onPress: () {},
              ),
            ],
          ),
          size: size,
          textScale: 2,
          theme: theme,
        );

        final touchTarget = tester.getSize(
          find.byKey(const Key('touch-target')),
        );
        expect(touchTarget.width, greaterThanOrEqualTo(44));
        expect(touchTarget.height, greaterThanOrEqualTo(44));
        expect(
          tester.takeException(),
          isNull,
          reason: '${size.width} ${theme.colors.brightness}',
        );
      }
    }
  });

  testWidgets(
    'narrow status cells preserve complete title and description lines',
    (tester) async {
      await _pump(
        tester,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AGrid(
            columns: 2,
            horizontalGap: 12,
            verticalGap: 12,
            childAspectRatio: 1.05,
            children: [
              AGridItem(
                visual: const Text('12'),
                title: const Text('待处理'),
                description: const Text('今天还有 12 项任务'),
                badge: FBadge(child: const Text('8')),
                enabled: false,
              ),
              const AGridItem(
                visual: Icon(FLucideIcons.messageCircle),
                title: Text('消息'),
                description: Text('还有 8 条未读消息'),
              ),
            ],
          ),
        ),
        size: const Size(320, 640),
      );

      _expectCompleteLine(tester, '待处理');
      _expectCompleteLine(tester, '今天还有 12 项任务');
      _expectCompleteLine(tester, '消息');
      _expectCompleteLine(tester, '还有 8 条未读消息');
    },
  );
}

Color? _surfaceColor(WidgetTester tester, Key itemKey) {
  final surface = find.descendant(
    of: find.byKey(itemKey),
    matching: find.byType(AnimatedContainer),
  );
  final decoration = tester.widget<AnimatedContainer>(surface).decoration;
  return (decoration as BoxDecoration).color;
}

void _expectCompleteLine(WidgetTester tester, String text) {
  final finder = find.text(text);
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  expect(
    paragraph.didExceedMaxLines,
    isFalse,
    reason: '$text must render without ellipsis',
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  double textScale = 1,
  TextDirection textDirection = TextDirection.ltr,
  FThemeData? theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: Directionality(
        textDirection: textDirection,
        child: FTheme(
          data: theme ?? lightTheme,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: size.width, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

final _transparentPixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==',
);
