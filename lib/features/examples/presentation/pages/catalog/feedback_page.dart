import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_catalog_tile.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader(title: Text('examples.feedback.title'.tr())),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'examples.feedback.catalog.title'.tr(),
          description: 'examples.feedback.catalog.showroom_description'.tr(),
          child: Column(
            spacing: 12,
            children: [
              _tile(
                context,
                icon: FLucideIcons.refreshCw,
                id: 'async',
                title: 'examples.feedback.playgrounds.async.title'.tr(),
                description: 'examples.feedback.catalog.async_description'.tr(),
                capabilitySummary:
                    'examples.feedback.catalog.async_capabilities'.tr(),
                route: const AsyncStatusPlaygroundRoute(),
              ),
              _tile(
                context,
                icon: FLucideIcons.messageSquareWarning,
                id: 'confirmation',
                title: 'examples.feedback.playgrounds.confirmation.title'.tr(),
                description:
                    'examples.feedback.catalog.confirmation_description'.tr(),
                capabilitySummary:
                    'examples.feedback.catalog.confirmation_capabilities'.tr(),
                route: const ConfirmationPlaygroundRoute(),
              ),
              _tile(
                context,
                icon: FLucideIcons.messageCircleMore,
                id: 'contextual',
                title: 'examples.feedback.playgrounds.contextual.title'.tr(),
                description: 'examples.feedback.catalog.contextual_description'
                    .tr(),
                capabilitySummary:
                    'examples.feedback.catalog.contextual_capabilities'.tr(),
                route: const ContextualFeedbackPlaygroundRoute(),
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
  key: ValueKey('feedback-$id'),
  icon: icon,
  title: title,
  description: description,
  capabilitySummary: capabilitySummary,
  onPress: () => context.pushRoute(route),
);
