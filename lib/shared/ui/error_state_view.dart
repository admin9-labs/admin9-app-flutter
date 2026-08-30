import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Text(title, style: context.theme.typography.body.lg),
        Text(message, textAlign: TextAlign.center),
        if (onRetry case final onRetry?)
          FButton(
            mainAxisSize: MainAxisSize.min,
            onPress: onRetry,
            child: Text(retryLabel ?? title),
          ),
      ],
    ),
  );
}
