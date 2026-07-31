import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

const _contractPath = 'tool/design_system/design_system_contract_probe.dart';
const _implementationRoot = 'lib/core/design_system';
const _deferredImplementations = <String>{'AppSelect', 'AppSegmentedControl'};
const _contractOnlyHelpers = <String>{'AppPlatformIconPair'};

void main(List<String> arguments) {
  if (arguments.length > 1 ||
      (arguments.isNotEmpty && arguments.single != '--self-test')) {
    stderr.writeln(
      'usage: dart run tool/design_system/verify_public_api_parity.dart '
      '[--self-test]',
    );
    exit(64);
  }

  final contractSource = File(_contractPath).readAsStringSync();
  final errors = _verify(contractSource);
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }

  if (arguments case ['--self-test']) {
    const navigatorParameter = '    required this.navigatorKey,\n';
    if (!contractSource.contains(navigatorParameter)) {
      stderr.writeln('parity self-test mutation target is missing');
      exit(1);
    }
    final mutated = contractSource.replaceFirst(navigatorParameter, '');
    final mutationErrors = _verify(mutated);
    if (!mutationErrors.any((error) => error.contains('AppFeedback'))) {
      stderr.writeln('parity self-test failed to detect AppFeedback drift');
      exit(1);
    }
    const missingImplementation = '''
abstract class AppUnimplemented extends StatelessWidget {
  const AppUnimplemented({super.key});
}
''';
    final missingErrors = _verify('$contractSource\n$missingImplementation');
    if (!missingErrors.any(
      (error) => error.contains('AppUnimplemented implementation is missing'),
    )) {
      stderr.writeln(
        'parity self-test failed to detect a missing implementation',
      );
      exit(1);
    }
    stdout.writeln('Public API parity mutation self-test: PASS');
  }

  stdout.writeln('Public API constructor parity: PASS');
}

List<String> _verify(String contractSource) {
  final contract = _classes(
    parseString(content: contractSource, path: _contractPath),
    _contractPath,
  );
  final implementations = <String, _ClassShape>{};
  for (final entity in Directory(
    _implementationRoot,
  ).listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final parsed = parseString(
      content: entity.readAsStringSync(),
      path: entity.path,
    );
    for (final entry in _classes(parsed, entity.path).entries) {
      final previous = implementations[entry.key];
      if (previous != null) {
        return [
          'public class ${entry.key} is declared in both '
              '${previous.path} and ${entry.value.path}',
        ];
      }
      implementations[entry.key] = entry.value;
    }
  }

  final errors = <String>[];
  var compared = 0;
  for (final entry in contract.entries) {
    if (entry.value.constructors.isEmpty) continue;
    final actual = implementations[entry.key];
    if (actual == null) {
      if (!_deferredImplementations.contains(entry.key) &&
          !_contractOnlyHelpers.contains(entry.key)) {
        errors.add('${entry.key} implementation is missing');
      }
      continue;
    }
    compared += 1;
    if (!_sameConstructors(entry.value.constructors, actual.constructors)) {
      errors.add(
        '${entry.key} constructor drift: contract '
        '${entry.value.constructors}, implementation ${actual.constructors}',
      );
    }
  }
  if (compared == 0) errors.add('no public constructors were compared');
  return errors;
}

Map<String, _ClassShape> _classes(ParseStringResult result, String path) {
  final classes = <String, _ClassShape>{};
  for (final declaration
      in result.unit.declarations.whereType<ClassDeclaration>()) {
    final constructors = <String, String>{};
    final body = declaration.body;
    final members = body is BlockClassBody
        ? body.members
        : const <ClassMember>[];
    for (final constructor in members.whereType<ConstructorDeclaration>()) {
      final name = constructor.name?.lexeme ?? 'new';
      constructors[name] = _normalize(constructor.parameters.toSource());
    }
    classes[declaration.namePart.typeName.lexeme] = _ClassShape(
      path: path,
      constructors: constructors,
    );
  }
  return classes;
}

String _normalize(String source) => source.replaceAll(RegExp(r'\s+'), '');

bool _sameConstructors(Map<String, String> left, Map<String, String> right) {
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}

final class _ClassShape {
  const _ClassShape({required this.path, required this.constructors});

  final String path;
  final Map<String, String> constructors;
}
