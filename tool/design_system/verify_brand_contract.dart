import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'brand_contract_support.dart';

const _entryPath = 'lib/app/brand/app_brand_theme.dart';
const _identityPath = 'lib/app/app_identity.dart';
const _fixtureRoot = 'tool/design_system/fixtures/brand_contract';
const _manifestFixture =
    'docs/design-system/fixtures/foundation-manifest/valid.yaml';

Never _usage() {
  stderr.writeln(
    'usage: dart run tool/design_system/verify_brand_contract.dart\n'
    '   or: dart run tool/design_system/verify_brand_contract.dart --fixtures\n'
    '   or: dart run tool/design_system/verify_brand_contract.dart '
    '<manifest> <brand-entry.dart> <app-identity.dart>',
  );
  exit(64);
}

void main(List<String> arguments) {
  final errors = switch (arguments) {
    [] => _verifyFoundation(),
    ['--fixtures'] => _verifyFixtures(),
    [final manifest, final brand, final identity] => _verifyDerived(
      manifest,
      brand,
      identity,
    ),
    _ => _usage(),
  };
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('Brand contract: PASS (exact shape and generated values)');
}

List<String> _verifyFoundation() {
  const data = BrandContractData(
    appName: 'Admin9',
    appVersion: '1.0.0',
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
  final expectedIdentity = renderAppIdentity(data).replaceFirst(
    "static const productName = 'Admin9';",
    "static const productName = 'Admin9 App Foundation';",
  );
  return [
    ..._compareDart(_entryPath, expectedTheme),
    ..._compareDart(_identityPath, expectedIdentity),
  ];
}

List<String> _verifyDerived(
  String manifest,
  String brandEntry,
  String identity,
) {
  final data = readBrandContract(manifest);
  return [
    ..._compareDart(brandEntry, renderBrandTheme(data)),
    ..._compareDart(identity, renderAppIdentity(data)),
  ];
}

List<String> _verifyFixtures() {
  final errors = <String>[];
  final valid = _verifyDerived(
    _manifestFixture,
    '$_fixtureRoot/valid/app_brand_theme.dart',
    '$_fixtureRoot/valid/app_identity.dart',
  );
  if (valid.isNotEmpty) errors.add('valid fixture failed: ${valid.join('; ')}');
  for (final name in ['extra-field', 'value-drift']) {
    final invalid = _verifyDerived(
      _manifestFixture,
      '$_fixtureRoot/$name/app_brand_theme.dart',
      '$_fixtureRoot/$name/app_identity.dart',
    );
    if (invalid.isEmpty) errors.add('$name fixture unexpectedly passed');
  }
  return errors;
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
  final diagnostics = actualResult.errors;
  if (diagnostics.isNotEmpty) {
    return ['$path does not parse: ${diagnostics.join('; ')}'];
  }
  if (_canonical(actualResult.unit) != _canonical(expectedResult.unit)) {
    return ['$path differs from the exact manifest-derived contract'];
  }
  return const <String>[];
}

String _canonical(CompilationUnit unit) => unit.toSource().trim();
