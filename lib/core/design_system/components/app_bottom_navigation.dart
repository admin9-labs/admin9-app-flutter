import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';
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
    if (platform == TargetPlatform.iOS) {
      final scaler = MediaQuery.textScalerOf(context);
      final contentHeight = scaler.scale(24) + scaler.scale(10) + 12;
      return CupertinoTabBar(
        height: math.max(50, contentHeight),
        currentIndex: selectedIndex,
        onTap: onDestinationSelected,
        items: destinations
            .map(
              (destination) => BottomNavigationBarItem(
                icon: Icon(resolveAppIcon(destination.icon, platform)),
                activeIcon: Icon(
                  resolveAppIcon(destination.selectedIcon, platform),
                ),
                label: destination.label,
              ),
            )
            .toList(growable: false),
      );
    }
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations
          .map(
            (destination) => NavigationDestination(
              icon: Icon(resolveAppIcon(destination.icon, platform)),
              selectedIcon: Icon(
                resolveAppIcon(destination.selectedIcon, platform),
              ),
              label: destination.label,
            ),
          )
          .toList(growable: false),
    );
  }
}
