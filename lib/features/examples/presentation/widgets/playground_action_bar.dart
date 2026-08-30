import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class PlaygroundActionBar extends StatelessWidget {
  const PlaygroundActionBar({
    super.key,
    required this.copyLabel,
    required this.resetLabel,
    required this.onCopy,
    required this.onReset,
    this.enabled = true,
  });

  final String copyLabel;
  final String resetLabel;
  final VoidCallback onCopy;
  final VoidCallback onReset;
  final bool enabled;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked =
          constraints.maxWidth < 480 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.4;
      final buttons = [
        _ActionButton(
          key: const ValueKey('playground-reset'),
          label: resetLabel,
          icon: FLucideIcons.rotateCcw,
          variant: .outline,
          onPress: enabled ? onReset : null,
          expanded: stacked,
        ),
        _ActionButton(
          key: const ValueKey('playground-copy'),
          label: copyLabel,
          icon: FLucideIcons.copy,
          onPress: enabled ? onCopy : null,
          expanded: stacked,
        ),
      ];

      if (stacked) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: buttons,
        );
      }

      return Wrap(
        alignment: WrapAlignment.end,
        runAlignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: buttons,
      );
    },
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPress,
    required this.expanded,
    this.variant = FButtonVariant.primary,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPress;
  final bool expanded;
  final FButtonVariant variant;

  @override
  Widget build(BuildContext context) => FButton(
    variant: variant,
    mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
    prefix: Icon(icon),
    onPress: onPress,
    builder: (_, _, _, _, _, child) =>
        expanded ? Expanded(child: child!) : child!,
    child: Text(label, textAlign: TextAlign.center),
  );
}
