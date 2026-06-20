import 'package:flutter/material.dart';

import '../../../../core/theme/app_appearance.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.onComplete});

  static const _guideImage = 'assets/images/onboarding_guide.png';

  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('onboarding-page'),
      body: Semantics(
        label: '开启全新体验',
        button: true,
        child: GestureDetector(
          key: const Key('onboarding-start'),
          behavior: HitTestBehavior.opaque,
          onTap: onComplete,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _guideImage,
                key: const Key('onboarding-image'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, _, _) =>
                    _OnboardingFallback(onComplete: onComplete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingFallback extends StatelessWidget {
  const _OnboardingFallback({required this.onComplete});

  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onComplete,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              tokens.brand.gradientStart,
              tokens.brand.gradientMiddle,
              tokens.brand.gradientEnd,
            ],
          ),
        ),
        child: Center(
          child: FilledButton(
            key: const Key('onboarding-fallback-start'),
            onPressed: onComplete,
            child: const Text('立即体验'),
          ),
        ),
      ),
    );
  }
}
