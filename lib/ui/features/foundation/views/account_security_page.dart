import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/foundation_page.dart';
import '../../../../core/widgets/primary_pill_button.dart';
import '../../../../core/widgets/settings_group.dart';
import '../../mine/views/auth_page.dart';
import '../../mine/view_models/session_view_model.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionViewModel>().user;
    final tokens = context.tokens;

    if (user == null) {
      return FoundationPage(
        title: '账号与安全',
        children: [
          SettingsGroup(
            children: const [SettingsRow(title: '手机号', value: '未登录')],
          ),
          const SectionGap(),
          Text(
            '登录后可管理手机号、第三方账号绑定和账号注销。',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryPillButton(
            key: const Key('account-security-login'),
            onPressed: () => AppNavigator.push(context, const AuthPage()),
            label: '去登录',
          ),
        ],
      );
    }

    return FoundationPage(
      title: '账号与安全',
      children: [
        SettingsGroup(
          children: [SettingsRow(title: '手机号', value: user.phone)],
        ),
        const SectionGap(),
        SettingsGroup(
          children: [
            SettingsRow(
              title: 'QQ',
              icon: Icons.chat_bubble_outline,
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
            SettingsRow(
              title: '微信',
              icon: Icons.wechat,
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
            SettingsRow(
              title: '微博',
              icon: Icons.alternate_email,
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
            SettingsRow(
              title: '苹果',
              icon: Icons.apple,
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Center(
          child: Text(
            '永久注销账号',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: tokens.textTertiary),
          ),
        ),
      ],
    );
  }
}
