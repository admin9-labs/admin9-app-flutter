import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

const foundationTab = EmptyShellRoute('FoundationTab');
const formsTab = EmptyShellRoute('FormsTab');
const contentTab = EmptyShellRoute('ContentTab');
const feedbackTab = EmptyShellRoute('FeedbackTab');
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
        AutoRoute(
          page: foundationTab.page,
          path: 'foundation',
          initial: true,
          children: [
            AutoRoute(page: FoundationRoute.page, path: '', initial: true),
            AutoRoute(page: FoundationLayoutRoute.page, path: 'layout'),
            AutoRoute(page: FoundationNavigationRoute.page, path: 'navigation'),
            AutoRoute(
              page: FoundationInteractionRoute.page,
              path: 'interaction',
            ),
          ],
        ),
        AutoRoute(
          page: formsTab.page,
          path: 'forms',
          children: [
            AutoRoute(page: FormsRoute.page, path: '', initial: true),
            AutoRoute(page: ButtonsLabelsRoute.page, path: 'buttons-labels'),
            AutoRoute(page: TextInputRoute.page, path: 'text-input'),
            AutoRoute(page: TogglesGroupsRoute.page, path: 'toggles-groups'),
            AutoRoute(page: SelectRangeRoute.page, path: 'select-range'),
            AutoRoute(page: DateTimeRoute.page, path: 'date-time'),
          ],
        ),
        AutoRoute(
          page: contentTab.page,
          path: 'content',
          children: [
            AutoRoute(page: ContentRoute.page, path: '', initial: true),
            AutoRoute(page: ContentBasicsRoute.page, path: 'basics'),
            AutoRoute(page: AccordionRoute.page, path: 'accordion'),
            AutoRoute(page: CalendarRoute.page, path: 'calendar'),
            AutoRoute(page: LineCalendarRoute.page, path: 'line-calendar'),
            AutoRoute(page: ItemsAndTilesRoute.page, path: 'items-tiles'),
            AutoRoute(
              page: SelectableTilesRoute.page,
              path: 'selectable-tiles',
            ),
          ],
        ),
        AutoRoute(
          page: feedbackTab.page,
          path: 'feedback',
          children: [
            AutoRoute(page: FeedbackRoute.page, path: '', initial: true),
            AutoRoute(page: AlertsProgressRoute.page, path: 'alerts-progress'),
            AutoRoute(page: DialogsRoute.page, path: 'dialogs'),
            AutoRoute(page: SheetsRoute.page, path: 'sheets'),
            AutoRoute(page: PopoversRoute.page, path: 'popovers'),
            AutoRoute(page: ToastsTooltipsRoute.page, path: 'toasts-tooltips'),
          ],
        ),
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
