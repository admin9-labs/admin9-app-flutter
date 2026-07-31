import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
final class AppBrandTheme {
  const AppBrandTheme({
    required this.primaryLight,
    required this.primaryDark,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.logoAsset,
    required this.tertiaryLight,
    this.launchAsset,
    this.fontFamily,
    this.radiusDelta = 0,
  }) : assert(radiusDelta >= -2 && radiusDelta <= 2);

  final Color primaryLight;
  final Color primaryDark;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color tertiaryLight;
  final String logoAsset;
  final String? launchAsset;
  final String? fontFamily;
  final int radiusDelta;
}

const appBrandTheme = AppBrandTheme(
  primaryLight: Color(0xff315c66),
  primaryDark: Color(0xff9ccbd5),
  secondaryLight: Color(0xff67587a),
  secondaryDark: Color(0xffd1bce4),
  tertiaryLight: Color(0xff000000),
  logoAsset: 'assets/brand/logo.png',
  launchAsset: 'assets/brand/launch.png',
  fontFamily: null,
  radiusDelta: 0,
);
