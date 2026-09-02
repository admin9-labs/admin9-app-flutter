import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'app_router.gr.dart';
// examples:begin
import 'examples_routes.dart';
// examples:end
import 'media_routes.dart';

const homeTab = EmptyShellRoute('HomeTab');
const settingsTab = EmptyShellRoute('SettingsTab');

@AutoRouterConfig()
final class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: StartupGateRoute.page, path: '/', initial: true),
    CustomRoute(
      page: MainShellRoute.page,
      path: '/app',
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 120),
      transitionsBuilder: _mainShellTransition,
      children: [
        AutoRoute(
          page: homeTab.page,
          path: 'home',
          initial: true,
          children: [AutoRoute(page: HomeRoute.page, path: '', initial: true)],
        ),
        // examples:begin
        ...examplesRoutes,
        // examples:end
        ...mediaRoutes,
        AutoRoute(
          page: settingsTab.page,
          path: 'settings',
          children: [
            AutoRoute(page: SettingsRoute.page, path: '', initial: true),
          ],
        ),
      ],
    ),
    AutoRoute(page: ImageViewerRoute.page),
    AutoRoute(page: VideoFullscreenRoute.page),
    AutoRoute(page: LegalDocumentRoute.page, path: '/legal'),
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}

Widget _mainShellTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  if (MediaQuery.disableAnimationsOf(context)) return child;
  return FadeTransition(opacity: animation, child: child);
}
