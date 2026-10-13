import 'package:admin9_ui/admin9_ui.dart';

import 'dart:ui' show Tristate;

import '../support/test_theme.dart';

import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

void main() {
  test('count badges reject negative values', () {
    expect(
      () => AGridBadge.count(-1, semanticsLabel: '无效数量'),
      throwsAssertionError,
    );
  });

  testWidgets('defaults to four columns and reduces to three at 320px', (
    tester,
  ) async {
    for (final (size, expectedColumns) in [
      (const Size(320, 844), 3),
      (const Size(390, 844), 4),
    ]) {
      await _pump(
        tester,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AGrid(children: _items(8)),
        ),
        size: size,
      );

      final grid = tester.widget<AGrid>(find.byType(AGrid));
      expect(grid.columns, 4);
      expect(grid.surface, AGridSurface.transparent);
      final firstRowTop = tester.getTopLeft(find.byKey(const Key('item-0'))).dy;
      final firstRowItems = [
        for (var index = 0; index < 8; index++)
          if (tester.getTopLeft(find.byKey(Key('item-$index'))).dy ==
              firstRowTop)
            index,
      ];
      expect(firstRowItems, hasLength(expectedColumns));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('surface is transparent by default and configurable', (
    tester,
  ) async {
    for (final (surface, background, hasBorder) in [
      (AGridSurface.transparent, const Color(0x00000000), false),
      (AGridSurface.muted, lightTheme.colors.muted, true),
      (AGridSurface.outlined, const Color(0x00000000), true),
    ]) {
      await _pump(
        tester,
        AGrid(
          surface: surface,
          children: const [
            AGridItem(
              key: Key('surface-item'),
              icon: Icon(FLucideIcons.layoutGrid),
              label: Text('宫格'),
              onPress: _noop,
            ),
          ],
        ),
      );

      final decoration = _surfaceDecoration(tester, const Key('surface-item'));
      expect(decoration.color, background, reason: surface.name);
      expect(decoration.border != null, hasBorder, reason: surface.name);
    }
  });

  testWidgets('constructor layout values override Theme defaults', (
    tester,
  ) async {
    await _pump(
      tester,
      AGrid(
        columns: 2,
        horizontalGap: 4,
        verticalGap: 6,
        childAspectRatio: 1.25,
        padding: const EdgeInsets.all(8),
        children: _items(3),
      ),
      size: const Size(320, 640),
    );

    final one = tester.getRect(find.byKey(const Key('item-0')));
    final two = tester.getRect(find.byKey(const Key('item-1')));
    final three = tester.getRect(find.byKey(const Key('item-2')));
    expect(one.left, 8);
    expect(two.left - one.right, closeTo(4, 0.01));
    expect(three.top - one.bottom, closeTo(6, 0.01));
    expect(one.width / one.height, lessThanOrEqualTo(1.25));
    expect(one.width, greaterThanOrEqualTo(48));
    expect(one.height, greaterThanOrEqualTo(48));
  });

  testWidgets('renders compact badge kinds and count boundaries', (
    tester,
  ) async {
    await _pump(
      tester,
      AGrid(
        children: const [
          AGridItem(
            icon: Icon(FLucideIcons.bell),
            label: Text('零'),
            badge: AGridBadge.count(0, semanticsLabel: '没有未读消息'),
          ),
          AGridItem(
            icon: Icon(FLucideIcons.messageCircle),
            label: Text('数量'),
            badge: AGridBadge.count(100, semanticsLabel: '100 条未读消息'),
          ),
          AGridItem(
            icon: Icon(FLucideIcons.circleAlert),
            label: Text('提示'),
            badge: AGridBadge.dot(semanticsLabel: '有新提醒'),
          ),
          AGridItem(
            icon: Icon(FLucideIcons.sparkles),
            label: Text('状态'),
            badge: AGridBadge.label('这是一个很长的新标签'),
          ),
        ],
      ),
    );

    expect(find.text('0'), findsNothing);
    expect(find.text('99+'), findsOneWidget);
    final count = tester.getSize(
      find.byKey(const ValueKey('agrid-badge-count')),
    );
    expect(count.width, greaterThanOrEqualTo(18));
    expect(count.height, greaterThanOrEqualTo(18));
    expect(find.byKey(const ValueKey('agrid-badge-dot')), findsOneWidget);
    final dot = tester.getSize(find.byKey(const ValueKey('agrid-badge-dot')));
    expect(dot, const Size.square(8));
    final label = tester.renderObject<RenderParagraph>(find.text('这是一个很长的新标签'));
    expect(label.didExceedMaxLines, isTrue);
    expect(
      tester.getSize(find.byKey(const ValueKey('agrid-badge-label'))).width,
      lessThanOrEqualTo(48),
    );
    expect(find.byKey(const ValueKey('agrid-visual-surface')), findsNothing);
  });

  testWidgets('badge colors use destructive and secondary semantics', (
    tester,
  ) async {
    await _pump(
      tester,
      AGrid(
        children: const [
          AGridItem(
            icon: Icon(FLucideIcons.bell),
            label: Text('数量'),
            badge: AGridBadge.count(8, semanticsLabel: '8 条未读消息'),
          ),
          AGridItem(
            icon: Icon(FLucideIcons.sparkles),
            label: Text('标签'),
            badge: AGridBadge.label('新'),
          ),
        ],
      ),
    );

    final countDecoration =
        tester
                .widget<DecoratedBox>(
                  find.byKey(const ValueKey('agrid-badge-count')),
                )
                .decoration
            as BoxDecoration;
    final labelDecoration =
        tester
                .widget<DecoratedBox>(
                  find.byKey(const ValueKey('agrid-badge-label')),
                )
                .decoration
            as BoxDecoration;
    expect(countDecoration.color, lightTheme.colors.destructive);
    expect(labelDecoration.color, lightTheme.colors.secondary);
    expect(
      tester.widget<Text>(find.text('8')).style?.color,
      lightTheme.colors.destructiveForeground,
    );
    expect(
      tester.widget<Text>(find.text('新')).style?.color,
      lightTheme.colors.secondaryForeground,
    );
  });

  testWidgets('badge overlay does not move centered icon content', (
    tester,
  ) async {
    for (final size in [const Size(320, 844), const Size(390, 844)]) {
      for (final theme in [lightTheme, darkTheme]) {
        await _pump(
          tester,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AGrid(
              children: const [
                AGridItem(
                  key: Key('badged-item'),
                  icon: Icon(FLucideIcons.bell, key: Key('icon')),
                  label: Text('提醒'),
                  badge: AGridBadge.count(
                    8,
                    key: Key('badge'),
                    semanticsLabel: '8 条未读消息',
                  ),
                ),
                AGridItem(
                  key: Key('plain-item'),
                  icon: Icon(FLucideIcons.settings, key: Key('plain-icon')),
                  label: Text('设置'),
                ),
                AGridItem(icon: Icon(FLucideIcons.heart), label: Text('收藏')),
                AGridItem(icon: Icon(FLucideIcons.share2), label: Text('分享')),
              ],
            ),
          ),
          size: size,
          textScale: 2,
          theme: theme,
        );

        final item = tester.getRect(find.byKey(const Key('badged-item')));
        final badge = tester.getRect(find.byKey(const Key('badge')));
        final icon = tester.getCenter(find.byKey(const Key('icon')));
        final plainIcon = tester.getCenter(find.byKey(const Key('plain-icon')));
        expect(icon.dy, plainIcon.dy);
        expect(badge.top, greaterThanOrEqualTo(item.top));
        expect(badge.right, lessThanOrEqualTo(item.right));
        expect(badge.top - item.top, greaterThanOrEqualTo(8));
        expect(item.right - badge.right, greaterThanOrEqualTo(8));
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets(
    'selection, disabled state, semantics, and presses are distinct',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var presses = 0;
      await _pump(
        tester,
        AGrid(
          surface: AGridSurface.muted,
          children: [
            AGridItem(
              key: const Key('selected'),
              icon: const Icon(FLucideIcons.check),
              label: const Text('选中'),
              badge: const AGridBadge.count(8, semanticsLabel: '8 条未读消息'),
              selected: true,
              semanticsLabel: '选中入口',
              semanticsHint: '打开入口',
              onPress: () => presses++,
            ),
            AGridItem(
              key: const Key('disabled'),
              icon: const Icon(FLucideIcons.lock),
              label: const Text('停用'),
              badge: const AGridBadge.dot(
                key: Key('disabled-badge'),
                semanticsLabel: '有新提醒',
              ),
              enabled: false,
              semanticsLabel: '停用入口',
              onPress: () => presses++,
            ),
          ],
        ),
      );

      final selectedNode = find.semantics
          .byLabel('选中入口，8 条未读消息')
          .evaluate()
          .single;
      expect(selectedNode.hint, '打开入口');
      expect(selectedNode.flagsCollection.isButton, isTrue);
      expect(selectedNode.flagsCollection.isSelected, Tristate.isTrue);
      expect(selectedNode.flagsCollection.isEnabled, Tristate.isTrue);
      final disabledNode = find.semantics
          .byLabel('停用入口，有新提醒')
          .evaluate()
          .single;
      expect(disabledNode.flagsCollection.isButton, isTrue);
      expect(disabledNode.flagsCollection.isEnabled, Tristate.isFalse);
      final disabledBadgeOpacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byKey(const Key('disabled-badge')),
          matching: find.byType(Opacity),
        ),
      );
      expect(
        disabledBadgeOpacity.opacity,
        lightTheme.style.aGrid.badgeDisabledOpacity,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('selected')),
          matching: find.byType(FFocusedOutline),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('selected')));
      await tester.tap(find.byKey(const Key('disabled')));
      await tester.pumpAndSettle();
      expect(presses, 1);

      final selectedColor = _surfaceColor(tester, const Key('selected'));
      expect(selectedColor, lightTheme.colors.secondary);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('selected'))),
      );
      await tester.pump();
      expect(
        _surfaceColor(tester, const Key('selected')),
        lightTheme.colors.secondary,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      semantics.dispose();
    },
  );

  testWidgets('badge follows the directional top-end position', (tester) async {
    for (final direction in TextDirection.values) {
      await _pump(
        tester,
        AGrid(
          columns: 1,
          children: const [
            AGridItem(
              icon: Icon(FLucideIcons.bell, key: Key('icon')),
              label: Text('提醒'),
              badge: AGridBadge.count(
                9,
                key: Key('badge'),
                semanticsLabel: '9 条未读消息',
              ),
            ),
          ],
        ),
        textDirection: direction,
      );

      final badgeX = tester.getCenter(find.byKey(const Key('badge'))).dx;
      final iconX = tester.getCenter(find.byKey(const Key('icon'))).dx;
      expect(
        badgeX > iconX,
        direction == TextDirection.ltr,
        reason: direction.name,
      );
    }
  });

  testWidgets('long labels remain overflow-free at 320px and 2x text', (
    tester,
  ) async {
    await _pump(
      tester,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AGrid(
          children: const [
            AGridItem(
              icon: Icon(FLucideIcons.layoutGrid),
              label: Text('较长的中文功能入口'),
              badge: AGridBadge.label('新功能'),
            ),
            AGridItem(icon: Icon(FLucideIcons.settings), label: Text('设置')),
            AGridItem(icon: Icon(FLucideIcons.heart), label: Text('收藏')),
          ],
        ),
      ),
      size: const Size(320, 844),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    for (final item in find.byType(AGridItem).evaluate()) {
      expect(
        tester.getSize(find.byWidget(item.widget)).height,
        greaterThanOrEqualTo(48),
      );
    }
  });
  testWidgets(
    'measurable labels reduce columns at large text and retain full semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(
        tester,
        AGrid(
          children: [
            for (var i = 0; i < 4; i++)
              AGridItem.text(
                key: ValueKey('text-$i'),
                icon: const SizedBox.square(dimension: 44),
                label: '很长的服务入口名称$i',
                onPress: _noop,
              ),
          ],
        ),
        size: const Size(320, 844),
        textScale: 2,
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('text-1'))).dy,
        greaterThan(tester.getTopLeft(find.byKey(const ValueKey('text-0'))).dy),
      );
      expect(find.bySemanticsLabel('很长的服务入口名称0'), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets(
    'paged rows keep equal height and the last item remains actionable',
    (tester) async {
      var opened = -1;
      await _pump(
        tester,
        AGrid(
          rowsPerPage: 1,
          children: [
            for (var i = 0; i < 9; i++)
              AGridItem.text(
                key: ValueKey('entry-$i'),
                icon: const Icon(FLucideIcons.layoutGrid),
                label: '入口$i',
                onPress: () => opened = i,
              ),
          ],
        ),
      );
      final height = tester.getSize(find.byType(PageView)).height;
      await tester.drag(find.byType(PageView), const Offset(-390, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-390, 0));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(PageView)).height, height);
      await tester.tap(find.byKey(const ValueKey('entry-8')));
      await tester.pumpAndSettle();
      expect(opened, 8);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'paging restores across removal and resets safely when geometry changes',
    (tester) async {
      final bucket = PageStorageBucket();
      Widget content({bool visible = true, int columns = 4}) => PageStorage(
        bucket: bucket,
        child: visible
            ? AGrid(
                key: const PageStorageKey('entries'),
                columns: columns,
                rowsPerPage: 1,
                showIndicators: false,
                children: [
                  for (var i = 0; i < 9; i++)
                    AGridItem.text(
                      key: ValueKey('restore-$i'),
                      icon: const Icon(FLucideIcons.layoutGrid),
                      label: '入口$i',
                    ),
                ],
              )
            : const SizedBox(),
      );
      await _pump(tester, content());
      await tester.drag(find.byType(PageView), const Offset(-390, 0));
      await tester.pumpAndSettle();
      await _pump(tester, content(visible: false));
      await _pump(tester, content());
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        1,
      );
      await _pump(tester, content(columns: 2));
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        0,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('paging scopes use key equality rather than printed identities', (
    tester,
  ) async {
    final first = [for (var i = 0; i < 9; i++) Object()];
    final second = [for (var i = 0; i < 9; i++) Object()];
    Widget grid(List<Object> ids) => AGrid(
      key: const PageStorageKey('identity-grid'),
      rowsPerPage: 1,
      children: [
        for (var i = 0; i < ids.length; i++)
          AGridItem.text(
            key: ValueKey(ids[i]),
            icon: const SizedBox(),
            label: '入口$i',
          ),
      ],
    );
    await _pump(tester, grid(first));
    await tester.drag(find.byType(PageView), const Offset(-390, 0));
    await tester.pumpAndSettle();
    expect(find.text('入口4'), findsOneWidget);
    await _pump(tester, grid(second));
    await tester.pumpAndSettle();
    expect(find.text('入口0'), findsOneWidget);
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 0);
  });
  testWidgets('two-line text labels wrap within themed cells at large scale', (
    tester,
  ) async {
    await _pump(
      tester,
      const AGrid(
        children: [
          AGridItem.text(
            icon: Icon(FLucideIcons.layoutGrid),
            label: '服务入口',
            labelMaxLines: 2,
          ),
          AGridItem.text(
            icon: Icon(FLucideIcons.layoutGrid),
            label: '个人设置',
            labelMaxLines: 2,
          ),
        ],
      ),
      size: const Size(320, 844),
      textScale: 2,
    );
    final label = tester.renderObject<RenderParagraph>(find.text('服务入口'));
    expect(label.didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });
}

List<AGridItem> _items(int count) => [
  for (var index = 0; index < count; index++)
    AGridItem(
      key: Key('item-$index'),
      icon: const Icon(FLucideIcons.layoutGrid),
      label: Text('入口 ${index + 1}'),
    ),
];

Color? _surfaceColor(WidgetTester tester, Key itemKey) {
  return _surfaceDecoration(tester, itemKey).color;
}

BoxDecoration _surfaceDecoration(WidgetTester tester, Key itemKey) {
  final surface = find.descendant(
    of: find.byKey(itemKey),
    matching: find.byType(AnimatedContainer),
  );
  final decoration = tester.widget<AnimatedContainer>(surface).decoration;
  return decoration as BoxDecoration;
}

void _noop() {}

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
