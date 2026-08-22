import 'package:flutter/material.dart';

import '../admin9_ui.dart';
import '../ui/features/account/views/account_page.dart';
import '../ui/features/home/views/home_page.dart';

class Admin9Shell extends StatefulWidget {
  const Admin9Shell({super.key});

  @override
  State<Admin9Shell> createState() => _Admin9ShellState();
}

class _Admin9ShellState extends State<Admin9Shell> {
  int _selectedIndex = 0;

  static const _pages = [HomePage(), AccountPage()];
  static const _destinations = [
    AppNavigationDestination(
      label: '首页',
      icon: AppIconRole.home,
      selectedIcon: AppIconRole.homeSelected,
    ),
    AppNavigationDestination(
      label: '我的',
      icon: AppIconRole.account,
      selectedIcon: AppIconRole.accountSelected,
    ),
  ];

  void _selectDestination(int value) {
    if (value == _selectedIndex) return;
    setState(() => _selectedIndex = value);
  }

  @override
  Widget build(BuildContext context) {
    final body = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
    );
    final navigation = AppBottomNavigation(
      destinations: _destinations,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _selectDestination,
    );
    return Scaffold(body: body, bottomNavigationBar: navigation);
  }
}
