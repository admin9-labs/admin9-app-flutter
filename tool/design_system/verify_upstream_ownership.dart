import 'dart:io';

const _canonicalRepository =
    'https://github.com/admin9-labs/admin9-app-flutter.git';
const _maintainerName = '冯齐跃';
const _maintainerHandle = 'qiyue2015';

void main(List<String> arguments) {
  if (arguments.isNotEmpty) {
    stderr.writeln(
      'usage: dart run tool/design_system/verify_upstream_ownership.dart',
    );
    exit(64);
  }

  final errors = <String>[];
  final owners = File('docs/design-system/OWNERS.md').readAsStringSync();
  for (final required in [
    _maintainerName,
    '(`$_maintainerHandle`)',
    _canonicalRepository,
    'accessibility/test reviewer',
    'Starter maintainer',
  ]) {
    if (!owners.contains(required)) {
      errors.add('OWNERS.md must contain $required');
    }
  }

  final codeowners = File('.github/CODEOWNERS').readAsStringSync();
  for (final required in [
    '* @$_maintainerHandle',
    '/lib/core/design_system/ @$_maintainerHandle',
    '/tool/design_system/ @$_maintainerHandle',
    '/docs/design-system/ @$_maintainerHandle',
    '/android/ @$_maintainerHandle',
    '/ios/ @$_maintainerHandle',
  ]) {
    if (!codeowners.split('\n').contains(required)) {
      errors.add('CODEOWNERS must contain exactly: $required');
    }
  }

  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('Upstream ownership: PASS');
}
