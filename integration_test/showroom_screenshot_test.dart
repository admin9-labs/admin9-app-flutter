import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captures current Showroom and AGrid evidence', (tester) async {
    await EasyLocalization.ensureInitialized();
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('zh', 'CN')],
        fallbackLocale: const Locale('zh', 'CN'),
        startLocale: const Locale('zh', 'CN'),
        path: 'assets/translations',
        saveLocale: false,
        child: const ProviderScope(child: Admin9App()),
      ),
    );
    await tester.pumpAndSettle();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
    }

    await binding.takeScreenshot('01_foundation_showroom');

    await _tap(tester, const ValueKey('foundation-themes'));
    await _tap(tester, const ValueKey('theme-brightness-light'));
    await _dismissToasts(tester);
    await _showThemePreview(tester);
    await binding.takeScreenshot('02_theme_neutral_light');

    await _tap(tester, const ValueKey('theme-preset-ocean'));
    await _dismissToasts(tester);
    await _showThemePreview(tester);
    await binding.takeScreenshot('03_theme_ocean_light');

    await _tap(tester, const ValueKey('theme-preset-forest'));
    await _tap(tester, const ValueKey('theme-brightness-dark'));
    await _dismissToasts(tester);
    await _showThemePreview(tester);
    await binding.takeScreenshot('04_theme_forest_dark');

    await _tap(tester, const ValueKey('theme-preset-neutral'));
    await _tap(tester, const ValueKey('theme-brightness-light'));
    await _dismissToasts(tester);
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();

    await _tap(tester, const ValueKey('foundation-grid'));
    await _show(tester, const ValueKey('grid-playground-preview'));
    await binding.takeScreenshot('05_agrid_quick_light');

    await _tap(tester, const ValueKey('grid-scenario-content'));
    await _show(tester, const ValueKey('grid-playground-preview'));
    await binding.takeScreenshot('06_agrid_content_light');

    await _tap(tester, const ValueKey('grid-scenario-status'));
    await _tap(tester, const ValueKey('grid-selected-switch'));
    await _tap(tester, const ValueKey('grid-enabled-switch'));
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 2000),
      3000,
    );
    await tester.pumpAndSettle();
    await _show(tester, const ValueKey('grid-playground-preview'));
    _expectCompleteTextLine(tester, '待处理');
    _expectCompleteTextLine(tester, '今日还有 12 项');
    _expectCompleteTextLine(tester, '消息');
    _expectCompleteTextLine(tester, '还有 8 条未读消息');
    _expectCompleteTextLine(tester, '已完成');
    _expectCompleteTextLine(tester, '本周已处理 24 项');
    _expectCompleteTextLine(tester, '暂不可用');
    _expectCompleteTextLine(tester, '同步完成后开放');
    await binding.takeScreenshot('07_agrid_status_selected_disabled_light');

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    await _tap(tester, const ValueKey('foundation-themes'));
    await _tap(tester, const ValueKey('theme-preset-forest'));
    await _tap(tester, const ValueKey('theme-brightness-dark'));
    await _dismissToasts(tester);
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    await _tap(tester, const ValueKey('foundation-grid'));
    await _show(tester, const ValueKey('grid-playground-preview'));
    await binding.takeScreenshot('08_agrid_quick_dark');
  });
}

Future<void> _tap(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _show(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pumpAndSettle();
}

Future<void> _showThemePreview(WidgetTester tester) async {
  final preview = find.ancestor(
    of: find.byKey(const ValueKey('theme-preview-primary')),
    matching: find.byType(PlaygroundPreview),
  );
  expect(preview, findsOneWidget);
  final scrollable = find.byType(Scrollable).first;
  final position = tester.state<ScrollableState>(scrollable).position;
  final targetOffset =
      position.pixels +
      tester.getTopLeft(preview).dy -
      tester.getTopLeft(scrollable).dy -
      16;
  position.jumpTo(
    targetOffset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble(),
  );
  await tester.pumpAndSettle();
}

Future<void> _dismissToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettle();
}

void _expectCompleteTextLine(WidgetTester tester, String text) {
  final finder = find.text(text);
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  expect(
    paragraph.didExceedMaxLines,
    isFalse,
    reason: '$text must render without ellipsis',
  );
}
