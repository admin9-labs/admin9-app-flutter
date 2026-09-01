import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class PlaygroundActionBar extends StatelessWidget {
  const PlaygroundActionBar({
    super.key,
    required this.resetLabel,
    required this.onReset,
    this.enabled = true,
  });

  final String resetLabel;
  final VoidCallback onReset;
  final bool enabled;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked =
          constraints.maxWidth < 480 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.4;
      final button = FButton(
        key: const ValueKey('playground-reset'),
        variant: .outline,
        mainAxisSize: stacked ? MainAxisSize.max : MainAxisSize.min,
        prefix: const Icon(FLucideIcons.rotateCcw),
        onPress: enabled ? onReset : null,
        builder: (_, _, _, _, _, child) =>
            stacked ? Expanded(child: child!) : child!,
        child: Text(resetLabel, textAlign: TextAlign.center),
      );

      return stacked
          ? button
          : Align(alignment: AlignmentDirectional.centerEnd, child: button);
    },
  );
}
