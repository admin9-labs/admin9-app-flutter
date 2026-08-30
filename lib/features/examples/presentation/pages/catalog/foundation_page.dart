import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_catalog_tile.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class FoundationPage extends StatelessWidget {
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader(title: Text('examples.foundation.title'.tr())),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'examples.foundation.catalog.title'.tr(),
          description: 'examples.foundation.catalog.showroom_description'.tr(),
          child: Column(
            spacing: 12,
            children: [
              PlaygroundCatalogTile(
                key: const ValueKey('foundation-themes'),
                icon: FLucideIcons.palette,
                title: 'examples.foundation.concepts.themes.title'.tr(),
                description: 'examples.foundation.catalog.themes_description'
                    .tr(),
                capabilitySummary:
                    'examples.foundation.catalog.themes_capabilities'.tr(),
                onPress: () => context.pushRoute(const ThemesRoute()),
              ),
              PlaygroundCatalogTile(
                key: const ValueKey('foundation-icons'),
                icon: FLucideIcons.shapes,
                title: 'examples.foundation.reference.icons.title'.tr(),
                description: 'examples.foundation.catalog.icons_description'
                    .tr(),
                capabilitySummary:
                    'examples.foundation.catalog.icons_capabilities'.tr(),
                onPress: () => context.pushRoute(const IconsRoute()),
              ),
              PlaygroundCatalogTile(
                key: const ValueKey('foundation-app-shell'),
                icon: FLucideIcons.panelTop,
                title: 'examples.foundation.playgrounds.app_shell.title'.tr(),
                description: 'examples.foundation.catalog.app_shell_description'
                    .tr(),
                capabilitySummary:
                    'examples.foundation.catalog.app_shell_capabilities'.tr(),
                onPress: () =>
                    context.pushRoute(const AppShellPlaygroundRoute()),
              ),
              PlaygroundCatalogTile(
                key: const ValueKey('foundation-interaction'),
                icon: FLucideIcons.mousePointerClick,
                title: 'examples.foundation.playgrounds.interaction.title'.tr(),
                description:
                    'examples.foundation.catalog.interaction_description'.tr(),
                capabilitySummary:
                    'examples.foundation.catalog.interaction_capabilities'.tr(),
                onPress: () =>
                    context.pushRoute(const InteractionPlaygroundRoute()),
              ),
              PlaygroundCatalogTile(
                key: const ValueKey('foundation-grid'),
                icon: FLucideIcons.layoutGrid,
                title: 'examples.foundation.layout.grid.title'.tr(),
                description: 'examples.foundation.catalog.grid_description'
                    .tr(),
                capabilitySummary:
                    'examples.foundation.catalog.grid_capabilities'.tr(),
                onPress: () => context.pushRoute(const GridRoute()),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
