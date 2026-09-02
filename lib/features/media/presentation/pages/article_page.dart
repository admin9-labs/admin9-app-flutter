import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../app/routing/app_router.gr.dart';
import '../../../../shared/ui/media/image_viewer/a_image_viewer_item.dart';
import '../../data/models/media_scenario.dart';
import '../providers/media_scenario_provider.dart';

@RoutePage()
class ArticlePage extends ConsumerWidget {
  const ArticlePage({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(mediaScenarioRepositoryProvider).load().article;
    if (article.id != scenarioId) {
      return Center(child: Text(context.tr('media.article.missing')));
    }
    final viewerItems = article.images.map(_viewerItem).toList(growable: false);
    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(article.title),
        prefixes: [FHeaderAction.back(onPress: context.maybePop)],
      ),
      child: ListView(
        key: const PageStorageKey('media-article-scroll'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(article.summary, style: FTheme.of(context).typography.body.lg),
          const SizedBox(height: 20),
          for (var index = 0; index < article.images.length; index++) ...[
            _ArticleImage(
              source: article.images[index],
              onPress: () => context.router.root.push(
                ImageViewerRoute(items: viewerItems, initialIndex: index),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article.paragraphs[index],
              style: FTheme.of(context).typography.body.md
                  .copyWith(height: 1.6),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

AImageViewerItem _viewerItem(MediaImageSource source) => switch (source.kind) {
  MediaImageKind.asset => AImageViewerItem.asset(
    assetName: source.location,
    semanticLabel: source.semanticLabel,
  ),
  MediaImageKind.network => AImageViewerItem.network(
    uri: Uri.parse(source.location),
    semanticLabel: source.semanticLabel,
  ),
};

class _ArticleImage extends StatelessWidget {
  const _ArticleImage({required this.source, required this.onPress});

  final MediaImageSource source;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.tr(
      'media.article.open_image',
      namedArgs: {'label': source.semanticLabel},
    ),
    child: GestureDetector(
      key: ValueKey('article-image-${source.location}'),
      behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: switch (source.kind) {
            MediaImageKind.asset => Image.asset(
              source.location,
              fit: BoxFit.cover,
              semanticLabel: source.semanticLabel,
            ),
            MediaImageKind.network => Image.network(
              source.location,
              fit: BoxFit.cover,
              semanticLabel: source.semanticLabel,
            ),
          },
        ),
      ),
    ),
  );
}
