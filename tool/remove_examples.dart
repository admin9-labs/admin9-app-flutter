import 'dart:convert';
import 'dart:io';

const _blockFiles = [
  'lib/app/routing/app_router.dart',
  'lib/app/routing/main_destination.dart',
  'lib/app/routing/main_shell_page.dart',
  'lib/app/routing/startup_gate_page.dart',
  'lib/app/startup/startup_state.dart',
  'lib/features/home/presentation/pages/home_page.dart',
];

const _deletePaths = [
  'lib/features/examples',
  'lib/app/routing/examples_routes.dart',
  'test/features/examples',
  'test/features/settings/theme_workbench_test.dart',
  'test/shared/ui/layout/grid/grid_page_test.dart',
  'test/acceptance/mobile_starter_acceptance_test.dart',
  'integration_test/showroom_screenshot_test.dart',
];

const _begin = '// examples:begin';
const _end = '// examples:end';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1 ||
      (arguments.single != '--check' && arguments.single != '--apply')) {
    stderr.writeln('Usage: dart run tool/remove_examples.dart --check|--apply');
    exitCode = 64;
    return;
  }
  _requireRepositoryRoot();
  if (!Directory('lib/features/examples').existsSync()) {
    stdout.writeln('Examples is already removed.');
    return;
  }
  final problems = _preflight();
  if (problems.isNotEmpty) {
    for (final problem in problems) {
      stderr.writeln(problem);
    }
    exitCode = 1;
    return;
  }
  if (arguments.single == '--check') {
    stdout.writeln('Examples removal preflight passed.');
    for (final path in _deletePaths) {
      stdout.writeln('delete: $path');
    }
    return;
  }

  for (final path in _blockFiles) {
    _stripOwnedBlocks(File(path));
  }
  _removeTranslations();
  _moveStartupFixtureToMedia();
  _writeDerivedRouterTest();
  _writeDerivedNavigationTest();
  _writeDerivedStarterDocument();
  _updateDerivedDocuments();
  for (final path in _deletePaths) {
    _delete(path);
  }
  final generated = File('lib/app/routing/app_router.gr.dart');
  if (generated.existsSync()) generated.deleteSync();

  await _run('flutter', ['pub', 'get', '--enforce-lockfile']);
  await _run('dart', ['format', 'lib', 'test', 'integration_test', 'tool']);
  await _run('dart', ['run', 'build_runner', 'build']);
  await _run('flutter', ['analyze']);
  await _run('flutter', ['test']);
  await _run('dart', ['run', 'tool/check_markdown_links.dart']);
  await _run('git', ['diff', '--check']);
  stdout.writeln('Examples removed and the derived App baseline verified.');
}

void _requireRepositoryRoot() {
  if (!File('pubspec.yaml').existsSync() ||
      !File('lib/app/admin9_app.dart').existsSync()) {
    stderr.writeln('Run this command from the repository root.');
    exit(64);
  }
}

List<String> _preflight() {
  final problems = <String>[];
  for (final path in _blockFiles) {
    final file = File(path);
    if (!file.existsSync()) {
      problems.add('Missing integration file: $path');
      continue;
    }
    final text = file.readAsStringSync();
    final begins = _count(text, _begin);
    final ends = _count(text, _end);
    if (begins == 0 || begins != ends) {
      problems.add('Unbalanced Examples ownership markers: $path');
    }
  }
  for (final path in [
    'docs/product-startup-flow.md',
    'lib/features/media',
    'lib/features/settings',
    'lib/shared/ui/layout/grid',
  ]) {
    if (!FileSystemEntity.typeSync(path).isPresent) {
      problems.add('Protected App baseline is missing: $path');
    }
  }
  return problems;
}

int _count(String text, String token) => token.allMatches(text).length;

void _stripOwnedBlocks(File file) {
  final output = <String>[];
  var skipping = false;
  for (final line in file.readAsLinesSync()) {
    if (line.trim() == _begin) {
      if (skipping) {
        throw StateError('Nested Examples marker in ${file.path}');
      }
      skipping = true;
      continue;
    }
    if (line.trim() == _end) {
      if (!skipping) {
        throw StateError('Unexpected Examples end in ${file.path}');
      }
      skipping = false;
      continue;
    }
    if (!skipping) output.add(line);
  }
  if (skipping) throw StateError('Unclosed Examples marker in ${file.path}');
  file.writeAsStringSync('${output.join('\n')}\n');
}

void _removeTranslations() {
  final file = File('assets/translations/zh-CN.json');
  final source = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  source.removeWhere(
    (key, _) =>
        key.startsWith('examples.') ||
        key.startsWith('components.') ||
        key.startsWith('home.components_') ||
        key == 'navigation.components' ||
        key == 'home.showroom' ||
        key == 'home.showroom_body',
  );
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(source)}\n',
  );
}

void _moveStartupFixtureToMedia() {
  final fixture = File('test/fixtures/startup_ad/campaign.json');
  final json = jsonDecode(fixture.readAsStringSync()) as Map<String, dynamic>;
  final action = json['action']! as Map<String, dynamic>;
  if (action['routeKey'] == 'components') action['routeKey'] = 'media';
  fixture.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  final test = File('test/features/startup_ad/startup_ad_campaign_test.dart');
  test.writeAsStringSync(
    test.readAsStringSync().replaceAll(
      "expect(campaign?.action.routeKey, 'components');",
      "expect(campaign?.action.routeKey, 'media');",
    ),
  );
}

void _delete(String path) {
  final type = FileSystemEntity.typeSync(path);
  if (type == FileSystemEntityType.directory) {
    Directory(path).deleteSync(recursive: true);
  } else if (type == FileSystemEntityType.file) {
    File(path).deleteSync();
  }
}

void _writeDerivedRouterTest() {
  File('test/app/app_router_test.dart').writeAsStringSync(
    r'''import 'package:admin9_app_flutter/app/routing/app_router.dart';
import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/app/routing/media_routes.dart';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('derived App retains startup and three MainShell branches', () {
    final router = AppRouter();
    expect(router.defaultRouteType, const RouteType.adaptive());
    expect(router.matcher.match('/'), isNotNull);
    expect(router.matcher.match('/app/home'), isNotNull);
    expect(router.matcher.match('/app/media'), isNotNull);
    expect(router.matcher.match('/app/settings'), isNotNull);
    final shell = router.routes.singleWhere(
      (route) => route.name == MainShellRoute.name,
    );
    expect(shell.children?.map((route) => route.path), [
      'home',
      'media',
      'settings',
    ]);
    expect(shell.children?.map((route) => route.name), [
      homeTab.name,
      mediaTab.name,
      settingsTab.name,
    ]);
    expect(
      File('lib/app/routing/app_router.gr.dart').readAsStringSync(),
      isNot(contains('ComponentsRoute')),
    );
  });
}
''',
  );
}

void _writeDerivedNavigationTest() {
  File('test/app/app_navigation_test.dart').writeAsStringSync(r'''import 'package:admin9_app_flutter/features/home/presentation/pages/home_page.dart';
import 'package:admin9_app_flutter/features/media/presentation/pages/media_page.dart';
import 'package:admin9_app_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'support/test_admin9_app.dart';

void main() {
  testWidgets('derived App starts three retained destinations', (tester) async {
    await pumpTestAdmin9App(tester);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(FBottomNavigationBarItem), findsNWidgets(3));
    final navigation = find.byType(FBottomNavigationBar);
    for (final label in ['首页', '媒体', '设置']) {
      expect(
        find.descendant(of: navigation, matching: find.text(label)),
        findsOneWidget,
      );
    }
    await tester.tap(
      find.descendant(of: navigation, matching: find.text('媒体')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MediaPage), findsOneWidget);
    await tester.tap(
      find.descendant(of: navigation, matching: find.text('设置')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
  });
}
''');
}

void _writeDerivedStarterDocument() {
  File('docs/starter.md').writeAsStringSync('''# Upstream Starter Reference

The removable Examples Feature has been removed from this derived App.
Startup, Home, Media, Settings, Legal, Theme, persistence, AGrid, and
AImageViewer remain part of the App baseline. Product-specific authority
belongs in this derived repository.
''');
}

void _updateDerivedDocuments() {
  _replace(
    'README.md',
    'Four persistent destinations: Home, Components, Media, and Settings.',
    'Three persistent destinations: Home, Media, and Settings.',
  );
  _replace('docs/product.md', '      |-- Components\n', '');
  _replace(
    'docs/product.md',
    'Components contains the removable Examples Feature. Media and Settings are\nordinary App Features and remain when Examples is removed.',
    'The removable Examples Feature is absent. Media and Settings are ordinary\nApp Features alongside Home.',
  );
}

void _replace(String path, String from, String to) {
  final file = File(path);
  final source = file.readAsStringSync();
  if (!source.contains(from)) {
    throw StateError('Expected derivation text is missing from $path');
  }
  file.writeAsStringSync(source.replaceFirst(from, to));
}

Future<void> _run(String executable, List<String> arguments) async {
  stdout.writeln('\$ $executable ${arguments.join(' ')}');
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  final code = await process.exitCode;
  if (code != 0) {
    throw ProcessException(executable, arguments, 'Command failed', code);
  }
}

extension on FileSystemEntityType {
  bool get isPresent => this != FileSystemEntityType.notFound;
}
