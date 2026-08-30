import 'dart:io';

import 'package:admin9_app_flutter/app/routing/app_router.dart';
import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses adaptive routes and declares the five mobile branches', () {
    final router = AppRouter();

    expect(router.defaultRouteType, const RouteType.adaptive());
    expect(router.guards, isEmpty);

    final shell = router.routes.singleWhere(
      (route) => route.name == StarterShellRoute.name,
    );
    expect(shell.path, '/');
    expect(shell.initial, isTrue);
    expect(shell.children?.map((route) => route.path), [
      'foundation',
      'forms',
      'content',
      'feedback',
      'settings',
    ]);
    expect(shell.children?.map((route) => route.name), [
      foundationTab.name,
      formsTab.name,
      contentTab.name,
      feedbackTab.name,
      settingsTab.name,
    ]);
  });

  test('route table has no guards or speculative media paths', () {
    final routes = _flatten(AppRouter().routes).toList();
    const forbiddenPaths = [
      'discover',
      'library',
      'article',
      'video',
      'live',
      'topic',
    ];

    expect(routes.expand((route) => route.guards), isEmpty);
    expect(
      routes.every(
        (route) => forbiddenPaths.every(
          (forbidden) => !route.path.contains(forbidden),
        ),
      ),
      isTrue,
    );
  });

  test(
    'App assembly declares no guard, observer, or deep-link customization',
    () {
      const forbidden = [
        'AutoRouteGuard',
        'AutoRouterObserver',
        'NavigatorObserver',
        'navigatorObservers',
        'DeepLink',
        'deepLinkBuilder',
        'deepLinkTransformer',
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
    },
  );
}

Iterable<AutoRoute> _flatten(Iterable<AutoRoute> routes) sync* {
  for (final route in routes) {
    yield route;
    if (route.children case final children?) {
      yield* _flatten(children);
    }
  }
}

List<File> _appDartSources() =>
    Directory('lib/app')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList()
      ..sort((left, right) => left.path.compareTo(right.path));
