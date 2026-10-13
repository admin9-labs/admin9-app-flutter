import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'test_theme.dart';

Future<void> pumpContent(
  WidgetTester tester,
  Widget child, {
  double width = 390,
  double scale = 1,
  FThemeData? theme,
  TextDirection direction = TextDirection.ltr,
  bool visible = true,
  bool reduceMotion = false,
  bool accessibleNavigation = false,
}) async {
  tester.view
    ..physicalSize = Size(width, 844)
    ..devicePixelRatio = 1;
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
              child: SizedBox(
                width: width,
                child: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> advanceContent(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}
