import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

// examples:begin
import '../../features/examples/presentation/pages/components_page.dart';
// examples:end
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/media/presentation/pages/media_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../page_configuration/page_configuration.dart';
import '../page_configuration/page_configuration_provider.dart';

@RoutePage(name: 'PageRegistryRoute')
class PageRegistryPage extends ConsumerWidget {
  const PageRegistryPage({
    @PathParam.inherit('pageId') required this.pageId,
    super.key,
  });

  final String pageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(pageConfigurationProvider)
      .when(
        loading: () => const Center(child: FCircularProgress()),
        error: (error, _) => PageConfigurationError(message: '$error'),
        data: (configuration) {
          final definition = configuration.page(pageId);
          if (definition == null) {
            return PageConfigurationError(
              message: context.tr(
                'page_configuration.unknown_page',
                args: [pageId],
              ),
            );
          }
          final settingsIndex = configuration.visibleNavigation.indexWhere(
            (entry) => entry.pageType == 'settings',
          );
          return Column(
            children: [
              if (definition.showTitle)
                FHeader(
                  title: Text(definition.title),
                  suffixes: [
                    if (definition.actions.contains('open_settings') &&
                        settingsIndex >= 0)
                      FHeaderAction(
                        icon: const Icon(FLucideIcons.settings),
                        semanticsLabel: context.tr('home.open_settings'),
                        onPress: () =>
                            context.tabsRouter.setActiveIndex(settingsIndex),
                      ),
                  ],
                ),
              Expanded(
                child: definition.tabs.isEmpty
                    ? _page(definition)
                    : FTabs(
                        key: ValueKey(pageId),
                        expands: true,
                        scrollable: true,
                        children: [
                          for (final tab in definition.tabs)
                            FTabEntry.entry(
                              label: Text(tab.label),
                              child: _page(definition.forTab(tab)),
                            ),
                        ],
                      ),
              ),
            ],
          );
        },
      );

  Widget _page(PageDefinition definition) => switch (definition.pageType) {
    'home' => HomePage(showHeader: false, definition: definition),
    'settings' => SettingsPage(showHeader: false, definition: definition),
    // examples:begin
    'components' =>
      definition.shows('content')
          ? const ComponentsPage(showHeader: false)
          : const SizedBox.shrink(),
    // examples:end
    'media' =>
      definition.shows('content')
          ? const MediaPage(showHeader: false)
          : const SizedBox.shrink(),
    _ => _EmptyPage(visible: definition.shows('content')),
  };
}

class _EmptyPage extends StatelessWidget {
  const _EmptyPage({required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) => visible
      ? Center(child: Text(context.tr('page_configuration.empty')))
      : const SizedBox.shrink();
}

class PageConfigurationError extends StatelessWidget {
  const PageConfigurationError({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) => FScaffold(
    header: FHeader(title: Text(context.tr('page_configuration.error_title'))),
    child: SingleChildScrollView(
      child: Text('${context.tr('page_configuration.error_body')}\n$message'),
    ),
  );
}
