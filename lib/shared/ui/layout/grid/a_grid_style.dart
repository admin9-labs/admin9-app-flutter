import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' show ThemeExtension;

FVariants<
  FTappableVariantConstraint,
  FTappableVariant,
  Decoration,
  DecorationDelta
>
_itemDecoration({
  required FColors colors,
  required FBorderRadius borderRadius,
  required Color background,
  required BoxBorder? border,
  required Color selectedBackground,
  required Color disabledBackground,
  required Color disabledSelectedBackground,
  required BoxBorder? disabledBorder,
}) => FVariants.from(
  BoxDecoration(
    color: background,
    border: border,
    borderRadius: borderRadius.md,
  ),
  variants: {
    [.pressed]: DecorationDelta.boxDelta(
      color: colors.secondary,
      border: Border.all(color: colors.primary),
    ),
    [.selected]: DecorationDelta.boxDelta(
      color: selectedBackground,
      border: Border.all(color: colors.primary, width: 1.5),
    ),
    [.disabled]: DecorationDelta.boxDelta(
      color: disabledBackground,
      border: disabledBorder,
    ),
    [.disabled.and(.selected)]: DecorationDelta.boxDelta(
      color: disabledSelectedBackground,
      border: Border.all(color: colors.disable(colors.primary)),
    ),
  },
);

/// The Admin9 icon action grid's App-wide visual and interaction contract.
class AGridStyle extends ThemeExtension<AGridStyle> {
  const AGridStyle({
    required this.gridDecoration,
    required this.transparentItemDecoration,
    required this.mutedItemDecoration,
    required this.outlinedItemDecoration,
    required this.labelTextStyle,
    required this.iconStyle,
    required this.attentionBadgeDecoration,
    required this.attentionBadgeTextStyle,
    required this.neutralBadgeDecoration,
    required this.neutralBadgeTextStyle,
    required this.focusedOutlineStyle,
    required this.gridPadding,
    required this.itemPadding,
    required this.horizontalGap,
    required this.verticalGap,
    required this.childAspectRatio,
    required this.iconLabelSpacing,
    required this.iconSlotSize,
    required this.badgeTopOffset,
    required this.badgeEndOffset,
    required this.minimumTouchSize,
    required this.badgeCountPadding,
    required this.badgeLabelPadding,
    required this.badgeMinimumSize,
    required this.badgeDotSize,
    required this.badgeLabelMaxWidth,
    required this.badgeDisabledOpacity,
  });

  factory AGridStyle.inherit({
    required FColors colors,
    required FTypography typography,
    required FBorderRadius borderRadius,
    required FFocusedOutlineStyle focusedOutlineStyle,
  }) {
    const transparent = Color(0x00000000);
    final transparentItemDecoration = _itemDecoration(
      colors: colors,
      borderRadius: borderRadius,
      background: transparent,
      border: null,
      selectedBackground: transparent,
      disabledBackground: transparent,
      disabledSelectedBackground: transparent,
      disabledBorder: null,
    );
    final mutedItemDecoration = _itemDecoration(
      colors: colors,
      borderRadius: borderRadius,
      background: colors.muted,
      border: Border.all(color: colors.border),
      selectedBackground: colors.secondary,
      disabledBackground: colors.disable(colors.muted),
      disabledSelectedBackground: colors.disable(colors.secondary),
      disabledBorder: Border.all(color: colors.disable(colors.border)),
    );
    final outlinedItemDecoration = _itemDecoration(
      colors: colors,
      borderRadius: borderRadius,
      background: transparent,
      border: Border.all(color: colors.border),
      selectedBackground: transparent,
      disabledBackground: transparent,
      disabledSelectedBackground: transparent,
      disabledBorder: Border.all(color: colors.disable(colors.border)),
    );
    final labelTextStyle =
        FVariants<
          FTappableVariantConstraint,
          FTappableVariant,
          TextStyle,
          TextStyleDelta
        >.from(
          typography.body.xs.copyWith(color: colors.foreground),
          variants: {
            [.disabled]: TextStyleDelta.delta(
              color: colors.disable(colors.foreground),
            ),
            [.disabled.and(.selected)]: TextStyleDelta.delta(
              color: colors.disable(colors.foreground),
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
          IconThemeData(color: colors.foreground, size: 24),
          variants: {
            [.disabled]: IconThemeDataDelta.delta(
              color: colors.disable(colors.foreground),
            ),
            [.disabled.and(.selected)]: IconThemeDataDelta.delta(
              color: colors.disable(colors.foreground),
            ),
          },
        );

    return AGridStyle(
      gridDecoration: const BoxDecoration(),
      transparentItemDecoration: transparentItemDecoration,
      mutedItemDecoration: mutedItemDecoration,
      outlinedItemDecoration: outlinedItemDecoration,
      labelTextStyle: labelTextStyle,
      iconStyle: iconStyle,
      attentionBadgeDecoration: BoxDecoration(
        color: colors.destructive,
        borderRadius: borderRadius.pill,
      ),
      attentionBadgeTextStyle: typography.body.xs.copyWith(
        color: colors.destructiveForeground,
        fontWeight: FontWeight.w500,
      ),
      neutralBadgeDecoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: borderRadius.pill,
      ),
      neutralBadgeTextStyle: typography.body.xs.copyWith(
        color: colors.secondaryForeground,
        fontWeight: FontWeight.w500,
      ),
      focusedOutlineStyle: focusedOutlineStyle.copyWith(
        borderRadius: borderRadius.md,
        spacing: -1,
      ),
      gridPadding: EdgeInsets.zero,
      itemPadding: const EdgeInsets.all(12),
      horizontalGap: 8,
      verticalGap: 8,
      childAspectRatio: 1,
      iconLabelSpacing: 6,
      iconSlotSize: 44,
      badgeTopOffset: -4,
      badgeEndOffset: -6,
      minimumTouchSize: 48,
      badgeCountPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      badgeLabelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      badgeMinimumSize: 18,
      badgeDotSize: 8,
      badgeLabelMaxWidth: 48,
      badgeDisabledOpacity: 0.45,
    );
  }

  final Decoration gridDecoration;
  final FVariants<
    FTappableVariantConstraint,
    FTappableVariant,
    Decoration,
    DecorationDelta
  >
  transparentItemDecoration;
  final FVariants<
    FTappableVariantConstraint,
    FTappableVariant,
    Decoration,
    DecorationDelta
  >
  mutedItemDecoration;
  final FVariants<
    FTappableVariantConstraint,
    FTappableVariant,
    Decoration,
    DecorationDelta
  >
  outlinedItemDecoration;
  final FVariants<
    FTappableVariantConstraint,
    FTappableVariant,
    TextStyle,
    TextStyleDelta
  >
  labelTextStyle;
  final FVariants<
    FTappableVariantConstraint,
    FTappableVariant,
    IconThemeData,
    IconThemeDataDelta
  >
  iconStyle;
  final Decoration attentionBadgeDecoration;
  final TextStyle attentionBadgeTextStyle;
  final Decoration neutralBadgeDecoration;
  final TextStyle neutralBadgeTextStyle;
  final FFocusedOutlineStyle focusedOutlineStyle;
  final EdgeInsetsGeometry gridPadding;
  final EdgeInsetsGeometry itemPadding;
  final double horizontalGap;
  final double verticalGap;
  final double childAspectRatio;
  final double iconLabelSpacing;
  final double iconSlotSize;
  final double badgeTopOffset;
  final double badgeEndOffset;
  final double minimumTouchSize;
  final EdgeInsetsGeometry badgeCountPadding;
  final EdgeInsetsGeometry badgeLabelPadding;
  final double badgeMinimumSize;
  final double badgeDotSize;
  final double badgeLabelMaxWidth;
  final double badgeDisabledOpacity;

  @override
  AGridStyle copyWith({
    Decoration? gridDecoration,
    FVariants<
      FTappableVariantConstraint,
      FTappableVariant,
      Decoration,
      DecorationDelta
    >?
    transparentItemDecoration,
    FVariants<
      FTappableVariantConstraint,
      FTappableVariant,
      Decoration,
      DecorationDelta
    >?
    mutedItemDecoration,
    FVariants<
      FTappableVariantConstraint,
      FTappableVariant,
      Decoration,
      DecorationDelta
    >?
    outlinedItemDecoration,
    FVariants<
      FTappableVariantConstraint,
      FTappableVariant,
      TextStyle,
      TextStyleDelta
    >?
    labelTextStyle,
    FVariants<
      FTappableVariantConstraint,
      FTappableVariant,
      IconThemeData,
      IconThemeDataDelta
    >?
    iconStyle,
    Decoration? attentionBadgeDecoration,
    TextStyle? attentionBadgeTextStyle,
    Decoration? neutralBadgeDecoration,
    TextStyle? neutralBadgeTextStyle,
    FFocusedOutlineStyle? focusedOutlineStyle,
    EdgeInsetsGeometry? gridPadding,
    EdgeInsetsGeometry? itemPadding,
    double? horizontalGap,
    double? verticalGap,
    double? childAspectRatio,
    double? iconLabelSpacing,
    double? iconSlotSize,
    double? badgeTopOffset,
    double? badgeEndOffset,
    double? minimumTouchSize,
    EdgeInsetsGeometry? badgeCountPadding,
    EdgeInsetsGeometry? badgeLabelPadding,
    double? badgeMinimumSize,
    double? badgeDotSize,
    double? badgeLabelMaxWidth,
    double? badgeDisabledOpacity,
  }) => AGridStyle(
    gridDecoration: gridDecoration ?? this.gridDecoration,
    transparentItemDecoration:
        transparentItemDecoration ?? this.transparentItemDecoration,
    mutedItemDecoration: mutedItemDecoration ?? this.mutedItemDecoration,
    outlinedItemDecoration:
        outlinedItemDecoration ?? this.outlinedItemDecoration,
    labelTextStyle: labelTextStyle ?? this.labelTextStyle,
    iconStyle: iconStyle ?? this.iconStyle,
    attentionBadgeDecoration:
        attentionBadgeDecoration ?? this.attentionBadgeDecoration,
    attentionBadgeTextStyle:
        attentionBadgeTextStyle ?? this.attentionBadgeTextStyle,
    neutralBadgeDecoration:
        neutralBadgeDecoration ?? this.neutralBadgeDecoration,
    neutralBadgeTextStyle: neutralBadgeTextStyle ?? this.neutralBadgeTextStyle,
    focusedOutlineStyle: focusedOutlineStyle ?? this.focusedOutlineStyle,
    gridPadding: gridPadding ?? this.gridPadding,
    itemPadding: itemPadding ?? this.itemPadding,
    horizontalGap: horizontalGap ?? this.horizontalGap,
    verticalGap: verticalGap ?? this.verticalGap,
    childAspectRatio: childAspectRatio ?? this.childAspectRatio,
    iconLabelSpacing: iconLabelSpacing ?? this.iconLabelSpacing,
    iconSlotSize: iconSlotSize ?? this.iconSlotSize,
    badgeTopOffset: badgeTopOffset ?? this.badgeTopOffset,
    badgeEndOffset: badgeEndOffset ?? this.badgeEndOffset,
    minimumTouchSize: minimumTouchSize ?? this.minimumTouchSize,
    badgeCountPadding: badgeCountPadding ?? this.badgeCountPadding,
    badgeLabelPadding: badgeLabelPadding ?? this.badgeLabelPadding,
    badgeMinimumSize: badgeMinimumSize ?? this.badgeMinimumSize,
    badgeDotSize: badgeDotSize ?? this.badgeDotSize,
    badgeLabelMaxWidth: badgeLabelMaxWidth ?? this.badgeLabelMaxWidth,
    badgeDisabledOpacity: badgeDisabledOpacity ?? this.badgeDisabledOpacity,
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
      transparentItemDecoration: FVariants.lerpDecoration(
        transparentItemDecoration,
        other.transparentItemDecoration,
        t,
      ),
      mutedItemDecoration: FVariants.lerpDecoration(
        mutedItemDecoration,
        other.mutedItemDecoration,
        t,
      ),
      outlinedItemDecoration: FVariants.lerpDecoration(
        outlinedItemDecoration,
        other.outlinedItemDecoration,
        t,
      ),
      labelTextStyle: FVariants.lerpTextStyle(
        labelTextStyle,
        other.labelTextStyle,
        t,
      ),
      iconStyle: FVariants.lerpIconThemeData(iconStyle, other.iconStyle, t),
      attentionBadgeDecoration:
          Decoration.lerp(
            attentionBadgeDecoration,
            other.attentionBadgeDecoration,
            t,
          ) ??
          attentionBadgeDecoration,
      attentionBadgeTextStyle:
          TextStyle.lerp(
            attentionBadgeTextStyle,
            other.attentionBadgeTextStyle,
            t,
          ) ??
          attentionBadgeTextStyle,
      neutralBadgeDecoration:
          Decoration.lerp(
            neutralBadgeDecoration,
            other.neutralBadgeDecoration,
            t,
          ) ??
          neutralBadgeDecoration,
      neutralBadgeTextStyle:
          TextStyle.lerp(
            neutralBadgeTextStyle,
            other.neutralBadgeTextStyle,
            t,
          ) ??
          neutralBadgeTextStyle,
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
      horizontalGap:
          lerpDouble(horizontalGap, other.horizontalGap, t) ?? horizontalGap,
      verticalGap: lerpDouble(verticalGap, other.verticalGap, t) ?? verticalGap,
      childAspectRatio:
          lerpDouble(childAspectRatio, other.childAspectRatio, t) ??
          childAspectRatio,
      iconLabelSpacing:
          lerpDouble(iconLabelSpacing, other.iconLabelSpacing, t) ??
          iconLabelSpacing,
      iconSlotSize:
          lerpDouble(iconSlotSize, other.iconSlotSize, t) ?? iconSlotSize,
      badgeTopOffset:
          lerpDouble(badgeTopOffset, other.badgeTopOffset, t) ?? badgeTopOffset,
      badgeEndOffset:
          lerpDouble(badgeEndOffset, other.badgeEndOffset, t) ?? badgeEndOffset,
      minimumTouchSize:
          lerpDouble(minimumTouchSize, other.minimumTouchSize, t) ??
          minimumTouchSize,
      badgeCountPadding:
          EdgeInsetsGeometry.lerp(
            badgeCountPadding,
            other.badgeCountPadding,
            t,
          ) ??
          badgeCountPadding,
      badgeLabelPadding:
          EdgeInsetsGeometry.lerp(
            badgeLabelPadding,
            other.badgeLabelPadding,
            t,
          ) ??
          badgeLabelPadding,
      badgeMinimumSize:
          lerpDouble(badgeMinimumSize, other.badgeMinimumSize, t) ??
          badgeMinimumSize,
      badgeDotSize:
          lerpDouble(badgeDotSize, other.badgeDotSize, t) ?? badgeDotSize,
      badgeLabelMaxWidth:
          lerpDouble(badgeLabelMaxWidth, other.badgeLabelMaxWidth, t) ??
          badgeLabelMaxWidth,
      badgeDisabledOpacity:
          lerpDouble(badgeDisabledOpacity, other.badgeDisabledOpacity, t) ??
          badgeDisabledOpacity,
    );
  }
}

extension AGridFStyle on FStyle {
  AGridStyle get aGrid => extension<AGridStyle>();
}
