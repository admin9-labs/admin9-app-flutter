import 'dart:ui';

import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_theme_catalog.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog caches every preset, font size, radius, and brightness', () {
    for (final preset in AppThemePreset.values) {
      for (final fontSize in AppFontSizePreference.values) {
        for (final radius in AppRadiusPreference.values) {
          final first = AppThemeCatalog.resolve(
            preset: preset,
            fontSize: fontSize,
            radius: radius,
          );
          final second = AppThemeCatalog.resolve(
            preset: preset,
            fontSize: fontSize,
            radius: radius,
          );
          expect(identical(first, second), isTrue);
          expect(identical(first.lightMaterial, second.lightMaterial), isTrue);
          expect(identical(first.darkMaterial, second.darkMaterial), isTrue);
          expect(first.light.colors.brightness, Brightness.light);
          expect(first.dark.colors.brightness, Brightness.dark);
          for (final theme in [first.light, first.dark]) {
            expect(theme.style.aGrid, isA<AGridStyle>());
            expect(theme.typography.body.fontFamily, isNotEmpty);
            expect(theme.icons.search, isNotNull);
            expect(
              theme.buttonStyles.primary.md.contentStyle.constraints.minHeight,
              greaterThanOrEqualTo(44),
            );
            final material = theme.toApproximateMaterialTheme();
            expect(material.brightness, theme.colors.brightness);
            expect(material.colorScheme.primary, theme.colors.primary);
            expect(
              material.textTheme.bodyMedium?.fontFamily,
              theme.typography.body.fontFamily,
            );
          }
        }
      }
    }
  });

  test('presets have distinct primary and base palettes', () {
    final pairs = AppThemePreset.values
        .map(
          (preset) => AppThemeCatalog.resolve(
            preset: preset,
            fontSize: AppFontSizePreference.standard,
            radius: AppRadiusPreference.medium,
          ),
        )
        .toList();

    expect(
      pairs.map((pair) => pair.light.colors.primary).toSet(),
      hasLength(3),
    );
    expect(pairs.map((pair) => pair.light.colors.muted).toSet(), hasLength(3));
    expect(pairs.map((pair) => pair.dark.colors.card).toSet(), hasLength(3));
  });

  test('all semantic foreground/background pairs meet 4.5 to 1', () {
    for (final preset in AppThemePreset.values) {
      final pair = AppThemeCatalog.resolve(
        preset: preset,
        fontSize: AppFontSizePreference.standard,
        radius: AppRadiusPreference.medium,
      );
      for (final colors in [pair.light.colors, pair.dark.colors]) {
        final pairs = {
          'background': (colors.foreground, colors.background),
          'primary': (colors.primaryForeground, colors.primary),
          'secondary': (colors.secondaryForeground, colors.secondary),
          'muted': (colors.mutedForeground, colors.muted),
          'destructive': (colors.destructiveForeground, colors.destructive),
          'error': (colors.errorForeground, colors.error),
          'card': (colors.foreground, colors.card),
        };
        for (final MapEntry(key: name, value: colorPair) in pairs.entries) {
          expect(
            _contrast(colorPair.$1, colorPair.$2),
            greaterThanOrEqualTo(4.5),
            reason: '$preset ${colors.brightness} $name',
          );
        }
      }
    }
  });

  test('font-size choices scale Forui and Material typography together', () {
    final expectedBodySize = {
      AppFontSizePreference.extraSmall: 14.0,
      AppFontSizePreference.small: 15.0,
      AppFontSizePreference.standard: 16.0,
      AppFontSizePreference.large: 18.0,
      AppFontSizePreference.extraLarge: 20.0,
    };

    for (final entry in expectedBodySize.entries) {
      final pair = AppThemeCatalog.resolve(
        preset: AppThemePreset.neutral,
        fontSize: entry.key,
        radius: AppRadiusPreference.medium,
      );
      for (final (forui, material) in [
        (pair.light, pair.lightMaterial),
        (pair.dark, pair.darkMaterial),
      ]) {
        expect(forui.typography.body.sm.fontSize, entry.value);
        expect(forui.typography.display.lg.fontSize, 20 * entry.value / 16);
        expect(material.textTheme.bodyMedium?.fontSize, entry.value);
        expect(
          forui.style.aGrid.descriptionTextStyle.resolve({}).fontSize,
          entry.value,
        );
      }
    }
  });

  test('radius choices use the official Forui CLI token scales', () {
    final expected = {
      AppRadiusPreference.small: [3.0, 4.0, 6.0, 7.0, 10.0, 13.0],
      AppRadiusPreference.medium: [4.0, 6.0, 8.0, 10.0, 14.0, 18.0],
      AppRadiusPreference.large: [6.0, 8.0, 11.0, 14.0, 20.0, 25.0],
    };

    for (final entry in expected.entries) {
      final style = AppThemeCatalog.resolve(
        preset: AppThemePreset.neutral,
        fontSize: AppFontSizePreference.standard,
        radius: entry.key,
      ).light.style;
      final radii = style.borderRadius;
      expect(
        [
          radii.xs2,
          radii.xs,
          radii.sm,
          radii.md,
          radii.lg,
          radii.xl,
        ].map((radius) => radius.topLeft.x).toList(),
        entry.value,
      );
      expect(style.aGrid.focusedOutlineStyle.borderRadius, radii.md);
    }
  });
}

double _contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return (a > b ? a + 0.05 : b + 0.05) / (a > b ? b + 0.05 : a + 0.05);
}
