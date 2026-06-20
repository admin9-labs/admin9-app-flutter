import 'package:flutter/material.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/live_stream_player.dart';
import '../../../../domain/models/live_program.dart';

class TvLiveDetailPage extends StatelessWidget {
  const TvLiveDetailPage({
    super.key,
    required this.channel,
    this.streamPlayerBuilder,
  });

  final LiveTvChannel channel;
  final LiveStreamPlayerBuilder? streamPlayerBuilder;

  static const _messages = [
    _ChatMessage(time: '18:30', name: '135****1093', content: '今晚直播川超吗'),
    _ChatMessage(time: '18:30', name: '159****5066', content: '在小屏端有直播'),
    _ChatMessage(time: '21:54', name: '热心观众', content: '希望栏目继续关注民生线索，回应大家关切。'),
    _ChatMessage(time: '21:58', name: '城市观察员', content: '直播画面很清晰，期待后续互动。'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('tv-live-detail-page'),
      appBar: AppBar(title: Text(channel.name)),
      body: Column(
        children: [
          LiveStreamPlayer(
            key: const Key('tv-live-detail-player'),
            config: LiveStreamPlayerConfig(
              url: channel.streamUrl,
              title: channel.name,
              subtitle: channel.nowTitle,
            ),
            builder: streamPlayerBuilder,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageX,
                AppSpacing.lg,
                AppSpacing.pageX,
                AppSpacing.pageBottom,
              ),
              children: [
                Text('聊天室', style: context.typography.sectionTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '互动功能即将开放，当前仅展示模拟评论。',
                  key: const Key('tv-live-chat-coming-soon'),
                  style: context.typography.feedMeta.copyWith(
                    color: context.tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (var index = 0; index < _messages.length; index++) ...[
                  if (index == 2) const _ChatDateDivider(date: '2026-06-15'),
                  _ChatBubble(message: _messages[index]),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
          const _ChatInputBar(),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.time,
    required this.name,
    required this.content,
  });

  final String time;
  final String name;
  final String content;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: tokens.softFill,
          child: const Icon(Icons.person, size: AppIconSize.sm),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.time, style: context.typography.feedMeta),
              const SizedBox(height: AppSpacing.xs),
              Text(message.name, style: context.typography.feedTitleCompact),
              const SizedBox(height: AppSpacing.xxs),
              Text(message.content, style: context.typography.bodyText),
            ],
          ),
        ),
        IconButton(
          tooltip: '点赞功能即将开放',
          onPressed: null,
          icon: Icon(Icons.favorite_border, color: tokens.textTertiary),
        ),
      ],
    );
  }
}

class _ChatDateDivider extends StatelessWidget {
  const _ChatDateDivider({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Center(
        child: Text('- $date -', style: context.typography.feedMeta),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.sm,
          AppSpacing.pageX,
          AppSpacing.sm,
        ),
        // TODO: Wire this read-only prototype bar to the real chat service
        // when product scope reopens live interaction APIs.
        child: TextField(
          key: const Key('tv-live-chat-input'),
          readOnly: true,
          enableInteractiveSelection: false,
          decoration: InputDecoration(
            hintText: '互动评论即将开放',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }
}
