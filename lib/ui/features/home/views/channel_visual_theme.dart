import 'package:flutter/material.dart';

class ChannelVisualTheme {
  const ChannelVisualTheme({this.accentColor, this.cardSurfaceColor});

  final Color? accentColor;
  final Color? cardSurfaceColor;
}

class ChannelVisualThemeScope extends InheritedWidget {
  const ChannelVisualThemeScope({
    super.key,
    required this.theme,
    required super.child,
  });

  final ChannelVisualTheme theme;

  static ChannelVisualTheme of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ChannelVisualThemeScope>()
            ?.theme ??
        const ChannelVisualTheme();
  }

  @override
  bool updateShouldNotify(ChannelVisualThemeScope oldWidget) {
    return oldWidget.theme.accentColor != theme.accentColor ||
        oldWidget.theme.cardSurfaceColor != theme.cardSurfaceColor;
  }
}
