import 'package:flutter/material.dart';

import 'app_design_tokens.dart';

@immutable
final class AppDesignTokenData implements AppDesignTokens {
  const AppDesignTokenData({
    required this.background,
    required this.onBackground,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainer,
    required this.onSurfaceContainer,
    required this.outline,
    required this.danger,
    required this.onDanger,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.success,
    required this.onSuccess,
    required this.disabledText,
    required this.disabledContainer,
    required this.focus,
    required this.displayTextStyle,
    required this.pageTitleTextStyle,
    required this.sectionTitleTextStyle,
    required this.bodyTextStyle,
    required this.supportingTextStyle,
    required this.labelTextStyle,
    required this.captionTextStyle,
    required this.fieldRadius,
    required this.controlRadius,
    required this.stateMotion,
    required this.enterMotion,
    required this.exitMotion,
  });

  @override
  final Color background;
  @override
  final Color onBackground;
  @override
  final Color primary;
  @override
  final Color onPrimary;
  @override
  final Color secondary;
  @override
  final Color onSecondary;
  @override
  final Color surface;
  @override
  final Color onSurface;
  @override
  final Color surfaceContainer;
  @override
  final Color onSurfaceContainer;
  @override
  final Color outline;
  @override
  final Color danger;
  @override
  final Color onDanger;
  @override
  final Color warning;
  @override
  final Color onWarning;
  @override
  final Color info;
  @override
  final Color onInfo;
  @override
  final Color success;
  @override
  final Color onSuccess;
  @override
  final Color disabledText;
  @override
  final Color disabledContainer;
  @override
  final Color focus;

  @override
  double get space4 => 4;
  @override
  double get space8 => 8;
  @override
  double get space12 => 12;
  @override
  double get space16 => 16;
  @override
  double get space24 => 24;
  @override
  double get space32 => 32;
  @override
  double get space48 => 48;
  @override
  final double fieldRadius;
  @override
  final double controlRadius;

  @override
  final TextStyle displayTextStyle;
  @override
  final TextStyle pageTitleTextStyle;
  @override
  final TextStyle sectionTitleTextStyle;
  @override
  final TextStyle bodyTextStyle;
  @override
  final TextStyle supportingTextStyle;
  @override
  final TextStyle labelTextStyle;
  @override
  final TextStyle captionTextStyle;

  @override
  Duration get instantMotion => Duration.zero;
  @override
  final Duration stateMotion;
  @override
  final Duration enterMotion;
  @override
  final Duration exitMotion;
}
