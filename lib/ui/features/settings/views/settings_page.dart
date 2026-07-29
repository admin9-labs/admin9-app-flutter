import 'dart:async';

import 'package:flutter/widgets.dart'
    show
        BuildContext,
        Key,
        ListView,
        MediaQuery,
        MediaQueryData,
        Navigator,
        SizedBox,
        StatelessWidget,
        Widget;
import 'package:provider/provider.dart';

import '../../../../admin9_ui.dart';
import '../../../../app/app_route_names.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/appearance_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppearanceController>();
    final appearance = controller.appearance;
    final system = MediaQuery.of(context);
    return AppPage(
      title: '设置',
      parentLabel: '我的',
      navigationMode: AppPageNavigationMode.child,
      scrollable: false,
      body: ListView(
        children: [
          AppSection(
            title: '外观',
            children: [
              AppListTile(
                key: const Key('settings-theme'),
                title: '主题',
                currentValue: appearance.theme.label,
                disclosure: true,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.theme),
              ),
              AppListTile(
                key: const Key('settings-font-scale'),
                title: 'App 字号',
                currentValue: appearance.fontScale.label,
                disclosure: true,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.fontScale),
              ),
            ],
          ),
          AppSection(
            title: '辅助功能',
            footer: controller.persistenceFailed
                ? '设置暂未保存，请使用“重试保存设置”。'
                : _effectiveStatus(system, appearance),
            children: [
              AppSwitch(
                key: const Key('settings-grayscale'),
                label: '灰度',
                value: appearance.grayscale,
                onChanged: (value) => unawaited(
                  _saveBoolean(
                    context,
                    controller,
                    () => controller.setGrayscale(value),
                  ),
                ),
              ),
              AppSwitch(
                key: const Key('settings-high-contrast'),
                label: '高对比度',
                value: appearance.highContrast,
                onChanged: (value) => unawaited(
                  _saveBoolean(
                    context,
                    controller,
                    () => controller.setHighContrast(value),
                  ),
                ),
              ),
              AppSwitch(
                key: const Key('settings-reduce-motion'),
                label: '减少动态效果',
                value: appearance.reduceMotion,
                onChanged: (value) => unawaited(
                  _saveBoolean(
                    context,
                    controller,
                    () => controller.setReduceMotion(value),
                  ),
                ),
              ),
              if (controller.persistenceFailed)
                AppListTile(
                  key: const Key('settings-retry-persistence'),
                  title: '重试保存设置',
                  subtitle: '上次保存未完成，当前显示值尚未持久化。',
                  leadingIcon: AppIconRole.warning,
                  onTap: () =>
                      unawaited(_retryFromSettings(context, controller)),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _effectiveStatus(MediaQueryData system, AppAppearance appearance) {
    final requirements = <String>[
      if (system.highContrast) '系统高对比度已生效',
      if (system.disableAnimations) '系统减少动态效果已生效',
    ];
    if (requirements.isEmpty) {
      return 'App 偏好即时生效并自动保存；系统辅助设置始终具有更高优先级。';
    }
    return '${requirements.join('，')}；关闭 App 偏好不会削弱系统要求。';
  }

  Future<void> _saveBoolean(
    BuildContext context,
    AppearanceController controller,
    Future<void> Function() save,
  ) async {
    await save();
    if (!context.mounted || !controller.persistenceFailed) return;
    _showRetry(context, controller);
  }
}

class SettingsThemePage extends StatelessWidget {
  const SettingsThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppearanceController>();
    return AppSingleChoiceList<AppThemePreference>(
      title: '主题',
      value: controller.appearance.theme,
      choices: [
        for (final item in AppThemePreference.values)
          AppChoice(value: item, label: item.label),
      ],
      onChanged: (value) => unawaited(_saveTheme(context, controller, value)),
    );
  }

  Future<void> _saveTheme(
    BuildContext context,
    AppearanceController controller,
    AppThemePreference value,
  ) async {
    await controller.setTheme(value);
    if (!context.mounted || !controller.persistenceFailed) return;
    _showRetry(context, controller);
  }
}

class SettingsFontScalePage extends StatelessWidget {
  const SettingsFontScalePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppearanceController>();
    return AppSingleChoiceList<AppFontScale>(
      title: 'App 字号',
      value: controller.appearance.fontScale,
      choices: [
        for (final item in AppFontScale.values)
          AppChoice(value: item, label: item.label),
      ],
      onChanged: (value) =>
          unawaited(_saveFontScale(context, controller, value)),
    );
  }

  Future<void> _saveFontScale(
    BuildContext context,
    AppearanceController controller,
    AppFontScale value,
  ) async {
    await controller.setFontScale(value);
    if (!context.mounted || !controller.persistenceFailed) return;
    _showRetry(context, controller);
  }
}

void _showRetry(BuildContext context, AppearanceController controller) {
  final feedback = AppFeedbackHost.of(context);
  feedback.show(_retryRequest(feedback, controller));
}

AppFeedbackRequest _retryRequest(
  AppFeedbackController feedback,
  AppearanceController controller,
) => AppFeedbackRequest(
  message: '设置暂未保存。',
  tone: AppTone.error,
  actionLabel: '重试',
  onAction: () => unawaited(_retryPersistence(feedback, controller)),
);

Future<void> _retryPersistence(
  AppFeedbackController feedback,
  AppearanceController controller,
) async {
  await controller.retryPersistence();
  if (controller.persistenceFailed) {
    feedback.show(_retryRequest(feedback, controller));
  }
}

Future<void> _retryFromSettings(
  BuildContext context,
  AppearanceController controller,
) async {
  await controller.retryPersistence();
  if (!context.mounted || !controller.persistenceFailed) return;
  _showRetry(context, controller);
}
