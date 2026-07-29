import 'dart:convert';
import 'dart:io';

const _registerPath =
    'docs/design-system/evidence/admin9-design-system-v1-rule-register.md';
const _schemaPath = 'docs/design-system/schema/admin9-foundation.schema.json';
const _compatibilityPath =
    'docs/design-system/schema/admin9-foundation-compatibility.json';

void main() {
  final register = File(_registerPath).readAsStringSync();
  final linkPattern = RegExp(
    r'\[(DS-[A-Z]{3}-[0-9]{3})\]\((\.\./[^)#]+)#(ds-[a-z0-9-]+)\)',
  );
  final matches = linkPattern.allMatches(register).toList();
  final errors = <String>[];
  final ids = <String>{};

  if (matches.isEmpty) errors.add('rule register contains no linked rule IDs');
  for (final match in matches) {
    final id = match.group(1)!;
    final relativeTarget = match.group(2)!;
    final anchor = match.group(3)!;
    if (!ids.add(id)) errors.add('$id is duplicated');
    if (anchor != id.toLowerCase()) {
      errors.add('$id anchor must be ${id.toLowerCase()}, found $anchor');
    }

    final target = File(
      File(
        'docs/design-system/evidence/$relativeTarget',
      ).absolute.resolveSymbolicLinksSync(),
    );
    if (!target.existsSync()) {
      errors.add('$id target does not exist: ${target.path}');
      continue;
    }
    final marker = '<a id="$anchor"></a>';
    final count = marker.allMatches(target.readAsStringSync()).length;
    if (count != 1) {
      errors.add('$id target must contain exactly one $marker, found $count');
    }
  }

  final allModuleText = Directory('docs/design-system')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'))
      .map((file) => file.readAsStringSync())
      .join('\n');
  final declaredIds = RegExp(r'<a id="(ds-[a-z]{3}-[0-9]{3})"></a>')
      .allMatches(allModuleText)
      .map((match) => match.group(1)!.toUpperCase())
      .toSet();
  for (final id in declaredIds.difference(ids)) {
    errors.add('$id has an anchor but no register row');
  }
  for (final id in ids.difference(declaredIds)) {
    errors.add('$id has a register row but no normative anchor');
  }

  final schema = jsonDecode(File(_schemaPath).readAsStringSync());
  if (schema is! Map<String, Object?>) {
    errors.add('schema root is not an object');
  } else {
    final properties = schema['properties'];
    for (final field in [
      'foundation',
      'designSystem',
      'app',
      'brandConfiguration',
      'toolchain',
      'ownership',
      'exports',
      'compatibility',
      'provenance',
      'deviations',
    ]) {
      if (properties is! Map<String, Object?> ||
          !properties.containsKey(field)) {
        errors.add('schema missing rule-linked field: $field');
      }
      if (!register.contains('`$field')) {
        errors.add('rule register does not link schema field: $field');
      }
    }
  }

  final compatibility = jsonDecode(File(_compatibilityPath).readAsStringSync());
  if (compatibility is! Map<String, Object?> ||
      compatibility['schemaVersion'] != '1.0.0' ||
      compatibility['approved'] is! List<Object?> ||
      (compatibility['approved'] as List<Object?>).isEmpty) {
    errors.add('compatibility registry has no approved v1 entries');
  } else {
    const expectedKeys = <String>{
      'foundationCommit',
      'designSystemVersion',
      'designSystemSourceTag',
      'flutter',
      'dart',
      'status',
    };
    final tuples = <String>{};
    for (final entry in compatibility['approved'] as List<Object?>) {
      if (entry is! Map<String, Object?> ||
          entry.keys.toSet().difference(expectedKeys).isNotEmpty ||
          expectedKeys.difference(entry.keys.toSet()).isNotEmpty) {
        errors.add('compatibility registry entry has an invalid field set');
        continue;
      }
      final commit = entry['foundationCommit'];
      if (commit is! String || !RegExp(r'^[0-9a-f]{40}$').hasMatch(commit)) {
        errors.add('compatibility registry has an invalid Foundation commit');
      }
      if (entry['designSystemVersion'] is! String ||
          entry['designSystemSourceTag'] is! String ||
          entry['flutter'] is! String ||
          entry['dart'] is! String ||
          entry['status'] != 'approved') {
        errors.add('compatibility registry entry has invalid values');
      }
      final tuple = expectedKeys
          .where((key) => key != 'status')
          .map((key) => entry[key])
          .join('|');
      if (!tuples.add(tuple)) {
        errors.add('compatibility registry contains duplicate tuple: $tuple');
      }
    }
  }

  for (final gate in [
    'design_system_contract_probe.dart',
    'matrix A-L',
    'profile reachability',
    'predictive device gates',
  ]) {
    if (!register.contains(gate)) {
      errors.add('rule register missing gate: $gate');
    }
  }

  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('rule links: PASS (${ids.length} stable rules)');
}
