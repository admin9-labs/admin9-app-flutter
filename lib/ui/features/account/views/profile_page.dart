import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/foundation_page.dart';
import '../view_models/session_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    return FoundationPage(
      title: '账号资料',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.person_outline, size: 36),
          ),
          const SizedBox(height: 24),
          TextFormField(
            enabled: false,
            decoration: const InputDecoration(
              labelText: '昵称',
              hintText: '暂无资料',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            enabled: false,
            decoration: const InputDecoration(
              labelText: '手机号或邮箱',
              hintText: '暂无资料',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            session.isAuthenticated ? '资料服务尚未接入。' : '游客状态下没有账号资料。',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
