import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/foundation_page.dart';
import '../../../../core/widgets/unavailable_notice.dart';
import '../view_models/account_action_view_model.dart';

class AccountDeletionPage extends StatelessWidget {
  const AccountDeletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountActionViewModel(),
      child: const _AccountDeletionForm(),
    );
  }
}

class _AccountDeletionForm extends StatefulWidget {
  const _AccountDeletionForm();

  @override
  State<_AccountDeletionForm> createState() => _AccountDeletionFormState();
}

class _AccountDeletionFormState extends State<_AccountDeletionForm> {
  final _formKey = GlobalKey<FormState>();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AccountActionViewModel>();
    return FoundationPage(
      title: '账号注销',
      child: Form(
        key: _formKey,
        onChanged: viewModel.resetStatus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('注销属于不可逆账号操作。当前版本未连接账号服务，不会执行注销。'),
            const SizedBox(height: 20),
            TextFormField(
              controller: _confirmation,
              decoration: const InputDecoration(labelText: '输入“确认注销”'),
              validator: (value) => value == '确认注销' ? null : '请输入“确认注销”',
            ),
            const SizedBox(height: 16),
            if (viewModel.unavailable) ...[
              const UnavailableNotice(),
              const SizedBox(height: 16),
            ],
            FilledButton.tonal(
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? false)) return;
                viewModel.submitValidatedAction();
              },
              child: const Text('申请注销'),
            ),
          ],
        ),
      ),
    );
  }
}
