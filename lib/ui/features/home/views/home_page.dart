import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/top_level_page_config.dart';
import '../../../../core/widgets/top_level_page_scaffold.dart';
import '../../../../data/repositories/home_content_repository.dart';
import '../../../../domain/models/home_block.dart';
import '../../../../domain/models/media_channel.dart';
import '../view_models/channel_view_model.dart';
import 'channel_h5_tab.dart';
import 'channel_content_tab.dart';
import 'home_channel_visual_resolver.dart';
import 'channel_management_page.dart';
import '../../search/views/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.scrollToTopRequest = 0,
    this.channelH5WebViewBuilder = ChannelH5Tab.defaultWebViewBuilder,
  });

  final int scrollToTopRequest;
  final ChannelH5WebViewBuilder channelH5WebViewBuilder;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const _scrollToTopDuration = Duration(milliseconds: 1000);
  static const _scrollToTopCurve = Curves.easeOutCirc;
  static const _visualResolver = HomeChannelVisualResolver();

  final _pageScrollController = ScrollController();
  final _channelContentControllers = <String, ScrollController>{};
  TabController? _tabController;
  String _channelSignature = '';
  String _precacheSignature = '';
  int _selectedIndex = 0;

  @override
  void dispose() {
    _tabController?.dispose();
    _pageScrollController.dispose();
    for (final controller in _channelContentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final channels = viewModel.myChannels;
        final controller = _ensureController(channels);
        _pruneChannelContentControllers(channels);
        _precacheTopChromeBackdrops(context, channels);
        final contentRepository = context.read<HomeContentRepository>();

        return ConfiguredTopLevelPage(
          scrollToTopRequest: widget.scrollToTopRequest,
          controller: _pageScrollController,
          tabController: controller,
          config: TopLevelPageConfig(
            title: '首页',
            surfaceBuilder: (context, tabController) =>
                _channelSurface(context, channels, controller),
            chromeBackgroundBuilder: (context, tabController) =>
                _chromeBackground(context, channels, controller),
            search: TopLevelSearchConfig(
              key: const Key('home-search-entry'),
              placeholder: '搜索新闻、服务',
              onTap: _openSearch,
            ),
            onScrollToTop: () => _scrollHomeToTop(channels),
            onTabChanged: (index) {
              if (_selectedIndex == index) return;
              _resetOuterScrollToTop();
              setState(() => _selectedIndex = index);
            },
            tabs: TopLevelTabConfig(
              headerKey: const Key('home-channel-tabs-sliver'),
              barKey: const Key('home-pinned-channel-bar'),
              viewportSliverKey: const Key('home-channel-tab-viewport-sliver'),
              viewportKey: const Key('home-channel-tab-viewport'),
              viewKey: const Key('home-channel-tab-view'),
              rhythmPaddingKey: const Key('home-channel-tab-rhythm-padding'),
              newsStyle: true,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              selectedColorBuilder: (context, tabController) =>
                  _channelAccentFor(context, channels, tabController),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const Key('channel-manage-button'),
                    tooltip: '频道管理',
                    onPressed: () => _openChannelManagement(context),
                    icon: const Icon(Icons.grid_view_rounded, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ),
              tabs: [
                for (final channel in channels)
                  TopLevelTabItem(
                    id: channel.id,
                    label: channel.label,
                    controller: _contentControllerFor(channel.id),
                    builder: (context, controller) {
                      if (channel.content.type == MediaChannelContentType.h5) {
                        final url = channel.content.h5Url;
                        if (url == null || url.isEmpty) {
                          return EmptyChannel(
                            key: ValueKey('home-channel-empty-${channel.id}'),
                            channel: channel.label,
                            controller: controller,
                          );
                        }

                        return ChannelH5Tab(
                          key: ValueKey('home-channel-h5-tab-${channel.id}'),
                          channelId: channel.id,
                          channelLabel: channel.label,
                          url: url,
                          webViewBuilder: widget.channelH5WebViewBuilder,
                        );
                      }

                      final blocks = contentRepository.blocksForChannel(
                        channel.id,
                      );
                      if (blocks.isEmpty) {
                        return EmptyChannel(
                          key: ValueKey('home-channel-empty-${channel.id}'),
                          channel: channel.label,
                          controller: controller,
                        );
                      }

                      return _buildChannelContentTab(
                        context: context,
                        channel: channel,
                        blocks: blocks,
                        controller: controller!,
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  ChannelContentTab _buildChannelContentTab({
    required BuildContext context,
    required MediaChannel channel,
    required List<PageBlock> blocks,
    required ScrollController controller,
  }) {
    final immersiveBackground = _visualResolver.immersiveBackgroundFor(
      context,
      channel.style,
    );
    final contentTopPadding = immersiveBackground == null
        ? AppSpacing.homeChannelContentTopGap
        : channel.style.immersiveContentTopInset ??
              AppSpacing.homeImmersiveChannelContentTopInset;

    return ChannelContentTab(
      key: ValueKey('home-channel-content-${channel.id}'),
      blocks: blocks,
      emptyTitle: '${channel.label} 暂无内容',
      emptyMessage: '暂无内容',
      controller: controller,
      contentTopPadding: contentTopPadding,
      immersiveBackground: immersiveBackground,
      contentBackground: null,
      visualTheme: _visualResolver.visualThemeFor(channel.style),
    );
  }

  TopLevelChromeBackground _chromeBackground(
    BuildContext context,
    List<MediaChannel> channels,
    TabController controller,
  ) {
    if (channels.isEmpty) return const TopLevelChromeBackground.transparent();

    final channel = _selectedChannel(channels);
    return _visualResolver.chromeBackgroundFor(context, channel.style);
  }

  PageSurface _channelSurface(
    BuildContext context,
    List<MediaChannel> channels,
    TabController controller,
  ) {
    if (channels.isEmpty) {
      return PageSurface(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );
    }

    final transition = _channelTransition(controller, channels.length);
    final fromChannel = channels[transition.fromIndex];
    final toChannel = channels[transition.toIndex];
    final defaultBackground = Theme.of(context).scaffoldBackgroundColor;
    final fromBackground = _visualResolver.backgroundFor(
      context,
      fromChannel.style,
      defaultBackground,
    );
    final toBackground = _visualResolver.backgroundFor(
      context,
      toChannel.style,
      defaultBackground,
    );
    final backgroundColor =
        Color.lerp(fromBackground, toBackground, transition.progress) ??
        fromBackground;
    final chromeDarkFactor = _lerp(
      _visualResolver.chromeDarkFactorFor(fromBackground),
      _visualResolver.chromeDarkFactorFor(toBackground),
      transition.progress,
    );
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fromChrome = _visualResolver.topChromeBackdropFor(
      context,
      fromChannel.style,
    );
    final toChrome = _visualResolver.topChromeBackdropFor(
      context,
      toChannel.style,
    );
    final fromImageWeight = fromChrome == null ? 0.0 : 1 - transition.progress;
    final toImageWeight = toChrome == null ? 0.0 : transition.progress;
    final imageWeight = (fromImageWeight + toImageWeight)
        .clamp(0.0, 1.0)
        .toDouble();
    final activeChrome = toImageWeight >= fromImageWeight
        ? toChrome
        : fromChrome;
    final activeChannel = toImageWeight >= fromImageWeight
        ? toChannel
        : fromChannel;
    final frameBackground = _visualResolver.frameBackgroundFor(
      context,
      activeChannel.style,
      strength: imageWeight,
    );

    if (activeChrome == null || dark || imageWeight == 0) {
      return PageSurface(
        backgroundColor: backgroundColor,
        chromeDarkFactor: chromeDarkFactor,
        frameBackground: frameBackground,
        backdrop: PageBackdrop(
          enabled: false,
          startColor: backgroundColor,
          middleColor: backgroundColor,
          endColor: backgroundColor,
          blendMode: PageBackdropBlendMode.none,
        ),
      );
    }

    final backdrop = activeChrome.gradient
        ? PageBackdrop.gradient(
            startColor: activeChrome.startColor ?? backgroundColor,
            middleColor:
                activeChrome.middleColor ??
                activeChrome.startColor ??
                backgroundColor,
            endColor: activeChrome.endColor ?? backgroundColor,
            colors: activeChrome.colors,
            stops: activeChrome.stops,
            height: activeChrome.height ?? AppSpacing.topLevelBackdropHeight,
            strength: imageWeight,
            blendMode: activeChrome.blendMode,
            blendColor: activeChrome.blendColor,
          )
        : activeChrome.solidColor != null
        ? PageBackdrop.solid(
            color: activeChrome.solidColor!,
            height: activeChrome.height ?? AppSpacing.topLevelBackdropHeight,
            strength: imageWeight,
            blendMode: activeChrome.blendMode,
            blendColor: activeChrome.blendColor,
          )
        : PageBackdrop.image(
            tokens: context.tokens,
            endColor: backgroundColor,
            assetName: activeChrome.assetName,
            imageUrl: activeChrome.imageUrl,
            darkAssetName: activeChrome.darkAssetName,
            darkImageUrl: activeChrome.darkImageUrl,
            enabled: true,
            imageOpacity: imageWeight,
            imageAlignment: activeChrome.imageAlignment,
            blendMode: activeChrome.blendMode,
            blendColor: activeChrome.blendColor,
          );

    return PageSurface(
      backgroundColor: backgroundColor,
      chromeDarkFactor: chromeDarkFactor,
      frameBackground: frameBackground,
      backdrop: backdrop,
    );
  }

  Color? _channelAccentFor(
    BuildContext context,
    List<MediaChannel> channels,
    TabController controller,
  ) {
    if (channels.isEmpty) return null;
    if (Theme.of(context).brightness == Brightness.dark) return null;

    final transition = _channelTransition(controller, channels.length);
    final fromColor = channels[transition.fromIndex].style.accentColor;
    final toColor = channels[transition.toIndex].style.accentColor;
    if (fromColor == null && toColor == null) return null;
    if (fromColor == null) return toColor;
    if (toColor == null) return fromColor;
    return Color.lerp(fromColor, toColor, transition.progress);
  }

  _HomeChannelTransition _channelTransition(
    TabController controller,
    int channelCount,
  ) {
    final animationValue =
        (controller.animation?.value ?? controller.index.toDouble())
            .clamp(0.0, channelCount - 1)
            .toDouble();
    if (controller.indexIsChanging &&
        controller.previousIndex != controller.index) {
      final fromIndex = _safeChannelIndex(
        controller.previousIndex,
        channelCount,
      );
      final toIndex = _safeChannelIndex(controller.index, channelCount);
      final distance = (toIndex - fromIndex).toDouble();
      final progress = distance == 0
          ? 1.0
          : ((animationValue - fromIndex) / distance)
                .clamp(0.0, 1.0)
                .toDouble();

      return _HomeChannelTransition(
        fromIndex: fromIndex,
        toIndex: toIndex,
        progress: progress,
      );
    }

    final pageValue = animationValue;
    final lowerIndex = pageValue.floor().clamp(0, channelCount - 1).toInt();
    final upperIndex = pageValue.ceil().clamp(0, channelCount - 1).toInt();
    final progress = (pageValue - lowerIndex).clamp(0.0, 1.0).toDouble();

    return _HomeChannelTransition(
      fromIndex: lowerIndex,
      toIndex: upperIndex,
      progress: progress,
    );
  }

  double _lerp(double begin, double end, double t) {
    return begin + (end - begin) * t.clamp(0.0, 1.0);
  }

  MediaChannel _selectedChannel(List<MediaChannel> channels) {
    return channels[_safeChannelIndex(_selectedIndex, channels.length)];
  }

  int _safeChannelIndex(int index, int length) {
    return index.clamp(0, length - 1).toInt();
  }

  TabController _ensureController(List<MediaChannel> channels) {
    final signature = channels.map((channel) => channel.id).join(',');
    if (_tabController == null || _channelSignature != signature) {
      _tabController?.dispose();
      _channelSignature = signature;
      _selectedIndex = _selectedIndex.clamp(0, channels.length - 1);
      _tabController = TabController(
        length: channels.length,
        vsync: this,
        initialIndex: _selectedIndex,
      );
    }
    return _tabController!;
  }

  ScrollController _contentControllerFor(String channelId) {
    return _channelContentControllers.putIfAbsent(
      channelId,
      ScrollController.new,
    );
  }

  void _pruneChannelContentControllers(List<MediaChannel> channels) {
    final activeIds = channels.map((channel) => channel.id).toSet();
    final removedIds = _channelContentControllers.keys
        .where((id) => !activeIds.contains(id))
        .toList();
    for (final id in removedIds) {
      _channelContentControllers.remove(id)?.dispose();
    }
  }

  Future<void> _openChannelManagement(BuildContext context) async {
    final selectedId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ChannelManagementPage(
          currentChannelId: context
              .read<ChannelViewModel>()
              .myChannels[_selectedIndex]
              .id,
        ),
      ),
    );
    if (!context.mounted || selectedId == null) return;

    final channels = context.read<ChannelViewModel>().myChannels;
    final index = channels.indexWhere((channel) => channel.id == selectedId);
    if (index < 0) return;

    setState(() => _selectedIndex = index);
    _tabController?.animateTo(index);
  }

  void _openSearch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SearchPage()));
  }

  Future<void> _scrollHomeToTop(List<MediaChannel> channels) async {
    final animations = <Future<void>>[];
    if (_pageScrollController.hasClients && _pageScrollController.offset > 0) {
      animations.add(_animateControllerToTop(_pageScrollController));
    }

    final currentChannel = channels.isEmpty ? null : _selectedChannel(channels);
    final contentController = currentChannel == null
        ? null
        : _channelContentControllers[currentChannel.id];
    if (contentController != null &&
        contentController.hasClients &&
        contentController.offset > 0) {
      animations.add(_animateControllerToTop(contentController));
    }

    if (animations.isEmpty) return;
    await Future.wait(animations);
  }

  Future<void> _animateControllerToTop(ScrollController controller) {
    if (!controller.hasClients || controller.offset <= 0) {
      return Future<void>.value();
    }
    return controller.animateTo(
      0,
      duration: _scrollToTopDuration,
      curve: _scrollToTopCurve,
    );
  }

  void _resetOuterScrollToTop() {
    if (!_pageScrollController.hasClients ||
        _pageScrollController.offset == 0) {
      return;
    }
    _pageScrollController.jumpTo(0);
  }

  void _precacheTopChromeBackdrops(
    BuildContext context,
    List<MediaChannel> channels,
  ) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final brandId = context.tokens.brand.id;
    final signature = [
      dark ? 'dark' : 'light',
      brandId.name,
      for (final channel in channels)
        [
          channel.id,
          channel.style.topBackground.mode.name,
          channel.style.topSurfaceMode.name,
          channel.style.surfaceMode.name,
          channel.style.backdropAssetName ?? '',
          channel.style.backdropImageUrl ?? '',
          channel.style.darkBackdropAssetName ?? '',
          channel.style.darkBackdropImageUrl ?? '',
          channel.style.immersiveBackdropAssetName ?? '',
          channel.style.immersiveBackdropImageUrl ?? '',
          channel.style.darkImmersiveBackdropAssetName ?? '',
          channel.style.darkImmersiveBackdropImageUrl ?? '',
        ].join('|'),
    ].join(';');
    if (_precacheSignature == signature) return;
    _precacheSignature = signature;

    final providers = <ImageProvider<Object>>[];
    if (!dark) {
      final brandAsset = AppAssets.topLevelHeaderImage(brandId);
      if (brandAsset.isNotEmpty) {
        providers.add(AssetImage(brandAsset));
      }
    }

    for (final channel in channels) {
      final style = channel.style;
      final topBackgroundMode = _visualResolver.effectiveTopBackgroundMode(
        style,
      );
      if (topBackgroundMode == MediaChannelTopBackgroundMode.color ||
          topBackgroundMode == MediaChannelTopBackgroundMode.gradient) {
        continue;
      }

      final topSurfaceMode = _visualResolver.effectiveTopSurfaceMode(style);
      if (topSurfaceMode == MediaChannelTopSurfaceMode.channelColor) continue;

      final assetName = _visualResolver.resolveTopChromeBackdropAsset(
        style: style,
        dark: dark,
        brandId: brandId,
        topSurfaceMode: topSurfaceMode,
      );
      if (assetName != null && assetName.isNotEmpty) {
        providers.add(AssetImage(assetName));
      }

      final imageUrl = _visualResolver.resolveTopChromeBackdropUrl(
        style: style,
        dark: dark,
        topSurfaceMode: topSurfaceMode,
      );
      if (imageUrl != null && imageUrl.isNotEmpty) {
        providers.add(NetworkImage(imageUrl));
      }
    }

    if (providers.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final provider in providers) {
        precacheImage(provider, context);
      }
    });
  }
}

class EmptyChannel extends StatelessWidget {
  const EmptyChannel({super.key, required this.channel, this.controller});

  final String channel;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: Key('empty-channel-$channel'),
      controller: controller,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(title: '$channel 暂无内容', message: '暂无内容'),
        ),
      ],
    );
  }
}

class _HomeChannelTransition {
  const _HomeChannelTransition({
    required this.fromIndex,
    required this.toIndex,
    required this.progress,
  });

  final int fromIndex;
  final int toIndex;
  final double progress;
}
