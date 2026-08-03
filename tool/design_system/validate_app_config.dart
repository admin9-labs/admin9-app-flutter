import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as image;

const _schemaPath = 'docs/design-system/schema/app-config.schema.json';
const _fixtureRoot = 'docs/design-system/fixtures/app-config';
const _fixtureExpectedErrors = <String, List<String>>{
  'invalid-asset-traversal.yaml': [r'$.brand.logoPath does not match'],
  'invalid-brand-contrast.yaml': [
    r'$.brand.primaryPair.light must provide at least 3:1 focus contrast',
    r'$.brand.primaryPair.dark must provide at least 3:1 focus contrast',
  ],
  'invalid-missing-app.yaml': [r'$.app is required'],
  'invalid-unknown-field.yaml': [r'$.app.unsupportedField is unknown'],
  'invalid-version.yaml': [r'$.app.version does not match'],
};

Never _usage() {
  stderr.writeln(
    'usage: dart run tool/design_system/validate_app_config.dart '
    '<app-config.yaml>\n'
    '   or: dart run tool/design_system/validate_app_config.dart --fixtures',
  );
  exit(64);
}

void main(List<String> arguments) {
  if (arguments.length != 1) _usage();
  final schema = _readJson(_schemaPath);
  if (arguments.single == '--fixtures') {
    _validateFixtures(schema);
    return;
  }

  final errors = _validateFile(arguments.single, schema);
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('${arguments.single}: valid app configuration');
}

Map<String, Object?> _readJson(String path) {
  final value = jsonDecode(File(path).readAsStringSync());
  if (value is! Map<String, Object?>) {
    throw FormatException('$path root must be an object');
  }
  return value;
}

List<String> _validateFile(String path, Map<String, Object?> schema) {
  final file = File(path);
  if (!file.existsSync()) return ['$path: file does not exist'];
  Object? value;
  try {
    value = jsonDecode(file.readAsStringSync());
  } on Object catch (error) {
    return ['$path: invalid JSON-compatible YAML: $error'];
  }

  final errors = <String>[];
  _validate(value, schema, schema, r'$', errors);
  if (value is Map<String, Object?>) {
    _validateSemanticConfig(value, path, errors);
  }
  return errors.map((error) => '$path: $error').toList();
}

void _validateFixtures(Map<String, Object?> schema) {
  final validPath = '$_fixtureRoot/valid.yaml';
  final validErrors = _validateFile(validPath, schema);
  if (validErrors.isNotEmpty) {
    validErrors.forEach(stderr.writeln);
    exit(1);
  }

  final invalidFiles =
      Directory(_fixtureRoot)
          .listSync()
          .whereType<File>()
          .where((file) => file.uri.pathSegments.last.startsWith('invalid-'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));
  var failed = invalidFiles.isEmpty;
  if (invalidFiles.isEmpty) {
    stderr.writeln('$_fixtureRoot: no invalid fixtures found');
  }
  for (final fixture in invalidFiles) {
    final name = fixture.uri.pathSegments.last;
    final expected = _fixtureExpectedErrors[name];
    final errors = _validateFile(fixture.path, schema);
    if (expected == null) {
      stderr.writeln('${fixture.path}: missing expected-error contract');
      failed = true;
      continue;
    }
    final missing = expected.where(
      (substring) => !errors.any((error) => error.contains(substring)),
    );
    if (errors.isEmpty || missing.isNotEmpty) {
      stderr.writeln(
        '${fixture.path}: expected rejection evidence missing: '
        '${missing.isEmpty ? expected.join(', ') : missing.join(', ')}',
      );
      for (final error in errors) {
        stderr.writeln('  actual: $error');
      }
      failed = true;
      continue;
    }
    stdout.writeln('${fixture.path}: rejected (${expected.join('; ')})');
  }

  final fixtureNames = invalidFiles.map((file) => file.uri.pathSegments.last);
  final orphanContracts = _fixtureExpectedErrors.keys.where(
    (name) => !fixtureNames.contains(name),
  );
  if (orphanContracts.isNotEmpty) {
    stderr.writeln(
      'expected-error contracts without fixtures: ${orphanContracts.join(', ')}',
    );
    failed = true;
  }
  if (failed) exit(1);
  stdout.writeln('$validPath: valid');
  stdout.writeln(
    'app config fixtures: PASS (${invalidFiles.length} invalid cases)',
  );
}

void _validate(
  Object? value,
  Map<String, Object?> node,
  Map<String, Object?> root,
  String path,
  List<String> errors,
) {
  final reference = node[r'$ref'];
  if (reference is String) {
    _validate(value, _resolveReference(reference, root), root, path, errors);
    return;
  }

  if (node.containsKey('const') && value != node['const']) {
    errors.add('$path must equal ${jsonEncode(node['const'])}');
    return;
  }
  final enumValues = node['enum'];
  if (enumValues is List && !enumValues.contains(value)) {
    errors.add('$path must be one of ${jsonEncode(enumValues)}');
    return;
  }

  final allowedTypes = switch (node['type']) {
    final String type => [type],
    final List<Object?> types => types.whereType<String>().toList(),
    _ => const <String>[],
  };
  if (allowedTypes.isNotEmpty && !_matchesType(value, allowedTypes)) {
    errors.add('$path must have type ${allowedTypes.join('|')}');
    return;
  }
  if (value == null) return;

  if (value is String) {
    final minLength = node['minLength'];
    if (minLength is int && value.length < minLength) {
      errors.add('$path must contain at least $minLength character(s)');
    }
    final pattern = node['pattern'];
    if (pattern is String && !RegExp(pattern).hasMatch(value)) {
      errors.add('$path does not match $pattern');
    }
    return;
  }

  if (value is num) {
    final minimum = node['minimum'];
    final maximum = node['maximum'];
    if (minimum is num && value < minimum) {
      errors.add('$path must be at least $minimum');
    }
    if (maximum is num && value > maximum) {
      errors.add('$path must be at most $maximum');
    }
    return;
  }

  if (value is List<Object?>) {
    final items = node['items'];
    if (items is Map<String, Object?>) {
      for (var index = 0; index < value.length; index += 1) {
        _validate(value[index], items, root, '$path[$index]', errors);
      }
    }
    return;
  }

  if (value is Map<String, Object?>) {
    final required = (node['required'] as List<Object?>? ?? const [])
        .whereType<String>();
    for (final key in required) {
      if (!value.containsKey(key)) errors.add('$path.$key is required');
    }
    final properties = node['properties'];
    if (properties is! Map<String, Object?>) return;
    if (node['additionalProperties'] == false) {
      for (final key in value.keys) {
        if (!properties.containsKey(key)) errors.add('$path.$key is unknown');
      }
    }
    for (final entry in properties.entries) {
      final child = entry.value;
      if (value.containsKey(entry.key) && child is Map<String, Object?>) {
        _validate(value[entry.key], child, root, '$path.${entry.key}', errors);
      }
    }
  }
}

void _validateSemanticConfig(
  Map<String, Object?> config,
  String configPath,
  List<String> errors,
) {
  final app = config['app'];
  if (app is Map<String, Object?>) {
    final name = app['name'];
    if (name is String && name.trim().isEmpty) {
      errors.add(r'$.app.name must not be blank');
    }
  }

  final brand = config['brand'];
  if (brand is! Map<String, Object?>) return;
  _validateBrandContrast(brand, errors);
  for (final entry in const [('logoPath', 1024), ('launchAssetPath', 1)]) {
    final relativePath = brand[entry.$1];
    if (relativePath is! String ||
        !relativePath.startsWith('assets/') ||
        relativePath.split('/').any((segment) => segment == '..')) {
      continue;
    }
    _validatePngAsset(
      configPath,
      relativePath,
      minimumSize: entry.$2,
      field: entry.$1,
      errors: errors,
    );
  }
}

void _validatePngAsset(
  String configPath,
  String relativePath, {
  required int minimumSize,
  required String field,
  required List<String> errors,
}) {
  final configDirectory = File(configPath).absolute.parent;
  final assetsDirectory = Directory.fromUri(
    configDirectory.uri.resolve('assets/'),
  );
  final asset = File.fromUri(configDirectory.uri.resolve(relativePath));
  final assetsPath = assetsDirectory.absolute.path;
  final assetsPrefix = assetsPath.endsWith(Platform.pathSeparator)
      ? assetsPath
      : '$assetsPath${Platform.pathSeparator}';
  if (!asset.absolute.path.startsWith(assetsPrefix)) {
    errors.add(
      r'$.brand.'
      '$field must remain inside the config assets directory',
    );
    return;
  }
  if (!asset.existsSync()) {
    errors.add(
      r'$.brand.'
      '$field does not exist relative to the app config',
    );
    return;
  }
  final canonicalAssets = assetsDirectory.resolveSymbolicLinksSync();
  final canonicalAsset = asset.resolveSymbolicLinksSync();
  final canonicalPrefix = canonicalAssets.endsWith(Platform.pathSeparator)
      ? canonicalAssets
      : '$canonicalAssets${Platform.pathSeparator}';
  if (!canonicalAsset.startsWith(canonicalPrefix)) {
    errors.add(
      r'$.brand.'
      '$field resolves outside the config assets directory',
    );
    return;
  }
  final decoded = image.decodePng(asset.readAsBytesSync());
  if (decoded == null) {
    errors.add(
      r'$.brand.'
      '$field must reference a valid PNG',
    );
    return;
  }
  if (decoded.width != decoded.height || decoded.width < minimumSize) {
    errors.add(
      r'$.brand.'
      '$field must be square and at least ${minimumSize}x$minimumSize',
    );
  }
}

void _validateBrandContrast(Map<String, Object?> brand, List<String> errors) {
  final primary = brand['primaryPair'];
  if (primary is! Map<String, Object?>) return;
  const surfaceSets = <String, List<String>>{
    'light': ['#F7F8FA', '#FFFFFF', '#EEF1F4'],
    'dark': ['#111418', '#191D22', '#242A31'],
  };
  for (final mode in surfaceSets.keys) {
    final raw = primary[mode];
    if (raw is! String || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(raw)) {
      continue;
    }
    final focus = _parseRgb(raw);
    final minimum = surfaceSets[mode]!
        .map((surface) => _contrastRatio(focus, _parseRgb(surface)))
        .reduce((first, second) => first < second ? first : second);
    if (minimum < 3) {
      errors.add(
        r'$.brand.primaryPair.'
        '$mode must provide at least 3:1 focus contrast against all $mode surfaces',
      );
    }
  }
}

List<int> _parseRgb(String value) {
  final packed = int.parse(value.substring(1), radix: 16);
  return [(packed >> 16) & 0xff, (packed >> 8) & 0xff, packed & 0xff];
}

double _contrastRatio(List<int> first, List<int> second) {
  final firstLuminance = _relativeLuminance(first);
  final secondLuminance = _relativeLuminance(second);
  final lighter = math.max(firstLuminance, secondLuminance);
  final darker = math.min(firstLuminance, secondLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(List<int> color) {
  final channels = color.map((component) {
    final value = component / 255;
    return value <= 0.04045
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }).toList();
  return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2];
}

Map<String, Object?> _resolveReference(
  String reference,
  Map<String, Object?> root,
) {
  if (!reference.startsWith('#/')) {
    throw FormatException('unsupported schema reference: $reference');
  }
  Object? current = root;
  for (final segment in reference.substring(2).split('/')) {
    if (current is! Map<String, Object?> || !current.containsKey(segment)) {
      throw FormatException('missing schema reference: $reference');
    }
    current = current[segment];
  }
  if (current is! Map<String, Object?>) {
    throw FormatException('schema reference is not an object: $reference');
  }
  return current;
}

bool _matchesType(Object? value, List<String> allowed) {
  return allowed.any(
    (type) => switch (type) {
      'null' => value == null,
      'object' => value is Map<String, Object?>,
      'array' => value is List<Object?>,
      'string' => value is String,
      'boolean' => value is bool,
      'integer' => value is int,
      'number' => value is num,
      _ => false,
    },
  );
}
