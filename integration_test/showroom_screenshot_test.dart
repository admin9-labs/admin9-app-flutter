import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
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
    _expectCompleteTextLine(tester, '今天还有 12 项任务');
    _expectCompleteTextLine(tester, '消息');
    _expectCompleteTextLine(tester, '还有 8 条未读消息');
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
  await _show(tester, const ValueKey('theme-preview-primary'));
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -240));
  await tester.pumpAndSettle();
}

Future<void> _dismissToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettle();
}

void _expectCompleteTextLine(WidgetTester tester, String text) {
  final finder = find.text(text);
  final context = tester.element(finder);
  final style = DefaultTextStyle.of(context).style;
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    locale: Localizations.maybeLocaleOf(context),
    maxLines: 1,
  )..layout(maxWidth: tester.getSize(finder).width);
  expect(
    tester.getSize(finder).height,
    greaterThanOrEqualTo(painter.height),
    reason: '$text must receive at least one complete text line',
  );
}
