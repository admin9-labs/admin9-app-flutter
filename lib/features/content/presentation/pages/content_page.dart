import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/empty_state_view.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  bool _hasExample = false;

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader(title: Text('content.catalog.title'.tr())),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'content.catalog.section_title'.tr(),
          description: 'content.catalog.description'.tr(),
          child: FTileGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.layoutGrid),
                title: Text('content.catalog.basics.title'.tr()),
                subtitle: Text('content.catalog.basics.description'.tr()),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => context.pushRoute(const ContentBasicsRoute()),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.listCollapse),
                title: Text('content.catalog.accordion.title'.tr()),
                subtitle: Text('content.catalog.accordion.description'.tr()),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => context.pushRoute(const AccordionRoute()),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.calendarDays),
                title: Text('content.catalog.calendar.title'.tr()),
                subtitle: Text('content.catalog.calendar.description'.tr()),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => context.pushRoute(const CalendarRoute()),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.calendarRange),
                title: Text('content.catalog.line_calendar.title'.tr()),
                subtitle: Text(
                  'content.catalog.line_calendar.description'.tr(),
                ),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => context.pushRoute(const LineCalendarRoute()),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.listTree),
                title: Text('content.catalog.items_and_tiles.title'.tr()),
                subtitle: Text(
                  'content.catalog.items_and_tiles.description'.tr(),
                ),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => context.pushRoute(const ItemsAndTilesRoute()),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.listChecks),
                title: Text('content.catalog.selectable_tiles.title'.tr()),
                subtitle: Text(
                  'content.catalog.selectable_tiles.description'.tr(),
                ),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => context.pushRoute(const SelectableTilesRoute()),
              ),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'content.empty_state.section_title'.tr(),
          child: _hasExample
              ? FCard(
                  builder: (context, style, _) => Padding(
                    padding: style.padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text(
                          'content.empty_state.item_title'.tr(),
                          style: style.titleTextStyle,
                        ),
                        Text(
                          'content.empty_state.item_description'.tr(),
                          style: style.subtitleTextStyle,
                        ),
                        FButton(
                          variant: .outline,
                          mainAxisSize: MainAxisSize.min,
                          onPress: () => setState(() => _hasExample = false),
                          child: Text('content.empty_state.reset'.tr()),
                        ),
                      ],
                    ),
                  ),
                )
              : EmptyStateView(
                  title: 'content.empty_state.title'.tr(),
                  message: 'content.empty_state.message'.tr(),
                  actionLabel: 'content.empty_state.action'.tr(),
                  onAction: () => setState(() => _hasExample = true),
                ),
        ),
      ],
    ),
  );
}
