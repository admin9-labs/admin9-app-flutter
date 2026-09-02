import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'main_destination.dart';

@RoutePage()
class MainShellPage extends StatefulWidget {
  const MainShellPage({
    super.key,
    this.initialDestination = MainDestination.home,
  });

  final MainDestination initialDestination;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  bool _didSelectInitialDestination = false;

  @override
  Widget build(BuildContext context) => AutoTabsRouter(
    homeIndex: widget.initialDestination.index,
    builder: (context, child) {
      final tabsRouter = context.tabsRouter;
      if (!_didSelectInitialDestination) {
        _didSelectInitialDestination = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              tabsRouter.activeIndex != widget.initialDestination.index) {
            tabsRouter.setActiveIndex(widget.initialDestination.index);
          }
        });
      }
      return FScaffold(
        childPad: false,
        footer: FBottomNavigationBar(
          index: tabsRouter.activeIndex,
          onChange: tabsRouter.setActiveIndex,
          children: [
            FBottomNavigationBarItem(
              icon: const Icon(FLucideIcons.house),
              label: Text(context.tr('navigation.home')),
            ),
            // examples:begin
            FBottomNavigationBarItem(
              icon: const Icon(FLucideIcons.blocks),
              label: Text(context.tr('navigation.components')),
            ),
            // examples:end
            FBottomNavigationBarItem(
              icon: const Icon(FLucideIcons.play),
              label: Text(context.tr('navigation.media')),
            ),
            FBottomNavigationBarItem(
              icon: const Icon(FLucideIcons.settings),
              label: Text(context.tr('navigation.settings')),
            ),
          ],
        ),
        child: child,
      );
    },
  );
}
