import 'package:flutter/material.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';
import 'app_search_entry.dart';
import 'app_tab_bar.dart';
import 'top_level_page_scaffold.dart';

typedef TopLevelSurfaceBuilder =
    PageSurface Function(BuildContext context, TabController? controller);

typedef TopLevelChromeBackgroundBuilder =
    TopLevelChromeBackground Function(
      BuildContext context,
      TabController? controller,
    );

typedef TopLevelPlainSliverBuilder =
    List<Widget> Function(BuildContext context);

typedef TopLevelTabContentBuilder =
    Widget Function(BuildContext context, ScrollController? controller);

typedef TopLevelTabColorBuilder =
    Color? Function(BuildContext context, TabController controller);

/// Shared shell configuration for the app's fixed top-level tab pages.
///
/// This keeps the current five-section prototype consistent; keep business
/// special cases inside feature pages instead of turning this into a general
/// page DSL.
class TopLevelPageConfig {
  const TopLevelPageConfig({
    required this.title,
    required this.surfaceBuilder,
    this.chromeBackgroundBuilder,
    this.mode = TopLevelPageScaffoldMode.scrollEdgeTitle,
    this.scrollEdgeTitleBehavior =
        TopLevelScrollEdgeTitleBehavior.revealOnScroll,
    this.scrollEdgeTitleAlignment = TopLevelScrollEdgeTitleAlignment.leading,
    this.scrollEdgeTitleBarEnabled = true,
    this.reserveToolbarSlot,
    this.actions = const [],
    this.search,
    this.tabs,
    this.plainSliversBuilder,
    this.onScrollToTop,
    this.onTabChanged,
  }) : assert(
         (tabs == null) != (plainSliversBuilder == null),
         'Configure either tabs or plain slivers, but not both.',
       );

  final String title;
  final TopLevelSurfaceBuilder surfaceBuilder;
  final TopLevelChromeBackgroundBuilder? chromeBackgroundBuilder;
  final TopLevelPageScaffoldMode mode;
  final TopLevelScrollEdgeTitleBehavior scrollEdgeTitleBehavior;
  final TopLevelScrollEdgeTitleAlignment scrollEdgeTitleAlignment;
  final bool scrollEdgeTitleBarEnabled;
  final bool? reserveToolbarSlot;
  final List<Widget> actions;
  final TopLevelSearchConfig? search;
  final TopLevelTabConfig? tabs;
  final TopLevelPlainSliverBuilder? plainSliversBuilder;
  final Future<void> Function()? onScrollToTop;
  final ValueChanged<int>? onTabChanged;
}

class TopLevelSearchConfig {
  const TopLevelSearchConfig({
    required this.key,
    required this.placeholder,
    required this.onTap,
  });

  final Key key;
  final String placeholder;
  final VoidCallback onTap;
}

class TopLevelTabConfig {
  const TopLevelTabConfig({
    required this.tabs,
    required this.headerKey,
    required this.barKey,
    required this.viewportSliverKey,
    required this.viewportKey,
    required this.viewKey,
    this.trailing,
    this.rhythmPaddingKey,
    this.isScrollable = true,
    this.tabAlignment = TabAlignment.start,
    this.newsStyle = false,
    this.overlayColor,
    this.selectedColorBuilder,
  }) : assert(tabs.length > 0, 'Top-level tab pages need at least one tab.');

  final List<TopLevelTabItem> tabs;
  final Key headerKey;
  final Key barKey;
  final Key viewportSliverKey;
  final Key viewportKey;
  final Key viewKey;
  final Widget? trailing;
  final Key? rhythmPaddingKey;
  final bool isScrollable;
  final TabAlignment tabAlignment;
  final bool newsStyle;
  final WidgetStateProperty<Color?>? overlayColor;
  final TopLevelTabColorBuilder? selectedColorBuilder;
}

class TopLevelTabItem {
  const TopLevelTabItem({
    required this.id,
    required this.label,
    required this.builder,
    this.controller,
  });

  final String id;
  final String label;
  final TopLevelTabContentBuilder builder;
  final ScrollController? controller;
}

class ConfiguredTopLevelPage extends StatefulWidget {
  const ConfiguredTopLevelPage({
    super.key,
    required this.config,
    this.scrollToTopRequest = 0,
    this.controller,
    this.tabController,
    this.initialTabIndex = 0,
  });

  final TopLevelPageConfig config;
  final int scrollToTopRequest;
  final ScrollController? controller;
  final TabController? tabController;
  final int initialTabIndex;

  @override
  State<ConfiguredTopLevelPage> createState() => _ConfiguredTopLevelPageState();
}

class _ConfiguredTopLevelPageState extends State<ConfiguredTopLevelPage>
    with TickerProviderStateMixin {
  late final ScrollController _fallbackController;
  TabController? _tabController;
  String _tabSignature = '';
  var _selectedIndex = 0;

  ScrollController get _controller => widget.controller ?? _fallbackController;

  @override
  void initState() {
    super.initState();
    _fallbackController = ScrollController();
    _selectedIndex = widget.tabController?.index ?? widget.initialTabIndex;
    widget.tabController?.addListener(_handleTabControllerChange);
  }

  @override
  void didUpdateWidget(covariant ConfiguredTopLevelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabController != widget.tabController) {
      oldWidget.tabController?.removeListener(_handleTabControllerChange);
      if (widget.tabController != null) {
        _disposeInternalTabController();
        _selectedIndex = widget.tabController!.index;
      } else {
        _selectedIndex = oldWidget.tabController?.index ?? _selectedIndex;
      }
      widget.tabController?.addListener(_handleTabControllerChange);
    }
    final tabCount = widget.config.tabs?.tabs.length ?? 0;
    if (tabCount > 0) {
      _selectedIndex = _selectedIndex.clamp(0, tabCount - 1);
    }
  }

  @override
  void dispose() {
    widget.tabController?.removeListener(_handleTabControllerChange);
    _disposeInternalTabController();
    _fallbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.config.tabs;
    final controller = tabs == null ? null : _ensureTabController(tabs);

    if (controller != null) {
      return AnimatedBuilder(
        animation: controller.animation ?? controller,
        builder: (context, child) => _buildScaffold(context, controller),
      );
    }

    return _buildScaffold(context, null);
  }

  Widget _buildScaffold(BuildContext context, TabController? tabController) {
    final config = widget.config;
    final surface = config.surfaceBuilder(context, tabController);
    final chromeBackground = config.chromeBackgroundBuilder?.call(
      context,
      tabController,
    );
    final resolvedSurface = surface.resolve(context);
    final foreground = TopLevelChromeForeground.resolve(
      context,
      resolvedSurface,
    );
    final reserveToolbarSlot = _reservesToolbarSlot(config);
    final toolbarSlotReserved = _reservesScaffoldToolbarSlot(
      config,
      reserveToolbarSlot: reserveToolbarSlot,
    );
    final hasPinnedTabs = config.tabs != null;

    return TopLevelPageScaffold(
      title: config.title,
      mode: config.mode,
      scrollEdgeTitleBehavior: config.scrollEdgeTitleBehavior,
      scrollEdgeTitleAlignment: config.scrollEdgeTitleAlignment,
      scrollEdgeTitleBarEnabled: config.scrollEdgeTitleBarEnabled,
      reserveToolbarSlot: reserveToolbarSlot,
      actions: config.actions,
      toolbar: _buildSearchToolbar(context, config.search, foreground),
      chromeBackground:
          chromeBackground ?? const TopLevelChromeBackground.transparent(),
      backdropCanvasHeightBuilder: (context) => topLevelBackdropChromeHeight(
        topPadding: MediaQuery.paddingOf(context).top,
        reserveToolbarSlot: toolbarSlotReserved,
        includePinnedChannels: hasPinnedTabs,
      ),
      scrollToTopRequest: widget.scrollToTopRequest,
      onScrollToTop: () => _scrollToTop(tabController),
      controller: _controller,
      surface: surface,
      slivers: _buildSlivers(context, foreground, tabController),
    );
  }

  bool _reservesScaffoldToolbarSlot(
    TopLevelPageConfig config, {
    required bool reserveToolbarSlot,
  }) {
    final showsToolbarControls =
        config.scrollEdgeTitleBarEnabled &&
        (config.mode == TopLevelPageScaffoldMode.scrollEdgeTitle ||
            config.search != null);
    return showsToolbarControls || reserveToolbarSlot;
  }

  bool _reservesToolbarSlot(TopLevelPageConfig config) {
    final explicit = config.reserveToolbarSlot;
    if (explicit != null) return explicit;

    if (config.scrollEdgeTitleBarEnabled) {
      return config.mode == TopLevelPageScaffoldMode.scrollEdgeTitle ||
          config.search != null ||
          config.actions.isNotEmpty;
    }

    return config.tabs != null;
  }

  Widget? _buildSearchToolbar(
    BuildContext context,
    TopLevelSearchConfig? search,
    TopLevelChromeForeground foreground,
  ) {
    if (search == null) return null;

    final darkFactor = foreground.darkFactor;
    final backgroundColor = Colors.white.withValues(
      alpha: _lerp(0.50, 0.10, darkFactor),
    );
    final borderColor = Colors.white.withValues(
      alpha: _lerp(0.30, 0.14, darkFactor),
    );
    final blurSigma = _lerp(8.0, 0.0, darkFactor);

    return Center(
      child: AppSearchEntry(
        key: search.key,
        placeholder: search.placeholder,
        onTap: search.onTap,
        height: 40,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        foregroundColor: foreground.search,
        blurSigma: blurSigma,
      ),
    );
  }

  List<Widget> _buildSlivers(
    BuildContext context,
    TopLevelChromeForeground foreground,
    TabController? tabController,
  ) {
    final tabs = widget.config.tabs;
    if (tabs == null || tabController == null) {
      return widget.config.plainSliversBuilder!(context);
    }

    return [
      SliverPersistentHeader(
        key: tabs.headerKey,
        pinned: true,
        delegate: _ConfiguredPinnedTabHeaderDelegate(
          foreground: foreground,
          title: widget.config.title,
          config: tabs,
          controller: tabController,
        ),
      ),
      SliverLayoutBuilder(
        key: tabs.viewportSliverKey,
        builder: (context, constraints) {
          final tabViewportExtent =
              (constraints.viewportMainAxisExtent -
                      constraints.precedingScrollExtent)
                  .clamp(0.0, double.infinity)
                  .toDouble();

          return SliverToBoxAdapter(
            child: SizedBox(
              key: tabs.viewportKey,
              height: tabViewportExtent,
              child: TabBarView(
                key: tabs.viewKey,
                controller: tabController,
                children: [
                  for (final tab in tabs.tabs)
                    tab.builder(context, tab.controller),
                ],
              ),
            ),
          );
        },
      ),
    ];
  }

  double _lerp(double begin, double end, double t) {
    return begin + (end - begin) * t.clamp(0.0, 1.0);
  }

  TabController _ensureTabController(TopLevelTabConfig tabs) {
    final externalController = widget.tabController;
    if (externalController != null) {
      return externalController;
    }

    final signature = tabs.tabs.map((tab) => tab.id).join(',');
    if (_tabController == null || _tabSignature != signature) {
      _disposeInternalTabController();
      _tabSignature = signature;
      _selectedIndex = _selectedIndex.clamp(0, tabs.tabs.length - 1);
      _tabController = TabController(
        length: tabs.tabs.length,
        vsync: this,
        initialIndex: _selectedIndex,
      )..addListener(_handleTabControllerChange);
    }
    return _tabController!;
  }

  Future<void> _scrollToTop(TabController? tabController) async {
    final customHandler = widget.config.onScrollToTop;
    if (customHandler != null) {
      await customHandler();
      return;
    }

    final tabItems = widget.config.tabs?.tabs;
    ScrollController? activeController;
    if (tabController != null && tabItems != null) {
      final index = tabController.index.clamp(0, tabItems.length - 1).toInt();
      activeController = tabItems[index].controller;
    }
    if (activeController != null &&
        activeController.hasClients &&
        activeController.offset > 0) {
      await _animateControllerToTop(activeController);
      return;
    }

    await _animateControllerToTop(_controller);
  }

  Future<void> _animateControllerToTop(ScrollController controller) {
    if (!controller.hasClients || controller.offset <= 0) {
      return Future<void>.value();
    }
    return controller.animateTo(
      0,
      duration: TopLevelPageScaffold.scrollToTopDuration,
      curve: TopLevelPageScaffold.scrollToTopCurve,
    );
  }

  void _disposeInternalTabController() {
    _tabController?.removeListener(_handleTabControllerChange);
    _tabController?.dispose();
    _tabController = null;
    _tabSignature = '';
  }

  void _handleTabControllerChange() {
    final controller = widget.tabController ?? _tabController;
    if (controller == null || controller.indexIsChanging) return;
    if (_selectedIndex == controller.index) return;
    _selectedIndex = controller.index;
    widget.config.onTabChanged?.call(controller.index);
  }
}

class _ConfiguredPinnedTabHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  const _ConfiguredPinnedTabHeaderDelegate({
    required this.foreground,
    required this.title,
    required this.config,
    required this.controller,
  });

  final TopLevelChromeForeground foreground;
  final String title;
  final TopLevelTabConfig config;
  final TabController controller;

  @override
  double get minExtent => AppSpacing.topLevelPinnedChannelHeight;

  @override
  double get maxExtent => AppSpacing.topLevelPinnedChannelHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final selectedColor = config.selectedColorBuilder?.call(
      context,
      controller,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox(
          key: config.barKey,
          height: AppSpacing.topLevelPinnedChannelHeight,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  key:
                      config.rhythmPaddingKey ??
                      ValueKey('${config.barKey}-rhythm-padding'),
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                  child: AppTabBar(
                    controller: controller,
                    isScrollable: config.isScrollable,
                    tabAlignment: config.tabAlignment,
                    labelColor: selectedColor ?? foreground.selected,
                    unselectedLabelColor: foreground.unselected,
                    indicatorColor: selectedColor ?? foreground.indicator,
                    indicatorPadding: const EdgeInsets.only(
                      bottom: AppSpacing.sm,
                    ),
                    indicatorWeight: config.newsStyle ? 3 : 2,
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: config.newsStyle
                          ? AppSpacing.sm
                          : AppSpacing.md,
                    ),
                    overlayColor: config.overlayColor,
                    unselectedFontWeight: config.newsStyle
                        ? FontWeight.w600
                        : null,
                    tabs: [for (final tab in config.tabs) Tab(text: tab.label)],
                  ),
                ),
              ),
              if (config.trailing != null)
                IconTheme(
                  data: IconThemeData(
                    color: selectedColor ?? foreground.selected,
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: selectedColor ?? foreground.selected,
                    ),
                    child: config.trailing!,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _ConfiguredPinnedTabHeaderDelegate oldDelegate) {
    return oldDelegate.foreground != foreground ||
        oldDelegate.title != title ||
        oldDelegate.config != config ||
        oldDelegate.controller != controller;
  }
}

class TopLevelChromeForeground {
  const TopLevelChromeForeground({
    required this.selected,
    required this.unselected,
    required this.indicator,
    required this.search,
    this.darkFactor = 0,
  });

  final Color selected;
  final Color unselected;
  final Color indicator;
  final Color search;
  final double darkFactor;

  static TopLevelChromeForeground resolve(
    BuildContext context,
    ResolvedPageSurface surface,
  ) {
    final tokens = context.tokens;
    final darkFactor =
        surface.chromeDarkFactor ?? (surface.isDarkBackground ? 1.0 : 0.0);
    final light = TopLevelChromeForeground(
      selected: tokens.brand.primary,
      unselected: tokens.textSecondary,
      indicator: tokens.brand.primary,
      search: tokens.textTertiary,
      darkFactor: 0,
    );
    final dark = TopLevelChromeForeground(
      selected: Colors.white,
      unselected: Colors.white.withValues(alpha: 0.72),
      indicator: Colors.white,
      search: Colors.white.withValues(alpha: 0.82),
      darkFactor: 1,
    );

    if (darkFactor > 0 && darkFactor < 1) {
      return TopLevelChromeForeground(
        selected: Color.lerp(light.selected, dark.selected, darkFactor)!,
        unselected: Color.lerp(light.unselected, dark.unselected, darkFactor)!,
        indicator: Color.lerp(light.indicator, dark.indicator, darkFactor)!,
        search: Color.lerp(light.search, dark.search, darkFactor)!,
        darkFactor: darkFactor,
      );
    }

    if (surface.isDarkBackground) {
      return dark;
    }

    return light;
  }
}
