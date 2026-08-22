import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/line_info.dart';

const _policyPath = 'tool/design_system/ui_candidate_boundary.json';
const _fixtureRoot = 'tool/design_system/fixtures/ui_candidate_boundary';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    final errors = _validateTree(
      Directory.current.path,
      _readPolicy(File(_policyPath)),
      verifyDeclaredDependencies: true,
    );
    _finish(errors, 'UI candidate boundary: PASS');
  }
  if (arguments.length == 1 && arguments.single == '--fixtures') {
    _verifyFixtures();
    return;
  }
  stderr.writeln(
    'usage: dart run tool/design_system/verify_ui_candidate_boundary.dart '
    '[--fixtures]',
  );
  exit(64);
}

Never _finish(List<String> errors, String success) {
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln(success);
  exit(0);
}

void _verifyFixtures() {
  const fixturePolicy = _Policy(
    candidatePackages: {'candidate_ui'},
    adapterRoots: ['lib/core/design_system/adapters/'],
    publicBarrel: 'lib/admin9_ui.dart',
    rootThemeFiles: {
      'lib/app/admin9_app.dart',
      'lib/core/design_system/foundation/app_theme.dart',
    },
  );
  final passCases = _caseDirectories('$_fixtureRoot/pass');
  final failCases = _caseDirectories('$_fixtureRoot/fail');
  final failures = <String>[];

  for (final fixture in passCases) {
    final errors = _validateTree(fixture.path, fixturePolicy);
    if (errors.isNotEmpty) {
      failures.add('${fixture.path}: expected pass, got ${errors.join('; ')}');
    }
  }
  for (final fixture in failCases) {
    final expectedFile = File('${fixture.path}/expected.txt');
    if (!expectedFile.existsSync()) {
      failures.add('${fixture.path}: expected.txt is missing');
      continue;
    }
    final expected = expectedFile.readAsStringSync().trim();
    final errors = _validateTree(fixture.path, fixturePolicy);
    if (!errors.any((error) => error.contains(expected))) {
      failures.add(
        '${fixture.path}: expected violation "$expected", got '
        '${errors.join('; ')}',
      );
    }
  }

  _finish(
    failures,
    'UI candidate boundary fixtures: PASS '
    '(${passCases.length} positive, ${failCases.length} negative)',
  );
}

List<Directory> _caseDirectories(String path) {
  final directory = Directory(path);
  if (!directory.existsSync()) return const <Directory>[];
  return (directory.listSync().whereType<Directory>().toList()
    ..sort((left, right) => left.path.compareTo(right.path)));
}

List<String> _validateTree(
  String root,
  _Policy policy, {
  bool verifyDeclaredDependencies = false,
}) {
  final files = _dartFiles(root);
  final errors = <String>[];
  final parsed = <String, _ParsedSource>{};
  final dependencyGraph = <String, Set<String>>{};
  final exportGraph = <String, Set<String>>{};
  final partGraph = <String, Set<String>>{};
  final candidatePrefixesByPath = <String, Set<String>>{};

  for (final file in files) {
    final relative = _relativePath(root, file.path);
    final source = file.readAsStringSync();
    final result = parseString(content: source, path: relative);
    final parsedSource = _ParsedSource(
      source: source,
      unit: result.unit,
      lineInfo: result.lineInfo,
    );
    parsed[relative] = parsedSource;
  }

  for (final entry in parsed.entries) {
    final path = entry.key;
    final source = entry.value;
    final inAdapterPath = _isUnder(path, policy.adapterRoots);
    final candidatePrefixes = candidatePrefixesByPath.putIfAbsent(
      path,
      () => <String>{},
    );
    final localDependencies = dependencyGraph.putIfAbsent(
      path,
      () => <String>{},
    );

    for (final directive
        in source.unit.directives.whereType<ImportDirective>()) {
      final location = _location(path, source, directive.offset);
      var importsCandidate = false;
      for (final uri in _namespaceUris(directive)) {
        final package = _packageName(uri);
        final target = _normalizeImport(path, uri);
        if (target.startsWith('lib/')) localDependencies.add(target);
        if (package != null && policy.candidatePackages.contains(package)) {
          importsCandidate = true;
          if (!inAdapterPath) {
            errors.add(
              '$location candidate package imports are allowed only under '
              '${policy.adapterRoots.join(', ')}: $uri',
            );
          }
        }
      }
      if (importsCandidate) {
        final prefix = directive.prefix?.name;
        if (prefix == null) {
          errors.add(
            '$location candidate package imports require an explicit prefix',
          );
        } else {
          candidatePrefixes.add(prefix);
        }
      }
    }

    for (final directive
        in source.unit.directives.whereType<ExportDirective>()) {
      final location = _location(path, source, directive.offset);
      for (final uri in _namespaceUris(directive)) {
        final package = _packageName(uri);
        final target = _normalizeImport(path, uri);
        if (target.startsWith('lib/')) {
          localDependencies.add(target);
          exportGraph.putIfAbsent(path, () => <String>{}).add(target);
        }
        if ((package != null && policy.candidatePackages.contains(package)) ||
            _isUnder(target, policy.adapterRoots)) {
          errors.add(
            '$location candidate packages and adapters must not be exported: '
            '$uri',
          );
        }
      }
    }

    for (final directive in source.unit.directives.whereType<PartDirective>()) {
      final uri = directive.uri.stringValue;
      if (uri == null) continue;
      final target = _normalizeImport(path, uri);
      if (target.startsWith('lib/')) {
        localDependencies.add(target);
        partGraph.putIfAbsent(path, () => <String>{}).add(target);
      }
    }
  }

  final adapterFiles = _adapterFiles(
    parsed.keys,
    partGraph,
    policy.adapterRoots,
  );
  final adapterNames = <String>{};
  for (final path in adapterFiles) {
    final source = parsed[path];
    if (source != null) adapterNames.addAll(_publicAdapterNames(source.source));
  }
  for (final entry in partGraph.entries) {
    final libraryPrefixes = candidatePrefixesByPath[entry.key];
    if (libraryPrefixes == null || libraryPrefixes.isEmpty) continue;
    for (final part in entry.value) {
      candidatePrefixesByPath
          .putIfAbsent(part, () => <String>{})
          .addAll(libraryPrefixes);
    }
  }

  for (final path in adapterFiles) {
    final source = parsed[path];
    if (source == null) continue;
    for (final declaration
        in source.unit.declarations.whereType<ExtensionDeclaration>()) {
      final name = declaration.name?.lexeme;
      if (name == null || !_isPrivate(name)) {
        errors.add(
          '${_location(path, source, declaration.offset)} candidate adapters '
          'must not declare public context extensions',
        );
      }
    }
    for (final signature in _publicSignatures(source)) {
      for (final prefix in candidatePrefixesByPath[path] ?? const <String>{}) {
        if (RegExp('\\b${RegExp.escape(prefix)}\\.').hasMatch(signature.text)) {
          errors.add(
            '${_location(path, source, signature.offset)} candidate types '
            'must not appear in adapter public API',
          );
        }
      }
    }
  }

  for (final rootThemeFile in policy.rootThemeFiles) {
    final path = _pathToAdapter(rootThemeFile, dependencyGraph, adapterFiles);
    if (path != null) {
      errors.add(
        '$rootThemeFile: root Theme and app host files must not depend on '
        'candidate adapters: ${path.join(' -> ')}',
      );
    }
  }

  final publicFiles = _publicApiFiles(
    parsed,
    policy.publicBarrel,
    exportGraph,
    partGraph,
  );
  for (final path in publicFiles) {
    final source = parsed[path];
    if (source == null) continue;
    for (final signature in _publicSignatures(source)) {
      for (final adapterName in adapterNames) {
        if (RegExp(
          '\\b${RegExp.escape(adapterName)}\\b',
        ).hasMatch(signature.text)) {
          errors.add(
            '${_location(path, source, signature.offset)} adapter types must '
            'not appear in the App* public API: $adapterName',
          );
        }
      }
    }
  }

  if (verifyDeclaredDependencies) {
    final pubspec = File('$root/pubspec.yaml');
    final manifest = pubspec.existsSync() ? pubspec.readAsStringSync() : '';
    for (final package in policy.candidatePackages) {
      if (!RegExp(
        '^  ${RegExp.escape(package)}:',
        multiLine: true,
      ).hasMatch(manifest)) {
        errors.add(
          '$_policyPath lists $package but pubspec.yaml does not declare it',
        );
      }
    }
  }

  return errors;
}

List<String>? _pathToAdapter(
  String start,
  Map<String, Set<String>> graph,
  Set<String> adapterFiles,
) {
  final pending = <List<String>>[
    [start],
  ];
  final visited = <String>{};
  while (pending.isNotEmpty) {
    final path = pending.removeAt(0);
    final current = path.last;
    if (!visited.add(current)) continue;
    if (current != start && adapterFiles.contains(current)) return path;
    for (final next in graph[current] ?? const <String>{}) {
      pending.add([...path, next]);
    }
  }
  return null;
}

Set<String> _publicApiFiles(
  Map<String, _ParsedSource> parsed,
  String barrelPath,
  Map<String, Set<String>> exportGraph,
  Map<String, Set<String>> partGraph,
) {
  if (!parsed.containsKey(barrelPath)) return const <String>{};
  final publicFiles = <String>{};
  final pending = <String>[barrelPath];
  final visited = <String>{};
  while (pending.isNotEmpty) {
    final current = pending.removeLast();
    if (!visited.add(current)) continue;
    for (final target in exportGraph[current] ?? const <String>{}) {
      if (parsed.containsKey(target) && publicFiles.add(target)) {
        pending.add(target);
      }
    }
    for (final part in partGraph[current] ?? const <String>{}) {
      if (parsed.containsKey(part)) publicFiles.add(part);
    }
  }
  return publicFiles;
}

Set<String> _publicAdapterNames(String source) {
  final names = <String>{};
  final declaration = RegExp(
    r'^\s*(?:(?:abstract|base|final|interface|sealed)\s+)*'
    r'(?:class|enum|mixin|typedef|extension\s+type)\s+([A-Za-z]\w*)',
    multiLine: true,
  );
  for (final match in declaration.allMatches(source)) {
    final name = match.group(1);
    if (name != null && !_isPrivate(name)) names.add(name);
  }
  return names;
}

Set<String> _adapterFiles(
  Iterable<String> files,
  Map<String, Set<String>> partGraph,
  List<String> adapterRoots,
) {
  final result = files.where((path) => _isUnder(path, adapterRoots)).toSet();
  var changed = true;
  while (changed) {
    changed = false;
    for (final library in result.toList()) {
      for (final part in partGraph[library] ?? const <String>{}) {
        if (result.add(part)) changed = true;
      }
    }
  }
  return result;
}

Iterable<String> _namespaceUris(NamespaceDirective directive) sync* {
  final primary = directive.uri.stringValue;
  if (primary != null) yield primary;
  for (final configuration in directive.configurations) {
    final conditional = configuration.uri.stringValue;
    if (conditional != null) yield conditional;
  }
}

List<_Signature> _publicSignatures(_ParsedSource source) {
  final signatures = <_Signature>[];
  for (final declaration in source.unit.declarations) {
    if (declaration is ClassDeclaration) {
      final className = declaration.namePart.typeName.lexeme;
      if (_isPrivate(className)) continue;
      signatures.add(
        _slice(source.source, declaration.offset, declaration.body.offset),
      );
      final body = declaration.body;
      if (body is BlockClassBody) {
        _addPublicMemberSignatures(source, body.members, signatures);
      }
    } else if (declaration is EnumDeclaration) {
      final name = _namedDeclarationName(declaration.toSource(), 'enum');
      if (name == null || _isPrivate(name)) continue;
      signatures.add(
        _slice(source.source, declaration.offset, declaration.body.offset),
      );
      _addPublicMemberSignatures(source, declaration.body.members, signatures);
    } else if (declaration is MixinDeclaration) {
      final name = _namedDeclarationName(declaration.toSource(), 'mixin');
      if (name == null || _isPrivate(name)) continue;
      signatures.add(
        _slice(source.source, declaration.offset, declaration.body.offset),
      );
      _addPublicMemberSignatures(source, declaration.body.members, signatures);
    } else if (declaration is ExtensionTypeDeclaration) {
      final name = _extensionTypeName(declaration.toSource());
      if (name == null || _isPrivate(name)) continue;
      signatures.add(
        _slice(source.source, declaration.offset, declaration.body.offset),
      );
      final body = declaration.body;
      if (body is BlockClassBody) {
        _addPublicMemberSignatures(source, body.members, signatures);
      }
    } else if (declaration is FunctionDeclaration &&
        !_isPrivate(declaration.name.lexeme)) {
      signatures.add(
        _slice(
          source.source,
          declaration.offset,
          declaration.functionExpression.body.offset,
        ),
      );
    } else if (declaration is ExtensionDeclaration) {
      final name = declaration.name?.lexeme;
      if (name == null || !_isPrivate(name)) {
        signatures.add(
          _slice(source.source, declaration.offset, declaration.body.offset),
        );
      }
    } else if (declaration is TypeAlias) {
      final name = _typedefName(declaration.toSource());
      if (name != null && !_isPrivate(name)) {
        signatures.add(
          _slice(source.source, declaration.offset, declaration.end),
        );
      }
    } else if (declaration is TopLevelVariableDeclaration &&
        declaration.variables.variables.any(
          (variable) => !_isPrivate(variable.name.lexeme),
        )) {
      signatures.add(
        _slice(source.source, declaration.offset, declaration.end),
      );
    }
  }
  return signatures;
}

void _addPublicMemberSignatures(
  _ParsedSource source,
  Iterable<ClassMember> members,
  List<_Signature> signatures,
) {
  for (final member in members) {
    if (member is MethodDeclaration && !_isPrivate(member.name.lexeme)) {
      signatures.add(_slice(source.source, member.offset, member.body.offset));
    } else if (member is ConstructorDeclaration) {
      final name = member.name?.lexeme;
      if (name == null || !_isPrivate(name)) {
        signatures.add(
          _slice(source.source, member.offset, member.body.offset),
        );
      }
    } else if (member is FieldDeclaration &&
        member.fields.variables.any(
          (variable) => !_isPrivate(variable.name.lexeme),
        )) {
      signatures.add(_slice(source.source, member.offset, member.end));
    }
  }
}

String? _namedDeclarationName(String source, String keyword) => RegExp(
  '\\b${RegExp.escape(keyword)}\\s+([A-Za-z]\\w*)',
).firstMatch(source)?.group(1);

String? _extensionTypeName(String source) =>
    RegExp(r'\bextension\s+type\s+([A-Za-z]\w*)').firstMatch(source)?.group(1);

String? _typedefName(String source) =>
    RegExp(r'\btypedef\s+([A-Za-z]\w*)').firstMatch(source)?.group(1);

_Signature _slice(String source, int start, int end) =>
    _Signature(offset: start, text: source.substring(start, end));

List<File> _dartFiles(String root) =>
    (Directory(root)
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.dart') &&
              !file.path.contains('/.dart_tool/') &&
              !file.path.contains('/build/'),
        )
        .toList()
      ..sort((left, right) => left.path.compareTo(right.path)));

String _relativePath(String root, String path) {
  final normalizedRoot = root
      .replaceAll('\\', '/')
      .replaceFirst(RegExp(r'/$'), '');
  final normalizedPath = path.replaceAll('\\', '/');
  return normalizedPath.startsWith('$normalizedRoot/')
      ? normalizedPath.substring(normalizedRoot.length + 1)
      : normalizedPath;
}

bool _isUnder(String path, Iterable<String> roots) =>
    roots.any((root) => path.startsWith(root));

bool _isPrivate(String name) => name.startsWith('_');

String? _packageName(String uri) {
  if (!uri.startsWith('package:')) return null;
  return uri.substring('package:'.length).split('/').first;
}

String _normalizeImport(String importer, String uri) {
  if (uri.startsWith('package:admin9_app_flutter/')) {
    return 'lib/${uri.substring('package:admin9_app_flutter/'.length)}';
  }
  if (uri.startsWith('package:') || uri.startsWith('dart:')) return uri;
  final segments = importer.split('/')..removeLast();
  for (final segment in uri.split('/')) {
    if (segment == '.') continue;
    if (segment == '..') {
      if (segments.isNotEmpty) segments.removeLast();
    } else {
      segments.add(segment);
    }
  }
  return segments.join('/');
}

String _location(String path, _ParsedSource source, int offset) =>
    '$path:${source.lineInfo.getLocation(offset).lineNumber}';

_Policy _readPolicy(File file) {
  final value = jsonDecode(file.readAsStringSync());
  if (value is! Map<String, Object?> || value['schemaVersion'] != '1.0.0') {
    stderr.writeln('${file.path}: invalid UI candidate boundary policy');
    exit(2);
  }
  Set<String> readSet(String key) =>
      (value[key] as List<Object?>? ?? const <Object?>[])
          .whereType<String>()
          .toSet();
  return _Policy(
    candidatePackages: readSet('candidatePackages'),
    adapterRoots: readSet('adapterRoots').toList()..sort(),
    publicBarrel: value['publicBarrel'] as String,
    rootThemeFiles: readSet('rootThemeFiles'),
  );
}

final class _Policy {
  const _Policy({
    required this.candidatePackages,
    required this.adapterRoots,
    required this.publicBarrel,
    required this.rootThemeFiles,
  });

  final Set<String> candidatePackages;
  final List<String> adapterRoots;
  final String publicBarrel;
  final Set<String> rootThemeFiles;
}

final class _ParsedSource {
  const _ParsedSource({
    required this.source,
    required this.unit,
    required this.lineInfo,
  });

  final String source;
  final CompilationUnit unit;
  final LineInfo lineInfo;
}

final class _Signature {
  const _Signature({required this.offset, required this.text});

  final int offset;
  final String text;
}
