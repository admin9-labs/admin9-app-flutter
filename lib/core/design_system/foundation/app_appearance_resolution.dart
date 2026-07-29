import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_appearance.dart';

@immutable
final class EffectiveAppearance {
  const EffectiveAppearance({
    required this.brightness,
    required this.fontScale,
    required this.grayscale,
    required this.highContrast,
    required this.reduceMotion,
    required this.boldText,
  });

  factory EffectiveAppearance.resolve({
    required AppAppearance app,
    required MediaQueryData system,
    required Brightness resolvedBrightness,
  }) => EffectiveAppearance(
    brightness: resolvedBrightness,
    fontScale: app.fontScale,
    grayscale: app.grayscale,
    highContrast: system.highContrast || app.highContrast,
    reduceMotion: system.disableAnimations || app.reduceMotion,
    boldText: system.boldText,
  );

  final Brightness brightness;
  final AppFontScale fontScale;
  final bool grayscale;
  final bool highContrast;
  final bool reduceMotion;
  final bool boldText;
}

@immutable
class AppTextScaler implements TextScaler {
  const AppTextScaler({required this.system, required this.preferenceFactor});

  final TextScaler system;
  final double preferenceFactor;

  @override
  double scale(double fontSize) => system.scale(fontSize) * preferenceFactor;

  @override
  double get textScaleFactor => scale(16) / 16;

  @override
  TextScaler clamp({
    double minScaleFactor = 0,
    double maxScaleFactor = double.infinity,
  }) {
    if (minScaleFactor == maxScaleFactor) {
      return TextScaler.linear(minScaleFactor);
    }
    return _BoundedTextScaler(
      delegate: this,
      minScaleFactor: minScaleFactor,
      maxScaleFactor: maxScaleFactor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppTextScaler &&
      other.system == system &&
      other.preferenceFactor == preferenceFactor;

  @override
  int get hashCode => Object.hash(system, preferenceFactor);
}

@immutable
class _BoundedTextScaler implements TextScaler {
  const _BoundedTextScaler({
    required this.delegate,
    required this.minScaleFactor,
    required this.maxScaleFactor,
  });

  final TextScaler delegate;
  final double minScaleFactor;
  final double maxScaleFactor;

  @override
  double scale(double fontSize) => delegate
      .scale(fontSize)
      .clamp(fontSize * minScaleFactor, fontSize * maxScaleFactor);

  @override
  double get textScaleFactor => scale(16) / 16;

  @override
  TextScaler clamp({
    double minScaleFactor = 0,
    double maxScaleFactor = double.infinity,
  }) {
    final minimum = math.max(this.minScaleFactor, minScaleFactor);
    final maximum = math.min(this.maxScaleFactor, maxScaleFactor);
    if (maximum <= minimum) return TextScaler.linear(minimum);
    return _BoundedTextScaler(
      delegate: delegate,
      minScaleFactor: minimum,
      maxScaleFactor: maximum,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _BoundedTextScaler &&
      other.delegate == delegate &&
      other.minScaleFactor == minScaleFactor &&
      other.maxScaleFactor == maxScaleFactor;

  @override
  int get hashCode => Object.hash(delegate, minScaleFactor, maxScaleFactor);
}
