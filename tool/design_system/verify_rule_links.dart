import 'dart:io';

const _registerPath =
    'docs/design-system/evidence/admin9-design-system-v1-rule-register.md';

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
