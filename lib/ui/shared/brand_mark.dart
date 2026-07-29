import 'package:flutter/material.dart';

import '../../app/app_identity.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56, this.showName = true});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(AppIdentity.logoAsset, width: size, height: size),
        if (showName) ...[
          const SizedBox(width: 12),
          Text(
            AppIdentity.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );
  }
}
