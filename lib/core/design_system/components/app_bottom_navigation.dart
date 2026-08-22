import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';
import '../foundation/app_design_tokens.dart';
import 'app_icon.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : assert(destinations.length >= 2 && destinations.length <= 5),
       assert(selectedIndex >= 0 && selectedIndex < destinations.length);

  final List<AppNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final tokens = AppDesignScope.of(context);
    return Material(
      color: tokens.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (final (index, destination) in destinations.indexed)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: selectedIndex == index,
                    label: destination.label,
                    onTap: () => onDestinationSelected(index),
                    child: ExcludeSemantics(
                      child: InkWell(
                        onTap: () => onDestinationSelected(index),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 56),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: tokens.space4,
                              vertical: tokens.space8,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  resolveAppIcon(
                                    selectedIndex == index
                                        ? destination.selectedIcon
                                        : destination.icon,
                                    platform,
                                  ),
                                  color: selectedIndex == index
                                      ? tokens.primary
                                      : tokens.onSurfaceContainer,
                                ),
                                SizedBox(height: tokens.space4),
                                Text(
                                  destination.label,
                                  textAlign: TextAlign.center,
                                  style: tokens.captionTextStyle.copyWith(
                                    color: selectedIndex == index
                                        ? tokens.primary
                                        : tokens.onSurfaceContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
