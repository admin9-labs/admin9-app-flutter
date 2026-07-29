import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/branding/app_brand.dart';
import '../core/navigation/app_routes.dart';
import '../core/preferences/app_preferences.dart';
import '../core/widgets/brand_mark.dart';

class PrivacyController extends ChangeNotifier {
  PrivacyController(this._preferences)
    : _accepted = _preferences.privacyAccepted;

  final AppPreferences _preferences;
  bool _accepted;

  bool get accepted => _accepted;

  Future<void> accept() async {
    if (_accepted) return;
    await _preferences.setPrivacyAccepted(true);
    _accepted = true;
    notifyListeners();
  }
}

class PrivacyGate extends StatelessWidget {
  const PrivacyGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accepted = context.watch<PrivacyController>().accepted;
    return accepted ? child : const _PrivacyConsentPage();
  }
}

class _PrivacyConsentPage extends StatelessWidget {
  const _PrivacyConsentPage();

  @override
  Widget build(BuildContext context) {
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
                    '${AppBrand.name} 需要在您同意后保存必要的本地偏好。当前版本不连接后端，也不会创建用户或会话。',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.userAgreement,
                        ),
                        child: const Text('用户协议'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.privacyPolicy,
                        ),
                        child: const Text('隐私政策'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('privacy-accept-button'),
                    onPressed: context.read<PrivacyController>().accept,
                    child: const Text('同意并继续'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('未同意前无法进入应用。')),
                      );
                    },
                    child: const Text('暂不同意'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
