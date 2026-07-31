import 'dart:convert';
import 'dart:io';

const canonicalRemote = 'https://github.com/admin9-labs/admin9-app-flutter.git';
const _maintainerName = '冯齐跃';
const _maintainerHandle = 'qiyue2015';

void main(List<String> arguments) {
  final errors = switch (arguments) {
    [] => _verifyFoundation(),
    ['--derived-root', final root] => _verifyDerived(root),
    _ => [
      'usage: dart run tool/design_system/verify_repository_governance.dart '
          '[--derived-root <path>]',
    ],
  };
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('Repository governance: PASS');
}

List<String> _verifyFoundation() {
  final errors = <String>[];
  _expectRemote(
    errors,
    root: '.',
    name: 'origin',
    expectedFetch: canonicalRemote,
    expectedPush: canonicalRemote,
  );
  final owners = File('docs/design-system/OWNERS.md').readAsStringSync();
  for (final required in [
    _maintainerName,
    '(`$_maintainerHandle`)',
    canonicalRemote,
    'accessibility/test reviewer',
    'Foundation release maintainer',
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
  return errors;
}

List<String> _verifyDerived(String root) {
  final errors = <String>[];
  final directory = Directory(root).absolute;
  if (!directory.existsSync()) return ['${directory.path} is not a directory'];
  _expectRemote(
    errors,
    root: directory.path,
    name: 'foundation',
    expectedFetch: canonicalRemote,
    expectedPush: 'DISABLED',
  );
  final manifestFile = File('${directory.path}/admin9-foundation.yaml');
  if (!manifestFile.existsSync()) {
    errors.add('derived repository has no admin9-foundation.yaml');
    return errors;
  }
  final manifest = jsonDecode(manifestFile.readAsStringSync());
  if (manifest is! Map<String, Object?> ||
      manifest['foundation'] is! Map<String, Object?> ||
      (manifest['foundation'] as Map<String, Object?>)['upstreamRemote'] !=
          canonicalRemote) {
    errors.add('derived manifest upstreamRemote must be $canonicalRemote');
  }
  return errors;
}

void _expectRemote(
  List<String> errors, {
  required String root,
  required String name,
  required String expectedFetch,
  required String expectedPush,
}) {
  final fetch = _git(root, ['remote', 'get-url', name]);
  final push = _git(root, ['remote', 'get-url', '--push', name]);
  if (fetch != expectedFetch) {
    errors.add('$name fetch URL must be $expectedFetch; found $fetch');
  }
  if (push != expectedPush) {
    errors.add('$name push URL must be $expectedPush; found $push');
  }
}

String _git(String root, List<String> arguments) {
  final result = Process.runSync('git', ['-C', root, ...arguments]);
  if (result.exitCode != 0) return '<missing>';
  return (result.stdout as String).trim();
}
