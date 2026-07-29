import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/foundation_page.dart';
import '../../../../core/widgets/unavailable_notice.dart';
import '../view_models/auth_form_view_model.dart';

enum AuthFlow {
  login('登录', '登录'),
  register('注册', '提交注册'),
  forgotPassword('忘记密码', '继续'),
  resetPassword('重置密码', '重置密码'),
  changePassword('修改密码', '修改密码'),
  accountRecovery('账号找回', '提交找回');

  const AuthFlow(this.title, this.actionLabel);

  final String title;
  final String actionLabel;
}

class AuthFormPage extends StatelessWidget {
  const AuthFormPage({super.key, required this.flow});

  final AuthFlow flow;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthFormViewModel(),
      child: _AuthFormView(flow: flow),
    );
  }
}

class _AuthFormView extends StatefulWidget {
  const _AuthFormView({required this.flow});

  final AuthFlow flow;

  @override
  State<_AuthFormView> createState() => _AuthFormViewState();
}

class _AuthFormViewState extends State<_AuthFormView> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthFormViewModel>();
    return FoundationPage(
      title: widget.flow.title,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: viewModel.resetStatus,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_needsAccount)
                TextFormField(
                  key: const Key('auth-account-field'),
                  controller: _accountController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  decoration: const InputDecoration(
                    labelText: '手机号或邮箱',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _validateAccount,
                ),
              if (_needsAccount) const SizedBox(height: 16),
              if (widget.flow == AuthFlow.changePassword) ...[
                _PasswordField(
                  controller: _currentPasswordController,
                  label: '当前密码',
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
              ],
              if (_needsPassword) ...[
                _PasswordField(
                  key: const Key('auth-password-field'),
                  controller: _passwordController,
                  label: _passwordLabel,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
              ],
              if (_needsConfirmation) ...[
                _PasswordField(
                  key: const Key('auth-confirmation-field'),
                  controller: _confirmationController,
                  label: '确认新密码',
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value != _passwordController.text) return '两次输入的密码不一致';
                    return _validatePassword(value);
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (viewModel.state == AuthSubmissionState.unavailable) ...[
                const UnavailableNotice(),
                const SizedBox(height: 16),
              ],
              FilledButton(
                key: const Key('auth-submit-button'),
                onPressed: _submit,
                child: Text(widget.flow.actionLabel),
              ),
              const SizedBox(height: 12),
              ..._secondaryActions(context),
            ],
          ),
        ),
      ),
    );
  }

  bool get _needsAccount => switch (widget.flow) {
    AuthFlow.login ||
    AuthFlow.register ||
    AuthFlow.forgotPassword ||
    AuthFlow.accountRecovery => true,
    _ => false,
  };

  bool get _needsPassword => switch (widget.flow) {
    AuthFlow.login ||
    AuthFlow.register ||
    AuthFlow.resetPassword ||
    AuthFlow.changePassword => true,
    _ => false,
  };

  bool get _needsConfirmation => switch (widget.flow) {
    AuthFlow.register ||
    AuthFlow.resetPassword ||
    AuthFlow.changePassword => true,
    _ => false,
  };

  String get _passwordLabel => switch (widget.flow) {
    AuthFlow.login => '密码',
    _ => '新密码',
  };

  String? _validateAccount(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return '请输入手机号或邮箱';
    if (normalized.length < 5 || normalized.contains(' ')) {
      return '请输入有效的手机号或邮箱';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return '请输入密码';
    if (value.length < 8) return '密码至少需要 8 位';
    return null;
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthFormViewModel>().submitValidatedForm();
  }

  List<Widget> _secondaryActions(BuildContext context) => switch (widget.flow) {
    AuthFlow.login => [
      TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
        child: const Text('忘记密码'),
      ),
      TextButton(
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.register),
        child: const Text('注册账号'),
      ),
    ],
    AuthFlow.register => [
      TextButton(
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.login),
        child: const Text('返回登录'),
      ),
    ],
    AuthFlow.forgotPassword => [
      TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.resetPassword),
        child: const Text('已有重置凭据'),
      ),
    ],
    _ => const [],
  };
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final TextInputAction textInputAction;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _obscure ? '显示密码' : '隐藏密码',
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
      validator: widget.validator,
    );
  }
}
