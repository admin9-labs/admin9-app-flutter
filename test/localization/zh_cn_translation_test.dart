import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, String> translations;
  late Set<String> sourceKeys;
  late Set<String> exampleSourceKeys;

  setUpAll(() {
    final source = File('assets/translations/zh-CN.json').readAsStringSync();
    final decoded = jsonDecode(source);
    expect(decoded, isA<Map<String, dynamic>>());
    translations = _flatten(decoded as Map<String, dynamic>);
    final sources = _applicationSources();
    sourceKeys = _staticTranslationKeys(sources);
    exampleSourceKeys = _exampleTranslationKeys(sources);
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
    expect(sourceKeys, isNotEmpty);
    final missing = sourceKeys.difference(translations.keys.toSet()).toList()
      ..sort();
    expect(
      missing,
      isEmpty,
      reason: 'Missing zh-CN keys: ${missing.join(', ')}',
    );
  });

  test('Examples translations have no missing, orphan, or legacy keys', () {
    final exampleTranslations = translations.keys
        .where((key) => key.startsWith('examples.'))
        .toSet();
    if (!Directory('lib/features/examples').existsSync()) {
      expect(exampleSourceKeys, isEmpty);
      expect(exampleTranslations, isEmpty);
      expect(
        translations.keys.where((key) => key.startsWith('components.')),
        isEmpty,
      );
      return;
    }
    expect(exampleSourceKeys, isNotEmpty);
    expect(
      exampleSourceKeys.difference(exampleTranslations),
      isEmpty,
      reason: 'Missing Examples translations',
    );
    expect(
      exampleTranslations.difference(exampleSourceKeys),
      isEmpty,
      reason: 'Orphan Examples translations',
    );
    expect(
      translations.keys.where(
        (key) =>
            RegExp(r'^(foundation|forms|content|feedback)\.').hasMatch(key),
      ),
      isEmpty,
    );
  });
}

List<File> _applicationSources() =>
    Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList()
      ..sort((left, right) => left.path.compareTo(right.path));

Set<String> _staticTranslationKeys(Iterable<File> files) {
  final keys = <String>{};
  final patterns = [
    RegExp(r"'([^'\r\n]+)'\s*\.tr\s*\("),
    RegExp(r'"([^"\r\n]+)"\s*\.tr\s*\('),
    RegExp(r"\btr\s*\(\s*'([^'\r\n]+)'"),
    RegExp(r'\btr\s*\(\s*"([^"\r\n]+)"'),
  ];
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final pattern in patterns) {
      keys.addAll(pattern.allMatches(source).map((match) => match.group(1)!));
    }
  }
  return keys;
}

Set<String> _exampleTranslationKeys(Iterable<File> files) {
  final pattern = RegExp(r'''['"](examples\.[A-Za-z0-9_.-]+)['"]''');
  return {
    for (final file in files)
      for (final match in pattern.allMatches(file.readAsStringSync()))
        match.group(1)!,
  };
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
