import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/app/routing/examples_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ledger = _ledgerRows();
  final registry = _registryRows();

  test('Forui 0.26.0 ledger contains every official capability once', () {
    expect(ledger, hasLength(72));
    expect(ledger.map((row) => row.id).toSet(), hasLength(72));
    expect(
      ledger.every(
        (row) =>
            row.axes.isNotEmpty &&
            row.target.isNotEmpty &&
            row.evidence.isNotEmpty,
      ),
      isTrue,
    );

    final official = _officialUrls();
    expect(official, hasLength(72));
    expect(ledger.map((row) => _normalize(row.url)).toSet(), official);
  });

  test('ledger coverage modes and widget totals match the mobile contract', () {
    const modes = {'direct', 'indirect', 'documented', 'excluded'};
    expect(ledger.every((row) => modes.contains(row.coverage)), isTrue);

    final widgets = ledger.where((row) => row.id.startsWith('W')).toList();
    expect(widgets, hasLength(57));
    expect(widgets.where((row) => row.coverage == 'direct'), hasLength(48));
    expect(widgets.where((row) => row.coverage == 'indirect'), hasLength(3));
    expect(widgets.where((row) => row.coverage == 'documented'), isEmpty);
    expect(widgets.where((row) => row.coverage == 'excluded'), hasLength(6));
  });

  test('17 Playgrounds join source, route, translation, test, and ledger', () {
    expect(registry, hasLength(17));
    expect(registry.map((row) => row.id).toSet(), hasLength(17));
    expect(registry.map((row) => row.route).toSet(), hasLength(17));

    final routes = _exampleRoutes();
    final translations = Map<String, dynamic>.from(
      jsonDecode(File('assets/translations/zh-CN.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final missing = <String>[];
    for (final row in registry) {
      final page = File('lib/features/examples/presentation/pages/${row.page}');
      if (!page.existsSync()) missing.add('${row.id}: page ${row.page}');
      if (routes[row.route] != _routeName(row.page)) {
        missing.add(
          '${row.id}: ${row.route} resolves to ${routes[row.route]}, '
          'expected ${_routeName(row.page)}',
        );
      }
      if (!translations.keys.any(
        (key) =>
            key == row.translationPrefix ||
            key.startsWith('${row.translationPrefix}.'),
      )) {
        missing.add('${row.id}: translation ${row.translationPrefix}');
      }
      if (!File(row.testPath).existsSync()) {
        missing.add('${row.id}: test ${row.testPath}');
      }
      for (final capability in row.capabilities) {
        final ledgerRow = ledger.where((entry) => entry.id == capability);
        if (ledgerRow.isEmpty) {
          missing.add('${row.id}: unknown capability $capability');
        } else if (_targetId(ledgerRow.single) != row.id) {
          missing.add('$capability: ledger does not target ${row.id}');
        }
      }
    }

    final registeredRoutes = registry.map((row) => row.route).toSet();
    final detailRoutes = routes.keys.toSet()
      ..removeAll({'/foundation', '/forms', '/content', '/feedback'});
    expect(detailRoutes, registeredRoutes);
    expect(missing, isEmpty, reason: missing.join('\n'));
  });

  test('direct and indirect capabilities have named focused evidence', () {
    final missing = <String>[];
    final registryById = {for (final row in registry) row.id: row};
    for (final row in ledger.where(
      (row) => row.coverage == 'direct' || row.coverage == 'indirect',
    )) {
      final targetId = _targetId(row);
      final playground = registryById[targetId];
      if (playground == null) {
        missing.add('${row.id}: unknown Playground $targetId');
        continue;
      }
      if (!playground.capabilities.contains(row.id)) {
        missing.add('${row.id}: absent from ${playground.id} mapping');
      }

      final testPaths = RegExp(r'`(test/[^`]+_test\.dart)`')
          .allMatches(row.evidence)
          .map((match) => match.group(1)!)
          .toList();
      if (testPaths.isEmpty) missing.add('${row.id}: test <missing>');
      for (final testPath in testPaths) {
        final testFile = File(testPath);
        if (!testFile.existsSync()) {
          missing.add('${row.id}: test $testPath');
          continue;
        }
        if (!RegExp(
          "(?:test|testWidgets)\\(\\s*['\"]"
          "[^'\"]*\\b${RegExp.escape(row.id)}\\b",
          multiLine: true,
        ).hasMatch(testFile.readAsStringSync())) {
          missing.add('${row.id}: no named test in $testPath');
        }
      }
    }

    expect(missing, isEmpty, reason: missing.join('\n'));
  });

  test(
    'removed component routes and shallow tests have no residual source',
    () {
      final generated = File('lib/app/routing/app_router.gr.dart')
          .readAsStringSync();
      for (final removed in [
        'AccordionRoute',
        'AlertsProgressRoute',
        'ButtonsLabelsRoute',
        'CalendarRoute',
        'ContentBasicsRoute',
        'DateTimeRoute',
        'DialogsRoute',
        'FoundationInteractionRoute',
        'FoundationLayoutRoute',
        'FoundationNavigationRoute',
        'ItemsAndTilesRoute',
        'LineCalendarRoute',
        'PopoversRoute',
        'SelectRangeRoute',
        'SelectableTilesRoute',
        'SheetsRoute',
        'TextInputRoute',
        'ToastsTooltipsRoute',
        'TogglesGroupsRoute',
      ]) {
        expect(generated, isNot(contains(removed)));
      }
      for (final removed in [
        'test/features/forms/forms_pages_test.dart',
        'test/features/content/content_pages_test.dart',
        'test/features/feedback/feedback_pages_test.dart',
        'test/features/foundation/foundation_pages_test.dart',
      ]) {
        expect(File(removed).existsSync(), isFalse);
      }
    },
  );
}

String _targetId(_LedgerRow row) =>
    RegExp(r'^`([^`]+)`$').firstMatch(row.target)!.group(1)!;

Set<String> _officialUrls() {
  final source = File(
    '.agents/skills/admin9-flutter-app/references/0.26.0/llms.txt',
  ).readAsStringSync();
  final body = source
      .split('## Concepts')
      .last
      .split('## Full Documentation')
      .first;
  return RegExp(r'https://forui\.dev/docs/[A-Za-z0-9_./-]+')
      .allMatches(body)
      .map((match) => _normalize(match.group(0)!))
      .toSet();
}

List<_LedgerRow> _ledgerRows() {
  final source = File('docs/starter.md').readAsStringSync();
  final body = source
      .split('<!-- forui-capability-ledger:start -->')
      .last
      .split('<!-- forui-capability-ledger:end -->')
      .first;
  return body
      .split('\n')
      .where((line) => RegExp(r'^\| [A-Z]+\d+ \|').hasMatch(line))
      .map((line) {
        final cells = _cells(line);
        final url = RegExp(r'\((https://forui\.dev/[^)]+)\)')
            .firstMatch(cells[1])!
            .group(1)!;
        return _LedgerRow(
          id: cells[0],
          url: url,
          axes: cells[2],
          target: cells[3],
          coverage: cells[4],
          evidence: cells[5],
        );
      })
      .toList();
}

List<_RegistryRow> _registryRows() {
  final source = File('docs/starter.md').readAsStringSync();
  final body = source
      .split('### Current Playground Registry')
      .last
      .split('### Current Capability Ledger')
      .first;
  return body.split('\n').where((line) => line.startsWith('| `')).map((line) {
    final cells = _cells(line);
    return _RegistryRow(
      id: _code(cells[0]),
      page: _code(cells[1]),
      route: _code(cells[2]),
      translationPrefix: _code(cells[3]),
      testPath: _code(cells[4]),
      capabilities: RegExp(r'[A-Z]+\d+')
          .allMatches(cells[5])
          .map((match) => match.group(0)!)
          .toSet(),
    );
  }).toList();
}

List<String> _cells(String line) => line
    .substring(1, line.length - 1)
    .split('|')
    .map((cell) => cell.trim())
    .toList();

String _code(String cell) => RegExp(r'`([^`]+)`').firstMatch(cell)!.group(1)!;

String _normalize(String url) => url.replaceFirst(RegExp(r'\.md$'), '');

Map<String, String> _exampleRoutes() => {
  for (final branch in examplesTabRoutes)
    for (final route in branch.children!)
      route.path.isEmpty ? '/${branch.path}' : '/${branch.path}/${route.path}':
          route.name,
};

String _routeName(String page) {
  final file = page.split('/').last.replaceFirst('_page.dart', '');
  final pageName = file
      .split('_')
      .map(
        (part) => '${part.substring(0, 1).toUpperCase()}${part.substring(1)}',
      )
      .join();
  return '${pageName}Route';
}

final class _LedgerRow {
  const _LedgerRow({
    required this.id,
    required this.url,
    required this.axes,
    required this.target,
    required this.coverage,
    required this.evidence,
  });

  final String id;
  final String url;
  final String axes;
  final String target;
  final String coverage;
  final String evidence;
}

final class _RegistryRow {
  const _RegistryRow({
    required this.id,
    required this.page,
    required this.route,
    required this.translationPrefix,
    required this.testPath,
    required this.capabilities,
  });

  final String id;
  final String page;
  final String route;
  final String translationPrefix;
  final String testPath;
  final Set<String> capabilities;
}
