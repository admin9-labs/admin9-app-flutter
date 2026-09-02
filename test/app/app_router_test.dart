import 'dart:io';

import 'package:admin9_app_flutter/app/routing/app_router.dart';
import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/app/routing/examples_routes.dart';
import 'package:admin9_app_flutter/app/routing/media_routes.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses adaptive routes and declares four MainShell branches', () {
    final router = AppRouter();

    expect(router.defaultRouteType, const RouteType.adaptive());
    expect(router.matcher.match('/'), isNotNull);
    expect(router.matcher.match('/app/home'), isNotNull);
    expect(router.matcher.match('/app/components'), isNotNull);
    expect(router.matcher.match('/app/media'), isNotNull);
    expect(router.matcher.match('/app/settings'), isNotNull);

    final startup = router.routes.singleWhere(
      (route) => route.name == StartupGateRoute.name,
    );
    expect(startup.path, '/');
    expect(startup.initial, isTrue);

    final shell = router.routes.singleWhere(
      (route) => route.name == MainShellRoute.name,
    );
    expect(shell.path, '/app');
    expect(shell.children?.map((route) => route.path), [
      'home',
      'components',
      'media',
      'settings',
    ]);
    expect(shell.children?.map((route) => route.name), [
      homeTab.name,
      componentsTab.name,
      mediaTab.name,
      settingsTab.name,
    ]);
    expect(examplesRoutes, hasLength(1));
    expect(
      _flatten(examplesRoutes).map((route) => route.path),
      containsAll([
        'forui/foundation',
        'forui/forms',
        'forui/content',
        'forui/feedback',
        'admin9/grid',
      ]),
    );
    expect(
      File('lib/app/routing/app_router.dart')
          .readAsStringSync()
          .split('...examplesRoutes')
          .length,
      2,
      reason: 'Examples must have exactly one AppRouter mount point.',
    );
  });

  test('route table has no guards or excluded speculative product paths', () {
    final routes = _flatten(AppRouter().routes).toList();
    const excludedPaths = ['discover', 'library', 'topic', 'upload', 'drm'];

    expect(routes.expand((route) => route.guards), isEmpty);
    expect(
      routes.every(
        (route) =>
            excludedPaths.every((excluded) => !route.path.contains(excluded)),
      ),
      isTrue,
    );
  });

  test('App deep links enter the startup gate without navigation in state', () {
    const forbidden = [
      'AutoRouteGuard',
      'AutoRouterObserver',
      'NavigatorObserver',
      'navigatorObservers',
    ];

    for (final file in _appDartSources()) {
      final source = file.readAsStringSync();
      for (final token in forbidden) {
        expect(
          source,
          isNot(contains(token)),
          reason: '${file.path} contains unapproved routing token $token.',
        );
      }
    }
    final app = File('lib/app/admin9_app.dart').readAsStringSync();
    final coordinator = File('lib/app/startup/startup_provider.dart')
        .readAsStringSync();
    expect(app, contains('deepLinkBuilder'));
    expect(app, contains('StartupGateRoute'));
    expect(coordinator, isNot(contains('auto_route')));
  });
}

Iterable<AutoRoute> _flatten(Iterable<AutoRoute> routes) sync* {
  for (final route in routes) {
    yield route;
    if (route.children case final children?) yield* _flatten(children);
  }
}

List<File> _appDartSources() =>
    Directory('lib/app')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList()
      ..sort((left, right) => left.path.compareTo(right.path));
