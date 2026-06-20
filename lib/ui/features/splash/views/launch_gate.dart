import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/foundation_repository.dart';
import '../../../../data/repositories/splash_repository.dart';
import '../../foundation/views/agreement_page.dart';
import '../view_models/launch_view_model.dart';
import 'onboarding_page.dart';
import 'privacy_guide_page.dart';

class LaunchGate extends StatefulWidget {
  const LaunchGate({super.key, required this.child});

  final Widget child;

  @override
  State<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<LaunchGate> {
  bool _didPreloadSplash = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LaunchViewModel>(
      builder: (context, viewModel, _) {
        if (!viewModel.privacyAccepted) {
          if (viewModel.privacyDeclinedThisLaunch) {
            return PrivacyDeclinedPage(
              onReviewAgain: viewModel.reviewPrivacyGuide,
            );
          }

          return PrivacyGuidePage(
            onAccept: viewModel.acceptPrivacy,
            onDecline: viewModel.declinePrivacy,
            onOpenAgreement: _openAgreement,
          );
        }

        if (!viewModel.onboardingCompleted) {
          return OnboardingPage(onComplete: viewModel.completeOnboarding);
        }

        if (kIsWeb) {
          return widget.child;
        }

        _preloadSplashAfterFirstFrame(context, viewModel);

        return widget.child;
      },
    );
  }

  void _preloadSplashAfterFirstFrame(
    BuildContext context,
    LaunchViewModel viewModel,
  ) {
    if (_didPreloadSplash) return;
    _didPreloadSplash = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      viewModel.preloadSplash(context.read<SplashRepository>());
    });
  }

  void _openAgreement(String id) {
    final repository = context.read<FoundationRepository>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AgreementPage(document: repository.agreement(id)),
      ),
    );
  }
}

class PrivacyDeclinedPage extends StatelessWidget {
  const PrivacyDeclinedPage({super.key, required this.onReviewAgain});

  final VoidCallback onReviewAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: const Key('privacy-declined-page'),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '需同意后使用',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '西昌发布客户端需要在您同意《用户协议》和《隐私政策》后，才能继续提供首页、登录、互动与本地缓存等功能。您暂不同意时，我们不会写入同意状态，也不会进入后续页面或预加载启动页内容。',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('privacy-review-again'),
                    onPressed: onReviewAgain,
                    child: const Text('重新查看并选择'),
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
