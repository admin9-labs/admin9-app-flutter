import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as image;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

final class AppConfigData {
  const AppConfigData({
    required this.appName,
    required this.appVersion,
    required this.androidApplicationId,
    required this.iosBundleId,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.logoAsset,
    required this.launchAsset,
    required this.fontFamily,
    required this.radiusDelta,
    this.assetSourceRoot,
  });

  final String appName;
  final String appVersion;
  final String androidApplicationId;
  final String iosBundleId;
  final String primaryLight;
  final String primaryDark;
  final String secondaryLight;
  final String secondaryDark;
  final String logoAsset;
  final String launchAsset;
  final String? fontFamily;
  final int radiusDelta;
  final String? assetSourceRoot;
}

AppConfigData readAppConfig(String configPath) {
  final value = jsonDecode(File(configPath).readAsStringSync());
  if (value is! Map<String, Object?>) {
    throw const FormatException('app config root must be an object');
  }
  final app = value['app'] as Map<String, Object?>;
  final brand = value['brand'] as Map<String, Object?>;
  final primary = brand['primaryPair'] as Map<String, Object?>;
  final secondary = brand['secondaryPair'] as Map<String, Object?>;
  return AppConfigData(
    appName: app['name'] as String,
    appVersion: app['version'] as String,
    androidApplicationId: app['androidApplicationId'] as String,
    iosBundleId: app['iosBundleId'] as String,
    primaryLight: primary['light'] as String,
    primaryDark: primary['dark'] as String,
    secondaryLight: secondary['light'] as String,
    secondaryDark: secondary['dark'] as String,
    logoAsset: brand['logoPath'] as String,
    launchAsset: brand['launchAssetPath'] as String,
    fontFamily: brand['fontFamily'] as String?,
    radiusDelta: brand['radiusDelta'] as int,
    assetSourceRoot: File(configPath).absolute.parent.path,
  );
}

String renderBrandTheme(AppConfigData data) =>
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

String renderAppIdentity(AppConfigData data) =>
    '''abstract final class AppIdentity {
  static const name = ${_stringLiteral(data.appName)};
  static const productName = ${_stringLiteral(data.appName)};
  static const version = ${_stringLiteral(data.appVersion)};
  static const logoAsset = ${_stringLiteral(data.logoAsset)};
}
''';

String _colorLiteral(String value) => '0xff${value.substring(1).toLowerCase()}';

String _stringLiteral(String value) {
  final encoded = jsonEncode(value);
  final body = encoded
      .substring(1, encoded.length - 1)
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$');
  return "'$body'";
}

List<String> synchronizeAppConfig(
  AppConfigData data,
  String repositoryRoot, {
  required bool write,
}) {
  final root = Directory(repositoryRoot).absolute;
  final errors = <String>[];
  if (!root.existsSync()) return ['${root.path} is not a directory'];
  final assetSourceRoot = Directory(data.assetSourceRoot ?? root.path).absolute;
  final logoSource = _readSquarePng(
    assetSourceRoot,
    data.logoAsset,
    minimumSize: 1024,
  );
  final launchSource = _readSquarePng(assetSourceRoot, data.launchAsset);

  void syncText(String relativePath, String expected) {
    final file = File('${root.path}/$relativePath');
    if (write) {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(expected);
    } else if (!file.existsSync() || file.readAsStringSync() != expected) {
      errors.add('$relativePath differs from the app config output');
    }
  }

  void syncBytes(String relativePath, Uint8List expected) {
    final file = File('${root.path}/$relativePath');
    if (write) {
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(expected);
    } else if (!file.existsSync() ||
        !_sameBytes(file.readAsBytesSync(), expected)) {
      errors.add('$relativePath differs from the app config output');
    }
  }

  syncText('lib/app/brand/app_brand_theme.dart', renderBrandTheme(data));
  syncText('lib/app/app_identity.dart', renderAppIdentity(data));

  final pubspecPath = '${root.path}/pubspec.yaml';
  final pubspecSource = _requiredFile(pubspecPath).readAsStringSync();
  final pubspecEditor = YamlEditor(pubspecSource);
  final pubspec = loadYaml(pubspecSource);
  if (pubspec is! YamlMap) throw FormatException('$pubspecPath is not a map');
  final flutter = pubspec['flutter'];
  if (flutter is! YamlMap) {
    throw FormatException(
      '$pubspecPath does not contain flutter configuration',
    );
  }
  final existingAssets = flutter['assets'];
  final assets = <String>{
    if (existingAssets is YamlList)
      ...existingAssets.nodes.map((node) => node.value).whereType<String>(),
    data.logoAsset,
    data.launchAsset,
  }.toList()..sort();
  pubspecEditor.update(['description'], '${data.appName} for Android and iOS.');
  pubspecEditor.update(['version'], data.appVersion);
  pubspecEditor.update(['flutter', 'assets'], assets);
  syncText('pubspec.yaml', pubspecEditor.toString());

  final gradlePath = '${root.path}/android/app/build.gradle.kts';
  final gradleSource = _requiredFile(gradlePath).readAsStringSync();
  final namespaceMatch = RegExp(
    r'^\s*namespace = "([^"]+)"$',
    multiLine: true,
  ).allMatches(gradleSource).toList();
  if (namespaceMatch.length != 1) {
    throw FormatException('$gradlePath must contain exactly one namespace');
  }
  final oldNamespace = namespaceMatch.single.group(1)!;
  var expectedGradle = _replaceExactlyOnce(
    gradleSource,
    RegExp(r'^(\s*namespace = ")[^"]+("\s*)$', multiLine: true),
    (match) => '${match.group(1)}${data.androidApplicationId}${match.group(2)}',
    gradlePath,
  );
  expectedGradle = _replaceExactlyOnce(
    expectedGradle,
    RegExp(r'^(\s*applicationId = ")[^"]+("\s*)$', multiLine: true),
    (match) => '${match.group(1)}${data.androidApplicationId}${match.group(2)}',
    gradlePath,
  );
  syncText('android/app/build.gradle.kts', expectedGradle);

  final manifestPath = '${root.path}/android/app/src/main/AndroidManifest.xml';
  final manifestSource = _requiredFile(manifestPath).readAsStringSync();
  syncText(
    'android/app/src/main/AndroidManifest.xml',
    _replaceExactlyOnce(
      manifestSource,
      RegExp(r'android:label="[^"]*"'),
      (_) => 'android:label="${_xmlEscape(data.appName)}"',
      manifestPath,
    ),
  );
  _synchronizeAndroidSources(
    root,
    oldNamespace: oldNamespace,
    newNamespace: data.androidApplicationId,
    write: write,
    errors: errors,
  );
  for (final filename in ['MainActivity.kt', 'ReleasePluginRegistry.kt']) {
    _verifyAndroidSource(
      root,
      namespace: data.androidApplicationId,
      filename: filename,
      errors: errors,
    );
  }

  final plistPath = '${root.path}/ios/Runner/Info.plist';
  var expectedPlist = _requiredFile(plistPath).readAsStringSync();
  for (final key in ['CFBundleDisplayName', 'CFBundleName']) {
    expectedPlist = _replaceExactlyOnce(
      expectedPlist,
      RegExp('(<key>$key</key>\\s*<string>)[^<]*(</string>)'),
      (match) =>
          '${match.group(1)}${_xmlEscape(data.appName)}${match.group(2)}',
      plistPath,
    );
  }
  syncText('ios/Runner/Info.plist', expectedPlist);

  final projectPath = '${root.path}/ios/Runner.xcodeproj/project.pbxproj';
  final projectSource = _requiredFile(projectPath).readAsStringSync();
  final bundlePattern = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);');
  final bundleMatches = bundlePattern.allMatches(projectSource).toList();
  if (bundleMatches.isEmpty) {
    throw FormatException('$projectPath contains no bundle identifiers');
  }
  final existingBundleIds =
      bundleMatches.map((match) => match.group(1)!).toSet().toList()
        ..sort((left, right) => left.length.compareTo(right.length));
  final existingMainBundleId = existingBundleIds.first;
  if (existingBundleIds.any(
    (value) =>
        value != existingMainBundleId &&
        !value.startsWith('$existingMainBundleId.'),
  )) {
    throw FormatException(
      '$projectPath bundle identifiers must share one main app prefix',
    );
  }
  final expectedProject = projectSource.replaceAllMapped(bundlePattern, (
    match,
  ) {
    final suffix = match.group(1)!.substring(existingMainBundleId.length);
    return 'PRODUCT_BUNDLE_IDENTIFIER = ${data.iosBundleId}$suffix;';
  });
  syncText('ios/Runner.xcodeproj/project.pbxproj', expectedProject);

  syncBytes(data.logoAsset, logoSource.bytes);
  syncBytes(data.launchAsset, launchSource.bytes);
  final logo = logoSource.decoded;
  final launch = launchSource.decoded;
  const androidIcons = <String, int>{
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
  };
  for (final entry in androidIcons.entries) {
    syncBytes(entry.key, _resizePng(logo, entry.value));
  }
  syncBytes(
    'android/app/src/main/res/drawable-nodpi/admin9_launch_logo.png',
    _resizePng(launch, 216),
  );

  final iconContents =
      jsonDecode(
            _requiredFile(
              '${root.path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  final iconRecords = iconContents['images'] as List<Object?>;
  for (final record in iconRecords.whereType<Map<String, Object?>>()) {
    final filename = record['filename'];
    if (filename is! String) continue;
    final size = double.parse((record['size'] as String).split('x').first);
    final scale = int.parse((record['scale'] as String).replaceFirst('x', ''));
    syncBytes(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/$filename',
      renderIosAppIconPng(logo, (size * scale).round(), data.primaryLight),
    );
  }
  for (final entry in const <String, int>{
    'LaunchImage.png': 108,
    'LaunchImage@2x.png': 216,
    'LaunchImage@3x.png': 324,
  }.entries) {
    syncBytes(
      'ios/Runner/Assets.xcassets/LaunchImage.imageset/${entry.key}',
      _resizePng(launch, entry.value),
    );
  }

  return errors;
}

void _synchronizeAndroidSources(
  Directory root, {
  required String oldNamespace,
  required String newNamespace,
  required bool write,
  required List<String> errors,
}) {
  final sourceRoot = Directory('${root.path}/android/app/src/main/kotlin');
  final oldPackagePath = oldNamespace.replaceAll('.', '/');
  final newPackagePath = newNamespace.replaceAll('.', '/');
  for (final filename in ['MainActivity.kt', 'ReleasePluginRegistry.kt']) {
    final source = _requiredFile(
      '${sourceRoot.path}/$oldPackagePath/$filename',
    );
    final expected = _replaceExactlyOnce(
      source.readAsStringSync(),
      RegExp('^package ${RegExp.escape(oldNamespace)}\\s*\$', multiLine: true),
      (_) => 'package $newNamespace',
      source.path,
    );
    final destination = File('${sourceRoot.path}/$newPackagePath/$filename');
    if (write) {
      destination.parent.createSync(recursive: true);
      destination.writeAsStringSync(expected);
      if (source.path != destination.path) source.deleteSync();
    } else {
      if (!destination.existsSync() ||
          destination.readAsStringSync() != expected) {
        errors.add(
          'android app source $filename does not use the configured application ID',
        );
      }
      if (source.path != destination.path && source.existsSync()) {
        errors.add('android app source $filename remains in the old namespace');
      }
    }
  }
}

void _verifyAndroidSource(
  Directory root, {
  required String namespace,
  required String filename,
  required List<String> errors,
}) {
  final sourceRoot = Directory('${root.path}/android/app/src/main/kotlin');
  final matches = sourceRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.uri.pathSegments.last == filename)
      .toList();
  final expected = File(
    '${sourceRoot.path}/${namespace.replaceAll('.', '/')}/$filename',
  );
  if (matches.length != 1 ||
      matches.single.absolute.path != expected.absolute.path) {
    errors.add(
      'android app source $filename must exist exactly once at the configured application ID path',
    );
    return;
  }
  final packagePattern = RegExp(
    '^package ${RegExp.escape(namespace)}\\s*\$',
    multiLine: true,
  );
  if (!packagePattern.hasMatch(matches.single.readAsStringSync())) {
    errors.add(
      'android app source $filename does not declare the configured application ID package',
    );
  }
}

File _requiredFile(String path) {
  final file = File(path);
  if (!file.existsSync()) throw FormatException('$path is missing');
  return file;
}

({Uint8List bytes, image.Image decoded}) _readSquarePng(
  Directory root,
  String relativePath, {
  int minimumSize = 1,
}) {
  final file = _requiredFile('${root.path}/$relativePath');
  if (!relativePath.toLowerCase().endsWith('.png')) {
    throw FormatException('$relativePath must be a PNG asset');
  }
  final bytes = file.readAsBytesSync();
  final decoded = image.decodePng(bytes);
  if (decoded == null) {
    throw FormatException('$relativePath is not a valid PNG');
  }
  if (decoded.width != decoded.height || decoded.width < minimumSize) {
    throw FormatException(
      '$relativePath must be square and at least ${minimumSize}x$minimumSize',
    );
  }
  return (bytes: bytes, decoded: decoded);
}

Uint8List _resizePng(image.Image source, int size) => image.encodePng(
  image.copyResize(
    source,
    width: size,
    height: size,
    interpolation: image.Interpolation.cubic,
  ),
  level: 9,
);

Uint8List renderIosAppIconPng(
  image.Image source,
  int size,
  String backgroundColor,
) {
  final rgb = int.parse(backgroundColor.substring(1), radix: 16);
  final output = image.Image(width: size, height: size, numChannels: 3);
  image.fill(
    output,
    color: image.ColorRgb8(rgb >> 16, (rgb >> 8) & 0xff, rgb & 0xff),
  );
  image.compositeImage(
    output,
    image.copyResize(
      source,
      width: size,
      height: size,
      interpolation: image.Interpolation.cubic,
    ),
  );
  return image.encodePng(output, level: 9);
}

String _replaceExactlyOnce(
  String source,
  RegExp pattern,
  String Function(Match match) replacement,
  String path,
) {
  final matches = pattern.allMatches(source).toList();
  if (matches.length != 1) {
    throw FormatException('$path expected one ${pattern.pattern} match');
  }
  return source.replaceFirstMapped(pattern, replacement);
}

String _xmlEscape(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

bool _sameBytes(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
