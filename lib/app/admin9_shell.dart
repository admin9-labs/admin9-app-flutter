import 'package:flutter/material.dart';

import '../core/theme/app_appearance.dart';
import '../core/theme/app_spacing.dart';
import '../core/widgets/live_stream_player.dart';
import '../ui/features/home/views/channel_h5_tab.dart';
import '../ui/features/home/views/home_page.dart';
import '../ui/features/live/views/live_page.dart';
import '../ui/features/mine/views/mine_page.dart';
import '../ui/features/report/views/report_page.dart';
import '../ui/features/services/views/services_page.dart';

class Admin9Shell extends StatefulWidget {
  const Admin9Shell({
    super.key,
    this.channelH5WebViewBuilder = ChannelH5Tab.defaultWebViewBuilder,
    this.liveStreamPlayerBuilder,
  });

  final ChannelH5WebViewBuilder channelH5WebViewBuilder;
  final LiveStreamPlayerBuilder? liveStreamPlayerBuilder;

  @override
  State<Admin9Shell> createState() => _Admin9ShellState();
}

class _Admin9ShellState extends State<Admin9Shell> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final _scrollToTopRequests = List<int>.filled(_sections.length, 0);

  static const _sections = [
    _BottomSection('首页', Icons.home_outlined, Icons.home),
    _BottomSection('直播', Icons.play_circle_outline, Icons.play_circle),
    _BottomSection('爆料', Icons.campaign_outlined, Icons.campaign),
    _BottomSection('服务', Icons.apps_outlined, Icons.apps),
    _BottomSection('我的', Icons.person_outline, Icons.person),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void handleStatusBarTap() {
    super.handleStatusBarTap();
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;

    setState(() {
      _scrollToTopRequests[_selectedIndex]++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      primary: false,
      backgroundColor: tokens.pageBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              key: const Key('admin9-shell-content'),
              width: _contentWidth(context),
              height: constraints.maxHeight,
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  HomePage(
                    scrollToTopRequest: _scrollToTopRequests[0],
                    channelH5WebViewBuilder: widget.channelH5WebViewBuilder,
                  ),
                  LivePage(
                    scrollToTopRequest: _scrollToTopRequests[1],
                    isPlaybackActive: _selectedIndex == 1,
                    streamPlayerBuilder: widget.liveStreamPlayerBuilder,
                  ),
                  ReportPage(scrollToTopRequest: _scrollToTopRequests[2]),
                  ServicesPage(scrollToTopRequest: _scrollToTopRequests[3]),
                  MinePage(scrollToTopRequest: _scrollToTopRequests[4]),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: SizedBox(
          key: const Key('admin9-shell-navigation'),
          width: _contentWidth(context),
          child: NavigationBar(
            height: AppSpacing.bottomNavHeight,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                if (_selectedIndex == index) {
                  _scrollToTopRequests[index]++;
                  return;
                }
                _selectedIndex = index;
              });
            },
            destinations: [
              for (final item in _sections)
                NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _contentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width > AppSpacing.contentMaxWidth
        ? AppSpacing.contentMaxWidth
        : width;
  }
}

class _BottomSection {
  const _BottomSection(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
