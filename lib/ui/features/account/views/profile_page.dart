import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../admin9_ui.dart';
import '../view_models/session_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    return AppPage(
      title: '账号资料',
      navigationMode: AppPageNavigationMode.child,
      parentLabel: '我的',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.person_outline, size: 36),
          ),
          const SizedBox(height: 24),
          const AppSection(
            title: '身份信息',
            children: [
              AppListTile(title: '昵称', currentValue: '暂无资料'),
              AppListTile(title: '手机号或邮箱', currentValue: '暂无资料'),
            ],
          ),
          const SizedBox(height: 20),
          AppNotice(
            tone: AppTone.info,
            message: session.isAuthenticated ? '资料服务尚未接入。' : '游客状态下没有账号资料。',
          ),
        ],
      ),
    );
  }
}
