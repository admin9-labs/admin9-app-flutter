import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_catalog_tile.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.content.catalog.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: context.maybePop)],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'examples.content.catalog.section_title'.tr(),
          description: 'examples.content.catalog.showroom_description'.tr(),
          child: Column(
            spacing: 12,
            children: [
              _tile(
                context,
                icon: FLucideIcons.layoutDashboard,
                id: 'overview',
                title: 'examples.content.playgrounds.overview.title'.tr(),
                description: 'examples.content.catalog.overview_description'
                    .tr(),
                capabilitySummary:
                    'examples.content.catalog.overview_capabilities'.tr(),
                route: const OverviewPlaygroundRoute(),
              ),
              _tile(
                context,
                icon: FLucideIcons.calendarRange,
                id: 'calendar',
                title: 'examples.content.playgrounds.calendar.title'.tr(),
                description: 'examples.content.catalog.calendar_description'
                    .tr(),
                capabilitySummary:
                    'examples.content.catalog.calendar_capabilities'.tr(),
                route: const CalendarPlaygroundRoute(),
              ),
              _tile(
                context,
                icon: FLucideIcons.listTree,
                id: 'lists',
                title: 'examples.content.playgrounds.lists.title'.tr(),
                description: 'examples.content.catalog.lists_description'.tr(),
                capabilitySummary: 'examples.content.catalog.lists_capabilities'
                    .tr(),
                route: const ListsPlaygroundRoute(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

PlaygroundCatalogTile _tile(
  BuildContext context, {
  required IconData icon,
  required String id,
  required String title,
  required String description,
  required String capabilitySummary,
  required PageRouteInfo<void> route,
}) => PlaygroundCatalogTile(
  key: ValueKey('content-$id'),
  icon: icon,
  title: title,
  description: description,
  capabilitySummary: capabilitySummary,
  onPress: () => context.pushRoute(route),
);
