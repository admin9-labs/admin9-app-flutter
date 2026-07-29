import 'package:flutter/material.dart';

import '../../../../app/app_route_names.dart';
import '../../../../core/widgets/foundation_page.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      title: '账号安全',
      padding: EdgeInsets.zero,
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.password_outlined),
            title: const Text('修改密码'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
          ),
          ListTile(
            leading: const Icon(Icons.manage_search_outlined),
            title: const Text('账号找回'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.accountRecovery),
          ),
          ListTile(
            leading: Icon(
              Icons.person_remove_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              '账号注销',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.accountDeletion),
          ),
        ],
      ),
    );
  }
}
