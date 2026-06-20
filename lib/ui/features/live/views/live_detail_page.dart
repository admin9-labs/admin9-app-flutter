import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../domain/models/live_program.dart';
import '../../../shared/app_state_controller.dart';
import '../../mine/view_models/session_view_model.dart';

class LiveDetailPage extends StatelessWidget {
  const LiveDetailPage({super.key, required this.program});

  final LiveProgram program;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateController>();
    final reserved = appState.isReservedLive(program.id);

    return Scaffold(
      appBar: AppBar(title: const Text('直播详情')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          Container(
            height: AppMediaSize.heroHeight,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          StatusPill(label: _statusText(program)),
          const SizedBox(height: AppSpacing.md),
          Text(program.title, style: context.typography.heroTitle),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${program.source} · ${program.time}',
            style: context.typography.feedMeta,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(program.summary, style: context.typography.feedSummary),
          const SizedBox(height: AppSpacing.xxl),
          FilledButton.icon(
            key: const Key('reserve-live-button'),
            onPressed: program.status == LiveStatus.upcoming
                ? () => _guardLogin(
                    context,
                    () => appState.toggleLiveReservation(program),
                  )
                : () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('直播暂不可播放'))),
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(
              program.status == LiveStatus.upcoming
                  ? (reserved ? '取消预约' : '预约提醒')
                  : '进入观看',
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('直播互动', style: context.typography.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          AppCard(child: Text('互动区暂未开放', style: context.typography.feedMeta)),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('相关推荐', style: context.typography.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Text(
              '全省服务业大会特别报道',
              style: context.typography.feedTitleCompact,
            ),
          ),
        ],
      ),
    );
  }

  void _guardLogin(BuildContext context, VoidCallback action) {
    final session = context.read<SessionViewModel>();
    if (!session.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先登录')));
      return;
    }
    action();
  }

  String _statusText(LiveProgram program) {
    return switch (program.status) {
      LiveStatus.live => '正在直播',
      LiveStatus.upcoming => '直播预告',
      LiveStatus.replay => '直播回放',
    };
  }
}
