import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../domain/models/media_channel.dart';
import '../view_models/channel_view_model.dart';

class ChannelManagementPage extends StatefulWidget {
  const ChannelManagementPage({super.key, this.currentChannelId});

  final String? currentChannelId;

  @override
  State<ChannelManagementPage> createState() => _ChannelManagementPageState();
}

class _ChannelManagementPageState extends State<ChannelManagementPage> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.pageBackground,
      body: SafeArea(
        child: Consumer<ChannelViewModel>(
          builder: (context, viewModel, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth > AppSpacing.contentMaxWidth
                    ? AppSpacing.contentMaxWidth
                    : constraints.maxWidth;

                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: width,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageX,
                        AppSpacing.sm,
                        AppSpacing.pageX,
                        AppSpacing.pageBottom,
                      ),
                      children: [
                        _Header(
                          onClose: () => Navigator.of(context).pop(),
                          onReset: () => _confirmReset(context, viewModel),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _ChannelSection(
                          title: '我的频道',
                          description: _editing ? '长按排序' : null,
                          actionLabel: _editing ? '完成' : '编辑',
                          onAction: () => setState(() => _editing = !_editing),
                          child: _ChannelWrap(
                            channels: viewModel.myChannels,
                            editing: _editing,
                            selectedChannelId: widget.currentChannelId,
                            onTap: (channel) {
                              if (_editing) return;
                              Navigator.of(context).pop(channel.id);
                            },
                            onRemove: viewModel.removeChannel,
                            onMove: (dragged, target) => viewModel.moveChannel(
                              draggedId: dragged.id,
                              targetId: target.id,
                            ),
                          ),
                        ),
                        if (viewModel.moreChannels.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.cardGap),
                          _ChannelSection(
                            title: '选择频道',
                            child: _MoreChannelWrap(
                              channels: viewModel.moreChannels,
                              onAdd: viewModel.addChannel,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    ChannelViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('恢复默认频道和排序？'),
          content: const Text('将恢复系统默认频道列表，“推荐”会保持在首位。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              key: const Key('confirm-reset-channels'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('恢复默认'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await viewModel.resetDefault();
      if (mounted) setState(() => _editing = false);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose, required this.onReset});

  final VoidCallback onClose;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        IconButton(
          key: const Key('close-channel-management'),
          tooltip: '关闭',
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded, size: AppIconSize.action),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            '频道管理',
            style: context.typography.heroTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: tokens.textPrimary,
            ),
          ),
        ),
        TextButton.icon(
          key: const Key('reset-channels-button'),
          onPressed: onReset,
          style: TextButton.styleFrom(
            foregroundColor: tokens.brand.primary.withValues(alpha: 0.9),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            textStyle: context.typography.actionLabel,
          ),
          icon: const Icon(Icons.restart_alt_rounded, size: 17),
          label: const Text('恢复默认'),
        ),
      ],
    );
  }
}

class _ChannelSection extends StatelessWidget {
  const _ChannelSection({
    required this.title,
    required this.child,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? description;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: title,
            subtitle: description,
            dense: true,
            actionLabel: label,
            onActionTap: onAction,
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _ChannelWrap extends StatelessWidget {
  const _ChannelWrap({
    required this.channels,
    required this.editing,
    required this.selectedChannelId,
    required this.onTap,
    required this.onRemove,
    required this.onMove,
  });

  final List<MediaChannel> channels;
  final bool editing;
  final String? selectedChannelId;
  final ValueChanged<MediaChannel> onTap;
  final ValueChanged<MediaChannel> onRemove;
  final void Function(MediaChannel dragged, MediaChannel target) onMove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var index = 0; index < channels.length; index++)
          _EditableChannelChip(
            channel: channels[index],
            editing: editing,
            selected:
                selectedChannelId == channels[index].id ||
                (selectedChannelId == null && index == 0),
            onTap: () => onTap(channels[index]),
            onRemove: () => onRemove(channels[index]),
            onMove: (dragged) => onMove(dragged, channels[index]),
          ),
      ],
    );
  }
}

class _MoreChannelWrap extends StatelessWidget {
  const _MoreChannelWrap({required this.channels, required this.onAdd});

  final List<MediaChannel> channels;
  final ValueChanged<MediaChannel> onAdd;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final channel in channels)
          ActionChip(
            key: Key('add-channel-${channel.id}'),
            avatar: Icon(
              Icons.add_rounded,
              size: 18,
              color: tokens.textPrimary,
            ),
            label: Text(
              channel.label,
              textAlign: TextAlign.center,
              style: context.typography.actionLabel.copyWith(
                color: tokens.textPrimary,
              ),
            ),
            onPressed: () => onAdd(channel),
            backgroundColor: tokens.softFill,
            side: BorderSide(color: tokens.divider),
            shape: const StadiumBorder(),
            visualDensity: VisualDensity.compact,
            labelPadding: const EdgeInsets.only(right: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
          ),
      ],
    );
  }
}

class _EditableChannelChip extends StatelessWidget {
  const _EditableChannelChip({
    required this.channel,
    required this.editing,
    required this.selected,
    required this.onTap,
    required this.onRemove,
    required this.onMove,
  });

  final MediaChannel channel;
  final bool editing;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final ValueChanged<MediaChannel> onMove;

  @override
  Widget build(BuildContext context) {
    final chip = _ChipShell(
      channel: channel,
      editing: editing,
      selected: selected,
      onTap: onTap,
      onRemove: onRemove,
    );

    return DragTarget<MediaChannel>(
      onWillAcceptWithDetails: (details) {
        return editing && !channel.fixed && details.data.id != channel.id;
      },
      onAcceptWithDetails: (details) => onMove(details.data),
      builder: (context, candidateData, _) {
        final highlighted = candidateData.isNotEmpty;
        final target = AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: highlighted ? const EdgeInsets.all(2) : EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
            border: highlighted
                ? Border.all(color: context.tokens.brand.primary, width: 2)
                : null,
          ),
          child: chip,
        );

        if (!editing || channel.fixed) return target;
        return LongPressDraggable<MediaChannel>(
          data: channel,
          feedback: Material(
            color: Colors.transparent,
            child: _ChipShell(
              channel: channel,
              editing: editing,
              selected: selected,
              onTap: onTap,
              onRemove: onRemove,
              elevated: true,
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: target),
          child: target,
        );
      },
    );
  }
}

class _ChipShell extends StatelessWidget {
  const _ChipShell({
    required this.channel,
    required this.editing,
    required this.selected,
    required this.onTap,
    required this.onRemove,
    this.elevated = false,
  });

  final MediaChannel channel;
  final bool editing;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = selected
        ? (dark ? tokens.textPrimary : tokens.brand.primary)
        : tokens.softFill;
    final foreground = selected
        ? (dark ? tokens.pageBackground : Colors.white)
        : tokens.textPrimary;

    return Material(
      elevation: elevated ? 6 : 0,
      color: background,
      shadowColor: Colors.black26,
      shape: const StadiumBorder(),
      child: InkWell(
        key: Key('my-channel-${channel.id}'),
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppSpacing.minTouchTarget * 1.55,
            minHeight: AppSpacing.minTouchTarget,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: editing && !channel.fixed
                  ? AppSpacing.md
                  : AppSpacing.lg,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (editing && !channel.fixed) ...[
                  GestureDetector(
                    key: Key('remove-channel-${channel.id}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: onRemove,
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ] else if (editing && channel.fixed) ...[
                  Icon(Icons.lock_rounded, size: 16, color: foreground),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    channel.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.typography.actionLabel.fontSize,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
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
