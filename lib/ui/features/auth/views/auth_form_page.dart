import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    show
        AutofillGroup,
        AutovalidateMode,
        BuildContext,
        Column,
        CrossAxisAlignment,
        ExcludeSemantics,
        FocusManager,
        FocusNode,
        Form,
        FormState,
        GlobalKey,
        Key,
        Navigator,
        Semantics,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        TextEditingController,
        TextInputType,
        Widget;
import 'package:provider/provider.dart';

import '../../../../admin9_ui.dart';
import '../../../../app/app_route_names.dart';
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
  const AuthFormPage({
    super.key,
    required this.flow,
    required this.parentLabel,
  });

  final AuthFlow flow;
  final String parentLabel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthFormViewModel(),
      child: _AuthFormView(flow: flow, parentLabel: parentLabel),
    );
  }
}

class _AuthFormView extends StatefulWidget {
  const _AuthFormView({required this.flow, required this.parentLabel});

  final AuthFlow flow;
  final String parentLabel;

  @override
  State<_AuthFormView> createState() => _AuthFormViewState();
}

class _AuthFormViewState extends State<_AuthFormView> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _accountFocus = FocusNode();
  final _currentPasswordFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmationFocus = FocusNode();

  @override
  void dispose() {
    _accountController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    _accountFocus.dispose();
    _currentPasswordFocus.dispose();
    _passwordFocus.dispose();
    _confirmationFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthFormViewModel>();
    return AppPage(
      title: widget.flow.title,
      navigationMode: AppPageNavigationMode.child,
      parentLabel: widget.parentLabel,
      body: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: viewModel.resetStatus,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_needsAccount)
                AppTextField(
                  key: const Key('auth-account-field'),
                  controller: _accountController,
                  label: '手机号或邮箱',
                  focusNode: _accountFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: _needsPassword
                      ? TextInputAction.next
                      : TextInputAction.done,
                  autofillHints: const [AutofillHints.username],
                  validator: _validateAccount,
                  onFieldSubmitted: (_) => _focusAfterAccount(),
                ),
              if (_needsAccount) const SizedBox(height: 16),
              if (widget.flow == AuthFlow.changePassword) ...[
                AppTextField(
                  controller: _currentPasswordController,
                  label: '当前密码',
                  focusNode: _currentPasswordFocus,
                  validator: _validatePassword,
                  obscureText: true,
                  showObscureToggle: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
              ],
              if (_needsPassword) ...[
                AppTextField(
                  key: const Key('auth-password-field'),
                  controller: _passwordController,
                  label: _passwordLabel,
                  focusNode: _passwordFocus,
                  validator: _validatePassword,
                  obscureText: true,
                  showObscureToggle: true,
                  textInputAction: _needsConfirmation
                      ? TextInputAction.next
                      : TextInputAction.done,
                  autofillHints: [_passwordAutofillHint],
                  onFieldSubmitted: (_) => _needsConfirmation
                      ? _confirmationFocus.requestFocus()
                      : _submit(),
                ),
                const SizedBox(height: 16),
              ],
              if (_needsConfirmation) ...[
                AppTextField(
                  key: const Key('auth-confirmation-field'),
                  controller: _confirmationController,
                  label: '确认新密码',
                  focusNode: _confirmationFocus,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  showObscureToggle: true,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) {
                    if (value != _passwordController.text) return '两次输入的密码不一致';
                    return _validatePassword(value);
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
              ],
              if (viewModel.state == AuthSubmissionState.unavailable) ...[
                Semantics(
                  liveRegion: true,
                  label: '信息，服务尚未接入，当前操作不会提交或保存。',
                  child: ExcludeSemantics(
                    child: const AppNotice(
                      tone: AppTone.info,
                      message: '服务尚未接入，当前操作不会提交或保存。',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              AppButton(
                key: const Key('auth-submit-button'),
                label: widget.flow.actionLabel,
                onPressed: _submit,
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

  String get _passwordAutofillHint => switch (widget.flow) {
    AuthFlow.login => AutofillHints.password,
    AuthFlow.register ||
    AuthFlow.resetPassword ||
    AuthFlow.changePassword => AutofillHints.newPassword,
    _ => AutofillHints.password,
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      _focusFirstInvalid();
      return;
    }
    TextInput.finishAutofillContext(shouldSave: false);
    context.read<AuthFormViewModel>().submitValidatedForm();
  }

  void _focusAfterAccount() {
    if (widget.flow == AuthFlow.changePassword) {
      _currentPasswordFocus.requestFocus();
    } else if (_needsPassword) {
      _passwordFocus.requestFocus();
    } else {
      _submit();
    }
  }

  void _focusFirstInvalid() {
    if (_needsAccount && _validateAccount(_accountController.text) != null) {
      _accountFocus.requestFocus();
    } else if (widget.flow == AuthFlow.changePassword &&
        _validatePassword(_currentPasswordController.text) != null) {
      _currentPasswordFocus.requestFocus();
    } else if (_needsPassword &&
        _validatePassword(_passwordController.text) != null) {
      _passwordFocus.requestFocus();
    } else if (_needsConfirmation) {
      _confirmationFocus.requestFocus();
    }
  }

  List<Widget> _secondaryActions(BuildContext context) => switch (widget.flow) {
    AuthFlow.login => [
      AppButton(
        variant: AppButtonVariant.tertiary,
        label: '忘记密码',
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.forgotPassword,
          arguments: '登录',
        ),
      ),
      AppButton(
        variant: AppButtonVariant.tertiary,
        label: '注册账号',
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.register),
      ),
    ],
    AuthFlow.register => [
      AppButton(
        variant: AppButtonVariant.tertiary,
        label: '返回登录',
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.login),
      ),
    ],
    AuthFlow.forgotPassword => [
      AppButton(
        variant: AppButtonVariant.tertiary,
        label: '已有重置凭据',
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.resetPassword,
          arguments: '忘记密码',
        ),
      ),
    ],
    _ => const [],
  };
}
