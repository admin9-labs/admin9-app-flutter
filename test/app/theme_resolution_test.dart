import 'dart:io';
import 'dart:ui';

import 'package:admin9_app_flutter/features/foundation/presentation/pages/foundation_page.dart';
import 'package:admin9_app_flutter/features/settings/data/models/theme_preference.dart';
import 'package:admin9_app_flutter/features/settings/presentation/providers/theme_preference_provider.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' as material;

import 'support/test_admin9_app.dart';

void main() {
  test('generated themes contain no placeholder extensions', () {
    final extensionArgument = RegExp(r'\bextensions\s*:');
    for (final path in ['lib/theme/colors.dart', 'lib/theme/style.dart']) {
      expect(
        File(path).readAsStringSync(),
        isNot(contains(extensionArgument)),
        reason: '$path must omit extension arguments until one has a consumer',
      );
    }

    for (final theme in [lightTheme, darkTheme]) {
      expect(theme.colors.extensions, isEmpty);
      expect(theme.style.extensions, isEmpty);
    }
  });

  testWidgets('resolves explicit and system brightness for both theme layers', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final repository = FakeThemePreferenceRepository(
      preference: ThemePreference.light,
    );
    await pumpTestAdmin9App(tester, repository: repository);

    _expectBrightness(tester, Brightness.light);
    final context = tester.element(find.byType(FoundationPage));
    final container = ProviderScope.containerOf(context);

    await container
        .read(themePreferenceProvider.notifier)
        .setPreference(ThemePreference.dark);
    await tester.pumpAndSettle();
    _expectBrightness(tester, Brightness.dark);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await container
        .read(themePreferenceProvider.notifier)
        .setPreference(ThemePreference.system);
    await tester.pumpAndSettle();
    _expectBrightness(tester, Brightness.dark);
  });
}

void _expectBrightness(WidgetTester tester, Brightness expected) {
  final context = tester.element(find.byType(FoundationPage));
  expect(material.Theme.of(context).brightness, expected);
  expect(FTheme.of(context).colors.brightness, expected);
}
