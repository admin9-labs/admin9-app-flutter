import 'package:flutter/widgets.dart'
    show
        BuildContext,
        Image,
        MainAxisSize,
        Row,
        SizedBox,
        StatelessWidget,
        Text,
        Widget;

import '../../admin9_ui.dart';
import '../../app/app_identity.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56, this.showName = true});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(AppIdentity.logoAsset, width: size, height: size),
        if (showName) ...[
          const SizedBox(width: 12),
          Text(AppIdentity.name, style: tokens.pageTitleTextStyle),
        ],
      ],
    );
  }
}
