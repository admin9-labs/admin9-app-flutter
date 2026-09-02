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
      final style = theme.style.aGrid;
      expect(theme.style.extensions, contains(isA<AGridStyle>()));
      expect(style.minimumTouchSize, greaterThanOrEqualTo(44));
      expect(style.horizontalGap, 8);
      expect(style.verticalGap, 8);
      expect(style.childAspectRatio, 1);
      expect(style.iconStyle.resolve({}).size, 24);
      expect(style.iconSlotSize, 44);
      expect(style.badgeTopOffset, -4);
      expect(style.badgeEndOffset, -6);
    }
  });

  test('AGridStyle copyWith and lerp preserve the complete contract', () {
    final light = lightTheme.style.aGrid;
    final dark = darkTheme.style.aGrid;
    final copy = light.copyWith(
      horizontalGap: 20,
      verticalGap: 24,
      childAspectRatio: 1.25,
      itemPadding: const EdgeInsets.all(18),
      badgeDotSize: 10,
      badgeLabelMaxWidth: 56,
      badgeDisabledOpacity: 0.35,
      iconSlotSize: 48,
      badgeTopOffset: -2,
      badgeEndOffset: -4,
    );

    expect(copy.horizontalGap, 20);
    expect(copy.verticalGap, 24);
    expect(copy.childAspectRatio, 1.25);
    expect(copy.itemPadding, const EdgeInsets.all(18));
    expect(copy.badgeDotSize, 10);
    expect(copy.badgeLabelMaxWidth, 56);
    expect(copy.badgeDisabledOpacity, 0.35);
    expect(copy.iconSlotSize, 48);
    expect(copy.badgeTopOffset, -2);
    expect(copy.badgeEndOffset, -4);
    expect(copy.gridDecoration, light.gridDecoration);
    expect(copy.transparentItemDecoration, light.transparentItemDecoration);
    expect(copy.mutedItemDecoration, light.mutedItemDecoration);
    expect(copy.outlinedItemDecoration, light.outlinedItemDecoration);
    expect(copy.attentionBadgeDecoration, light.attentionBadgeDecoration);

    final midpoint = light.lerp(dark, 0.5);
    final styleMidpoint = lightTheme.style.lerp(darkTheme.style, 0.5).aGrid;
    expect(midpoint, isA<AGridStyle>());
    expect(styleMidpoint, isA<AGridStyle>());
    expect(midpoint.minimumTouchSize, light.minimumTouchSize);
    expect(
      midpoint.transparentItemDecoration.resolve({FTappableVariant.selected}),
      isA<Decoration>(),
    );
    final transparentSelected = light.transparentItemDecoration.resolve({
      FTappableVariant.selected,
    }) as BoxDecoration;
    expect(transparentSelected.color, const Color(0x00000000));
    expect((transparentSelected.border! as Border).top.width, 1.5);
    final pressed = light.mutedItemDecoration.resolve({
      FTappableVariant.pressed,
    }) as BoxDecoration;
    expect(pressed.color, lightTheme.colors.secondary);
    expect(pressed.border, Border.all(color: lightTheme.colors.primary));
    expect(
      midpoint.labelTextStyle.resolve({FTappableVariant.disabled}),
      isA<TextStyle>(),
    );
    expect(midpoint.attentionBadgeDecoration, isA<Decoration>());
    expect(midpoint.neutralBadgeTextStyle, isA<TextStyle>());
  });

  test('item and badge text meet contrast across all App themes', () {
    for (final preset in AppThemePreset.values) {
      for (final radius in AppRadiusPreference.values) {
        final pair = AppThemeCatalog.resolve(
          preset: preset,
          fontSize: AppFontSizePreference.standard,
          radius: radius,
        );
        for (final theme in [pair.light, pair.dark]) {
          final style = theme.style.aGrid;
          final itemForeground = style.labelTextStyle.resolve({
            FTappableVariant.selected,
          }).color!;
          final itemBackground = (style.mutedItemDecoration.resolve({
            FTappableVariant.selected,
          }) as BoxDecoration).color!;
          final attentionBackground =
              (style.attentionBadgeDecoration as BoxDecoration).color!;
          final neutralBackground =
              (style.neutralBadgeDecoration as BoxDecoration).color!;
          final reason =
              '${preset.name}/${radius.name}/${theme.colors.brightness.name}';

          expect(
            _contrast(itemForeground, itemBackground),
            greaterThanOrEqualTo(4.5),
            reason: 'item $reason',
          );
          expect(
            _contrast(
              style.attentionBadgeTextStyle.color!,
              attentionBackground,
            ),
            greaterThanOrEqualTo(4.5),
            reason: 'attention badge $reason',
          );
          expect(
            _contrast(style.neutralBadgeTextStyle.color!, neutralBackground),
            greaterThanOrEqualTo(4.5),
            reason: 'neutral badge $reason',
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
