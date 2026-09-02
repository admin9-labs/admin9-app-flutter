import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

const componentsTab = EmptyShellRoute('ComponentsTab');

final List<AutoRoute> examplesRoutes = [
  AutoRoute(
    page: componentsTab.page,
    path: 'components',
    children: [
      AutoRoute(page: ComponentsRoute.page, path: '', initial: true),
      AutoRoute(page: FoundationRoute.page, path: 'forui/foundation'),
      AutoRoute(
        page: ThemesRoute.page,
        path: 'forui/foundation/concepts/themes',
      ),
      AutoRoute(
        page: IconsRoute.page,
        path: 'forui/foundation/reference/icons',
      ),
      AutoRoute(
        page: AppShellPlaygroundRoute.page,
        path: 'forui/foundation/playground/app-shell',
      ),
      AutoRoute(
        page: InteractionPlaygroundRoute.page,
        path: 'forui/foundation/playground/interaction',
      ),
      AutoRoute(page: GridRoute.page, path: 'admin9/grid'),
      AutoRoute(page: FormsRoute.page, path: 'forui/forms'),
      AutoRoute(
        page: ButtonsPlaygroundRoute.page,
        path: 'forui/forms/playground/buttons',
      ),
      AutoRoute(
        page: TextInputPlaygroundRoute.page,
        path: 'forui/forms/playground/text-input',
      ),
      AutoRoute(
        page: SelectionControlsPlaygroundRoute.page,
        path: 'forui/forms/playground/selection-controls',
      ),
      AutoRoute(
        page: SelectsPlaygroundRoute.page,
        path: 'forui/forms/playground/selects',
      ),
      AutoRoute(
        page: ValueControlsPlaygroundRoute.page,
        path: 'forui/forms/playground/value-controls',
      ),
      AutoRoute(
        page: SchedulingPlaygroundRoute.page,
        path: 'forui/forms/playground/scheduling',
      ),
      AutoRoute(page: ContentRoute.page, path: 'forui/content'),
      AutoRoute(
        page: OverviewPlaygroundRoute.page,
        path: 'forui/content/playground/overview',
      ),
      AutoRoute(
        page: CalendarPlaygroundRoute.page,
        path: 'forui/content/playground/calendar',
      ),
      AutoRoute(
        page: ListsPlaygroundRoute.page,
        path: 'forui/content/playground/lists',
      ),
      AutoRoute(page: FeedbackRoute.page, path: 'forui/feedback'),
      AutoRoute(
        page: AsyncStatusPlaygroundRoute.page,
        path: 'forui/feedback/playground/status',
      ),
      AutoRoute(
        page: ConfirmationPlaygroundRoute.page,
        path: 'forui/feedback/playground/confirmation',
      ),
      AutoRoute(
        page: ContextualFeedbackPlaygroundRoute.page,
        path: 'forui/feedback/playground/contextual',
      ),
    ],
  ),
];
