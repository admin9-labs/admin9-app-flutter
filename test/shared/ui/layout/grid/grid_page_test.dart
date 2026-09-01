import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:admin9_app_flutter/features/examples/presentation/pages/layout/grid/grid_page.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_item.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'package:shared_preferences/shared_preferences.dart';

late Map<String, dynamic> _translations;

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    _translations = jsonDecode(
      await File('assets/translations/zh-CN.json').readAsString(),
    ) as Map<String, dynamic>;
  });

  testWidgets('three scenarios render complete, interactive AGrid contexts', (
    tester,
  ) async {
    await _pumpPage(tester);

    expect(find.text('Admin9 网格'), findsOneWidget);
    expect(find.byType(AGrid), findsOneWidget);
    expect(find.byType(AGridItem), findsNWidgets(4));
    var grid = tester.widget<AGrid>(find.byType(AGrid));
    expect(grid.columns, 3);

    await tester.tap(find.byKey(const ValueKey('grid-preview-target')));
    await tester.pump();
    var target = tester.widget<AGridItem>(
      find.byKey(const ValueKey('grid-preview-target')),
    );
    expect(target.selected, isTrue);
    expect(find.byKey(const ValueKey('playground-status')), findsOneWidget);
    expect(find.byType(FToast), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('grid-scenario-content')));
    await tester.pumpAndSettle();
    grid = tester.widget<AGrid>(find.byType(AGrid));
    target = tester.widget<AGridItem>(
      find.byKey(const ValueKey('grid-preview-target')),
    );
    expect(grid.columns, 1);
    expect(grid.childAspectRatio, 3.2);
    expect(target.layout, AGridItemLayout.horizontalStart);
    expect(target.semanticsLabel, contains('品牌资源'));
    expect(target.semanticsLabel, contains('查看启动图、图标与品牌素材'));
    expect(find.byKey(const ValueKey('grid-preview-image')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('grid-preview-badge-label')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('grid-scenario-status')));
    await tester.pumpAndSettle();
    grid = tester.widget<AGrid>(find.byType(AGrid));
    expect(grid.columns, 2);
    expect(
      find.byKey(const ValueKey('grid-preview-custom-visual')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<AGridItem>(find.byKey(const ValueKey('grid-preview-target')))
          .semanticsLabel,
      contains('12'),
    );
    expect(
      find.byKey(const ValueKey('grid-preview-badge-count')),
      findsOneWidget,
    );
    expect(
      tester
          .widgetList<AGridItem>(find.byType(AGridItem))
          .where((item) => item.selected),
      hasLength(1),
    );
    expect(
      tester
          .widgetList<AGridItem>(find.byType(AGridItem))
          .where((item) => !item.enabled),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('configuration changes preview and reset', (tester) async {
    await _pumpPage(tester);

    await _scrollTo(tester, find.byKey(const ValueKey('grid-layout-end')));
    await tester.tap(find.byKey(const ValueKey('grid-layout-end')));
    await tester.tap(find.byKey(const ValueKey('grid-visual-custom')));
    await tester.tap(find.byKey(const ValueKey('grid-badge-dot')));
    await tester.pumpAndSettle();

    var target = tester.widget<AGridItem>(
      find.byKey(const ValueKey('grid-preview-target')),
    );
    expect(target.layout, AGridItemLayout.horizontalEnd);
    expect(
      find.byKey(const ValueKey('grid-preview-custom-visual')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grid-preview-badge-dot')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull, reason: 'choice controls');

    await _scrollTo(tester, find.byKey(const ValueKey('grid-enabled-switch')));
    await tester.tap(find.byKey(const ValueKey('grid-enabled-switch')));
    await tester.tap(find.byKey(const ValueKey('grid-selected-switch')));
    await tester.pumpAndSettle();
    target = tester.widget<AGridItem>(
      find.byKey(const ValueKey('grid-preview-target')),
    );
    expect(target.enabled, isFalse);
    expect(target.selected, isTrue);
    expect(tester.takeException(), isNull, reason: 'state switches');

    await _setSliderToEnd(
      tester,
      find.byKey(const ValueKey('grid-columns-slider')),
    );
    expect(tester.takeException(), isNull, reason: 'columns');
    await _setSliderToEnd(
      tester,
      find.byKey(const ValueKey('grid-horizontal-gap-slider')),
    );
    expect(tester.takeException(), isNull, reason: 'horizontal gap');
    await _setSliderToEnd(
      tester,
      find.byKey(const ValueKey('grid-vertical-gap-slider')),
    );
    expect(tester.takeException(), isNull, reason: 'vertical gap');
    await _setSliderToEnd(
      tester,
      find.byKey(const ValueKey('grid-ratio-slider')),
    );
    expect(tester.takeException(), isNull, reason: 'ratio');
    await _setSliderToEnd(
      tester,
      find.byKey(const ValueKey('grid-padding-slider')),
    );
    expect(tester.takeException(), isNull, reason: 'padding');
    final grid = tester.widget<AGrid>(find.byType(AGrid));
    expect(grid.columns, 4);
    expect(grid.horizontalGap, 24);
    expect(grid.verticalGap, 24);
    expect(grid.childAspectRatio, 3.25);
    expect(grid.padding, const EdgeInsets.all(24));

    await _scrollTo(tester, find.byKey(const ValueKey('playground-reset')));
    await tester.tap(find.byKey(const ValueKey('playground-reset')));
    await tester.pump();
    final resetGrid = tester.widget<AGrid>(find.byType(AGrid));
    final resetTarget = tester.widget<AGridItem>(
      find.byKey(const ValueKey('grid-preview-target')),
    );
    expect(resetGrid.columns, 3);
    expect(resetGrid.horizontalGap, 8);
    expect(resetGrid.padding, EdgeInsets.zero);
    expect(resetTarget.layout, AGridItemLayout.vertical);
    expect(resetTarget.enabled, isTrue);
    expect(resetTarget.selected, isFalse);
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('image scenario uses a memory-backed preview', (tester) async {
    await _pumpPage(tester);

    await tester.tap(find.byKey(const ValueKey('grid-scenario-content')));
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(
      find.byKey(const ValueKey('grid-preview-image')),
    );
    expect(image.image, isA<MemoryImage>());
  });

  testWidgets('320/390, large text, RTL, and light/dark stay overflow-free', (
    tester,
  ) async {
    for (final size in [const Size(320, 844), const Size(390, 844)]) {
      for (final theme in [lightTheme, darkTheme]) {
        for (final direction in ui.TextDirection.values) {
          await _pumpPage(
            tester,
            size: size,
            textScale: 2,
            theme: theme,
            textDirection: direction,
          );
          expect(find.byType(AGrid), findsOneWidget);
          expect(tester.takeException(), isNull);
          expect(find.byKey(const ValueKey('playground-code')), findsNothing);
          expect(find.byKey(const ValueKey('playground-copy')), findsNothing);
        }
      }
    }
  });
}

Future<void> _setSliderToEnd(WidgetTester tester, Finder finder) async {
  await _scrollTo(tester, finder);
  final rect = tester.getRect(finder);
  await tester.tapAt(Offset(rect.right - 8, rect.bottom - 8));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpPage(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  ui.TextDirection textDirection = ui.TextDirection.ltr,
  FThemeData? theme,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      assetLoader: _GridTranslations(_translations),
      saveLocale: false,
      child: _GridApp(
        size: size,
        textScale: textScale,
        textDirection: textDirection,
        theme: theme ?? lightTheme,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _GridApp extends StatelessWidget {
  const _GridApp({
    required this.size,
    required this.textScale,
    required this.textDirection,
    required this.theme,
  });

  final Size size;
  final double textScale;
  final ui.TextDirection textDirection;
  final FThemeData theme;

  @override
  Widget build(BuildContext context) => material.MaterialApp(
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: [
      ...context.localizationDelegates,
      ...material.GlobalMaterialLocalizations.delegates,
      FLocalizations.delegate,
    ],
    builder: (context, child) => FTheme(
      data: theme,
      child: FToaster(child: child!),
    ),
    home: Directionality(
      textDirection: textDirection,
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: const GridPage(),
      ),
    ),
  );
}

class _GridTranslations extends AssetLoader {
  const _GridTranslations(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      translations;
}
