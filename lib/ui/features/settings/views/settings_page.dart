import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/appearance_controller.dart';
import '../../../../core/widgets/foundation_page.dart';
import '../../../../core/widgets/settings_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppearanceController>();
    final appearance = controller.appearance;
    return FoundationPage(
      title: '设置',
      padding: EdgeInsets.zero,
      child: ListView(
        children: [
          SettingsSection(
            title: '外观',
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SegmentedButton<AppThemePreference>(
                  segments: [
                    for (final item in AppThemePreference.values)
                      ButtonSegment(value: item, label: Text(item.label)),
                  ],
                  selected: {appearance.theme},
                  onSelectionChanged: (value) =>
                      controller.setTheme(value.first),
                  showSelectedIcon: false,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('字体大小'),
                trailing: DropdownButton<AppFontScale>(
                  value: appearance.fontScale,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final item in AppFontScale.values)
                      DropdownMenuItem(value: item, child: Text(item.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setFontScale(value);
                  },
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.tonality_outlined),
                title: const Text('全局灰度'),
                value: appearance.grayscale,
                onChanged: controller.setGrayscale,
              ),
            ],
          ),
          SettingsSection(
            title: '无障碍',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.contrast),
                title: const Text('增强对比度'),
                value: appearance.highContrast,
                onChanged: controller.setHighContrast,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.motion_photos_off_outlined),
                title: const Text('减少动态效果'),
                value: appearance.reduceMotion,
                onChanged: controller.setReduceMotion,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
