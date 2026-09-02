import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_catalog_tile.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class FormsPage extends StatelessWidget {
  const FormsPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.forms.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: context.maybePop)],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'examples.forms.catalog.title'.tr(),
          description: 'examples.forms.catalog.showroom_description'.tr(),
          child: Column(
            spacing: 12,
            children: [
              _tile(
                context,
                icon: FLucideIcons.mousePointerClick,
                id: 'buttons',
                title: 'examples.forms.playgrounds.buttons.title'.tr(),
                description: 'examples.forms.catalog.buttons_description'.tr(),
                capabilitySummary: 'examples.forms.catalog.buttons_capabilities'
                    .tr(),
                route: const ButtonsPlaygroundRoute(),
              ),
              _tile(
                context,
                icon: FLucideIcons.textCursorInput,
                id: 'text_input',
                title: 'examples.forms.playgrounds.text_input.title'.tr(),
                description: 'examples.forms.catalog.text_input_description'
                    .tr(),
                capabilitySummary:
                    'examples.forms.catalog.text_input_capabilities'.tr(),
                route: const TextInputPlaygroundRoute(),
              ),
              _tile(
                context,
                icon: FLucideIcons.listChecks,
                id: 'selection_controls',
                title: 'examples.forms.playgrounds.selection_controls.title'
                    .tr(),
                description:
                    'examples.forms.catalog.selection_controls_description'
                        .tr(),
                capabilitySummary:
                    'examples.forms.catalog.selection_controls_capabilities'
                        .tr(),
                route: const SelectionControlsPlaygroundRoute(),
              ),
              _tile(
                context,
                icon: FLucideIcons.listFilter,
                id: 'selects',
                title: 'examples.forms.playgrounds.selects.title'.tr(),
                description: 'examples.forms.catalog.selects_description'.tr(),
                capabilitySummary: 'examples.forms.catalog.selects_capabilities'
                    .tr(),
                route: const SelectsPlaygroundRoute(),
              ),
              _tile(
                context,
                icon: FLucideIcons.slidersHorizontal,
                id: 'value_controls',
                title: 'examples.forms.playgrounds.value_controls.title'.tr(),
                description: 'examples.forms.catalog.value_controls_description'
                    .tr(),
                capabilitySummary:
                    'examples.forms.catalog.value_controls_capabilities'.tr(),
                route: const ValueControlsPlaygroundRoute(),
              ),
              _tile(
                context,
                icon: FLucideIcons.calendarClock,
                id: 'scheduling',
                title: 'examples.forms.playgrounds.scheduling.title'.tr(),
                description: 'examples.forms.catalog.scheduling_description'
                    .tr(),
                capabilitySummary:
                    'examples.forms.catalog.scheduling_capabilities'.tr(),
                route: const SchedulingPlaygroundRoute(),
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
  key: ValueKey('forms-$id'),
  icon: icon,
  title: title,
  description: description,
  capabilitySummary: capabilitySummary,
  onPress: () => context.pushRoute(route),
);
