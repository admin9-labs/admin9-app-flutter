import 'package:flutter/material.dart' show SelectionArea;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class PlaygroundCodePanel extends StatelessWidget {
  const PlaygroundCodePanel({
    super.key,
    required this.title,
    required this.summary,
    required this.code,
  });

  final String title;
  final String summary;
  final String code;

  @override
  Widget build(BuildContext context) => FCard(
    builder: (context, style, _) => Padding(
      padding: style.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(title, style: style.titleTextStyle),
          Text(
            key: const ValueKey('playground-parameter-summary'),
            summary,
            style: style.subtitleTextStyle,
          ),
          SelectionArea(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.theme.colors.muted,
                borderRadius: context.theme.style.borderRadius.md,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  key: const ValueKey('playground-code'),
                  code,
                  style: context.theme.typography.body.sm,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
