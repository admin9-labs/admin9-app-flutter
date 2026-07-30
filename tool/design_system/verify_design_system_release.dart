import 'dart:convert';
import 'dart:io';

const _readmePath = 'docs/design-system/README.md';
const _changelogPath = 'docs/design-system/CHANGELOG.md';
const _derivedContractPath =
    'docs/design-system/05-derived-project-contract.md';
const _schemaPath = 'docs/design-system/schema/admin9-foundation.schema.json';
const _compatibilityPath =
    'docs/design-system/schema/admin9-foundation-compatibility.json';
const _validFixturePath =
    'docs/design-system/fixtures/foundation-manifest/valid.yaml';

Never _usage() {
  stderr.writeln(
    'usage: dart run tool/design_system/verify_design_system_release.dart '
    '--version=<semver> --foundation-commit=<40-hex-sha>',
  );
  exit(64);
}

void main(List<String> arguments) {
  if (arguments.length != 2) _usage();
  final versionArgument = arguments.where(
    (argument) => argument.startsWith('--version='),
  );
  final commitArgument = arguments.where(
    (argument) => argument.startsWith('--foundation-commit='),
  );
  if (versionArgument.length != 1 || commitArgument.length != 1) _usage();

  final version = versionArgument.single.substring('--version='.length);
  final foundationCommit = commitArgument.single.substring(
    '--foundation-commit='.length,
  );
  if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version) ||
      !RegExp(r'^[0-9a-f]{40}$').hasMatch(foundationCommit)) {
    _usage();
  }
  final sourceTag = 'design-system-v$version';
  final errors = <String>[];

  final readme = File(_readmePath).readAsStringSync();
  _expectMatch(
    errors,
    _readmePath,
    readme,
    RegExp(r'^> Version: v([^\s]+)$', multiLine: true),
    version,
  );

  final changelog = File(_changelogPath).readAsStringSync();
  _expectMatch(
    errors,
    _changelogPath,
    changelog,
    RegExp(r'^## ([^\s]+) - \d{4}-\d{2}-\d{2}$', multiLine: true),
    version,
  );

  final derivedContract = File(_derivedContractPath).readAsStringSync();
  final contractMatch = RegExp(
    r'exact specification version `([^`]+)` and source tag `([^`]+)`',
  ).firstMatch(derivedContract);
  if (contractMatch == null ||
      contractMatch.group(1) != version ||
      contractMatch.group(2) != sourceTag) {
    errors.add(
      '$_derivedContractPath must name $version and $sourceTag exactly',
    );
  }

  final schema = _readObject(_schemaPath);
  final schemaDesignSystem = _objectAt(schema, [
    'properties',
    'designSystem',
    'properties',
  ]);
  _expectValue(
    errors,
    '$_schemaPath designSystem.version.const',
    _objectAt(schemaDesignSystem, ['version'])['const'],
    version,
  );
  _expectValue(
    errors,
    '$_schemaPath designSystem.sourceTag.const',
    _objectAt(schemaDesignSystem, ['sourceTag'])['const'],
    sourceTag,
  );

  final fixture = _readObject(_validFixturePath);
  final fixtureDesignSystem = _objectAt(fixture, ['designSystem']);
  _expectValue(
    errors,
    '$_validFixturePath designSystem.version',
    fixtureDesignSystem['version'],
    version,
  );
  _expectValue(
    errors,
    '$_validFixturePath designSystem.sourceTag',
    fixtureDesignSystem['sourceTag'],
    sourceTag,
  );
  _expectValue(
    errors,
    '$_validFixturePath foundation.commit',
    _objectAt(fixture, ['foundation'])['commit'],
    foundationCommit,
  );

  final compatibility = _readObject(_compatibilityPath);
  final approved = compatibility['approved'];
  if (approved is! List<Object?>) {
    errors.add('$_compatibilityPath approved must be an array');
  } else {
    final matching = approved.whereType<Map<String, Object?>>().where(
      (entry) =>
          entry['designSystemVersion'] == version &&
          entry['designSystemSourceTag'] == sourceTag &&
          entry['foundationCommit'] == foundationCommit &&
          entry['flutter'] == '3.44.1' &&
          entry['dart'] == '3.12.1' &&
          entry['status'] == 'approved',
    );
    if (matching.length != 1) {
      errors.add(
        '$_compatibilityPath must contain exactly one approved '
        '$version/$foundationCommit tuple, found ${matching.length}',
      );
    }
  }

  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln(
    'Design System release consistency: PASS '
    '(v$version, Foundation $foundationCommit)',
  );
}

Map<String, Object?> _readObject(String path) {
  final value = jsonDecode(File(path).readAsStringSync());
  if (value is! Map<String, Object?>) {
    throw FormatException('$path root must be an object');
  }
  return value;
}

Map<String, Object?> _objectAt(Map<String, Object?> root, List<String> path) {
  Object? value = root;
  for (final segment in path) {
    if (value is! Map<String, Object?> || !value.containsKey(segment)) {
      throw FormatException('${path.join('.')} is missing');
    }
    value = value[segment];
  }
  if (value is! Map<String, Object?>) {
    throw FormatException('${path.join('.')} must be an object');
  }
  return value;
}

void _expectMatch(
  List<String> errors,
  String path,
  String contents,
  RegExp pattern,
  String expected,
) {
  final matches = pattern.allMatches(contents).toList();
  if (matches.isEmpty || matches.first.group(1) != expected) {
    errors.add('$path version must be $expected');
  }
}

void _expectValue(
  List<String> errors,
  String location,
  Object? actual,
  String expected,
) {
  if (actual != expected) errors.add('$location must be $expected');
}
