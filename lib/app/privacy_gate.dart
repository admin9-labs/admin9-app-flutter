import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../admin9_ui.dart';
import '../core/preferences/app_preferences.dart';
import 'app_route_names.dart';
import 'app_identity.dart';
import '../ui/shared/brand_mark.dart';

class PrivacyController extends ChangeNotifier {
  PrivacyController(this._preferences)
    : _accepted = _preferences.privacyAccepted;

  final AppPreferences _preferences;
  bool _accepted;
  bool _isSaving = false;
  bool _saveFailed = false;

  bool get accepted => _accepted;
  bool get isSaving => _isSaving;
  bool get saveFailed => _saveFailed;

  Future<bool> accept() async {
    if (_accepted) return true;
    if (_isSaving) return false;
    _isSaving = true;
    _saveFailed = false;
    notifyListeners();
    bool persisted;
    try {
      persisted = await _preferences.setPrivacyAccepted(true);
    } on Object {
      persisted = false;
    }
    _isSaving = false;
    _saveFailed = !persisted;
    if (persisted) _accepted = true;
    notifyListeners();
    return persisted;
  }
}

class PrivacyGate extends StatefulWidget {
  const PrivacyGate({super.key, required this.child});

  final Widget child;

  @override
  State<PrivacyGate> createState() => _PrivacyGateState();
}

class _PrivacyGateState extends State<PrivacyGate> {
  bool? _wasAccepted;
  bool _announcementScheduled = false;

  @override
  Widget build(BuildContext context) {
    final accepted = context.watch<PrivacyController>().accepted;
    if (_wasAccepted == false && accepted && !_announcementScheduled) {
      _announcementScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _announcementScheduled = false;
        if (!mounted || !MediaQuery.supportsAnnounceOf(context)) return;
        SemanticsService.sendAnnouncement(
          View.of(context),
          '已进入首页',
          Directionality.of(context),
        );
      });
    }
    _wasAccepted = accepted;
    return accepted ? widget.child : const _PrivacyConsentPage();
  }
}

class _PrivacyConsentPage extends StatelessWidget {
  const _PrivacyConsentPage();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrivacyController>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(child: BrandMark(size: 64)),
                  const SizedBox(height: 32),
                  Text(
                    '隐私保护提示',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '${AppIdentity.name} 需要在您同意后保存必要的本地偏好。当前版本不连接后端，也不会创建用户或会话。',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      AppButton(
                        variant: AppButtonVariant.tertiary,
                        label: '用户协议',
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.userAgreement,
                          arguments: '隐私保护提示',
                        ),
                      ),
                      AppButton(
                        variant: AppButtonVariant.tertiary,
                        label: '隐私政策',
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.privacyPolicy,
                          arguments: '隐私保护提示',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    key: const Key('privacy-accept-button'),
                    label: controller.isSaving ? '正在保存' : '同意并继续',
                    enabled: !controller.isSaving,
                    loading: controller.isSaving,
                    onPressed: () => _accept(context),
                  ),
                  if (controller.saveFailed) ...[
                    const SizedBox(height: 8),
                    const AppNotice(
                      tone: AppTone.error,
                      message: '隐私选择尚未保存，应用仍保持锁定。',
                    ),
                  ],
                  const SizedBox(height: 8),
                  AppButton(
                    variant: AppButtonVariant.tertiary,
                    label: '暂不同意',
                    onPressed: () => AppFeedbackHost.of(context).show(
                      const AppFeedbackRequest(
                        message: '未同意前无法进入应用。',
                        tone: AppTone.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context) async {
    final saved = await context.read<PrivacyController>().accept();
    if (!saved && context.mounted) {
      AppFeedbackHost.of(context).show(
        const AppFeedbackRequest(message: '无法保存隐私选择，请重试。', tone: AppTone.error),
      );
    }
  }
}
