import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';
import 'examples_routes.dart';

const settingsTab = EmptyShellRoute('SettingsTab');

@AutoRouterConfig()
final class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: StarterShellRoute.page,
      path: '/',
      initial: true,
      children: [
        ...examplesTabRoutes,
        AutoRoute(
          page: settingsTab.page,
          path: 'settings',
          children: [
            AutoRoute(page: SettingsRoute.page, path: '', initial: true),
          ],
        ),
      ],
    ),
    RedirectRoute(path: '*', redirectTo: '/foundation'),
  ];
}
