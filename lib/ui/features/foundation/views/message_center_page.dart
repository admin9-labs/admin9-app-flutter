import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_tab_bar.dart';
import '../../../../core/widgets/message_card.dart';
import '../../../../data/repositories/foundation_repository.dart';
import '../../../../domain/models/foundation_models.dart';

class MessageCenterPage extends StatefulWidget {
  const MessageCenterPage({super.key});

  @override
  State<MessageCenterPage> createState() => _MessageCenterPageState();
}

class _MessageCenterPageState extends State<MessageCenterPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  static const _tabs = [
    _MessageTab('评论', MessageCategory.comments),
    _MessageTab('获赞', MessageCategory.likes),
    _MessageTab('系统消息', MessageCategory.system),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: _tabs.length - 1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<FoundationRepository>();
    final messages = repository.messages;

    return Scaffold(
      appBar: AppBar(
        title: AppTabBar(
          controller: _controller,
          tabs: [for (final tab in _tabs) Tab(text: tab.label)],
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > AppSpacing.contentMaxWidth
                ? AppSpacing.contentMaxWidth
                : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                key: const Key('message-center-content'),
                width: width,
                child: TabBarView(
                  controller: _controller,
                  children: [
                    for (final tab in _tabs)
                      _MessageList(
                        messages: messages
                            .where(
                              (message) => message.category == tab.category,
                            )
                            .toList(),
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

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages});

  final List<FoundationMessage> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text('暂无消息', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageX,
        AppSpacing.pageTop,
        AppSpacing.pageX,
        AppSpacing.pageBottom,
      ),
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageCard(
          title: message.title,
          time: message.time,
          unread: message.unread,
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
      itemCount: messages.length,
    );
  }
}

class _MessageTab {
  const _MessageTab(this.label, this.category);

  final String label;
  final MessageCategory category;
}
