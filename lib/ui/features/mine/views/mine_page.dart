import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/primary_pill_button.dart';
import '../../../../core/widgets/quick_action_grid.dart';
import '../../../../core/widgets/top_level_page_config.dart';
import '../../../../core/widgets/top_level_page_scaffold.dart';
import '../../foundation/views/about_page.dart';
import '../../foundation/views/account_security_page.dart';
import '../../foundation/views/message_center_page.dart';
import '../../points/views/points_pages.dart';
import '../../../shared/app_state_controller.dart';
import '../view_models/session_view_model.dart';
import 'activity_list_page.dart';
import 'auth_page.dart';
import 'settings_page.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key, this.scrollToTopRequest = 0});

  final int scrollToTopRequest;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();
    final appState = context.watch<AppStateController>();
    final user = session.user;

    return ConfiguredTopLevelPage(
      scrollToTopRequest: scrollToTopRequest,
      config: TopLevelPageConfig(
        title: '我的',
        surfaceBuilder: _sharedImageSurface,
        actions: [
          IconButton(
            key: const Key('mine-top-message-action'),
            tooltip: '消息通知',
            icon: const Icon(Icons.notifications_none),
            onPressed: () =>
                AppNavigator.push(context, const MessageCenterPage()),
          ),
          IconButton(
            key: const Key('mine-top-settings-action'),
            tooltip: '设置',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => AppNavigator.push(context, const SettingsPage()),
          ),
        ],
        plainSliversBuilder: (context) => [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageX,
              AppSpacing.sectionGap,
              AppSpacing.pageX,
              AppSpacing.bottomNavPagePadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileHeader(
                  nickname: user?.nickname,
                  phone: user?.maskedPhone,
                  stats: [
                    _ProfileStatData(
                      key: const Key('mine-profile-stat-points'),
                      label: '积分',
                      value: session.isLoggedIn
                          ? '${appState.pointsBalance}'
                          : '--',
                      onTap: () =>
                          openPointsPage(context, const PointsCenterPage()),
                    ),
                    _ProfileStatData(
                      key: const Key('mine-profile-stat-favorites'),
                      label: '收藏',
                      value: '${appState.favoriteArticles.length}',
                      onTap: () => AppNavigator.push(
                        context,
                        const ActivityListPage(
                          kind: ActivityListKind.favorites,
                        ),
                      ),
                    ),
                    _ProfileStatData(
                      key: const Key('mine-profile-stat-orders'),
                      label: '兑换',
                      value: session.isLoggedIn
                          ? '${appState.pointOrders.length}'
                          : '--',
                      onTap: () =>
                          openPointsPage(context, const PointsOrdersPage()),
                    ),
                  ],
                  onLogin: () => AppNavigator.push(context, const AuthPage()),
                  onProfile: () => _toast(context, '账号资料暂不可用'),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _MineActions(
                  onOpen: (kind) =>
                      AppNavigator.push(context, ActivityListPage(kind: kind)),
                  onSettings: () =>
                      AppNavigator.push(context, const SettingsPage()),
                  onAccountSecurity: () =>
                      AppNavigator.push(context, const AccountSecurityPage()),
                  onAbout: () => AppNavigator.push(context, const AboutPage()),
                ),
              ]),
            ),
          ),
        ],
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

  static void _toast(BuildContext context, String message) {
    showAppSnackBar(context, message);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.nickname,
    required this.phone,
    required this.stats,
    required this.onLogin,
    required this.onProfile,
  });

  final String? nickname;
  final String? phone;
  final List<_ProfileStatData> stats;
  final VoidCallback onLogin;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final loggedIn = phone != null;
    final tokens = context.tokens;

    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: tokens.softFill,
              child: Text(
                loggedIn ? (nickname ?? '用').characters.first : '融',
                style: context.typography.heroTitle.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loggedIn ? phone! : '立即登录',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.heroTitle.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: tokens.textSecondary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.pillRadius,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: AppSpacing.xxs,
                      ),
                      child: Text(
                        loggedIn ? '黑铁' : '未登录',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.label.copyWith(
                          color: tokens.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: loggedIn ? 96 : 92,
              child: PrimaryPillButton(
                onPressed: loggedIn ? onProfile : onLogin,
                label: loggedIn ? '账号资料' : '登录',
                variant: loggedIn ? AppButtonVariant.secondary : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ProfileStats(stats: stats),
      ],
    );
  }
}

class _ProfileStatData {
  const _ProfileStatData({
    required this.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final Key key;
  final String label;
  final String value;
  final VoidCallback onTap;
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.stats});

  final List<_ProfileStatData> stats;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return DecoratedBox(
      key: const Key('mine-profile-stats'),
      decoration: BoxDecoration(
        color: tokens.cardBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: tokens.divider),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxs,
            vertical: AppSpacing.xs,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 340 ? 2 : stats.length;
              final width = constraints.maxWidth / columns;
              return Wrap(
                runSpacing: AppSpacing.xs,
                children: [
                  for (final stat in stats)
                    SizedBox(
                      width: width,
                      child: _ProfileStatItem(stat: stat),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileStatItem extends StatelessWidget {
  const _ProfileStatItem({required this.stat});

  final _ProfileStatData stat;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      button: true,
      label: '${stat.label} ${stat.value}',
      child: InkWell(
        key: stat.key,
        borderRadius: BorderRadius.circular(AppRadius.input),
        onTap: stat.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.feedTitleCompact.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.feedMeta.copyWith(
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MineActions extends StatelessWidget {
  const _MineActions({
    required this.onOpen,
    required this.onSettings,
    required this.onAccountSecurity,
    required this.onAbout,
  });

  final ValueChanged<ActivityListKind> onOpen;
  final VoidCallback onSettings;
  final VoidCallback onAccountSecurity;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MineActionGroup(
          title: '常用记录',
          subtitle: '收藏、历史和互动内容',
          items: [
            QuickActionItem(
              icon: Icons.favorite_border,
              label: '我的关注',
              onTap: () => onOpen(ActivityListKind.follows),
            ),
            QuickActionItem(
              icon: Icons.star_border,
              label: '我的收藏',
              onTap: () => onOpen(ActivityListKind.favorites),
            ),
            QuickActionItem(
              icon: Icons.hourglass_empty,
              label: '浏览历史',
              onTap: () => onOpen(ActivityListKind.history),
            ),
            QuickActionItem(
              icon: Icons.article_outlined,
              label: '我的评论',
              onTap: () => onOpen(ActivityListKind.comments),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        _MineActionGroup(
          title: '服务互动',
          subtitle: '预约、办理、爆料和反馈',
          items: [
            QuickActionItem(
              icon: Icons.access_time,
              label: '我的预约',
              onTap: () => onOpen(ActivityListKind.reservations),
            ),
            QuickActionItem(
              icon: Icons.campaign_outlined,
              label: '我的爆料',
              onTap: () => onOpen(ActivityListKind.reports),
            ),
            QuickActionItem(
              icon: Icons.feedback_outlined,
              label: '反馈记录',
              onTap: () => onOpen(ActivityListKind.feedbacks),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        _MineActionGroup(
          title: '设置支持',
          subtitle: '账号、安全与应用信息',
          items: [
            QuickActionItem(
              icon: Icons.verified_user_outlined,
              label: '账号安全',
              onTap: onAccountSecurity,
            ),
            QuickActionItem(
              icon: Icons.settings_outlined,
              label: '设置',
              onTap: onSettings,
            ),
            QuickActionItem(
              icon: Icons.info_outline,
              label: '关于',
              onTap: onAbout,
            ),
          ],
        ),
      ],
    );
  }
}

class _MineActionGroup extends StatelessWidget {
  const _MineActionGroup({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<QuickActionItem> items;

  @override
  Widget build(BuildContext context) {
    return QuickActionSection(
      title: title,
      subtitle: subtitle,
      gridKey: Key('quick-action-grid-mine-$title'),
      items: items,
      shrinkToItemCount: true,
    );
  }
}
