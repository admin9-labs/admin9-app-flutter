import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'production UI depends only on Flutter, Forui and its style contract',
    () {
      final root = Directory('lib').absolute;
      expect(root.existsSync(), isTrue);
      const allowed = [
        'package:flutter/',
        'package:forui/',
        'package:material_ui/',
        'package:admin9_ui/',
      ];
      final directives = RegExp(
        r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
        multiLine: true,
      );
      final violations = <String>[];
      for (final file
          in root
              .listSync(recursive: true, followLinks: false)
              .whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        for (final match in directives.allMatches(file.readAsStringSync())) {
          final path = match.group(1)!;
          if (path.startsWith('dart:')) continue;
          final permitted = path.startsWith('package:')
              ? allowed.any(path.startsWith)
              : file.parent.uri
                    .resolve(path)
                    .toString()
                    .startsWith(root.uri.toString());
          if (!permitted) violations.add('${file.path}: $path');
        }
      }
      expect(
        violations,
        isEmpty,
        reason: 'Package source must not import host application code.',
      );
    },
  );
}
