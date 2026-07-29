import 'package:flutter/widgets.dart'
    show BuildContext, ListView, Navigator, StatelessWidget, Widget;

import '../../../../admin9_ui.dart';
import '../../../../app/app_route_names.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '账号安全',
      navigationMode: AppPageNavigationMode.child,
      parentLabel: '我的',
      scrollable: false,
      body: ListView(
        children: [
          AppListTile(
            title: '修改密码',
            disclosure: true,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.changePassword,
              arguments: '账号安全',
            ),
          ),
          AppListTile(
            title: '账号找回',
            disclosure: true,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.accountRecovery,
              arguments: '账号安全',
            ),
          ),
          AppListTile(
            title: '账号注销（不可逆）',
            leadingIcon: AppIconRole.warning,
            disclosure: true,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.accountDeletion),
          ),
        ],
      ),
    );
  }
}
