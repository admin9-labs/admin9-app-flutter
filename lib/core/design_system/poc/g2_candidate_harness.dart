import 'package:flutter/material.dart';

import '../adapters/forui/forui_candidate_adapter.dart';
import '../components/app_bottom_navigation.dart';
import '../components/app_form_components.dart';
import '../components/app_interaction.dart';
import '../components/app_notice.dart';
import '../components/app_progress_indicator.dart';
import '../components/app_settings_components.dart';
import '../foundation/app_contracts.dart';
import 'g2_first_party_candidate.dart';

enum G2CandidateKind { control, firstParty, forui }

enum G2CandidateScenario { auth, account, settings, feedback }

enum G2CandidateEvidenceState { baseline, alternate }

class G2CandidateHarness extends StatefulWidget {
  const G2CandidateHarness({
    super.key,
    required this.candidate,
    required this.scenario,
    this.evidenceState = G2CandidateEvidenceState.baseline,
  });

  final G2CandidateKind candidate;
  final G2CandidateScenario scenario;
  final G2CandidateEvidenceState evidenceState;

  @override
  State<G2CandidateHarness> createState() => _G2CandidateHarnessState();
}

class _G2CandidateHarnessState extends State<G2CandidateHarness> {
  late final TextEditingController _accountController;
  late final TextEditingController _passwordController;
  late final FocusNode _accountFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _feedbackTriggerFocus;
  bool _highContrast = true;
  bool _showTransientFeedback = false;
  int _selectedNavigationIndex = 1;
  int _primaryTapCount = 0;
  String? _selectedAction;

  bool get _alternate =>
      widget.evidenceState == G2CandidateEvidenceState.alternate;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController(text: 'admin9@example.com');
    _passwordController = TextEditingController(text: 'password');
    _accountFocus = FocusNode();
    _passwordFocus = FocusNode();
    _feedbackTriggerFocus = FocusNode();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _accountFocus.dispose();
    _passwordFocus.dispose();
    _feedbackTriggerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: widget.scenario != G2CandidateScenario.account,
              child: SingleChildScrollView(
                key: const Key('g2-scroll'),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _title,
                      key: const Key('g2-page-title'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    _scenario(),
                  ],
                ),
              ),
            ),
          ),
          if (widget.scenario == G2CandidateScenario.account) _navigation(),
        ],
      ),
    );
    return widget.candidate == G2CandidateKind.forui
        ? ForuiCandidateScope(child: content)
        : content;
  }

  String get _title => switch (widget.scenario) {
    G2CandidateScenario.auth => _alternate ? '登录' : '注册',
    G2CandidateScenario.account => '我的',
    G2CandidateScenario.settings => '设置',
    G2CandidateScenario.feedback => '操作与反馈',
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
      Text(
        _alternate ? '欢迎回来' : '创建账号',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 4),
      const Text('当前版本仅验证表单，服务尚未接入。'),
      const SizedBox(height: 20),
      _textField(
        key: const Key('g2-account-field'),
        controller: _accountController,
        focusNode: _accountFocus,
        label: '账号',
        errorText: _alternate ? '请输入手机号或邮箱，长错误内容必须完整显示且不能遮挡后续操作。' : null,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.username],
      ),
      const SizedBox(height: 16),
      _textField(
        key: const Key('g2-password-field'),
        controller: _passwordController,
        focusNode: _passwordFocus,
        label: _alternate ? '密码' : '新密码',
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        autofillHints: _alternate
            ? const [AutofillHints.password]
            : const [AutofillHints.newPassword],
        obscureText: true,
      ),
      const SizedBox(height: 20),
      _button(
        key: const Key('g2-primary-action'),
        label: _alternate ? '登录' : '注册',
        onPressed: _handlePrimaryAction,
      ),
      const SizedBox(height: 12),
      _button(
        key: const Key('g2-disabled-action'),
        label: '当前不可用',
        onPressed: _noop,
        enabled: false,
        variant: AppButtonVariant.secondary,
      ),
      Text('主要操作触发 $_primaryTapCount 次', key: const Key('g2-primary-count')),
      const SizedBox(height: 16),
      _feedbackNotice(
        title: '服务尚未接入',
        message: '表单状态会保留，稍后可重试。',
        tone: AppTone.info,
      ),
    ],
  );

  Widget _account() => _alternate
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _feedbackNotice(
              title: '暂无可用账号能力',
              message: '当前状态没有列表项，底部导航仍保持可用。',
              tone: AppTone.info,
            ),
            const SizedBox(height: 16),
            _feedbackNotice(
              title: '列表载入失败',
              message: '请检查网络后重试，现有导航状态保持不变。',
              tone: AppTone.error,
              actionLabel: '重试',
              onAction: _noop,
            ),
          ],
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('林晓', style: Theme.of(context).textTheme.titleMedium),
            const Text('sample@example.com · 示例身份数据'),
            const SizedBox(height: 16),
            _tile(
              key: const Key('g2-profile-tile'),
              title: '账号资料',
              subtitle: '查看和维护当前账号资料。',
              value: '已登录',
              onPressed: _noop,
            ),
            const Divider(),
            _tile(
              key: const Key('g2-security-tile'),
              title: '账号安全',
              subtitle: '资料服务尚未接入。',
              value: '查看',
              onPressed: _noop,
            ),
            const Divider(),
            _tile(title: '设置', value: '跟随系统', onPressed: _noop),
          ],
        );

  Widget _settings() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _switch(
        key: const Key('g2-contrast-switch'),
        label: '高对比度',
        value: _highContrast,
        onChanged: (value) => setState(() => _highContrast = value),
      ),
      const Divider(),
      _tile(
        key: const Key('g2-appearance-tile'),
        title: '外观',
        subtitle: 'App 偏好即时生效并自动保存，系统辅助设置始终具有更高优先级。',
        value: '跟随系统',
        onPressed: _noop,
      ),
      const SizedBox(height: 16),
      if (_alternate)
        _feedbackNotice(
          title: '设置暂未保存',
          message: '请使用重试保存设置，当前有效设置保持不变。',
          tone: AppTone.error,
          actionLabel: '重试保存设置',
          onAction: _noop,
        )
      else
        _feedbackNotice(
          title: '当前有效设置',
          message: '系统辅助设置优先于 App 偏好。',
          tone: AppTone.info,
        ),
    ],
  );

  Widget _feedback() => _alternate
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dialogPanel(),
            const SizedBox(height: 20),
            Focus(
              key: const Key('g2-feedback-trigger-focus'),
              focusNode: _feedbackTriggerFocus,
              child: _button(
                key: const Key('g2-show-feedback'),
                label: '显示失败反馈',
                onPressed: () => setState(() => _showTransientFeedback = true),
              ),
            ),
            if (_showTransientFeedback) ...[
              const SizedBox(height: 12),
              _feedbackNotice(
                key: const Key('g2-transient-feedback'),
                title: '操作失败',
                message: '操作失败，请检查后重试。',
                tone: AppTone.error,
                actionLabel: '撤销',
                onAction: () => setState(() => _showTransientFeedback = false),
              ),
            ],
          ],
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _actionMenu(),
            if (_selectedAction != null) ...[
              const SizedBox(height: 8),
              Text('已选择：$_selectedAction'),
            ],
            const SizedBox(height: 20),
            _progress(label: '已完成 45%', value: 0.45),
            const SizedBox(height: 20),
            _progress(label: '正在同步', value: null),
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

  Widget _textField({
    Key? key,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    String? errorText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    bool obscureText = false,
  }) => switch (widget.candidate) {
    G2CandidateKind.control => AppTextField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      label: label,
      forceErrorText: errorText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
    ),
    G2CandidateKind.firstParty => G2FirstPartyTextField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      label: label,
      errorText: errorText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
    ),
    G2CandidateKind.forui => ForuiCandidateTextField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      label: label,
      errorText: errorText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
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
    Key? key,
    required String title,
    required String message,
    required AppTone tone,
    String? actionLabel,
    VoidCallback? onAction,
  }) => switch (widget.candidate) {
    G2CandidateKind.control => AppNotice(
      key: key,
      title: title,
      message: message,
      tone: tone,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
    G2CandidateKind.firstParty => G2FirstPartyFeedback(
      key: key,
      title: title,
      message: message,
      tone: tone,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
    G2CandidateKind.forui => ForuiCandidateFeedback(
      key: key,
      title: title,
      message: message,
      tone: tone,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  };

  Widget _progress({required String label, required double? value}) =>
      switch (widget.candidate) {
        G2CandidateKind.control => AppProgressIndicator(
          label: label,
          kind: AppProgressKind.linear,
          value: value,
        ),
        G2CandidateKind.firstParty => G2FirstPartyProgress(
          label: label,
          value: value,
        ),
        G2CandidateKind.forui => ForuiCandidateProgress(
          label: label,
          value: value,
        ),
      };

  Widget _navigation() => switch (widget.candidate) {
    G2CandidateKind.control => AppBottomNavigation(
      destinations: const [
        AppNavigationDestination(
          label: '首页',
          icon: AppIconRole.home,
          selectedIcon: AppIconRole.homeSelected,
        ),
        AppNavigationDestination(
          label: '我的',
          icon: AppIconRole.account,
          selectedIcon: AppIconRole.accountSelected,
        ),
      ],
      selectedIndex: _selectedNavigationIndex,
      onDestinationSelected: _selectNavigation,
    ),
    G2CandidateKind.firstParty => G2FirstPartyBottomNavigation(
      selectedIndex: _selectedNavigationIndex,
      onSelected: _selectNavigation,
    ),
    G2CandidateKind.forui => ForuiCandidateBottomNavigation(
      selectedIndex: _selectedNavigationIndex,
      onSelected: _selectNavigation,
    ),
  };

  Widget _dialogPanel() => switch (widget.candidate) {
    G2CandidateKind.control => AppDialog(
      variant: AppDialogVariant.confirmation,
      title: '确认继续当前操作',
      body: const Text('继续后将保存当前选择，取消不会改变已有状态。'),
      cancelLabel: '取消',
      confirmLabel: '确认',
    ),
    G2CandidateKind.firstParty => G2FirstPartyDialogPanel(
      title: '确认继续当前操作',
      message: '继续后将保存当前选择，取消不会改变已有状态。',
      onCancel: _noop,
      onConfirm: _noop,
    ),
    G2CandidateKind.forui => ForuiCandidateDialogPanel(
      title: '确认继续当前操作',
      message: '继续后将保存当前选择，取消不会改变已有状态。',
      onCancel: _noop,
      onConfirm: _noop,
    ),
  };

  Widget _actionMenu() => switch (widget.candidate) {
    G2CandidateKind.control => AppActionMenu<int>(
      title: '选择操作',
      items: [
        for (final (index, item) in _menuItems.indexed)
          AppActionMenuItem(
            value: index,
            label: item.label,
            enabled: item.enabled,
            destructive: item.destructive,
          ),
      ],
      cancelLabel: '取消',
      onSelected: (value) => _selectAction(_menuItems[value].label),
    ),
    G2CandidateKind.firstParty => G2FirstPartyActionMenu(
      items: _menuItems,
      onSelected: (value) => _selectAction(_menuItems[value].label),
      onCancel: _noop,
    ),
    G2CandidateKind.forui => ForuiCandidateActionMenu(
      items: _menuItems,
      onSelected: (value) => _selectAction(_menuItems[value].label),
      onCancel: _noop,
    ),
  };

  void _handlePrimaryAction() => setState(() => _primaryTapCount += 1);

  void _selectNavigation(int value) =>
      setState(() => _selectedNavigationIndex = value);

  void _selectAction(String value) => setState(() => _selectedAction = value);

  void _noop() {}
}

const _menuItems = <({String label, bool enabled, bool destructive})>[
  (label: '查看完整账户资料', enabled: true, destructive: false),
  (label: '暂时不可使用的操作', enabled: false, destructive: false),
  (label: '删除当前资料且无法撤销', enabled: true, destructive: true),
];
