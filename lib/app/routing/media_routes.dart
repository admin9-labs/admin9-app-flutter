import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

final List<AutoRoute> mediaRoutes = [
  AutoRoute(page: ArticleRoute.page, path: 'article/:scenarioId'),
  AutoRoute(page: VideoRoute.page, path: 'video/:scenarioId'),
  AutoRoute(page: AudioRoute.page, path: 'audio/:scenarioId'),
];
