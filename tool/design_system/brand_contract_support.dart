import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as image;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

final class BrandContractData {
  const BrandContractData({
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
    androidApplicationId: app['androidApplicationId'] as String,
    iosBundleId: app['iosBundleId'] as String,
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

List<String> synchronizeDerivedBrand(
  BrandContractData data,
  String repositoryRoot, {
  required bool write,
}) {
  final root = Directory(repositoryRoot).absolute;
  final errors = <String>[];
  if (!root.existsSync()) return ['${root.path} is not a directory'];

  void syncText(String relativePath, String expected) {
    final file = File('${root.path}/$relativePath');
    if (write) {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(expected);
    } else if (!file.existsSync() || file.readAsStringSync() != expected) {
      errors.add('$relativePath differs from the manifest-derived output');
    }
  }

  void syncBytes(String relativePath, Uint8List expected) {
    final file = File('${root.path}/$relativePath');
    if (write) {
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(expected);
    } else if (!file.existsSync() ||
        !_sameBytes(file.readAsBytesSync(), expected)) {
      errors.add('$relativePath differs from the manifest-derived output');
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
  final expectedProject = projectSource.replaceAllMapped(bundlePattern, (
    match,
  ) {
    final suffix = match.group(1)!.endsWith('.RunnerTests')
        ? '.RunnerTests'
        : '';
    return 'PRODUCT_BUNDLE_IDENTIFIER = ${data.iosBundleId}$suffix;';
  });
  syncText('ios/Runner.xcodeproj/project.pbxproj', expectedProject);

  final logo = _readSquarePng(root, data.logoAsset, minimumSize: 1024);
  final launch = _readSquarePng(root, data.launchAsset);
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
      _resizePng(logo, (size * scale).round()),
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
  for (final language in ['kotlin', 'java']) {
    final sourceRoot = Directory('${root.path}/android/app/src/main/$language');
    if (!sourceRoot.existsSync()) continue;
    final candidates = sourceRoot
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) => file.path.endsWith('.kt') || file.path.endsWith('.java'),
        )
        .where(
          (file) => file.readAsStringSync().contains('package $oldNamespace'),
        )
        .toList();
    for (final source in candidates) {
      final expected = source.readAsStringSync().replaceFirst(
        'package $oldNamespace',
        'package $newNamespace',
      );
      final filename = source.uri.pathSegments.last;
      final destination = File(
        '${sourceRoot.path}/${newNamespace.replaceAll('.', '/')}/$filename',
      );
      if (write) {
        destination.parent.createSync(recursive: true);
        destination.writeAsStringSync(expected);
        if (source.path != destination.path) source.deleteSync();
      } else {
        if (!destination.existsSync() ||
            destination.readAsStringSync() != expected) {
          errors.add(
            'android app source $filename does not use the manifest application ID',
          );
        }
        if (source.path != destination.path && source.existsSync()) {
          errors.add(
            'android app source $filename remains in the old namespace',
          );
        }
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
      'android app source $filename must exist exactly once at the manifest application ID path',
    );
    return;
  }
  final packagePattern = RegExp(
    '^package ${RegExp.escape(namespace)}\\s*\$',
    multiLine: true,
  );
  if (!packagePattern.hasMatch(matches.single.readAsStringSync())) {
    errors.add(
      'android app source $filename does not declare the manifest application ID package',
    );
  }
}

File _requiredFile(String path) {
  final file = File(path);
  if (!file.existsSync()) throw FormatException('$path is missing');
  return file;
}

image.Image _readSquarePng(
  Directory root,
  String relativePath, {
  int minimumSize = 1,
}) {
  final file = _requiredFile('${root.path}/$relativePath');
  if (!relativePath.toLowerCase().endsWith('.png')) {
    throw FormatException('$relativePath must be a PNG asset');
  }
  final decoded = image.decodePng(file.readAsBytesSync());
  if (decoded == null) {
    throw FormatException('$relativePath is not a valid PNG');
  }
  if (decoded.width != decoded.height || decoded.width < minimumSize) {
    throw FormatException(
      '$relativePath must be square and at least ${minimumSize}x$minimumSize',
    );
  }
  return decoded;
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
