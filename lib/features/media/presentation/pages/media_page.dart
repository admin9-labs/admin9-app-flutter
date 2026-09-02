import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../app/routing/app_router.gr.dart';
import '../../../../shared/ui/responsive_page_body.dart';
import '../providers/media_scenario_provider.dart';

@RoutePage()
class MediaPage extends ConsumerWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(mediaScenarioRepositoryProvider).load();
    return Column(
      children: [
        FHeader(title: Text(context.tr('media.title'))),
        Expanded(
          child: ResponsivePageBody(
            safeAreaBottom: false,
            children: [
              Text(
                context.tr('media.description'),
                style: FTheme.of(context).typography.body.md,
              ),
              FItemGroup(
                children: [
                  FItem(
                    key: const ValueKey('media-open-article'),
                    prefix: const Icon(FLucideIcons.images),
                    title: Text(context.tr('media.images.title')),
                    subtitle: Text(catalog.article.summary),
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: () => context.pushRoute(
                      ArticleRoute(scenarioId: catalog.article.id),
                    ),
                  ),
                  FItem(
                    key: const ValueKey('media-open-video'),
                    prefix: const Icon(FLucideIcons.video),
                    title: Text(context.tr('media.video.title')),
                    subtitle: Text(context.tr('media.video.description')),
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: () => context.pushRoute(
                      VideoRoute(scenarioId: catalog.videos.first.id),
                    ),
                  ),
                  FItem(
                    key: const ValueKey('media-open-audio'),
                    prefix: const Icon(FLucideIcons.headphones),
                    title: Text(context.tr('media.audio.title')),
                    subtitle: Text(context.tr('media.audio.description')),
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: () => context.pushRoute(
                      AudioRoute(scenarioId: catalog.audio.first.id),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
