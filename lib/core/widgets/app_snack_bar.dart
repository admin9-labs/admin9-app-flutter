import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

void showAppSnackBar(BuildContext context, String message) {
  final normalized = message.trim();
  if (normalized.isEmpty) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(normalized),
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pageX,
        0,
        AppSpacing.pageX,
        AppSpacing.pageBottom,
      ),
    ),
  );
}
