import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' show ThemeExtension;

/// The Admin9 grid's App-wide visual and interaction contract.
class AGridStyle extends ThemeExtension<AGridStyle> {
  const AGridStyle({
    required this.gridDecoration,
    required this.itemDecoration,
    required this.visualDecoration,
    required this.titleTextStyle,
    required this.descriptionTextStyle,
    required this.iconStyle,
    required this.focusedOutlineStyle,
    required this.gridPadding,
    required this.itemPadding,
    required this.visualPadding,
    required this.horizontalGap,
    required this.verticalGap,
    required this.childAspectRatio,
    required this.visualSpacing,
    required this.textSpacing,
    required this.minimumTouchSize,
  });

  factory AGridStyle.inherit({
    required FColors colors,
    required FTypography typography,
    required FBorderRadius borderRadius,
    required FFocusedOutlineStyle focusedOutlineStyle,
  }) {
    final itemDecoration =
        FVariants<
          FTappableVariantConstraint,
          FTappableVariant,
          Decoration,
          DecorationDelta
        >.from(
          BoxDecoration(
            color: colors.card,
            border: Border.all(color: colors.border),
            borderRadius: borderRadius.md,
          ),
          variants: {
            [.pressed]: DecorationDelta.boxDelta(color: colors.secondary),
            [.selected]: DecorationDelta.boxDelta(
              color: colors.secondary,
              border: Border.all(color: colors.primary, width: 1.5),
            ),
            [.disabled]: DecorationDelta.boxDelta(
              color: colors.disable(colors.card),
              border: Border.all(color: colors.disable(colors.border)),
            ),
            [.disabled.and(.selected)]: DecorationDelta.boxDelta(
              color: colors.disable(colors.secondary),
              border: Border.all(color: colors.disable(colors.primary)),
            ),
          },
        );
    final titleTextStyle =
        FVariants<
          FTappableVariantConstraint,
          FTappableVariant,
          TextStyle,
          TextStyleDelta
        >.from(
          typography.body.md.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w600,
          ),
          variants: {
            [.selected]: TextStyleDelta.delta(
              color: colors.secondaryForeground,
            ),
            [.disabled]: TextStyleDelta.delta(
              color: colors.disable(colors.foreground),
            ),
            [.disabled.and(.selected)]: TextStyleDelta.delta(
              color: colors.disable(colors.secondaryForeground),
            ),
          },
        );
    final visualDecoration =
        FVariants<
          FTappableVariantConstraint,
          FTappableVariant,
          Decoration,
          DecorationDelta
        >.from(
          BoxDecoration(color: colors.muted, borderRadius: borderRadius.md),
          variants: {
            [.pressed]: DecorationDelta.boxDelta(color: colors.secondary),
            [.selected]: DecorationDelta.boxDelta(color: colors.primary),
            [.disabled]: DecorationDelta.boxDelta(
              color: colors.disable(colors.muted),
            ),
            [.disabled.and(.selected)]: DecorationDelta.boxDelta(
              color: colors.disable(colors.primary),
            ),
          },
        );
    final descriptionTextStyle =
        FVariants<
          FTappableVariantConstraint,
          FTappableVariant,
          TextStyle,
          TextStyleDelta
        >.from(
          typography.body.sm.copyWith(color: colors.mutedForeground),
          variants: {
            [.disabled]: TextStyleDelta.delta(
              color: colors.disable(colors.mutedForeground),
            ),
          },
        );
    final iconStyle =
        FVariants<
          FTappableVariantConstraint,
          FTappableVariant,
          IconThemeData,
          IconThemeDataDelta
        >.from(
          IconThemeData(color: colors.primary, size: 28),
          variants: {
            [.selected]: IconThemeDataDelta.delta(
              color: colors.primaryForeground,
            ),
            [.disabled]: IconThemeDataDelta.delta(
              color: colors.disable(colors.primary),
            ),
            [.disabled.and(.selected)]: IconThemeDataDelta.delta(
              color: colors.disable(colors.primaryForeground),
            ),
          },
        );

    return AGridStyle(
      gridDecoration: const BoxDecoration(),
      itemDecoration: itemDecoration,
      visualDecoration: visualDecoration,
      titleTextStyle: titleTextStyle,
      descriptionTextStyle: descriptionTextStyle,
      iconStyle: iconStyle,
      focusedOutlineStyle: focusedOutlineStyle.copyWith(
        borderRadius: borderRadius.md,
        spacing: -1,
      ),
      gridPadding: EdgeInsets.zero,
      itemPadding: const EdgeInsets.all(12),
      visualPadding: const EdgeInsets.all(10),
      horizontalGap: 12,
      verticalGap: 12,
      childAspectRatio: 1,
      visualSpacing: 10,
      textSpacing: 4,
      minimumTouchSize: 48,
    );
  }

  final Decoration gridDecoration;
  final FVariants<
    FTappableVariantConstraint,
    FTappableVariant,
    Decoration,
    DecorationDelta
  >
  itemDecoration;
  final FVariants<
    FTappableVariantConstraint,
    FTappableVariant,
    Decoration,
    DecorationDelta
  >
  visualDecoration;
  final FVariants<
    FTappableVariantConstraint,
    FTappableVariant,
    TextStyle,
    TextStyleDelta
  >
  titleTextStyle;
  final FVariants<
    FTappableVariantConstraint,
    FTappableVariant,
    TextStyle,
    TextStyleDelta
  >
  descriptionTextStyle;
  final FVariants<
    FTappableVariantConstraint,
    FTappableVariant,
    IconThemeData,
    IconThemeDataDelta
  >
  iconStyle;
  final FFocusedOutlineStyle focusedOutlineStyle;
  final EdgeInsetsGeometry gridPadding;
  final EdgeInsetsGeometry itemPadding;
  final EdgeInsetsGeometry visualPadding;
  final double horizontalGap;
  final double verticalGap;
  final double childAspectRatio;
  final double visualSpacing;
  final double textSpacing;
  final double minimumTouchSize;

  @override
  AGridStyle copyWith({
    Decoration? gridDecoration,
    FVariants<
      FTappableVariantConstraint,
      FTappableVariant,
      Decoration,
      DecorationDelta
    >?
    itemDecoration,
    FVariants<
      FTappableVariantConstraint,
      FTappableVariant,
      Decoration,
      DecorationDelta
    >?
    visualDecoration,
    FVariants<
      FTappableVariantConstraint,
      FTappableVariant,
      TextStyle,
      TextStyleDelta
    >?
    titleTextStyle,
    FVariants<
      FTappableVariantConstraint,
      FTappableVariant,
      TextStyle,
      TextStyleDelta
    >?
    descriptionTextStyle,
    FVariants<
      FTappableVariantConstraint,
      FTappableVariant,
      IconThemeData,
      IconThemeDataDelta
    >?
    iconStyle,
    FFocusedOutlineStyle? focusedOutlineStyle,
    EdgeInsetsGeometry? gridPadding,
    EdgeInsetsGeometry? itemPadding,
    EdgeInsetsGeometry? visualPadding,
    double? horizontalGap,
    double? verticalGap,
    double? childAspectRatio,
    double? visualSpacing,
    double? textSpacing,
    double? minimumTouchSize,
  }) => AGridStyle(
    gridDecoration: gridDecoration ?? this.gridDecoration,
    itemDecoration: itemDecoration ?? this.itemDecoration,
    visualDecoration: visualDecoration ?? this.visualDecoration,
    titleTextStyle: titleTextStyle ?? this.titleTextStyle,
    descriptionTextStyle: descriptionTextStyle ?? this.descriptionTextStyle,
    iconStyle: iconStyle ?? this.iconStyle,
    focusedOutlineStyle: focusedOutlineStyle ?? this.focusedOutlineStyle,
    gridPadding: gridPadding ?? this.gridPadding,
    itemPadding: itemPadding ?? this.itemPadding,
    visualPadding: visualPadding ?? this.visualPadding,
    horizontalGap: horizontalGap ?? this.horizontalGap,
    verticalGap: verticalGap ?? this.verticalGap,
    childAspectRatio: childAspectRatio ?? this.childAspectRatio,
    visualSpacing: visualSpacing ?? this.visualSpacing,
    textSpacing: textSpacing ?? this.textSpacing,
    minimumTouchSize: minimumTouchSize ?? this.minimumTouchSize,
  );

  @override
  AGridStyle lerp(covariant AGridStyle? other, double t) {
    if (other == null) {
      return this;
    }

    return AGridStyle(
      gridDecoration:
          Decoration.lerp(gridDecoration, other.gridDecoration, t) ??
          gridDecoration,
      itemDecoration: FVariants.lerpDecoration(
        itemDecoration,
        other.itemDecoration,
        t,
      ),
      visualDecoration: FVariants.lerpDecoration(
        visualDecoration,
        other.visualDecoration,
        t,
      ),
      titleTextStyle: FVariants.lerpTextStyle(
        titleTextStyle,
        other.titleTextStyle,
        t,
      ),
      descriptionTextStyle: FVariants.lerpTextStyle(
        descriptionTextStyle,
        other.descriptionTextStyle,
        t,
      ),
      iconStyle: FVariants.lerpIconThemeData(iconStyle, other.iconStyle, t),
      focusedOutlineStyle: focusedOutlineStyle.lerp(
        other.focusedOutlineStyle,
        t,
      ),
      gridPadding:
          EdgeInsetsGeometry.lerp(gridPadding, other.gridPadding, t) ??
          gridPadding,
      itemPadding:
          EdgeInsetsGeometry.lerp(itemPadding, other.itemPadding, t) ??
          itemPadding,
      visualPadding:
          EdgeInsetsGeometry.lerp(visualPadding, other.visualPadding, t) ??
          visualPadding,
      horizontalGap:
          lerpDouble(horizontalGap, other.horizontalGap, t) ?? horizontalGap,
      verticalGap: lerpDouble(verticalGap, other.verticalGap, t) ?? verticalGap,
      childAspectRatio:
          lerpDouble(childAspectRatio, other.childAspectRatio, t) ??
          childAspectRatio,
      visualSpacing:
          lerpDouble(visualSpacing, other.visualSpacing, t) ?? visualSpacing,
      textSpacing: lerpDouble(textSpacing, other.textSpacing, t) ?? textSpacing,
      minimumTouchSize:
          lerpDouble(minimumTouchSize, other.minimumTouchSize, t) ??
          minimumTouchSize,
    );
  }
}

extension AGridFStyle on FStyle {
  AGridStyle get aGrid => extension<AGridStyle>();
}
