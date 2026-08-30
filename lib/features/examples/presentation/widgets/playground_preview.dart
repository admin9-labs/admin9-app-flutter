import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class PlaygroundPreview extends StatelessWidget {
  const PlaygroundPreview({
    super.key,
    required this.title,
    required this.child,
    this.status,
  });

  final String title;
  final Widget child;
  final String? status;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: [
      Text(title, style: context.theme.typography.body.lg),
      child,
      if (status case final status?)
        Semantics(
          liveRegion: true,
          container: true,
          child: Text(
            key: const ValueKey('playground-status'),
            status,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
    ],
  );
}
