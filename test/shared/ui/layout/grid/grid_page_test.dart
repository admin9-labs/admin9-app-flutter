import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:admin9_app_flutter/features/examples/presentation/pages/layout/grid/grid_page.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_badge.dart';
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

  testWidgets('renders one complete icon action grid scenario', (tester) async {
    await _pumpPage(tester);

    expect(find.text('Admin9 图标宫格'), findsOneWidget);
    expect(find.byType(AGrid), findsOneWidget);
    expect(find.byType(AGridItem), findsNWidgets(8));
    expect(find.byType(AGridBadge), findsNWidgets(4));
    final grid = tester.widget<AGrid>(find.byType(AGrid));
    expect(grid.columns, 4);
    expect(grid.horizontalGap, 8);
    expect(grid.verticalGap, 8);
    expect(grid.childAspectRatio, 1);
    expect(grid.surface, AGridSurface.transparent);
    expect(
      find.byKey(const ValueKey('grid-preview-count-badge')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grid-preview-dot-badge')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grid-preview-label-badge')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('grid-scenario-content')), findsNothing);
    expect(find.byKey(const ValueKey('grid-visual-image')), findsNothing);

    final targetFinder = find.byKey(const ValueKey('grid-preview-target'));
    final target = tester.widget<AGridItem>(targetFinder);
    expect(target.selected, isFalse);
    expect(target.semanticsLabel, '扫一扫');
    expect(target.badge?.semanticsLabel, '8 条未读消息');

    await tester.tap(targetFinder);
    await tester.pump();
    expect(tester.widget<AGridItem>(targetFinder).selected, isTrue);
    expect(find.byKey(const ValueKey('playground-status')), findsOneWidget);
    expect(find.byType(FToast), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('configuration changes preview and reset restores defaults', (
    tester,
  ) async {
    await _pumpPage(tester);

    await _scrollTo(tester, find.byKey(const ValueKey('grid-badge-label')));
    await tester.tap(find.byKey(const ValueKey('grid-badge-label')));
    await tester.pumpAndSettle();
    var target = tester.widget<AGridItem>(
      find.byKey(const ValueKey('grid-preview-target')),
    );
    expect(
      target.badge?.key,
      const ValueKey('grid-preview-target-label-badge'),
    );

    await tester.tap(find.byKey(const ValueKey('grid-enabled-switch')));
    await tester.tap(find.byKey(const ValueKey('grid-selected-switch')));
    await tester.pumpAndSettle();
    target = tester.widget<AGridItem>(
      find.byKey(const ValueKey('grid-preview-target')),
    );
    expect(target.enabled, isFalse);
    expect(target.selected, isTrue);

    await _scrollTo(tester, find.byKey(const ValueKey('grid-surface-muted')));
    await tester.tap(find.byKey(const ValueKey('grid-surface-muted')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AGrid>(find.byType(AGrid)).surface,
      AGridSurface.muted,
    );
    await tester.tap(find.byKey(const ValueKey('grid-surface-outlined')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AGrid>(find.byType(AGrid)).surface,
      AGridSurface.outlined,
    );

    await _setSlider(
      tester,
      find.byKey(const ValueKey('grid-columns-slider')),
      0,
    );
    await _setSlider(
      tester,
      find.byKey(const ValueKey('grid-horizontal-gap-slider')),
      1,
    );
    await _setSlider(
      tester,
      find.byKey(const ValueKey('grid-vertical-gap-slider')),
      1,
    );
    await _setSlider(
      tester,
      find.byKey(const ValueKey('grid-ratio-slider')),
      1,
    );
    await _setSlider(
      tester,
      find.byKey(const ValueKey('grid-padding-slider')),
      1,
    );
    var grid = tester.widget<AGrid>(find.byType(AGrid));
    expect(grid.columns, 2);
    expect(grid.horizontalGap, 24);
    expect(grid.verticalGap, 24);
    expect(grid.childAspectRatio, 1.25);
    expect(grid.padding, const EdgeInsets.all(24));

    await _scrollTo(tester, find.byKey(const ValueKey('playground-reset')));
    await tester.tap(find.byKey(const ValueKey('playground-reset')));
    await tester.pump();
    grid = tester.widget<AGrid>(find.byType(AGrid));
    target = tester.widget<AGridItem>(
      find.byKey(const ValueKey('grid-preview-target')),
    );
    expect(grid.columns, 4);
    expect(grid.horizontalGap, 8);
    expect(grid.verticalGap, 8);
    expect(grid.childAspectRatio, 1);
    expect(grid.padding, EdgeInsets.zero);
    expect(grid.surface, AGridSurface.transparent);
    expect(target.enabled, isTrue);
    expect(target.selected, isFalse);
    expect(
      target.badge?.key,
      const ValueKey('grid-preview-target-count-badge'),
    );
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
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
          expect(find.byType(AGridItem), findsNWidgets(8));
          expect(tester.takeException(), isNull);
        }
      }
    }
  });
}

Future<void> _setSlider(
  WidgetTester tester,
  Finder finder,
  double normalized,
) async {
  await _scrollTo(tester, finder);
  final rect = tester.getRect(finder);
  final dx = rect.left + 8 + (rect.width - 16) * normalized;
  await tester.tapAt(Offset(dx, rect.bottom - 8));
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
