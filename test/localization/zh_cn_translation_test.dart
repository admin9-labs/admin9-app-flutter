import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, String> translations;

  setUpAll(() {
    final source = File('assets/translations/zh-CN.json').readAsStringSync();
    final decoded = jsonDecode(source);
    expect(decoded, isA<Map<String, dynamic>>());
    translations = _flatten(decoded as Map<String, dynamic>);
  });

  test('zh-CN JSON contains only non-empty translation values', () {
    expect(translations, isNotEmpty);
    expect(
      translations.entries.where(
        (entry) => entry.key.trim().isEmpty || entry.value.trim().isEmpty,
      ),
      isEmpty,
    );
  });

  test('zh-CN covers every static tr key used by application source', () {
    final sourceKeys = <String>{};
    final patterns = [
      RegExp(r"'([^'\r\n]+)'\s*\.tr\s*\("),
      RegExp(r'"([^"\r\n]+)"\s*\.tr\s*\('),
      RegExp(r"\btr\s*\(\s*'([^'\r\n]+)'"),
      RegExp(r'\btr\s*\(\s*"([^"\r\n]+)"'),
    ];

    final sourceFiles =
        Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    for (final file in sourceFiles) {
      final source = file.readAsStringSync();
      for (final pattern in patterns) {
        sourceKeys.addAll(
          pattern.allMatches(source).map((match) => match.group(1)!),
        );
      }
    }

    expect(sourceKeys, isNotEmpty);
    final missing = sourceKeys.difference(translations.keys.toSet()).toList()
      ..sort();
    expect(
      missing,
      isEmpty,
      reason: 'Missing zh-CN keys: ${missing.join(', ')}',
    );
  });
}

Map<String, String> _flatten(
  Map<String, dynamic> source, [
  String prefix = '',
]) {
  final result = <String, String>{};
  for (final entry in source.entries) {
    final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
    switch (entry.value) {
      case final String value:
        result[key] = value;
      case final Map<String, dynamic> nested:
        result.addAll(_flatten(nested, key));
      default:
        fail('Translation $key must be a String or nested JSON object.');
    }
  }
  return result;
}
