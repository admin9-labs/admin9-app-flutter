import 'package:flutter/material.dart';

abstract interface class AppDesignTokens {
  Color get background;
  Color get onBackground;
  Color get primary;
  Color get onPrimary;
  Color get secondary;
  Color get onSecondary;
  Color get surface;
  Color get onSurface;
  Color get surfaceContainer;
  Color get onSurfaceContainer;
  Color get outline;
  Color get danger;
  Color get onDanger;
  Color get warning;
  Color get onWarning;
  Color get info;
  Color get onInfo;
  Color get success;
  Color get onSuccess;
  Color get disabledText;
  Color get disabledContainer;
  Color get focus;
  double get space4;
  double get space8;
  double get space12;
  double get space16;
  double get space24;
  double get space32;
  double get space48;
  double get fieldRadius;
  double get controlRadius;
  TextStyle get displayTextStyle;
  TextStyle get pageTitleTextStyle;
  TextStyle get sectionTitleTextStyle;
  TextStyle get bodyTextStyle;
  TextStyle get supportingTextStyle;
  TextStyle get labelTextStyle;
  TextStyle get captionTextStyle;
  Duration get instantMotion;
  Duration get stateMotion;
  Duration get enterMotion;
  Duration get exitMotion;
}

class AppDesignScope extends InheritedWidget {
  const AppDesignScope({super.key, required this.tokens, required super.child});

  final AppDesignTokens tokens;

  static AppDesignTokens of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppDesignScope>();
    if (scope == null) {
      throw FlutterError('No AppDesignScope found in context.');
    }
    return scope.tokens;
  }

  @override
  bool updateShouldNotify(AppDesignScope oldWidget) =>
      !identical(tokens, oldWidget.tokens);
}
