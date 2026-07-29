import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _schemaPath = 'docs/design-system/schema/admin9-foundation.schema.json';
const _compatibilityPath =
    'docs/design-system/schema/admin9-foundation-compatibility.json';
const _ruleRegisterPath =
    'docs/design-system/evidence/admin9-design-system-v1-rule-register.md';
const _fixtureRoot = 'docs/design-system/fixtures/foundation-manifest';
const _fixtureExpectedErrors = <String, List<String>>{
  'invalid-asset-traversal.yaml': [
    r'$.brandConfiguration.logoPath does not match',
  ],
  'invalid-brand-drift.yaml': [
    r'$.brandConfiguration.themeSha256 does not match',
  ],
  'invalid-brand-contrast.yaml': [
    r'$.brandConfiguration.primaryPair.light must provide at least 3:1 focus contrast',
    r'$.brandConfiguration.primaryPair.dark must provide at least 3:1 focus contrast',
  ],
  'invalid-calendar.yaml': [
    r'$.deviations[0].startsOn is not a valid calendar date',
    r'$.provenance.generatedAt is not a valid UTC timestamp',
  ],
  'invalid-date-range.yaml': [r'$.deviations[0] startsOn must be'],
  'invalid-expired-deviation.yaml': [r'$.deviations[0] deviation expired'],
  'invalid-incompatible-combination.yaml': [
    r'$.compatibility is not an approved',
  ],
  'invalid-missing-source.yaml': [r'$.foundation.commit is required'],
  'invalid-unauthorized-override.yaml': [
    r'$.ownership.brand.allowedOverrides[0] must be one of',
  ],
  'invalid-unknown-field.yaml': [r'$.foundation.branch is unknown'],
  'invalid-unknown-rule.yaml': [r'$.deviations[0].ruleId does not exist'],
  'invalid-version-path.yaml': [
    r'$.foundation.commit does not match',
    r'$.app.version does not match',
    r'$.brandConfiguration.logoPath does not match',
  ],
};

Never _usage() {
  stderr.writeln(
    'usage: dart run tool/design_system/validate_foundation_manifest.dart '
    '<admin9-foundation.yaml>\n'
    '   or: dart run tool/design_system/validate_foundation_manifest.dart '
    '--fixtures',
  );
  exit(64);
}

void main(List<String> arguments) {
  if (arguments.length != 1) _usage();

  final schema = _readJson(_schemaPath);
  _validateSchemaKeywords(schema);
  if (arguments.single == '--fixtures') {
    _validateFixtures(schema);
    return;
  }

  final errors = _validateFile(arguments.single, schema);
  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln(error);
    }
    exit(1);
  }
  stdout.writeln(
    '${arguments.single}: valid at ${DateTime.now().toUtc().toIso8601String()}',
  );
}

Map<String, Object?> _readJson(String path) {
  try {
    final value = jsonDecode(File(path).readAsStringSync());
    if (value is! Map<String, Object?>) {
      throw const FormatException('root must be an object');
    }
    return value;
  } on Object catch (error) {
    stderr.writeln('$path: cannot parse JSON-compatible YAML: $error');
    exit(2);
  }
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
    _validateSemanticContract(value, path, errors);
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
          .where((file) => file.path.split('/').last.startsWith('invalid-'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (invalidFiles.isEmpty) {
    stderr.writeln('$_fixtureRoot: no invalid fixtures found');
    exit(1);
  }

  var failed = false;
  for (final fixture in invalidFiles) {
    final errors = _validateFile(fixture.path, schema);
    final name = fixture.uri.pathSegments.last;
    final expected = _fixtureExpectedErrors[name];
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
    'fixture contract: PASS (${invalidFiles.length} invalid cases)',
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
    final target = _resolveReference(reference, root);
    _validate(value, target, root, path, errors);
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
    final minItems = node['minItems'];
    if (minItems is int && value.length < minItems) {
      errors.add('$path must contain at least $minItems item(s)');
    }
    if (node['uniqueItems'] == true && value.toSet().length != value.length) {
      errors.add('$path must not contain duplicate items');
    }
    final itemSchema = node['items'];
    if (itemSchema is Map<String, Object?>) {
      for (var index = 0; index < value.length; index += 1) {
        _validate(value[index], itemSchema, root, '$path[$index]', errors);
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
      if (!value.containsKey(entry.key)) continue;
      final childSchema = entry.value;
      if (childSchema is Map<String, Object?>) {
        _validate(
          value[entry.key],
          childSchema,
          root,
          '$path.${entry.key}',
          errors,
        );
      }
    }
  }
}

void _validateSemanticContract(
  Map<String, Object?> manifest,
  String path,
  List<String> errors,
) {
  final compatibility = _readJson(_compatibilityPath);
  final approved = compatibility['approved'];
  final foundation = manifest['foundation'];
  final designSystem = manifest['designSystem'];
  final toolchain = manifest['toolchain'];
  if (approved is List<Object?> &&
      foundation is Map<String, Object?> &&
      designSystem is Map<String, Object?> &&
      toolchain is Map<String, Object?>) {
    final matches = approved.whereType<Map<String, Object?>>().any(
      (entry) =>
          entry['status'] == 'approved' &&
          entry['foundationCommit'] == foundation['commit'] &&
          entry['designSystemVersion'] == designSystem['version'] &&
          entry['designSystemSourceTag'] == designSystem['sourceTag'] &&
          entry['flutter'] == toolchain['flutter'] &&
          entry['dart'] == toolchain['dart'],
    );
    if (!matches) {
      errors.add(
        r'$.compatibility is not an approved Foundation/Design System/toolchain combination',
      );
    }
  }

  final ruleIds = RegExp(r'^\| \[?(DS-[A-Z]{3}-[0-9]{3})\]?', multiLine: true)
      .allMatches(File(_ruleRegisterPath).readAsStringSync())
      .map((match) => match.group(1)!)
      .toSet();
  final deviations = manifest['deviations'];
  if (deviations is List<Object?>) {
    final today = DateTime.now().toUtc();
    final validationDate = DateTime.utc(today.year, today.month, today.day);
    for (var index = 0; index < deviations.length; index += 1) {
      final deviation = deviations[index];
      if (deviation is! Map<String, Object?>) continue;
      final base =
          r'$.deviations['
          '$index]';
      final ruleId = deviation['ruleId'];
      if (ruleId is String && !ruleIds.contains(ruleId)) {
        errors.add('$base.ruleId does not exist in the stable rule register');
      }
      final startsOnText = deviation['startsOn'];
      final expiresOnText = deviation['expiresOn'];
      final startsOn = startsOnText is String
          ? _parseExactDate(startsOnText)
          : null;
      final expiresOn = expiresOnText is String
          ? _parseExactDate(expiresOnText)
          : null;
      if (startsOnText is String && startsOn == null) {
        errors.add('$base.startsOn is not a valid calendar date');
      }
      if (expiresOnText is String && expiresOn == null) {
        errors.add('$base.expiresOn is not a valid calendar date');
      }
      if (startsOn != null && expiresOn != null) {
        if (startsOn.isAfter(expiresOn)) {
          errors.add('$base startsOn must be on or before expiresOn');
        }
        if (expiresOn.isBefore(validationDate)) {
          errors.add('$base deviation expired on ${deviation['expiresOn']}');
        }
      }
    }
  }

  final provenance = manifest['provenance'];
  if (provenance is Map<String, Object?>) {
    final generatedAt = provenance['generatedAt'];
    if (generatedAt is String && !_isExactUtcTimestamp(generatedAt)) {
      errors.add(r'$.provenance.generatedAt is not a valid UTC timestamp');
    }
  }

  final brand = manifest['brandConfiguration'];
  if (brand is Map<String, Object?>) {
    _validateBrandContrast(brand, errors);
    final canonical = <String, Object?>{
      'primaryPair': brand['primaryPair'],
      'secondaryPair': brand['secondaryPair'],
      'approvedFont': brand['approvedFont'],
      'radiusDelta': brand['radiusDelta'],
      'logoSha256': brand['logoSha256'],
      'launchAssetSha256': brand['launchAssetSha256'],
    };
    final expectedTheme = _sha256(utf8.encode(jsonEncode(canonical)));
    if (brand['themeSha256'] != expectedTheme) {
      errors.add(
        r'$.brandConfiguration.themeSha256 does not match canonical brand evidence',
      );
    }

    for (final pair in [
      ('logoPath', 'logoSha256'),
      ('launchAssetPath', 'launchAssetSha256'),
    ]) {
      final assetPath = brand[pair.$1];
      final expectedHash = brand[pair.$2];
      if (assetPath is! String || expectedHash is! String) continue;
      final manifestDirectory = File(path).absolute.parent;
      final assetsDirectory = Directory.fromUri(
        manifestDirectory.uri.resolve('assets/'),
      );
      final asset = File.fromUri(manifestDirectory.uri.resolve(assetPath));
      final assetsPrefix =
          assetsDirectory.absolute.path.endsWith(Platform.pathSeparator)
          ? assetsDirectory.absolute.path
          : '${assetsDirectory.absolute.path}${Platform.pathSeparator}';
      if (!asset.absolute.path.startsWith(assetsPrefix)) {
        errors.add(
          '\$.brandConfiguration.${pair.$1} must remain inside the manifest assets directory',
        );
        continue;
      }
      if (!asset.existsSync()) {
        errors.add(
          '\$.brandConfiguration.${pair.$1} does not exist relative to the manifest',
        );
      } else {
        final canonicalAssets = assetsDirectory.resolveSymbolicLinksSync();
        final canonicalAsset = asset.resolveSymbolicLinksSync();
        final canonicalPrefix = canonicalAssets.endsWith(Platform.pathSeparator)
            ? canonicalAssets
            : '$canonicalAssets${Platform.pathSeparator}';
        if (!canonicalAsset.startsWith(canonicalPrefix)) {
          errors.add(
            '\$.brandConfiguration.${pair.$1} resolves outside the manifest assets directory',
          );
          continue;
        }
        if (_sha256(asset.readAsBytesSync()) == expectedHash) continue;
        errors.add(
          '\$.brandConfiguration.${pair.$2} does not match asset bytes',
        );
      }
    }
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
        r'$.brandConfiguration.primaryPair.'
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
  final lighter = firstLuminance >= secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance >= secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(List<int> rgb) {
  double linear(int channel) {
    final value = channel / 255;
    return value <= 0.04045
        ? value / 12.92
        : _pow((value + 0.055) / 1.055, 2.4);
  }

  return 0.2126 * linear(rgb[0]) +
      0.7152 * linear(rgb[1]) +
      0.0722 * linear(rgb[2]);
}

double _pow(double base, double exponent) =>
    math.pow(base, exponent).toDouble();

DateTime? _parseExactDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final parsed = DateTime.utc(year, month, day);
  final roundTrip =
      '${parsed.year.toString().padLeft(4, '0')}-'
      '${parsed.month.toString().padLeft(2, '0')}-'
      '${parsed.day.toString().padLeft(2, '0')}';
  return roundTrip == value ? parsed : null;
}

bool _isExactUtcTimestamp(String value) {
  final match = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z$',
  ).firstMatch(value);
  if (match == null) return false;
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !parsed.isUtc) return false;
  final roundTrip =
      '${parsed.year.toString().padLeft(4, '0')}-'
      '${parsed.month.toString().padLeft(2, '0')}-'
      '${parsed.day.toString().padLeft(2, '0')}T'
      '${parsed.hour.toString().padLeft(2, '0')}:'
      '${parsed.minute.toString().padLeft(2, '0')}:'
      '${parsed.second.toString().padLeft(2, '0')}Z';
  return roundTrip == value;
}

void _validateSchemaKeywords(Map<String, Object?> schema) {
  const supported = <String>{
    r'$schema',
    r'$id',
    r'$defs',
    r'$ref',
    'title',
    'type',
    'additionalProperties',
    'required',
    'properties',
    'const',
    'enum',
    'pattern',
    'minLength',
    'minItems',
    'minimum',
    'maximum',
    'uniqueItems',
    'items',
  };

  void visit(Object? value, String path) {
    if (value is Map<String, Object?>) {
      for (final entry in value.entries) {
        if (!supported.contains(entry.key)) {
          stderr.writeln('$path.${entry.key}: unsupported schema keyword');
          exit(2);
        }
        if ((entry.key == 'properties' || entry.key == r'$defs') &&
            entry.value is Map<String, Object?>) {
          for (final child in (entry.value as Map<String, Object?>).entries) {
            visit(child.value, '$path.${entry.key}.${child.key}');
          }
        } else {
          visit(entry.value, '$path.${entry.key}');
        }
      }
    } else if (value is List<Object?>) {
      for (var index = 0; index < value.length; index += 1) {
        visit(value[index], '$path[$index]');
      }
    }
  }

  visit(schema, r'$schema');
}

String _sha256(List<int> input) {
  const constants = <int>[
    0x428a2f98,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2,
  ];
  final bytes = BytesBuilder(copy: false)..add(input);
  bytes.addByte(0x80);
  while ((bytes.length + 8) % 64 != 0) {
    bytes.addByte(0);
  }
  final bitLength = input.length * 8;
  final lengthBytes = ByteData(8)..setUint64(0, bitLength, Endian.big);
  bytes.add(lengthBytes.buffer.asUint8List());

  final hash = <int>[
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19,
  ];
  final data = bytes.takeBytes();
  int rotate(int value, int count) =>
      ((value >>> count) | (value << (32 - count))) & 0xffffffff;
  for (var offset = 0; offset < data.length; offset += 64) {
    final words = List<int>.filled(64, 0);
    final block = ByteData.sublistView(data, offset, offset + 64);
    for (var index = 0; index < 16; index += 1) {
      words[index] = block.getUint32(index * 4, Endian.big);
    }
    for (var index = 16; index < 64; index += 1) {
      final s0 =
          rotate(words[index - 15], 7) ^
          rotate(words[index - 15], 18) ^
          (words[index - 15] >>> 3);
      final s1 =
          rotate(words[index - 2], 17) ^
          rotate(words[index - 2], 19) ^
          (words[index - 2] >>> 10);
      words[index] =
          (words[index - 16] + s0 + words[index - 7] + s1) & 0xffffffff;
    }
    var a = hash[0];
    var b = hash[1];
    var c = hash[2];
    var d = hash[3];
    var e = hash[4];
    var f = hash[5];
    var g = hash[6];
    var h = hash[7];
    for (var index = 0; index < 64; index += 1) {
      final s1 = rotate(e, 6) ^ rotate(e, 11) ^ rotate(e, 25);
      final choice = (e & f) ^ ((~e) & g);
      final temp1 =
          (h + s1 + choice + constants[index] + words[index]) & 0xffffffff;
      final s0 = rotate(a, 2) ^ rotate(a, 13) ^ rotate(a, 22);
      final majority = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (s0 + majority) & 0xffffffff;
      h = g;
      g = f;
      f = e;
      e = (d + temp1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) & 0xffffffff;
    }
    final values = [a, b, c, d, e, f, g, h];
    for (var index = 0; index < 8; index += 1) {
      hash[index] = (hash[index] + values[index]) & 0xffffffff;
    }
  }
  return hash.map((value) => value.toRadixString(16).padLeft(8, '0')).join();
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
