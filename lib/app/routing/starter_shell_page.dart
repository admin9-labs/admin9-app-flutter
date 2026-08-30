import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class StarterShellPage extends StatelessWidget {
  const StarterShellPage({super.key});

  @override
  Widget build(BuildContext context) => AutoTabsRouter(
    homeIndex: 0,
    builder: (context, child) {
      final tabsRouter = context.tabsRouter;
      return FScaffold(
        childPad: false,
        footer: FBottomNavigationBar(
          index: tabsRouter.activeIndex,
          onChange: tabsRouter.setActiveIndex,
          children: [
            FBottomNavigationBarItem(
              icon: const Icon(FLucideIcons.blocks),
              label: Text(context.tr('navigation.foundation')),
            ),
            FBottomNavigationBarItem(
              icon: const Icon(FLucideIcons.listChecks),
              label: Text(context.tr('navigation.forms')),
            ),
            FBottomNavigationBarItem(
              icon: const Icon(FLucideIcons.layoutList),
              label: Text(context.tr('navigation.content')),
            ),
            FBottomNavigationBarItem(
              icon: const Icon(FLucideIcons.messageCircle),
              label: Text(context.tr('navigation.feedback')),
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
