import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'app_router.gr.dart';
// examples:begin
import 'examples_routes.dart';
// examples:end
import 'media_routes.dart';

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
          page: PageConfigurationShellRoute.page,
          path: ':pageId',
          usesPathAsKey: true,
          children: [
            AutoRoute(page: PageRegistryRoute.page, path: '', initial: true),
            // examples:begin
            ...examplesRoutes,
            // examples:end
            ...mediaRoutes,
          ],
        ),
      ],
    ),
    AutoRoute(page: ImageViewerRoute.page),
    AutoRoute(page: VideoFullscreenRoute.page),
    AutoRoute(page: LegalDocumentRoute.page, path: '/legal'),
    AutoRoute(page: LoginRoute.page, path: '/auth/login'),
    AutoRoute(page: RegisterRoute.page, path: '/auth/register'),
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
