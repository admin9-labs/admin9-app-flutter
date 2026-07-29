import 'package:flutter/widgets.dart'
    show
        BuildContext,
        Center,
        ClipOval,
        ColoredBox,
        ExcludeSemantics,
        Semantics,
        SizedBox,
        StatelessWidget,
        Text,
        Widget;

import '../../../../admin9_ui.dart';

class AccountIdentityMark extends StatelessWidget {
  const AccountIdentityMark({
    super.key,
    required this.size,
    required this.label,
  });

  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return Semantics(
      image: true,
      label: label,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: ClipOval(
            child: ColoredBox(
              color: tokens.surfaceContainer,
              child: Center(
                child: Text(
                  '我',
                  style: tokens.pageTitleTextStyle.copyWith(
                    color: tokens.onSurfaceContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
