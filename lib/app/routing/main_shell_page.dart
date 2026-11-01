import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../page_configuration/page_configuration.dart';
import '../page_configuration/page_configuration_provider.dart';
import 'app_router.gr.dart';
import 'page_registry_page.dart';
import '../../shared/ui/loading_state_view.dart';
import 'main_destination.dart';

@RoutePage()
class MainShellPage extends ConsumerWidget {
  const MainShellPage({
    super.key,
    this.initialDestination = MainDestination.home,
  });

  final MainDestination initialDestination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(pageConfigurationProvider);
    return configuration.when(
      loading: () => FScaffold(
        child: LoadingStateView(label: context.tr('common.loading')),
      ),
      error: (error, stackTrace) => PageConfigurationError(message: '$error'),
      data: (configuration) => _ConfiguredShell(
        configuration: configuration,
        initialDestination: initialDestination,
      ),
    );
  }
}

class _ConfiguredShell extends StatefulWidget {
  const _ConfiguredShell({
    required this.configuration,
    required this.initialDestination,
  });

  final PageConfiguration configuration;
  final MainDestination initialDestination;

  @override
  State<_ConfiguredShell> createState() => _ConfiguredShellState();
}

class _ConfiguredShellState extends State<_ConfiguredShell> {
  bool _didSelectInitialDestination = false;

  @override
  Widget build(BuildContext context) {
    final entries = widget.configuration.visibleNavigation;
    final initialPageId = _pageIdFor(widget.initialDestination, entries);
    final homeIndex = entries.indexWhere(
      (entry) => entry.pageId == initialPageId,
    );
    return AutoTabsRouter(
      routes: [
        for (final entry in entries)
          PageConfigurationShellRoute(pageId: entry.pageId),
      ],
      homeIndex: homeIndex < 0 ? 0 : homeIndex,
      builder: (context, child) {
        final tabsRouter = context.tabsRouter;
        if (!_didSelectInitialDestination) {
          _didSelectInitialDestination = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                homeIndex >= 0 &&
                tabsRouter.activeIndex != homeIndex) {
              tabsRouter.setActiveIndex(homeIndex);
            }
          });
        }
        return FScaffold(
          childPad: false,
          footer: FBottomNavigationBar(
            index: tabsRouter.activeIndex,
            onChange: tabsRouter.setActiveIndex,
            children: [
              for (final entry in entries)
                FBottomNavigationBarItem(
                  icon: Icon(_navigationIcon(entry.icon)),
                  label: Text(entry.label, maxLines: 1),
                  semanticsLabel: entry.label,
                ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  String _pageIdFor(
    MainDestination destination,
    List<NavigationEntry> entries,
  ) {
    final preferred = switch (destination) {
      MainDestination.home => 'home',
      // examples:begin
      MainDestination.components => 'components',
      // examples:end
      MainDestination.media => 'media',
      MainDestination.settings => 'settings',
    };
    return entries
            .where((entry) => entry.pageType == preferred)
            .firstOrNull
            ?.pageId ??
        entries.first.pageId;
  }

  IconData _navigationIcon(String value) => switch (value) {
    'home' => FLucideIcons.house,
    'blocks' => FLucideIcons.blocks,
    'play' => FLucideIcons.play,
    'settings' => FLucideIcons.settings,
    'sliders-horizontal' => FLucideIcons.slidersHorizontal,
    _ => FLucideIcons.circleHelp,
  };
}
