import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../admin9_ui.dart';
import '../../../../app/app_route_names.dart';
import '../view_models/session_controller.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    return AppPage(
      title: '我的',
      navigationMode: AppPageNavigationMode.root,
      scrollable: false,
      body: Material(
        type: MaterialType.transparency,
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
                child: _GuestActions(
                  compact: MediaQuery.sizeOf(context).width <= 320,
                ),
              ),
            AppSection(
              title: '账号',
              children: [
                if (session.isAuthenticated) ...[
                  const _RouteTile(title: '账号资料', route: AppRoutes.profile),
                  const _RouteTile(
                    title: '账号安全',
                    route: AppRoutes.accountSecurity,
                  ),
                ],
                _RouteTile(title: '账号找回', route: AppRoutes.accountRecovery),
              ],
            ),
            const AppSection(
              title: '应用',
              children: [
                _RouteTile(title: '设置', route: AppRoutes.settings),
                _RouteTile(title: '用户协议', route: AppRoutes.userAgreement),
                _RouteTile(title: '隐私政策', route: AppRoutes.privacyPolicy),
                _RouteTile(title: '关于', route: AppRoutes.about),
              ],
            ),
            if (session.isAuthenticated)
              AppSection(
                title: '会话',
                children: [
                  AppListTile(
                    title: '退出登录',
                    leadingIcon: AppIconRole.warning,
                    onTap: () => _handleSignOut(context, session),
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
      AppFeedbackHost.of(context).show(
        const AppFeedbackRequest(message: '当前没有可退出的会话。', tone: AppTone.info),
      );
      return;
    }
    final confirmed = await AppInteractionHost.of(context).showConfirmation(
      title: '退出登录',
      message: '确定退出当前会话吗？',
      confirmLabel: '退出',
    );
    if (confirmed) session.signOut();
  }
}

class _GuestActions extends StatelessWidget {
  const _GuestActions({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final login = AppButton(
      label: '登录',
      onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
    );
    final register = AppButton(
      label: '注册',
      variant: AppButtonVariant.secondary,
      onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
    );
    if (compact) {
      return Column(
        key: const Key('guest-actions-column'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [login, const SizedBox(height: 12), register],
      );
    }
    return Row(
      key: const Key('guest-actions-row'),
      children: [
        Expanded(child: login),
        const SizedBox(width: 12),
        Expanded(child: register),
      ],
    );
  }
}

class _RouteTile extends StatelessWidget {
  const _RouteTile({required this.title, required this.route});

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: title,
      disclosure: true,
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
