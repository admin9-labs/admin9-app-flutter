import 'package:flutter/material.dart';

import '../adapters/forui/forui_candidate_adapter.dart';
import '../components/app_form_components.dart';
import '../components/app_notice.dart';
import '../components/app_progress_indicator.dart';
import '../components/app_settings_components.dart';
import '../foundation/app_contracts.dart';
import 'g2_first_party_candidate.dart';

enum G2CandidateKind { control, firstParty, forui }

enum G2CandidateScenario { auth, account, settings, feedback }

class G2CandidateHarness extends StatefulWidget {
  const G2CandidateHarness({
    super.key,
    required this.candidate,
    required this.scenario,
  });

  final G2CandidateKind candidate;
  final G2CandidateScenario scenario;

  @override
  State<G2CandidateHarness> createState() => _G2CandidateHarnessState();
}

class _G2CandidateHarnessState extends State<G2CandidateHarness> {
  late final TextEditingController _accountController;
  late final FocusNode _accountFocus;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController(text: 'admin9@example.com');
    _accountFocus = FocusNode();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _accountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              _scenario(),
            ],
          ),
        ),
      ),
    );
    return widget.candidate == G2CandidateKind.forui
        ? ForuiCandidateScope(child: content)
        : content;
  }

  String get _title => switch (widget.scenario) {
    G2CandidateScenario.auth => '登录',
    G2CandidateScenario.account => '个人中心',
    G2CandidateScenario.settings => '设置',
    G2CandidateScenario.feedback => '警告与撤销',
  };

  Widget _scenario() => switch (widget.scenario) {
    G2CandidateScenario.auth => _auth(),
    G2CandidateScenario.account => _account(),
    G2CandidateScenario.settings => _settings(),
    G2CandidateScenario.feedback => _feedback(),
  };

  Widget _auth() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _textField(
        key: const Key('g2-account-field'),
        label: '手机号或邮箱',
        errorText: '账号格式不正确，错误出现后内容区域按需增长。',
      ),
      const SizedBox(height: 16),
      _button(
        key: const Key('g2-primary-action'),
        label: '登录',
        onPressed: _noop,
      ),
      const SizedBox(height: 12),
      _button(
        key: const Key('g2-disabled-action'),
        label: '不可用',
        onPressed: _noop,
        enabled: false,
        variant: AppButtonVariant.secondary,
      ),
    ],
  );

  Widget _account() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _tile(
        key: const Key('g2-profile-tile'),
        title: '账号资料',
        subtitle: '游客状态下没有账号资料。',
        value: '已登录',
        onPressed: _noop,
      ),
      const Divider(),
      _tile(
        key: const Key('g2-team-tile'),
        title: '账号安全',
        subtitle: '资料服务尚未接入。',
        value: '查看',
        onPressed: _noop,
      ),
      const SizedBox(height: 16),
      _feedbackNotice(
        title: '操作失败',
        message: '操作失败，请检查后重试。',
        tone: AppTone.error,
      ),
    ],
  );

  Widget _settings() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _switch(
        key: const Key('g2-notification-switch'),
        label: '高对比度',
        value: _notifications,
        onChanged: (value) => setState(() => _notifications = value),
      ),
      const Divider(),
      _tile(
        title: '外观',
        subtitle: 'App 偏好即时生效并自动保存；系统辅助设置始终具有更高优先级。',
        value: '跟随系统',
        onPressed: _noop,
      ),
      const SizedBox(height: 16),
      _feedbackNotice(
        title: '设置暂未保存。',
        message: '设置暂未保存，请使用“重试保存设置”。',
        tone: AppTone.error,
      ),
      const SizedBox(height: 16),
      _button(label: '重试保存设置', onPressed: _noop),
    ],
  );

  Widget _feedback() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _feedbackNotice(
        title: '正在保存',
        message: '说明文字允许增长，不截断关键状态。',
        tone: AppTone.info,
      ),
      const SizedBox(height: 20),
      _progress(0.45),
      const SizedBox(height: 20),
      _button(
        key: const Key('g2-loading-action'),
        label: '提交中',
        onPressed: _noop,
        loading: true,
      ),
      const SizedBox(height: 12),
      _button(
        label: '危险操作',
        onPressed: _noop,
        variant: AppButtonVariant.destructive,
      ),
    ],
  );

  Widget _button({
    Key? key,
    required String label,
    required VoidCallback onPressed,
    AppButtonVariant variant = AppButtonVariant.primary,
    bool enabled = true,
    bool loading = false,
  }) => switch (widget.candidate) {
    G2CandidateKind.control => AppButton(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: variant,
      enabled: enabled,
      loading: loading,
    ),
    G2CandidateKind.firstParty => G2FirstPartyButton(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: variant,
      enabled: enabled,
      loading: loading,
    ),
    G2CandidateKind.forui => ForuiCandidateButton(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: variant,
      enabled: enabled,
      loading: loading,
    ),
  };

  Widget _textField({Key? key, required String label, String? errorText}) =>
      switch (widget.candidate) {
        G2CandidateKind.control => AppTextField(
          key: key,
          controller: _accountController,
          focusNode: _accountFocus,
          label: label,
          forceErrorText: errorText,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
        ),
        G2CandidateKind.firstParty => G2FirstPartyTextField(
          key: key,
          controller: _accountController,
          focusNode: _accountFocus,
          label: label,
          errorText: errorText,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
        ),
        G2CandidateKind.forui => ForuiCandidateTextField(
          key: key,
          controller: _accountController,
          focusNode: _accountFocus,
          label: label,
          errorText: errorText,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
        ),
      };

  Widget _switch({
    Key? key,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => switch (widget.candidate) {
    G2CandidateKind.control => AppSwitch(
      key: key,
      label: label,
      value: value,
      onChanged: onChanged,
    ),
    G2CandidateKind.firstParty => G2FirstPartySwitch(
      key: key,
      label: label,
      value: value,
      onChanged: onChanged,
    ),
    G2CandidateKind.forui => ForuiCandidateSwitch(
      key: key,
      label: label,
      value: value,
      onChanged: onChanged,
    ),
  };

  Widget _tile({
    Key? key,
    required String title,
    String? subtitle,
    String? value,
    VoidCallback? onPressed,
  }) => switch (widget.candidate) {
    G2CandidateKind.control => AppListTile(
      key: key,
      title: title,
      subtitle: subtitle,
      currentValue: value,
      disclosure: onPressed != null,
      onTap: onPressed,
    ),
    G2CandidateKind.firstParty => G2FirstPartyTile(
      key: key,
      title: title,
      subtitle: subtitle,
      value: value,
      onPressed: onPressed,
    ),
    G2CandidateKind.forui => ForuiCandidateTile(
      key: key,
      title: title,
      subtitle: subtitle,
      value: value,
      onPressed: onPressed,
    ),
  };

  Widget _feedbackNotice({
    required String title,
    required String message,
    required AppTone tone,
  }) => switch (widget.candidate) {
    G2CandidateKind.control => AppNotice(
      title: title,
      message: message,
      tone: tone,
    ),
    G2CandidateKind.firstParty => G2FirstPartyFeedback(
      title: title,
      message: message,
      tone: tone,
    ),
    G2CandidateKind.forui => ForuiCandidateFeedback(
      title: title,
      message: message,
      tone: tone,
    ),
  };

  Widget _progress(double value) => switch (widget.candidate) {
    G2CandidateKind.control => AppProgressIndicator(
      label: '已完成 45%',
      kind: AppProgressKind.linear,
      value: value,
    ),
    G2CandidateKind.firstParty => G2FirstPartyProgress(
      label: '已完成 45%',
      value: value,
    ),
    G2CandidateKind.forui => ForuiCandidateProgress(
      label: '已完成 45%',
      value: value,
    ),
  };

  void _noop() {}
}
