import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/appearance_controller.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/widgets/foundation_page.dart';
import '../../../../core/widgets/settings_group.dart';

class FontSizePage extends StatelessWidget {
  const FontSizePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceController>();
    final selected = appearance.settings.fontLevel;

    return FoundationPage(
      title: '字体大小',
      children: [
        SettingsGroup(
          children: [
            for (final level in AppFontLevel.values)
              SettingsRow(
                title: _label(level),
                trailing: selected == level
                    ? Icon(Icons.check, color: context.tokens.textPrimary)
                    : const SizedBox.shrink(),
                onTap: () => appearance.setFontLevel(level),
              ),
          ],
        ),
      ],
    );
  }

  String _label(AppFontLevel level) {
    return switch (level) {
      AppFontLevel.standard => '标准字体',
      AppFontLevel.medium => '中号字体',
      AppFontLevel.large => '大号字体',
    };
  }
}
