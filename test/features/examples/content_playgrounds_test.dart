import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:admin9_app_flutter/features/examples/presentation/pages/data/playgrounds/calendar_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/data/playgrounds/lists_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/data/playgrounds/overview_playground_page.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _locale = Locale('zh', 'CN');
late Map<String, dynamic> _translations;

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    _translations = jsonDecode(
      await File('assets/translations/zh-CN.json').readAsString(),
    ) as Map<String, dynamic>;
  });

  testWidgets(
    'WD01/WD02/WD03/WD05 project overview covers every required axis',
    (tester) async {
      await _pumpPage(tester, const OverviewPlaygroundPage());
      final semantics = tester.ensureSemantics();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FCard), findsWidgets);
      final avatars = tester.widgetList<FAvatar>(find.byType(FAvatar)).toList();
      expect(avatars.map((avatar) => avatar.size), [48, 32, 40, 52, 64]);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('overview-avatar-image')),
          matching: find.byType(RawImage),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('overview-avatar-fallback')),
          matching: find.text('CN'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('overview-avatar-raw-icon')),
        findsOneWidget,
      );

      final badges = tester.widgetList<FBadge>(find.byType(FBadge)).toList();
      expect(
        badges.map((badge) => badge.variant).toSet(),
        containsAll({
          FBadgeVariant.primary,
          FBadgeVariant.secondary,
          FBadgeVariant.outline,
          FBadgeVariant.destructive,
        }),
      );
      expect(find.semantics.byLabel('项目成员 12 人'), findsWidgets);

      expect(find.byType(FAccordion), findsOneWidget);
      expect(find.byType(FAccordionItem), findsNWidgets(2));
      final progress = find.semantics.byLabel('本周交付进度');
      final error = find.semantics.byLabel('暂时无法加载');
      expect(
        progress.evaluate().single.flagsCollection.isExpanded,
        Tristate.isTrue,
      );
      expect(
        error
            .evaluate()
            .singleWhere(
              (node) => node.flagsCollection.isExpanded != Tristate.none,
            )
            .flagsCollection
            .isExpanded,
        Tristate.isFalse,
      );
      await _tap(
        tester,
        find.descendant(
          of: find.byType(FAccordion),
          matching: find.text('暂时无法加载'),
        ),
      );
      expect(
        tester.widget<FCollapsible>(find.byType(FCollapsible).at(1)).value,
        1,
      );

      final projectCard = find.byKey(const ValueKey('overview-project-card'));
      expect(
        find.descendant(
          of: projectCard,
          matching: find.text('Admin9 移动端 Starter'),
        ),
        findsWidgets,
      );
      expect(
        find.descendant(of: projectCard, matching: find.byType(FButton)),
        findsNWidgets(2),
      );
      final initialStatus = _status(tester);
      await _tap(tester, find.byKey(const ValueKey('overview-share')));
      expect(_status(tester), isNot(initialStatus));

      expect(
        find.byKey(const ValueKey('overview-member-badge')),
        findsOneWidget,
      );

      await _tap(tester, find.byKey(const ValueKey('overview-show-badge')));
      expect(find.byKey(const ValueKey('overview-member-badge')), findsNothing);

      await _tap(
        tester,
        find.byKey(const ValueKey('overview-members-increase')),
      );
      expect(find.semantics.byLabel('项目成员 13 人'), findsWidgets);

      await _tap(tester, find.byKey(const ValueKey('overview-follow')));
      expect(find.text('已关注项目'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('playground-reset')));
      expect(
        find.byKey(const ValueKey('overview-member-badge')),
        findsOneWidget,
      );
      expect(find.semantics.byLabel('项目成员 12 人'), findsWidgets);
      expect(find.text('关注项目'), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('WD04/WD08 calendar covers modes, disabled dates, navigation', (
    tester,
  ) async {
    await _pumpPage(tester, const CalendarPlaygroundPage());
    final semantics = tester.ensureSemantics();

    expect(
      find.byKey(const ValueKey('calendar-playground-single')),
      findsOneWidget,
    );
    expect(find.byType(FLineCalendar), findsOneWidget);
    expect(
      tester
          .widget<FButton>(find.byKey(const ValueKey('calendar-mode-single')))
          .selected,
      isTrue,
    );

    var calendar = tester.widget<FCalendar>(find.byType(FCalendar));
    final navigation = calendar.control as FGridCalendarControl;
    final navigationController =
        navigation.controller! as FGridCalendarController;
    final nextMonth = navigationController.day.next(
      duration: const Duration(milliseconds: 1),
    );
    await tester.pumpAndSettle();
    await nextMonth;
    expect(navigationController.currentMonth, DateTime.utc(2026, 9));

    final single =
        calendar.selectionControl as FDateSelectionLiftedControl<DateTime?>;
    single.onChange(DateTime.utc(2026, 9, 3));
    await tester.pump();
    expect(_status(tester), contains('2026-09-03'));
    final blockedDay = find.semantics.byLabel(RegExp(r'^2026年9月8日'));
    final weekendDay = find.semantics.byLabel(RegExp(r'^2026年9月6日'));
    expect(
      blockedDay.evaluate().where(
        (node) =>
            !node.flagsCollection.isHidden &&
            !node.flagsCollection.isInMutuallyExclusiveGroup,
      ),
      hasLength(1),
    );
    expect(
      weekendDay.evaluate().where(
        (node) =>
            !node.flagsCollection.isHidden &&
            !node.flagsCollection.isInMutuallyExclusiveGroup,
      ),
      hasLength(1),
    );
    expect(
      blockedDay
          .evaluate()
          .singleWhere(
            (node) =>
                !node.flagsCollection.isHidden &&
                !node.flagsCollection.isInMutuallyExclusiveGroup,
          )
          .flagsCollection
          .isEnabled,
      Tristate.isFalse,
    );
    expect(
      weekendDay
          .evaluate()
          .singleWhere(
            (node) =>
                !node.flagsCollection.isHidden &&
                !node.flagsCollection.isInMutuallyExclusiveGroup,
          )
          .flagsCollection
          .isEnabled,
      Tristate.isFalse,
    );
    expect(_status(tester), contains('2026-09-03'));

    await _tap(tester, find.byKey(const ValueKey('calendar-mode-multiple')));
    calendar = tester.widget<FCalendar>(find.byType(FCalendar));
    final multiple =
        calendar.selectionControl as FDateSelectionLiftedControl<Set<DateTime>>;
    multiple.onChange({DateTime.utc(2026, 9, 3), DateTime.utc(2026, 9, 4)});
    await tester.pump();
    expect(
      tester
          .widget<FButton>(find.byKey(const ValueKey('calendar-mode-multiple')))
          .selected,
      isTrue,
    );
    expect(_status(tester), contains('2026-09-03,2026-09-04'));

    await _tap(tester, find.byKey(const ValueKey('calendar-mode-range')));
    expect(
      find.byKey(const ValueKey('calendar-playground-range')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FButton>(find.byKey(const ValueKey('calendar-mode-range')))
          .selected,
      isTrue,
    );

    final selection =
        tester.widget<FCalendar>(find.byType(FCalendar)).selectionControl
            as FDateSelectionLiftedControl<(DateTime, DateTime)?>;
    selection.onChange((DateTime.utc(2026, 9, 7), DateTime.utc(2026, 9, 9)));
    await tester.pump();
    expect(_status(tester), contains('2026-09-07..2026-09-09'));

    await _tap(tester, find.byKey(const ValueKey('calendar-exclude-weekends')));
    await _tap(tester, find.byKey(const ValueKey('calendar-mode-single')));
    await tester.ensureVisible(find.byType(FCalendar));
    await tester.pumpAndSettle();
    expect(
      weekendDay
          .evaluate()
          .singleWhere(
            (node) =>
                !node.flagsCollection.isHidden &&
                !node.flagsCollection.isInMutuallyExclusiveGroup,
          )
          .flagsCollection
          .isEnabled,
      Tristate.isTrue,
    );
    final enabledSingle =
        tester.widget<FCalendar>(find.byType(FCalendar)).selectionControl
            as FDateSelectionLiftedControl<DateTime?>;
    enabledSingle.onChange(DateTime.utc(2026, 9, 6));
    await tester.pump();
    expect(_status(tester), contains('2026-09-06'));

    final line = tester.widget<FLineCalendar>(find.byType(FLineCalendar));
    final lineScroll =
        (line.scrollControl as FLineCalendarScrollManagedControl).controller!;
    final before = lineScroll.offset;
    lineScroll.jumpToDate(DateTime.utc(2026, 10, 1));
    await tester.pump();
    expect(lineScroll.offset, isNot(before));

    lineScroll.jumpToDate(DateTime.utc(2026, 9, 2));
    await tester.pump();
    await tester.ensureVisible(find.byType(FLineCalendar));
    await tester.pumpAndSettle();
    final dynamic lineControl = line.control;
    lineControl.onChange(DateTime.utc(2026, 9, 2));
    await tester.pump();
    expect(_status(tester), contains('2026-09-02'));

    await _tap(tester, find.byKey(const ValueKey('calendar-show-line')));
    expect(find.byType(FLineCalendar), findsNothing);
    expect(
      tester
          .widget<FSwitch>(find.byKey(const ValueKey('calendar-show-line')))
          .value,
      isFalse,
    );

    await _tap(tester, find.byKey(const ValueKey('playground-reset')));
    expect(
      tester
          .widget<FButton>(find.byKey(const ValueKey('calendar-mode-single')))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<FSwitch>(find.byKey(const ValueKey('calendar-show-line')))
          .value,
      isTrue,
    );
    expect(find.byType(FLineCalendar), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('WD06/WD07/WT01/WT02/WT03/WT04 list scene covers all states', (
    tester,
  ) async {
    await _pumpPage(tester, const ListsPlaygroundPage());

    expect(find.byType(FItemGroup), findsOneWidget);
    expect(find.byType(FTileGroup), findsWidgets);
    expect(find.byType(FSelectMenuTile<String>), findsOneWidget);
    expect(find.byType(FSelectTileGroup<String>), findsNWidgets(3));

    final itemGroup = tester.widget<FItemGroup>(find.byType(FItemGroup));
    expect(itemGroup.divider, FItemDivider.indented);
    expect(itemGroup.scrollController, isNotNull);
    var firstItem = tester.widget<FItem>(
      find.byKey(const ValueKey('lists-item-0')),
    );
    final firstItemFinder = find.byKey(const ValueKey('lists-item-0'));
    expect(
      find.descendant(of: firstItemFinder, matching: find.byType(Icon)),
      findsNWidgets(2),
    );
    expect(
      find.descendant(
        of: firstItemFinder,
        matching: find.text('查看最近发布、构建与审核记录。'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: firstItemFinder, matching: find.text('1')),
      findsOneWidget,
    );
    expect(firstItem.onPress, isNotNull);
    firstItem = tester.widget<FItem>(
      find.byKey(const ValueKey('lists-item-1')),
    );
    firstItem.onPress!();
    await tester.pump();
    expect(_status(tester), contains('members-1'));

    final itemScroll = itemGroup.scrollController!;
    itemScroll.jumpTo(itemScroll.position.maxScrollExtent);
    await tester.pump();
    final destructive = tester.widget<FItem>(
      find.byKey(const ValueKey('lists-item-6')),
    );
    final disabled = tester.widget<FItem>(
      find.byKey(const ValueKey('lists-item-7')),
    );
    expect(destructive.variant, FItemVariant.destructive);
    expect(destructive.onPress, isNotNull);
    expect(disabled.enabled, isFalse);
    expect(disabled.onPress, isNull);

    await _tap(tester, find.byKey(const ValueKey('lists-menu-comfortable')));
    await _tap(tester, find.byKey(const ValueKey('lists-menu-compact-option')));
    expect(_status(tester), contains('compact'));

    await _tap(tester, find.byKey(const ValueKey('lists-layout-compact')));
    expect(_status(tester), contains('compact'));

    await _tap(tester, find.byKey(const ValueKey('lists-section-updates')));
    await _tap(tester, find.byKey(const ValueKey('lists-save-selection')));
    expect(find.text('请稍后重试。'), findsWidgets);
    await _tap(tester, find.byKey(const ValueKey('lists-section-members')));
    await _tap(tester, find.byKey(const ValueKey('lists-save-selection')));
    expect(_status(tester), '设置已保存');

    final tileGroup = tester.widget<FTileGroup>(
      find.byKey(const ValueKey('lists-tile-group')),
    );
    expect(tileGroup.divider, FItemDivider.indented);
    final dangerTile = tester.widget<FTile>(
      find.byKey(const ValueKey('lists-danger-tile')),
    );
    final disabledTile = tester.widget<FTile>(
      find.byKey(const ValueKey('lists-disabled-tile')),
    );
    expect(dangerTile.variant, FItemVariant.destructive);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('lists-danger-tile')),
        matching: find.byType(Icon),
      ),
      findsNWidgets(2),
    );
    expect(disabledTile.enabled, isFalse);
    expect(disabledTile.onPress, isNull);
    await _tap(tester, find.byKey(const ValueKey('lists-danger-tile')));
    expect(_status(tester), '离线缓存已清理');

    await _tap(tester, find.byKey(const ValueKey('lists-descriptions')));
    expect(find.text('查看项目成员及协作角色。'), findsNothing);

    await _tap(tester, find.byKey(const ValueKey('lists-full-dividers')));
    expect(
      tester.widget<FItemGroup>(find.byType(FItemGroup)).divider,
      FItemDivider.full,
    );

    await _tap(tester, find.byKey(const ValueKey('lists-enabled')));
    expect(tester.widget<FItemGroup>(find.byType(FItemGroup)).enabled, isFalse);
    expect(
      tester
          .widget<FTileGroup>(find.byKey(const ValueKey('lists-tile-group')))
          .enabled,
      isFalse,
    );

    await _tap(tester, find.byKey(const ValueKey('playground-reset')));
    expect(tester.widget<FItemGroup>(find.byType(FItemGroup)).enabled, isTrue);
    expect(
      tester.widget<FItemGroup>(find.byType(FItemGroup)).divider,
      FItemDivider.indented,
    );
    expect(
      tester
          .widget<FTileGroup>(find.byKey(const ValueKey('lists-tile-group')))
          .enabled,
      isTrue,
    );
    expect(find.text('查看项目成员及协作角色。'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('content playgrounds fit narrow and large-text viewports', (
    tester,
  ) async {
    for (final size in const [Size(320, 700), Size(390, 844)]) {
      for (final page in const [
        OverviewPlaygroundPage(),
        CalendarPlaygroundPage(),
        ListsPlaygroundPage(),
      ]) {
        await _pumpPage(tester, page, size: size, textScale: 2);
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('playground-reset')),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$page at $size');
        expect(find.byKey(const ValueKey('playground-code')), findsNothing);
        expect(find.byKey(const ValueKey('playground-copy')), findsNothing);
      }
    }
  });
}

String _status(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('playground-status'))).data!;

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [_locale],
      fallbackLocale: _locale,
      startLocale: _locale,
      path: 'assets/translations',
      assetLoader: _InMemoryAssetLoader(_translations),
      saveLocale: false,
      child: _TestHost(page: page, textScale: textScale),
    ),
  );
  await tester.pumpAndSettle();
}

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      Future.value(Map.of(translations));
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.page, required this.textScale});

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
        child: FToaster(
          child: FTooltipGroup(child: child ?? const SizedBox.shrink()),
        ),
      ),
    ),
  );
}
