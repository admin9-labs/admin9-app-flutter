import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

const mediaTab = EmptyShellRoute('MediaTab');

final List<AutoRoute> mediaRoutes = [
  AutoRoute(
    page: mediaTab.page,
    path: 'media',
    children: [
      AutoRoute(page: MediaRoute.page, path: '', initial: true),
      AutoRoute(page: ArticleRoute.page, path: 'article/:scenarioId'),
      AutoRoute(page: VideoRoute.page, path: 'video/:scenarioId'),
      AutoRoute(page: AudioRoute.page, path: 'audio/:scenarioId'),
    ],
  ),
];
