import 'dart:convert';
import 'dart:io';

final class BrandContractData {
  const BrandContractData({
    required this.appName,
    required this.appVersion,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.logoAsset,
    required this.launchAsset,
    required this.fontFamily,
    required this.radiusDelta,
  });

  final String appName;
  final String appVersion;
  final String primaryLight;
  final String primaryDark;
  final String secondaryLight;
  final String secondaryDark;
  final String logoAsset;
  final String launchAsset;
  final String? fontFamily;
  final int radiusDelta;
}

BrandContractData readBrandContract(String manifestPath) {
  final value = jsonDecode(File(manifestPath).readAsStringSync());
  if (value is! Map<String, Object?>) {
    throw const FormatException('manifest root must be an object');
  }
  final app = value['app'] as Map<String, Object?>;
  final brand = value['brandConfiguration'] as Map<String, Object?>;
  final primary = brand['primaryPair'] as Map<String, Object?>;
  final secondary = brand['secondaryPair'] as Map<String, Object?>;
  return BrandContractData(
    appName: app['name'] as String,
    appVersion: app['version'] as String,
    primaryLight: primary['light'] as String,
    primaryDark: primary['dark'] as String,
    secondaryLight: secondary['light'] as String,
    secondaryDark: secondary['dark'] as String,
    logoAsset: brand['logoPath'] as String,
    launchAsset: brand['launchAssetPath'] as String,
    fontFamily: brand['approvedFont'] as String?,
    radiusDelta: brand['radiusDelta'] as int,
  );
}

String renderBrandTheme(BrandContractData data) =>
    '''import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
final class AppBrandTheme {
  const AppBrandTheme({
    required this.primaryLight,
    required this.primaryDark,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.logoAsset,
    this.launchAsset,
    this.fontFamily,
    this.radiusDelta = 0,
  }) : assert(radiusDelta >= -2 && radiusDelta <= 2);

  final Color primaryLight;
  final Color primaryDark;
  final Color secondaryLight;
  final Color secondaryDark;
  final String logoAsset;
  final String? launchAsset;
  final String? fontFamily;
  final int radiusDelta;
}

const appBrandTheme = AppBrandTheme(
  primaryLight: Color(${_colorLiteral(data.primaryLight)}),
  primaryDark: Color(${_colorLiteral(data.primaryDark)}),
  secondaryLight: Color(${_colorLiteral(data.secondaryLight)}),
  secondaryDark: Color(${_colorLiteral(data.secondaryDark)}),
  logoAsset: ${_stringLiteral(data.logoAsset)},
  launchAsset: ${_stringLiteral(data.launchAsset)},
  fontFamily: ${data.fontFamily == null ? 'null' : _stringLiteral(data.fontFamily!)},
  radiusDelta: ${data.radiusDelta},
);
''';

String renderAppIdentity(BrandContractData data) =>
    '''abstract final class AppIdentity {
  static const name = ${_stringLiteral(data.appName)};
  static const productName = ${_stringLiteral(data.appName)};
  static const version = ${_stringLiteral(data.appVersion)};
  static const logoAsset = ${_stringLiteral(data.logoAsset)};
}
''';

String _colorLiteral(String value) => '0xff${value.substring(1).toLowerCase()}';

String _stringLiteral(String value) =>
    "'${value.replaceAll(r'\\', r'\\\\').replaceAll("'", r"\\'")}'";
