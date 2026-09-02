import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class InitializationView extends StatelessWidget {
  const InitializationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return ColoredBox(
      key: const ValueKey('app-initialization-state'),
      color: theme.colors.background,
      child: SafeArea(
        child: Center(
          child: Semantics(
            liveRegion: true,
            label: context.tr('startup.initializing'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 24,
              children: [
                Image.asset(
                  'assets/images/brand/admin9_launch_logo.png',
                  width: 108,
                  height: 108,
                  excludeFromSemantics: true,
                ),
                const FCircularProgress(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
