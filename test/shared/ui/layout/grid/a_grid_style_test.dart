import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_theme_catalog.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_style.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

void main() {
  test('G01 AGridStyle is registered for light and dark Forui styles', () {
    for (final theme in [lightTheme, darkTheme]) {
      expect(theme.style.extensions, contains(isA<AGridStyle>()));
      expect(theme.style.aGrid, isA<AGridStyle>());
      expect(theme.style.aGrid.minimumTouchSize, greaterThanOrEqualTo(44));
    }
  });

  test('AGridStyle copyWith and lerp preserve the complete contract', () {
    final light = lightTheme.style.aGrid;
    final dark = darkTheme.style.aGrid;
    final copy = light.copyWith(
      horizontalGap: 20,
      verticalGap: 24,
      childAspectRatio: 1.5,
      itemPadding: const EdgeInsets.all(18),
      visualPadding: const EdgeInsets.all(10),
    );

    expect(copy.horizontalGap, 20);
    expect(copy.verticalGap, 24);
    expect(copy.childAspectRatio, 1.5);
    expect(copy.itemPadding, const EdgeInsets.all(18));
    expect(copy.visualPadding, const EdgeInsets.all(10));
    expect(copy.gridDecoration, light.gridDecoration);
    expect(copy.itemDecoration, light.itemDecoration);
    expect(copy.visualDecoration, light.visualDecoration);

    final midpoint = light.lerp(dark, 0.5);
    final styleMidpoint = lightTheme.style.lerp(darkTheme.style, 0.5).aGrid;
    expect(midpoint, isA<AGridStyle>());
    expect(styleMidpoint, isA<AGridStyle>());
    expect(midpoint.minimumTouchSize, light.minimumTouchSize);
    expect(
      midpoint.itemDecoration.resolve({FTappableVariant.selected}),
      isA<Decoration>(),
    );
    expect(
      midpoint.titleTextStyle.resolve({FTappableVariant.disabled}),
      isA<TextStyle>(),
    );
    expect(
      midpoint.visualDecoration.resolve({FTappableVariant.selected}),
      isA<Decoration>(),
    );
  });

  test('selected title meets contrast on every selected item surface', () {
    for (final preset in AppThemePreset.values) {
      for (final radius in AppRadiusPreference.values) {
        final pair = AppThemeCatalog.resolve(preset: preset, radius: radius);
        for (final theme in [pair.light, pair.dark]) {
          final style = theme.style.aGrid;
          final foreground = style.titleTextStyle.resolve({
            FTappableVariant.selected,
          }).color!;
          final decoration = style.itemDecoration.resolve({
            FTappableVariant.selected,
          });
          final background = (decoration as BoxDecoration).color!;
          expect(
            _contrast(foreground, background),
            greaterThanOrEqualTo(4.5),
            reason:
                '${preset.name}/${radius.name}/'
                '${theme.colors.brightness.name}',
          );
        }
      }
    }
  });
}

double _contrast(Color foreground, Color background) {
  final light = foreground.computeLuminance();
  final dark = background.computeLuminance();
  final brightest = light > dark ? light : dark;
  final darkest = light > dark ? dark : light;
  return (brightest + 0.05) / (darkest + 0.05);
}
