import 'dart:io';
import 'dart:convert';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

enum _PolicyPhase { phase0d, finalPhase }

const _fixtureRoot = 'tool/design_system/fixtures/import_boundaries';
const _baselinePath = 'tool/design_system/import_boundary_baseline.json';
const _allowedFeatureWidgetDeclarations = <String>{
  'Align',
  'Builder',
  'Center',
  'Column',
  'ConstrainedBox',
  'CustomScrollView',
  'Expanded',
  'Flex',
  'Flexible',
  'FocusTraversalGroup',
  'Form',
  'LayoutBuilder',
  'ListView',
  'MediaQuery',
  'Padding',
  'Row',
  'SafeArea',
  'Semantics',
  'SingleChildScrollView',
  'SizedBox',
  'SliverList',
  'SliverPadding',
  'Stack',
  'Text',
  'Widget',
  'Wrap',
};
const _fixtureExpectedViolation = <String, String>{
  'barrel_exports_app.dart':
      'public barrel exports are not the exact allowlist',
  'barrel_exports_business.dart':
      'public barrel exports are not the exact allowlist',
  'barrel_exports_gallery.dart':
      'public barrel exports are not the exact allowlist',
  'barrel_uses_combinator.dart':
      'public barrel exports are not the exact allowlist',
  'barrel_declares_type.dart':
      'public barrel exports are not the exact allowlist',
  'core_imports_business.dart': 'Core must not import App or Business',
  'feature_imports_core_internal.dart':
      'imports Core internals instead of admin9_ui.dart',
  'feature_imports_material.dart':
      'Business imports an interactive platform library',
  'feature_imports_other_feature.dart':
      'feature account imports implementation of home',
  'feature_imports_route_assembler.dart':
      'feature imports the App host route assembler',
  'feature_imports_app_host.dart':
      'Business must not import App host internals',
  'feature_imports_widgets_umbrella.dart':
      'feature widgets import must use an explicit approved show list',
  'feature_imports_flutter_src.dart': 'imports private Flutter source',
  'feature_exports_material.dart':
      'Business must not export platform or Core libraries',
  'feature_exports_core_relative.dart':
      'Business must not export platform or Core libraries',
  'feature_imports_any_core.dart': 'feature imports Core internals',
  'shared_exports_material.dart':
      'Business must not export platform or Core libraries',
  'shared_exports_public_barrel.dart':
      'Business must not export platform or Core libraries',
  'shared_imports_material.dart':
      'Business imports an interactive platform library',
};

const publicBarrelExports = <String>{
  'core/design_system/foundation/app_contracts.dart',
  'core/design_system/foundation/app_design_tokens.dart',
};

const _appCoreInternalImportAllowlist = <String>{
  'lib/app/admin9_app.dart|lib/core/design_system/foundation/app_theme.dart',
  'lib/app/app_routes.dart|lib/core/design_system/foundation/app_theme.dart',
  'lib/app/app_routes.dart|lib/core/design_system/gallery/app_gallery_page.dart',
  'lib/app/app_routes.dart|lib/core/design_system/gallery/app_gallery_registry.dart',
};

const _businessAppImportAllowlist = <String>{
  'lib/app/app_identity.dart',
  'lib/app/app_route_names.dart',
};

void main(List<String> arguments) {
  if (arguments.length != 1) _usage();
  if (arguments.single == '--fixtures') {
    _verifyFixtures();
    return;
  }

  final phase = switch (arguments.single) {
    '--phase=0d' => _PolicyPhase.phase0d,
    '--phase=final' => _PolicyPhase.finalPhase,
    _ => _usage(),
  };
  final errors = _validateRepository(phase);
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('import boundaries: PASS (${phase.name})');
}

Never _usage() {
  stderr.writeln(
    'usage: dart run tool/design_system/verify_import_boundaries.dart '
    '--fixtures|--phase=0d|--phase=final',
  );
  exit(64);
}

void _verifyFixtures() {
  final passFiles = _dartFiles('$_fixtureRoot/pass');
  final failFiles = _dartFiles('$_fixtureRoot/fail');
  final errors = <String>[];
  for (final file in passFiles) {
    final violations = _validateFile(file, _PolicyPhase.finalPhase);
    if (violations.isNotEmpty) {
      errors.add('${file.path}: expected pass, got ${violations.join('; ')}');
    }
  }
  for (final file in failFiles) {
    final name = file.uri.pathSegments.last;
    final violations = name.startsWith('barrel_')
        ? verifyPublicBarrel(file)
        : _validateFile(file, _PolicyPhase.finalPhase);
    final expected = _fixtureExpectedViolation[name];
    if (expected == null) {
      errors.add('${file.path}: missing expected-violation contract');
    } else if (!violations.any((violation) => violation.contains(expected))) {
      errors.add(
        '${file.path}: expected violation "$expected", got '
        '${violations.join('; ')}',
      );
    }
  }
  final names = failFiles.map((file) => file.uri.pathSegments.last).toSet();
  final orphanContracts = _fixtureExpectedViolation.keys.toSet().difference(
    names,
  );
  if (orphanContracts.isNotEmpty) {
    errors.add(
      'expected-violation contracts without fixture: '
      '${orphanContracts.join(', ')}',
    );
  }
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln(
    'import-boundary fixtures: PASS '
    '(${passFiles.length} positive, ${failFiles.length} negative)',
  );
}

List<String> _validateRepository(_PolicyPhase phase) {
  final baseline = _readBaseline();
  final errors = <String>[];
  final observed = <String>{};
  for (final file in _dartFiles('lib')) {
    errors.addAll(_validateFile(file, phase, baseline: baseline));
    final path = file.path.replaceAll('\\', '/');
    final unit = parseString(content: file.readAsStringSync(), path: path).unit;
    for (final directive in unit.directives.whereType<ImportDirective>()) {
      final uri = directive.uri.stringValue;
      if (uri != null) observed.add('$path|${_normalizeImport(path, uri)}');
    }
  }
  errors.addAll(verifyPublicBarrel(File('lib/admin9_ui.dart')));
  if (phase == _PolicyPhase.phase0d) {
    final stale = <String>{
      ...baseline.legacyFeaturePlatformImports,
      ...baseline.legacyFeatureCoreImports,
    }.difference(observed);
    if (stale.isNotEmpty) {
      errors.add(
        'import boundary baseline contains removed debt: ${stale.join(', ')}',
      );
    }
  }
  return errors;
}

List<File> _dartFiles(String root) =>
    (Directory(root)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path)));

List<String> _validateFile(
  File file,
  _PolicyPhase phase, {
  _BoundaryBaseline baseline = const _BoundaryBaseline.empty(),
}) {
  final normalizedPath = file.path.replaceAll('\\', '/');
  final policyPath = _fixturePolicyPath(normalizedPath) ?? normalizedPath;
  final source = file.readAsStringSync();
  final result = parseString(content: source, path: normalizedPath);
  final errors = <String>[];
  final feature = _featureName(policyPath);
  final isBusiness = _isBusinessPath(policyPath);

  for (final directive in result.unit.directives.whereType<ImportDirective>()) {
    final uri = directive.uri.stringValue;
    if (uri == null) continue;
    final target = _normalizeImport(policyPath, uri);
    final line = result.lineInfo.getLocation(directive.offset).lineNumber;
    final location = '$normalizedPath:$line';
    final pair = '$policyPath|$target';

    if (uri.startsWith('package:flutter/src/')) {
      errors.add('$location imports private Flutter source: $uri');
    }

    if (policyPath.startsWith('lib/core/') &&
        (target.startsWith('lib/app/') || target.startsWith('lib/ui/'))) {
      errors.add('$location Core must not import App or Business: $uri');
    }

    if (!policyPath.startsWith('lib/core/design_system/') &&
        policyPath != 'lib/admin9_ui.dart' &&
        target.startsWith('lib/core/design_system/') &&
        !_appCoreInternalImportAllowlist.contains(pair)) {
      errors.add('$location imports Core internals instead of admin9_ui.dart');
    }

    if (isBusiness &&
        target.startsWith('lib/app/') &&
        !_businessAppImportAllowlist.contains(target)) {
      final message = target == 'lib/app/app_routes.dart'
          ? 'feature imports the App host route assembler'
          : 'Business must not import App host internals';
      errors.add('$location $message: $uri');
    }

    if (isBusiness && target.startsWith('lib/core/')) {
      if (phase == _PolicyPhase.finalPhase) {
        errors.add('$location feature imports Core internals: $uri');
      } else if (!baseline.legacyFeatureCoreImports.contains(pair)) {
        errors.add('$location new feature Core-internal import: $uri');
      }
    }

    final importedFeature = _featureName(target);
    if (feature != null &&
        importedFeature != null &&
        feature != importedFeature) {
      errors.add(
        '$location feature $feature imports implementation of '
        '$importedFeature: $uri',
      );
    }

    if (phase == _PolicyPhase.finalPhase &&
        isBusiness &&
        (uri == 'package:flutter/material.dart' ||
            uri == 'package:flutter/cupertino.dart')) {
      errors.add('$location Business imports an interactive platform library');
    } else if (phase == _PolicyPhase.phase0d &&
        isBusiness &&
        (uri == 'package:flutter/material.dart' ||
            uri == 'package:flutter/cupertino.dart') &&
        !baseline.legacyFeaturePlatformImports.contains('$policyPath|$uri')) {
      errors.add('$location new interactive platform import: $uri');
    }

    if (isBusiness && uri == 'package:flutter/widgets.dart') {
      final shown = directive.combinators
          .whereType<ShowCombinator>()
          .expand((combinator) => combinator.shownNames)
          .map((identifier) => identifier.name)
          .toSet();
      if (shown.isEmpty ||
          shown.difference(_allowedFeatureWidgetDeclarations).isNotEmpty) {
        errors.add(
          '$location feature widgets import must use an explicit approved '
          'show list',
        );
      }
    }
  }

  for (final directive in result.unit.directives.whereType<ExportDirective>()) {
    final uri = directive.uri.stringValue;
    if (uri == null) continue;
    final target = _normalizeImport(policyPath, uri);
    final line = result.lineInfo.getLocation(directive.offset).lineNumber;
    final location = '$normalizedPath:$line';
    if (isBusiness &&
        (uri.startsWith('package:flutter/') ||
            target.startsWith('lib/core/') ||
            target == 'lib/admin9_ui.dart' ||
            target.startsWith('lib/app/'))) {
      errors.add(
        '$location Business must not export platform or Core libraries: $uri',
      );
    }
  }
  return errors;
}

_BoundaryBaseline _readBaseline() {
  final value = jsonDecode(File(_baselinePath).readAsStringSync());
  if (value is! Map<String, Object?> || value['schemaVersion'] != '1.0.0') {
    stderr.writeln('$_baselinePath: invalid baseline schema');
    exit(2);
  }
  Set<String> readSet(String key) =>
      (value[key] as List<Object?>? ?? const <Object?>[])
          .whereType<String>()
          .toSet();
  return _BoundaryBaseline(
    legacyFeaturePlatformImports: readSet('legacyFeaturePlatformImports'),
    legacyFeatureCoreImports: readSet('legacyFeatureCoreImports'),
  );
}

final class _BoundaryBaseline {
  const _BoundaryBaseline({
    required this.legacyFeaturePlatformImports,
    required this.legacyFeatureCoreImports,
  });

  const _BoundaryBaseline.empty()
    : legacyFeaturePlatformImports = const <String>{},
      legacyFeatureCoreImports = const <String>{};

  final Set<String> legacyFeaturePlatformImports;
  final Set<String> legacyFeatureCoreImports;
}

String? _fixturePolicyPath(String path) {
  if (!path.contains('/fixtures/import_boundaries/')) return null;
  final name = path.split('/').last;
  if (name.startsWith('core_')) return 'lib/core/example.dart';
  if (name.startsWith('feature_')) {
    return 'lib/ui/features/account/example.dart';
  }
  if (name.startsWith('shared_')) return 'lib/ui/shared/example.dart';
  if (name.startsWith('barrel_')) return 'lib/admin9_ui.dart';
  return null;
}

bool _isBusinessPath(String path) =>
    path.startsWith('lib/ui/features/') || path.startsWith('lib/ui/shared/');

String? _featureName(String path) {
  final match = RegExp(r'lib/ui/features/([^/]+)/').firstMatch(path);
  return match?.group(1);
}

String _normalizeImport(String importer, String uri) {
  if (uri.startsWith('package:admin9_app_flutter/')) {
    return 'lib/${uri.substring('package:admin9_app_flutter/'.length)}';
  }
  if (!uri.startsWith('.')) return uri;
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

List<String> verifyPublicBarrel(File file) {
  final path = file.path.replaceAll('\\', '/');
  if (!file.existsSync()) return ['$path: public barrel is missing'];
  final result = parseString(content: file.readAsStringSync(), path: path);
  final exports = result.unit.directives
      .whereType<ExportDirective>()
      .map((directive) => directive.uri.stringValue)
      .whereType<String>()
      .toList();
  final exact =
      exports.toSet().containsAll(publicBarrelExports) &&
      publicBarrelExports.containsAll(exports) &&
      exports.length == publicBarrelExports.length;
  final forbiddenDirective = result.unit.directives.any(
    (directive) => directive is ImportDirective || directive is PartDirective,
  );
  final alteredExport = result.unit.directives.whereType<ExportDirective>().any(
    (directive) =>
        directive.combinators.isNotEmpty || directive.configurations.isNotEmpty,
  );
  if (!exact ||
      forbiddenDirective ||
      alteredExport ||
      result.unit.declarations.isNotEmpty) {
    return [
      '$path: public barrel exports are not the exact allowlist: '
          '${publicBarrelExports.toList()..sort()}',
    ];
  }
  return const <String>[];
}
