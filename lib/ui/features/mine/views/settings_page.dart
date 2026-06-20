import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/appearance_controller.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/foundation_page.dart';
import '../../../../core/widgets/primary_pill_button.dart';
import '../../../../core/widgets/settings_group.dart';
import '../../foundation/views/about_page.dart';
import '../../foundation/views/account_security_page.dart';
import '../../foundation/views/appearance_page.dart';
import '../../foundation/views/feedback_page.dart';
import '../../foundation/views/font_size_page.dart';
import '../../foundation/views/harmful_report_page.dart';
import '../../../shared/app_state_controller.dart';
import '../view_models/session_view_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceController>();
    final session = context.watch<SessionViewModel>();
    final appState = context.watch<AppStateController>();
    final user = session.user;

    return FoundationPage(
      title: '设置',
      children: [
        SettingsGroup(
          children: [
            SettingsRow(
              title: '账号与安全',
              value: user?.maskedPhone ?? '未登录',
              onTap: () =>
                  AppNavigator.push(context, const AccountSecurityPage()),
            ),
          ],
        ),
        const SectionGap(),
        SettingsGroup(
          children: [
            SettingsRow(
              title: '字体大小',
              value: _fontLabel(appearance.settings.fontLevel),
              onTap: () => AppNavigator.push(context, const FontSizePage()),
            ),
            SettingsRow(
              title: '外观主题',
              value: appearance.brand.label,
              onTap: () => AppNavigator.push(context, const AppearancePage()),
            ),
            SettingsRow(
              title: '接收推送',
              trailing: Switch(
                key: const Key('settings-push-switch'),
                value: appState.pushEnabled,
                onChanged: appState.setPushEnabled,
              ),
            ),
          ],
        ),
        const SectionGap(),
        SettingsGroup(
          children: [
            SettingsRow(
              title: '有害信息举报',
              onTap: () =>
                  AppNavigator.push(context, const HarmfulReportPage()),
            ),
            SettingsRow(
              title: '意见反馈',
              onTap: () => AppNavigator.push(context, const FeedbackPage()),
            ),
            SettingsRow(title: '清理缓存', value: '807.83MB', onTap: _clearCache),
            SettingsRow(
              title: '关于',
              onTap: () => AppNavigator.push(context, const AboutPage()),
            ),
          ],
        ),
        const SectionGap(height: AppSpacing.xxl),
        PrimaryPillButton(
          key: const Key('settings-logout'),
          onPressed: user == null ? null : session.logout,
          label: '退出登录',
          destructive: true,
        ),
      ],
    );
  }

  String _fontLabel(AppFontLevel level) {
    return switch (level) {
      AppFontLevel.standard => '标准字体',
      AppFontLevel.medium => '中号字体',
      AppFontLevel.large => '大号字体',
    };
  }

  void _clearCache() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('缓存已清理')));
  }
}
