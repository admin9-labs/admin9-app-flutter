import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

const foundationTab = EmptyShellRoute('FoundationTab');
const formsTab = EmptyShellRoute('FormsTab');
const contentTab = EmptyShellRoute('ContentTab');
const feedbackTab = EmptyShellRoute('FeedbackTab');

final List<AutoRoute> examplesTabRoutes = [
  AutoRoute(
    page: foundationTab.page,
    path: 'foundation',
    initial: true,
    children: [
      AutoRoute(page: FoundationRoute.page, path: '', initial: true),
      AutoRoute(page: ThemesRoute.page, path: 'concepts/themes'),
      AutoRoute(page: IconsRoute.page, path: 'reference/icons'),
      AutoRoute(
        page: AppShellPlaygroundRoute.page,
        path: 'playground/app-shell',
      ),
      AutoRoute(
        page: InteractionPlaygroundRoute.page,
        path: 'playground/interaction',
      ),
      AutoRoute(page: GridRoute.page, path: 'layout/grid'),
    ],
  ),
  AutoRoute(
    page: formsTab.page,
    path: 'forms',
    children: [
      AutoRoute(page: FormsRoute.page, path: '', initial: true),
      AutoRoute(page: ButtonsPlaygroundRoute.page, path: 'playground/buttons'),
      AutoRoute(
        page: TextInputPlaygroundRoute.page,
        path: 'playground/text-input',
      ),
      AutoRoute(
        page: SelectionControlsPlaygroundRoute.page,
        path: 'playground/selection-controls',
      ),
      AutoRoute(page: SelectsPlaygroundRoute.page, path: 'playground/selects'),
      AutoRoute(
        page: ValueControlsPlaygroundRoute.page,
        path: 'playground/value-controls',
      ),
      AutoRoute(
        page: SchedulingPlaygroundRoute.page,
        path: 'playground/scheduling',
      ),
    ],
  ),
  AutoRoute(
    page: contentTab.page,
    path: 'content',
    children: [
      AutoRoute(page: ContentRoute.page, path: '', initial: true),
      AutoRoute(
        page: OverviewPlaygroundRoute.page,
        path: 'playground/overview',
      ),
      AutoRoute(
        page: CalendarPlaygroundRoute.page,
        path: 'playground/calendar',
      ),
      AutoRoute(page: ListsPlaygroundRoute.page, path: 'playground/lists'),
    ],
  ),
  AutoRoute(
    page: feedbackTab.page,
    path: 'feedback',
    children: [
      AutoRoute(page: FeedbackRoute.page, path: '', initial: true),
      AutoRoute(
        page: AsyncStatusPlaygroundRoute.page,
        path: 'playground/status',
      ),
      AutoRoute(
        page: ConfirmationPlaygroundRoute.page,
        path: 'playground/confirmation',
      ),
      AutoRoute(
        page: ContextualFeedbackPlaygroundRoute.page,
        path: 'playground/contextual',
      ),
    ],
  ),
];
