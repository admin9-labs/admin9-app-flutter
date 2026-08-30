import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class ItemsAndTilesPage extends StatefulWidget {
  const ItemsAndTilesPage({super.key});

  @override
  State<ItemsAndTilesPage> createState() => _ItemsAndTilesPageState();
}

class _ItemsAndTilesPageState extends State<ItemsAndTilesPage> {
  String _statusKey = 'content.items_and_tiles.status.ready';

  void _setStatus(String key) => setState(() => _statusKey = key);

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('content.items_and_tiles.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        FAlert(
          title: Text('content.items_and_tiles.status.title'.tr()),
          subtitle: Text(_statusKey.tr()),
        ),
        ComponentExampleSection(
          title: 'content.items_and_tiles.items.title'.tr(),
          description: 'content.items_and_tiles.items.description'.tr(),
          child: FItemGroup(
            divider: FItemDivider.full,
            children: [
              FItem(
                prefix: const Icon(FLucideIcons.info),
                title: Text('content.items_and_tiles.items.primary'.tr()),
                subtitle: Text(
                  'content.items_and_tiles.items.primary_description'.tr(),
                ),
                details: Text('content.items_and_tiles.items.details'.tr()),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () =>
                    _setStatus('content.items_and_tiles.status.item_pressed'),
              ),
              FItem(
                enabled: false,
                prefix: const Icon(FLucideIcons.lock),
                title: Text('content.items_and_tiles.items.disabled'.tr()),
                subtitle: Text(
                  'content.items_and_tiles.items.disabled_description'.tr(),
                ),
              ),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'content.items_and_tiles.tiles.title'.tr(),
          description: 'content.items_and_tiles.tiles.description'.tr(),
          child: FTileGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.palette),
                title: Text('content.items_and_tiles.tiles.appearance'.tr()),
                subtitle: Text(
                  'content.items_and_tiles.tiles.appearance_description'.tr(),
                ),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () =>
                    _setStatus('content.items_and_tiles.status.tile_pressed'),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.bell),
                title: Text('content.items_and_tiles.tiles.notifications'.tr()),
                details: Text(
                  'content.items_and_tiles.tiles.notifications_details'.tr(),
                ),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => _setStatus(
                  'content.items_and_tiles.status.notification_pressed',
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
