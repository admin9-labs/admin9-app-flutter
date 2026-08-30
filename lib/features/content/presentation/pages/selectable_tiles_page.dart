import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class SelectableTilesPage extends StatelessWidget {
  const SelectableTilesPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('content.selectable_tiles.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'content.selectable_tiles.group.title'.tr(),
          description: 'content.selectable_tiles.group.description'.tr(),
          child: FSelectTileGroup<String>(
            control: const .managedRadio(initial: 'comfortable'),
            label: Text('content.selectable_tiles.group.label'.tr()),
            children: [
              FSelectTile<String>(
                title: Text('content.values.compact'.tr()),
                subtitle: Text(
                  'content.selectable_tiles.group.compact_description'.tr(),
                ),
                value: 'compact',
              ),
              FSelectTile<String>(
                title: Text('content.values.comfortable'.tr()),
                subtitle: Text(
                  'content.selectable_tiles.group.comfortable_description'.tr(),
                ),
                value: 'comfortable',
              ),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'content.selectable_tiles.menu.title'.tr(),
          description: 'content.selectable_tiles.menu.description'.tr(),
          child: FTileGroup(
            children: [
              FSelectMenuTile<String>(
                title: Text('content.selectable_tiles.menu.label'.tr()),
                prefix: const Icon(FLucideIcons.layoutGrid),
                selectControl: const .managedRadio(initial: 'list'),
                detailsBuilder: (_, values, _) =>
                    Text(switch (values.firstOrNull) {
                      'grid' => 'content.values.grid'.tr(),
                      _ => 'content.values.list'.tr(),
                    }),
                menu: [
                  FSelectTile<String>(
                    title: Text('content.values.list'.tr()),
                    value: 'list',
                  ),
                  FSelectTile<String>(
                    title: Text('content.values.grid'.tr()),
                    value: 'grid',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
