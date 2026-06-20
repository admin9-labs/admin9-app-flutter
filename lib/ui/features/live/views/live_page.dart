import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/live_stream_player.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/top_level_page_config.dart';
import '../../../../core/widgets/top_level_page_scaffold.dart';
import '../../../../data/repositories/live_repository.dart';
import '../../../../domain/models/live_program.dart';
import '../../mine/view_models/session_view_model.dart';
import '../../mine/views/auth_page.dart';
import 'interactive_live_detail_page.dart';
import 'live_program_detail_page.dart';
import 'tv_live_detail_page.dart';

class LivePage extends StatefulWidget {
  const LivePage({
    super.key,
    this.scrollToTopRequest = 0,
    this.isPlaybackActive = true,
    this.streamPlayerBuilder,
  });

  final int scrollToTopRequest;
  final bool isPlaybackActive;
  final LiveStreamPlayerBuilder? streamPlayerBuilder;

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  static const _tabs = [
    _LiveTab(label: '电视直播', kind: _LiveTabKind.tv),
    _LiveTab(label: '广播直播', kind: _LiveTabKind.radio),
    _LiveTab(label: '互动直播', kind: _LiveTabKind.interactive),
  ];

  final _tabControllers = <_LiveTabKind, ScrollController>{
    for (final tab in _tabs) tab.kind: ScrollController(),
  };

  @override
  void dispose() {
    for (final controller in _tabControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<LiveRepository>();

    return ConfiguredTopLevelPage(
      scrollToTopRequest: widget.scrollToTopRequest,
      config: TopLevelPageConfig(
        title: '直播',
        scrollEdgeTitleBarEnabled: false,
        reserveToolbarSlot: false,
        surfaceBuilder: _sharedImageSurface,
        tabs: TopLevelTabConfig(
          headerKey: const Key('live-tabs-sliver'),
          barKey: const Key('live-pinned-tab-bar'),
          viewportSliverKey: const Key('live-tab-viewport-sliver'),
          viewportKey: const Key('live-tab-viewport'),
          viewKey: const Key('live-tab-view'),
          tabs: [
            for (final tab in _tabs)
              TopLevelTabItem(
                id: tab.label,
                label: tab.label,
                controller: _tabControllers[tab.kind],
                builder: (context, controller) => _LiveTabView(
                  key: ValueKey('live-tab-content-${tab.label}'),
                  tab: tab,
                  repository: repository,
                  controller: controller,
                  isPlaybackActive: widget.isPlaybackActive,
                  streamPlayerBuilder: widget.streamPlayerBuilder,
                ),
              ),
          ],
        ),
      ),
    );
  }

  PageSurface _sharedImageSurface(
    BuildContext context,
    TabController? controller,
  ) {
    return PageSurface(
      backdrop: PageBackdrop.image(
        tokens: context.tokens,
        endColor: context.tokens.pageBackground,
        assetName: AppAssets.topLevelHeaderImage(context.tokens.brand.id),
        strength: 0.42,
        imageAlignment: Alignment.topCenter,
      ),
    );
  }
}

enum _LiveTabKind { tv, radio, interactive }

class _LiveTab {
  const _LiveTab({required this.label, required this.kind});

  final String label;
  final _LiveTabKind kind;
}

class _LiveTabView extends StatelessWidget {
  const _LiveTabView({
    super.key,
    required this.tab,
    required this.repository,
    required this.isPlaybackActive,
    this.controller,
    this.streamPlayerBuilder,
  });

  final _LiveTab tab;
  final LiveRepository repository;
  final bool isPlaybackActive;
  final ScrollController? controller;
  final LiveStreamPlayerBuilder? streamPlayerBuilder;

  @override
  Widget build(BuildContext context) {
    final child = switch (tab.kind) {
      _LiveTabKind.tv => _TvLiveTab(
        channels: repository.tvChannels,
        featuredPrograms: repository.featuredPrograms,
        isPlaybackActive: isPlaybackActive,
        streamPlayerBuilder: streamPlayerBuilder,
      ),
      _LiveTabKind.radio => _RadioLiveTab(
        channels: repository.radioChannels,
        isPlaybackActive: isPlaybackActive,
        streamPlayerBuilder: streamPlayerBuilder,
      ),
      _LiveTabKind.interactive => _InteractiveLiveTab(
        items: repository.interactiveLives,
      ),
    };

    return CustomScrollView(
      key: Key('live-${tab.label}-list'),
      controller: controller,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageX,
            tab.kind == _LiveTabKind.tv ? AppSpacing.sm : AppSpacing.sectionGap,
            AppSpacing.pageX,
            AppSpacing.bottomNavPagePadding,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Material(type: MaterialType.transparency, child: child),
            ]),
          ),
        ),
      ],
    );
  }
}

class _TvLiveTab extends StatelessWidget {
  const _TvLiveTab({
    required this.channels,
    required this.featuredPrograms,
    required this.isPlaybackActive,
    this.streamPlayerBuilder,
  });

  final List<LiveTvChannel> channels;
  final List<LiveFeaturedProgram> featuredPrograms;
  final bool isPlaybackActive;
  final LiveStreamPlayerBuilder? streamPlayerBuilder;

  @override
  Widget build(BuildContext context) {
    final selected = channels.first;
    final loggedIn = context.watch<SessionViewModel>().isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TvLivePreviewCard(
          channel: selected,
          loggedIn: loggedIn,
          isPlaybackActive: isPlaybackActive,
          streamPlayerBuilder: streamPlayerBuilder,
          onLogin: () => AppNavigator.push(context, const AuthPage()),
          onOpen: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TvLiveDetailPage(
                channel: selected,
                streamPlayerBuilder: streamPlayerBuilder,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppSectionHeader(title: '热门节目'),
        const SizedBox(height: AppSpacing.xxs),
        _FeaturedProgramGrid(programs: featuredPrograms),
      ],
    );
  }
}

class _TvLivePreviewCard extends StatelessWidget {
  const _TvLivePreviewCard({
    required this.channel,
    required this.loggedIn,
    required this.isPlaybackActive,
    required this.onLogin,
    required this.onOpen,
    this.streamPlayerBuilder,
  });

  final LiveTvChannel channel;
  final bool loggedIn;
  final bool isPlaybackActive;
  final VoidCallback onLogin;
  final VoidCallback onOpen;
  final LiveStreamPlayerBuilder? streamPlayerBuilder;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: AppCard(
        key: const Key('tv-live-preview-card'),
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (loggedIn && isPlaybackActive)
              LiveStreamPlayer(
                key: const Key('tv-live-preview-player'),
                config: LiveStreamPlayerConfig(
                  url: channel.streamUrl,
                  title: channel.name,
                  initialMuted: true,
                  showMuteButton: false,
                  showOverlayText: false,
                ),
                builder: streamPlayerBuilder,
              )
            else
              _LivePreviewPoster(color: Color(channel.accentColor)),
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 144, maxWidth: 168),
                child: FilledButton.icon(
                  key: loggedIn
                      ? const Key('tv-live-open-detail')
                      : const Key('tv-live-login-button'),
                  onPressed: loggedIn ? onOpen : onLogin,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('点击进入详情'),
                ),
              ),
            ),
            if (!loggedIn)
              const SizedBox.shrink(key: Key('tv-live-login-gate')),
            if (loggedIn && !isPlaybackActive)
              const SizedBox.shrink(key: Key('tv-live-inactive-gate')),
          ],
        ),
      ),
    );
  }
}

class _FeaturedProgramGrid extends StatelessWidget {
  const _FeaturedProgramGrid({required this.programs});

  final List<LiveFeaturedProgram> programs;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const Key('tv-featured-program-grid'),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: programs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.04,
      ),
      itemBuilder: (context, index) {
        final program = programs[index];
        return _FeaturedProgramCard(program: program);
      },
    );
  }
}

class _FeaturedProgramCard extends StatelessWidget {
  const _FeaturedProgramCard({required this.program});

  final LiveFeaturedProgram program;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('featured-program-${program.id}'),
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LiveProgramDetailPage(program: program),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _LivePoster(
                    title: program.heroLabel,
                    subtitle: program.channelName,
                    color: Color(program.accentColor),
                    compact: true,
                  ),
                  Positioned(
                    right: AppSpacing.sm,
                    top: AppSpacing.sm,
                    child: StatusPill(
                      label: '回看',
                      color: Colors.black.withValues(alpha: 0.42),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            program.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.feedTitleCompact,
          ),
        ],
      ),
    );
  }
}

class _RadioLiveTab extends StatefulWidget {
  const _RadioLiveTab({
    required this.channels,
    required this.isPlaybackActive,
    this.streamPlayerBuilder,
  });

  final List<LiveRadioChannel> channels;
  final bool isPlaybackActive;
  final LiveStreamPlayerBuilder? streamPlayerBuilder;

  @override
  State<_RadioLiveTab> createState() => _RadioLiveTabState();
}

class _RadioLiveTabState extends State<_RadioLiveTab> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final channel = widget.channels[_selectedIndex];
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          key: const Key('radio-live-player-card'),
          backgroundColor: tokens.brand.primary,
          showBorder: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isPlaybackActive)
                LiveStreamPlayer(
                  key: ValueKey('radio-live-player-${channel.id}'),
                  config: LiveStreamPlayerConfig(
                    url: channel.streamUrl,
                    title: channel.name,
                    subtitle: '${channel.frequency} · ${channel.nowTitle}',
                    aspectRatio: 16 / 7,
                  ),
                  builder: widget.streamPlayerBuilder,
                )
              else
                AspectRatio(
                  key: const Key('radio-live-inactive-gate'),
                  aspectRatio: 16 / 7,
                  child: _LivePoster(
                    title: channel.name,
                    subtitle: '${channel.frequency} · 切换到直播页后播放',
                    color: tokens.brand.primary,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: Colors.white,
                      size: AppIconSize.feature,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          channel.name,
                          style: context.typography.sectionTitle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '${channel.frequency} · 暂用电视直播流验证播放链路',
                          style: context.typography.feedMeta.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                channel.nowTitle,
                style: context.typography.heroTitle.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '主播：${channel.host}',
                style: context.typography.feedMeta.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _RadioWaveform(color: Colors.white.withValues(alpha: 0.76)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _RadioChannelSelector(
          channels: widget.channels,
          selectedIndex: _selectedIndex,
          onSelected: (index) => setState(() => _selectedIndex = index),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppSectionHeader(title: '节目单', subtitle: '下一档：${channel.nextTitle}'),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          key: const Key('radio-live-schedule-card'),
          child: Column(
            children: [
              _ScheduleRow(time: '正在直播', title: channel.nowTitle),
              const Divider(height: AppSpacing.xxl),
              _ScheduleRow(time: '稍后播出', title: channel.nextTitle),
              const Divider(height: AppSpacing.xxl),
              const _ScheduleRow(time: '夜间', title: '城市音乐地图'),
            ],
          ),
        ),
      ],
    );
  }
}

class _RadioChannelSelector extends StatelessWidget {
  const _RadioChannelSelector({
    required this.channels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<LiveRadioChannel> channels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Wrap(
        key: const Key('radio-live-channel-selector'),
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (var index = 0; index < channels.length; index++)
            ChoiceChip(
              key: Key('radio-live-channel-${channels[index].id}'),
              selected: index == selectedIndex,
              onSelected: (_) => onSelected(index),
              label: Text(
                '${channels[index].name} ${channels[index].frequency}',
              ),
            ),
        ],
      ),
    );
  }
}

class _RadioWaveform extends StatelessWidget {
  const _RadioWaveform({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const heights = [18.0, 38.0, 26.0, 48.0, 30.0, 58.0, 34.0, 44.0, 22.0];

    return Row(
      key: const Key('radio-live-waveform'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final height in heights) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: SizedBox(width: 10, height: height),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.time, required this.title});

  final String time;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(time, style: context.typography.feedMeta),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(title, style: context.typography.feedTitleCompact),
        ),
      ],
    );
  }
}

class _InteractiveLiveTab extends StatelessWidget {
  const _InteractiveLiveTab({required this.items});

  final List<InteractiveLiveItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const Key('interactive-live-grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _InteractiveLiveCard(item: item);
      },
    );
  }
}

class _InteractiveLiveCard extends StatelessWidget {
  const _InteractiveLiveCard({required this.item});

  final InteractiveLiveItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('interactive-live-${item.id}'),
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InteractiveLiveDetailPage(item: item),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _LivePoster(
              title: item.source,
              subtitle: item.kind == LivePlaybackKind.live ? 'LIVE' : 'REPLAY',
              color: Color(item.accentColor),
              compact: true,
            ),
            Positioned(
              right: AppSpacing.xs,
              top: AppSpacing.xs,
              child: StatusPill(
                label: item.label,
                color: Colors.black.withValues(alpha: 0.48),
                foregroundColor: Colors.white,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Text(
                item.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.typography.feedTitleCompact.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePreviewPoster extends StatelessWidget {
  const _LivePreviewPoster({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('tv-live-preview-poster'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.88),
            color.withValues(alpha: 0.48),
            Colors.black87,
          ],
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Align(
          alignment: Alignment.topLeft,
          child: Icon(
            Icons.live_tv_outlined,
            color: Colors.white,
            size: AppIconSize.feature,
          ),
        ),
      ),
    );
  }
}

class _LivePoster extends StatelessWidget {
  const _LivePoster({
    required this.title,
    required this.subtitle,
    required this.color,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.92),
            color.withValues(alpha: 0.62),
            Colors.black87,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.live_tv_outlined,
              color: Colors.white,
              size: compact ? AppIconSize.lg : AppIconSize.feature,
            ),
            const Spacer(),
            Text(
              title,
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (compact
                          ? context.typography.feedTitleCompact
                          : context.typography.heroTitle)
                      .copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.feedMeta.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
