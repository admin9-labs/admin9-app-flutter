import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Text(title, style: context.theme.typography.body.lg),
        Text(message, textAlign: TextAlign.center),
        if (actionLabel case final label?)
          FButton(
            mainAxisSize: MainAxisSize.min,
            onPress: onAction,
            child: Text(label),
          ),
      ],
    ),
  );
}
