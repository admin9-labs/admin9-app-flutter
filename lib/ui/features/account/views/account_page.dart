import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_route_names.dart';
import '../../../../core/widgets/settings_section.dart';
import '../view_models/session_controller.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const Key('account-page-list'),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Icon(
                      session.isAuthenticated
                          ? Icons.person
                          : Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.isAuthenticated ? '已登录' : '游客',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.isAuthenticated ? '会话已建立' : '当前没有用户会话',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!session.isAuthenticated)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.login),
                        child: const Text('登录'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
                        child: const Text('注册'),
                      ),
                    ),
                  ],
                ),
              ),
            SettingsSection(
              title: '账号',
              children: [
                _RouteTile(
                  icon: Icons.badge_outlined,
                  title: '账号资料',
                  route: AppRoutes.profile,
                ),
                _RouteTile(
                  icon: Icons.security_outlined,
                  title: '账号安全',
                  route: AppRoutes.accountSecurity,
                ),
                _RouteTile(
                  icon: Icons.manage_search_outlined,
                  title: '账号找回',
                  route: AppRoutes.accountRecovery,
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('退出登录'),
                  subtitle: session.isAuthenticated
                      ? null
                      : const Text('当前为游客状态'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _handleSignOut(context, session),
                ),
              ],
            ),
            const SettingsSection(
              title: '应用',
              children: [
                _RouteTile(
                  icon: Icons.settings_outlined,
                  title: '设置',
                  route: AppRoutes.settings,
                ),
                _RouteTile(
                  icon: Icons.description_outlined,
                  title: '用户协议',
                  route: AppRoutes.userAgreement,
                ),
                _RouteTile(
                  icon: Icons.privacy_tip_outlined,
                  title: '隐私政策',
                  route: AppRoutes.privacyPolicy,
                ),
                _RouteTile(
                  icon: Icons.info_outline,
                  title: '关于',
                  route: AppRoutes.about,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(
    BuildContext context,
    SessionController session,
  ) async {
    if (!session.isAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('当前没有可退出的会话。')));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定退出当前会话吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('退出'),
          ),
        ],
      ),
    );
    if (confirmed == true) session.signOut();
  }
}

class _RouteTile extends StatelessWidget {
  const _RouteTile({
    required this.icon,
    required this.title,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
