import 'package:flutter/material.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../domain/models/live_program.dart';

class LiveProgramDetailPage extends StatelessWidget {
  const LiveProgramDetailPage({super.key, required this.program});

  final LiveFeaturedProgram program;

  static const _dates = [
    ('周二', '6.9'),
    ('周三', '6.10'),
    ('周四', '6.11'),
    ('周五', '6.12'),
    ('周六', '6.13'),
    ('周日', '6.14'),
    ('周一', '6.15'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('live-program-detail-page'),
      appBar: AppBar(title: Text(program.title)),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _ProgramHero(program: program)),
              SliverToBoxAdapter(child: _DateStrip(dates: _dates)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageX,
                  AppSpacing.md,
                  AppSpacing.pageX,
                  AppSpacing.bottomNavPagePadding,
                ),
                sliver: SliverList.separated(
                  itemCount: program.schedule.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) =>
                      _EpisodeCard(episode: program.schedule[index]),
                ),
              ),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _DetailActionBar(),
          ),
        ],
      ),
    );
  }
}

class _ProgramHero extends StatelessWidget {
  const _ProgramHero({required this.program});

  final LiveFeaturedProgram program;

  @override
  Widget build(BuildContext context) {
    final color = Color(program.accentColor);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = (width / (16 / 9)).clamp(210.0, 260.0);

        return SizedBox(
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.62), Colors.black87],
              ),
            ),
            child: Padding(
              padding: AppInsets.section,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.live_tv_outlined, color: Colors.white),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        program.channelName,
                        style: context.typography.feedTitleCompact.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    program.title,
                    style: context.typography.heroTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    program.subtitle,
                    style: context.typography.feedMeta.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.dates});

  final List<(String, String)> dates;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.tokens.pageBackground,
      child: SizedBox(
        key: const Key('program-detail-date-strip'),
        height: 88,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageX,
            vertical: AppSpacing.sm,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: dates.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            if (index == dates.length) {
              return const _CalendarShortcut();
            }
            final selected = index == dates.length - 1;
            final date = dates[index];
            return DecoratedBox(
              decoration: BoxDecoration(
                color: selected
                    ? context.tokens.info.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: SizedBox(
                width: 58,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(date.$1, style: context.typography.feedMeta),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      date.$2,
                      style: context.typography.feedTitleCompact.copyWith(
                        color: selected
                            ? context.tokens.info
                            : context.tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CalendarShortcut extends StatelessWidget {
  const _CalendarShortcut();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            color: context.tokens.textPrimary,
          ),
          Text('日历', style: context.typography.label),
        ],
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({required this.episode});

  final LiveProgramEpisode episode;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.feedTitle,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(episode.time, style: context.typography.feedMeta),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 118,
            height: 76,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.media),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(episode.accentColor),
                  gradient: LinearGradient(
                    colors: [
                      Color(episode.accentColor),
                      Color(episode.accentColor).withValues(alpha: 0.58),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.play_arrow_rounded, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActionBar extends StatelessWidget {
  const _DetailActionBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.tokens.cardBackground.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: context.tokens.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageX,
            AppSpacing.sm,
            AppSpacing.pageX,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('program-detail-comment-input'),
                  decoration: InputDecoration(
                    hintText: '看了这么久，说点什么吧...',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const StatusPill(label: '评论', icon: Icons.chat_bubble_outline),
              const SizedBox(width: AppSpacing.sm),
              const StatusPill(label: '分享', icon: Icons.ios_share_outlined),
            ],
          ),
        ),
      ),
    );
  }
}
