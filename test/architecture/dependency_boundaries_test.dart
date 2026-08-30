import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared UI stays independent of app routing and features', () {
    final violations = <String>[];
    for (final file in _dartFiles('lib/shared/ui')) {
      for (final import in _directives(file)) {
        final resolved = _resolvedProjectPath(file, import);
        if (import == 'package:auto_route/auto_route.dart' ||
            import.startsWith('package:admin9_app_flutter/app/') ||
            import.startsWith('package:admin9_app_flutter/features/') ||
            (resolved?.contains('/lib/app/') ?? false) ||
            (resolved?.contains('/lib/features/') ?? false)) {
          violations.add('${file.path}: $import');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'shared/ui must not depend on app routing or any feature',
    );
  });

  test('settings and theme stay independent of Examples', () {
    final violations = <String>[];
    for (final root in ['lib/features/settings', 'lib/theme']) {
      for (final file in _dartFiles(root)) {
        for (final import in _directives(file)) {
          final resolved = _resolvedProjectPath(file, import);
          if (import.startsWith(
                'package:admin9_app_flutter/features/examples/',
              ) ||
              (resolved?.contains('/lib/features/examples/') ?? false)) {
            violations.add('${file.path}: $import');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'removing Examples must not require changes to settings or theme',
    );
  });

  test('Examples has one allowed production integration boundary', () {
    final consumers = <String>[];
    for (final file in _dartFiles('lib')) {
      if (file.path.contains('/features/examples/')) continue;
      if (file.readAsStringSync().contains('features/examples/')) {
        consumers.add(file.path);
      }
    }

    expect(
      consumers.every((path) => path.startsWith('lib/app/routing/')),
      isTrue,
      reason:
          'only app/routing may integrate the removable Examples feature: '
          '$consumers',
    );
  });
}

Iterable<File> _dartFiles(String root) sync* {
  final directory = Directory(root);
  if (!directory.existsSync()) return;

  final files =
      directory
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  yield* files;
}

Iterable<String> _directives(File file) sync* {
  final pattern = RegExp(
    r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );
  for (final match in pattern.allMatches(file.readAsStringSync())) {
    yield match.group(1)!;
  }
}

String? _resolvedProjectPath(File source, String import) {
  if (import.startsWith('dart:') || import.startsWith('package:')) return null;
  return source.parent.uri.resolve(import).toFilePath();
}
