import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) =>
            setState(() => _selectedIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
