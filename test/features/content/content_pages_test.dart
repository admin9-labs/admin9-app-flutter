import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/features/content/presentation/pages/accordion_page.dart';
import 'package:admin9_app_flutter/features/content/presentation/pages/calendar_page.dart';
import 'package:admin9_app_flutter/features/content/presentation/pages/content_basics_page.dart';
import 'package:admin9_app_flutter/features/content/presentation/pages/content_page.dart';
import 'package:admin9_app_flutter/features/content/presentation/pages/items_and_tiles_page.dart';
import 'package:admin9_app_flutter/features/content/presentation/pages/line_calendar_page.dart';
import 'package:admin9_app_flutter/features/content/presentation/pages/selectable_tiles_page.dart';
import 'package:admin9_app_flutter/shared/ui/empty_state_view.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
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

  testWidgets('content basics renders card, raw avatars, and badge variants', (
    tester,
  ) async {
    await _pumpPage(tester, const ContentBasicsPage());

    expect(find.byType(FCard), findsOneWidget);
    expect(find.byType(FAvatar), findsNWidgets(4));
    expect(find.byType(FBadge), findsNWidgets(5));
    expect(find.text('主要'), findsOneWidget);
    expect(find.text('危险'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accordion expands another mobile section', (tester) async {
    await _pumpPage(tester, const AccordionPage());

    expect(find.byType(FAccordion), findsOneWidget);
    expect(find.byType(FAccordionItem), findsNWidgets(3));
    final mobileSection = find.byType(FCollapsible).at(1);
    expect(tester.widget<FCollapsible>(mobileSection).value, 0);

    await tester.tap(find.text('移动端'));
    await tester.pumpAndSettle();

    expect(tester.widget<FCollapsible>(mobileSection).value, 1);
    expect(find.text('移动端内容会随屏幕和字号自然调整。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('calendar controls keep their configured dates in UTC', (
    tester,
  ) async {
    await _pumpPage(tester, const CalendarPage());

    final calendars = tester.widgetList<FCalendar>(find.byType(FCalendar));
    expect(calendars, hasLength(2));

    final grid = calendars.first.control as FGridCalendarControl;
    final wheel = calendars.last.control as FWheelCalendarControl;
    expect(grid.initial, DateTime.utc(2026, 8, 30));
    expect(grid.initial!.isUtc, isTrue);
    expect(wheel.initial, DateTime.utc(2026, 8, 30));
    expect(wheel.initial!.isUtc, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('line calendar uses UTC selection and disables Sundays', (
    tester,
  ) async {
    await _pumpPage(tester, const LineCalendarPage());

    final calendar = tester.widget<FLineCalendar>(find.byType(FLineCalendar));
    final control = calendar.control as FLineCalendarManagedControl;
    final initial = control.initial!;
    expect(initial.isUtc, isTrue);
    expect(calendar.selectable(initial), isTrue);
    expect(calendar.selectable(DateTime.utc(2026, 9, 6)), isFalse);

    final context = tester.element(find.byType(FLineCalendar));
    final today = calendar.builder(context, (
      style: context.theme.lineCalendarStyle,
      date: initial,
      variants: {FLineCalendarItemVariant.today},
    ), null);
    expect(today, isA<Stack>());
    expect((today as Stack).children.whereType<Positioned>(), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('content catalog empty state creates and clears an example', (
    tester,
  ) async {
    await _pumpPage(tester, const ContentPage());

    expect(find.byType(EmptyStateView), findsOneWidget);
    expect(find.text('暂无示例内容'), findsOneWidget);

    await tester.tap(find.text('添加示例'));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(EmptyStateView), findsNothing);
    expect(find.text('示例内容'), findsOneWidget);

    await tester.tap(find.text('清空示例'));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(EmptyStateView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('item and tile presses update the visible status', (
    tester,
  ) async {
    await _pumpPage(tester, const ItemsAndTilesPage());

    expect(find.byType(FItemGroup), findsOneWidget);
    expect(find.byType(FTileGroup), findsOneWidget);
    expect(find.text('等待操作'), findsOneWidget);

    await tester.tap(find.text('主要'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('已点击项目'), findsOneWidget);

    await tester.tap(find.text('外观'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('已点击列表项'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('select tiles and select menu respond to touch', (tester) async {
    await _pumpPage(tester, const SelectableTilesPage());

    expect(find.byType(FSelectTileGroup<String>), findsOneWidget);
    expect(find.byType(FSelectMenuTile<String>), findsOneWidget);

    await tester.tap(find.text('紧凑'));
    await tester.pump(const Duration(milliseconds: 200));
    final compactTile = tester.widget<FTile>(
      find.ancestor(of: find.text('紧凑'), matching: find.byType(FTile)),
    );
    expect(compactTile.selected, isTrue);

    await tester.tap(find.byType(FSelectMenuTile<String>));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('网格'));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('网格'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final pageListenable = ValueNotifier<Widget>(const SizedBox.shrink());
  addTearDown(pageListenable.dispose);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [_locale],
      fallbackLocale: _locale,
      startLocale: _locale,
      path: 'assets/translations',
      assetLoader: _InMemoryAssetLoader(_translations),
      saveLocale: false,
      child: _TestHost(page: pageListenable),
    ),
  );
  await tester.pumpAndSettle();
  pageListenable.value = page;
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      Future.value(Map.of(translations));
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.page});

  final ValueListenable<Widget> page;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: [
      ...context.localizationDelegates,
      FLocalizations.delegate,
    ],
    home: ValueListenableBuilder(
      valueListenable: page,
      builder: (_, page, _) => FScaffold(childPad: false, child: page),
    ),
    builder: (context, child) => FTheme(
      data: lightTheme,
      child: FToaster(
        child: FTooltipGroup(child: child ?? const SizedBox.shrink()),
      ),
    ),
  );
}
