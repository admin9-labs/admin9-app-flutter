import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../admin9_ui.dart';
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
  final _confirmationFocus = FocusNode();

  @override
  void dispose() {
    _confirmation.dispose();
    _confirmationFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AccountActionViewModel>();
    return AppPage(
      title: '账号注销',
      navigationMode: AppPageNavigationMode.child,
      parentLabel: '账号安全',
      body: Form(
        key: _formKey,
        onChanged: viewModel.resetStatus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('注销属于不可逆账号操作。当前版本未连接账号服务，不会执行注销。'),
            const SizedBox(height: 20),
            AppTextField(
              key: const Key('account-deletion-confirmation-field'),
              controller: _confirmation,
              focusNode: _confirmationFocus,
              label: '输入“确认注销”',
              textInputAction: TextInputAction.done,
              validator: (value) => value == '确认注销' ? null : '请输入“确认注销”',
              onFieldSubmitted: (_) => _submit(viewModel),
            ),
            const SizedBox(height: 16),
            if (viewModel.unavailable) ...[
              const AppNotice(
                tone: AppTone.info,
                message: '服务尚未接入，当前操作不会提交或保存。',
              ),
              const SizedBox(height: 16),
            ],
            AppButton(
              label: '申请注销',
              variant: AppButtonVariant.destructive,
              onPressed: () => _submit(viewModel),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(AccountActionViewModel viewModel) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      _confirmationFocus.requestFocus();
      return;
    }
    viewModel.submitValidatedAction();
  }
}
