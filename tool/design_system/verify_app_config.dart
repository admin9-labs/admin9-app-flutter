import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:image/image.dart' as image;

import 'app_config_support.dart';

const _entryPath = 'lib/app/brand/app_brand_theme.dart';
const _identityPath = 'lib/app/app_identity.dart';
const _fixtureRoot = 'tool/design_system/fixtures/app_config';
const _configFixture = 'docs/design-system/fixtures/app-config/valid.yaml';

Never _usage() {
  stderr.writeln(
    'usage: dart run tool/design_system/verify_app_config.dart\n'
    '   or: dart run tool/design_system/verify_app_config.dart --fixtures\n'
    '   or: dart run tool/design_system/verify_app_config.dart '
    '<app-config.yaml> <repository-root>',
  );
  exit(64);
}

void main(List<String> arguments) {
  final errors = switch (arguments) {
    [] => _verifyStarterDefaults(),
    ['--fixtures'] => _verifyFixtures(),
    [final config, final repositoryRoot] => _verifyConfiguredRepository(
      config,
      repositoryRoot,
    ),
    _ => _usage(),
  };
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('App configuration: PASS');
}

List<String> _verifyStarterDefaults() {
  const data = AppConfigData(
    appName: 'Admin9 App Starter',
    appVersion: '1.0.0',
    androidApplicationId: 'com.admin9.app.foundation',
    iosBundleId: 'com.admin9.app.foundation',
    primaryLight: '#2457A7',
    primaryDark: '#AFC6FF',
    secondaryLight: '#52606D',
    secondaryDark: '#C4CCD5',
    logoAsset: 'assets/branding/admin9_logo.png',
    launchAsset: '',
    fontFamily: null,
    radiusDelta: 0,
  );
  final expectedTheme = renderBrandTheme(data)
      .replaceFirst("  launchAsset: '',\n", '')
      .replaceFirst('  fontFamily: null,\n', '')
      .replaceFirst('  radiusDelta: 0,\n', '');
  final errors = <String>[
    ..._compareDart(_entryPath, expectedTheme),
    ..._compareDart(_identityPath, renderAppIdentity(data)),
  ];
  _expectText(
    errors,
    'pubspec.yaml',
    'description: "Admin9 App Starter for Android and iOS."',
  );
  _expectText(errors, 'pubspec.yaml', 'name: admin9_app_flutter');
  _expectText(errors, 'pubspec.yaml', 'version: 1.0.0+1');
  _expectText(
    errors,
    'android/app/build.gradle.kts',
    'namespace = "com.admin9.app.foundation"',
  );
  _expectText(
    errors,
    'android/app/build.gradle.kts',
    'applicationId = "com.admin9.app.foundation"',
  );
  _expectText(
    errors,
    'android/app/src/main/AndroidManifest.xml',
    'android:label="Admin9 App Starter"',
  );
  for (final path in [
    'android/app/src/main/kotlin/com/admin9/app/foundation/MainActivity.kt',
    'android/app/src/main/kotlin/com/admin9/app/foundation/ReleasePluginRegistry.kt',
  ]) {
    _expectText(errors, path, 'package com.admin9.app.foundation');
  }
  _expectCount(
    errors,
    'ios/Runner/Info.plist',
    '<string>Admin9 App Starter</string>',
    2,
  );
  _expectText(
    errors,
    'ios/Runner.xcodeproj/project.pbxproj',
    'PRODUCT_BUNDLE_IDENTIFIER = com.admin9.app.foundation;',
  );
  return errors;
}

List<String> _verifyConfiguredRepository(String config, String repositoryRoot) {
  final validation = Process.runSync(Platform.resolvedExecutable, [
    'run',
    'tool/design_system/validate_app_config.dart',
    config,
  ]);
  if (validation.exitCode != 0) {
    return [
      'app configuration validation failed:',
      if (validation.stderr.toString().trim().isNotEmpty)
        validation.stderr.toString().trim(),
    ];
  }
  return synchronizeAppConfig(
    readAppConfig(config),
    repositoryRoot,
    write: false,
  );
}

List<String> _verifyConfiguredDart(
  String config,
  String brandEntry,
  String identity,
) {
  final data = readAppConfig(config);
  return [
    ..._compareDart(brandEntry, renderBrandTheme(data)),
    ..._compareDart(identity, renderAppIdentity(data)),
  ];
}

List<String> _verifyFixtures() {
  final errors = <String>[];
  final valid = _verifyConfiguredDart(
    _configFixture,
    '$_fixtureRoot/valid/app_brand_theme.dart',
    '$_fixtureRoot/valid/app_identity.dart',
  );
  if (valid.isNotEmpty) errors.add('valid fixture failed: ${valid.join('; ')}');
  for (final name in ['extra-field', 'value-drift']) {
    final invalid = _verifyConfiguredDart(
      _configFixture,
      '$_fixtureRoot/$name/app_brand_theme.dart',
      '$_fixtureRoot/$name/app_identity.dart',
    );
    if (invalid.isEmpty) errors.add('$name fixture unexpectedly passed');
  }
  final logo = image.decodePng(
    File(
      'docs/design-system/fixtures/app-config/assets/brand/logo.png',
    ).readAsBytesSync(),
  );
  if (logo == null) {
    errors.add('valid Logo fixture is not a PNG');
  } else {
    final appIcon = image.decodePng(renderIosAppIconPng(logo, 1024, '#315C66'));
    if (appIcon == null || appIcon.numChannels != 3) {
      errors.add('generated iOS AppIcon must be opaque RGB');
    }
  }
  _verifyGeneratedStringSyntax(errors);
  _verifySynchronizerFixture(errors);
  return errors;
}

void _verifyGeneratedStringSyntax(List<String> errors) {
  const data = AppConfigData(
    appName: r"Example $value App's",
    appVersion: '1.0.0',
    androidApplicationId: 'com.example.app',
    iosBundleId: 'com.example.app',
    primaryLight: '#315C66',
    primaryDark: '#9CCBD5',
    secondaryLight: '#67587A',
    secondaryDark: '#D1BCE4',
    logoAsset: 'assets/brand/logo.png',
    launchAsset: 'assets/brand/launch.png',
    fontFamily: r"Brand $family Font's",
    radiusDelta: 0,
  );
  for (final entry in {
    'generated app identity': renderAppIdentity(data),
    'generated Brand Theme': renderBrandTheme(data),
  }.entries) {
    final result = parseString(
      content: entry.value,
      path: '${entry.key}.dart',
      throwIfDiagnostics: false,
    );
    if (result.errors.isNotEmpty) {
      errors.add('${entry.key} does not escape Dart string values');
    }
  }
}

void _verifySynchronizerFixture(List<String> errors) {
  final root = Directory.systemTemp.createTempSync('admin9-app-config-');
  try {
    for (final path in [
      'pubspec.yaml',
      'android/app/build.gradle.kts',
      'android/app/src/main/AndroidManifest.xml',
      'android/app/src/main/kotlin/com/admin9/app/foundation/MainActivity.kt',
      'android/app/src/main/kotlin/com/admin9/app/foundation/ReleasePluginRegistry.kt',
      'ios/Runner/Info.plist',
      'ios/Runner.xcodeproj/project.pbxproj',
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
    ]) {
      final destination = File('${root.path}/$path');
      destination.parent.createSync(recursive: true);
      File(path).copySync(destination.path);
    }

    final data = readAppConfig(_configFixture);
    final applyErrors = synchronizeAppConfig(data, root.path, write: true);
    if (applyErrors.isNotEmpty) {
      errors.add(
        'synchronizer write fixture failed: ${applyErrors.join('; ')}',
      );
      return;
    }
    final verifyErrors = synchronizeAppConfig(data, root.path, write: false);
    if (verifyErrors.isNotEmpty) {
      errors.add(
        'synchronizer read-only fixture failed: ${verifyErrors.join('; ')}',
      );
      return;
    }

    final identity = File('${root.path}/$_identityPath');
    identity.writeAsStringSync('abstract final class AppIdentity {}\n');
    final driftErrors = synchronizeAppConfig(data, root.path, write: false);
    if (!driftErrors.any((error) => error.startsWith(_identityPath))) {
      errors.add(
        'synchronizer read-only fixture did not reject identity drift',
      );
    }
  } on Object catch (error) {
    errors.add('synchronizer fixture failed: $error');
  } finally {
    root.deleteSync(recursive: true);
  }
}

List<String> _compareDart(String path, String expected) {
  final file = File(path);
  if (!file.existsSync()) return ['$path is missing'];
  final actualResult = parseString(
    content: file.readAsStringSync(),
    path: path,
    throwIfDiagnostics: false,
  );
  final expectedResult = parseString(
    content: expected,
    path: '$path.expected',
    throwIfDiagnostics: false,
  );
  if (actualResult.errors.isNotEmpty) {
    return ['$path does not parse: ${actualResult.errors.join('; ')}'];
  }
  if (expectedResult.errors.isNotEmpty) {
    return [
      'generated output for $path does not parse: '
          '${expectedResult.errors.join('; ')}',
    ];
  }
  if (_canonical(actualResult.unit) != _canonical(expectedResult.unit)) {
    return ['$path differs from the expected app configuration'];
  }
  return const <String>[];
}

void _expectText(List<String> errors, String path, String expected) {
  final source = File(path).readAsStringSync();
  if (!source.contains(expected)) errors.add('$path must contain $expected');
}

void _expectCount(
  List<String> errors,
  String path,
  String expected,
  int count,
) {
  final actual = expected.allMatches(File(path).readAsStringSync()).length;
  if (actual != count) {
    errors.add(
      '$path must contain $expected exactly $count times; found $actual',
    );
  }
}

String _canonical(CompilationUnit unit) => unit.toSource().trim();
