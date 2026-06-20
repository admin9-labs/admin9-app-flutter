import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/models/splash_content.dart';
import 'splash_file_image.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({
    super.key,
    required this.content,
    required this.remainingSeconds,
    required this.onSkip,
    this.onAction,
  });

  final SplashContent content;
  final int remainingSeconds;
  final VoidCallback onSkip;
  final ValueChanged<SplashContent>? onAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _SplashMedia(content: content),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  right: AppSpacing.sectionGap,
                ),
                child: TextButton(
                  key: const Key('splash-skip'),
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.42),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sectionGap,
                      vertical: AppSpacing.sm,
                    ),
                    textStyle: context.typography.label,
                  ),
                  child: Text('跳过 $remainingSeconds'),
                ),
              ),
            ),
          ),
          if (content.hasAction)
            _SplashAction(
              content: content,
              onAction: () => onAction?.call(content),
            ),
        ],
      ),
    );
  }
}

class _SplashAction extends StatelessWidget {
  const _SplashAction({required this.content, required this.onAction});

  final SplashContent content;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            0,
            AppSpacing.xxl,
            AppSpacing.xxxl,
          ),
          child: FilledButton(
            key: const Key('splash-action'),
            onPressed: onAction,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: context.tokens.brand.primary,
              minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
              textStyle: context.typography.buttonLabel,
            ),
            child: Text(content.callToAction),
          ),
        ),
      ),
    );
  }
}

class _SplashMedia extends StatelessWidget {
  const _SplashMedia({required this.content});

  final SplashContent content;

  @override
  Widget build(BuildContext context) {
    return switch (content.mediaType) {
      SplashMediaType.image ||
      SplashMediaType.gif => _ImageLikeContent(content: content),
      SplashMediaType.video => _VideoPlaceholder(content: content),
    };
  }
}

class _ImageLikeContent extends StatelessWidget {
  const _ImageLikeContent({required this.content});

  final SplashContent content;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _SplashFallbackBackground(),
        _SplashImage(content: content),
      ],
    );
  }
}

class _SplashImage extends StatelessWidget {
  const _SplashImage({required this.content});

  final SplashContent content;

  @override
  Widget build(BuildContext context) {
    if (content.sourceType == SplashSourceType.file && kIsWeb) {
      return const _SplashFallbackBackground();
    }

    return switch (content.sourceType) {
      SplashSourceType.asset => Image.asset(
        content.source,
        key: const Key('splash-asset-image'),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _SplashFallbackBackground(),
      ),
      SplashSourceType.file => SplashFileImage(
        source: content.source,
        key: const Key('splash-file-image'),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _SplashFallbackBackground(),
      ),
    };
  }
}

class _SplashFallbackBackground extends StatelessWidget {
  const _SplashFallbackBackground();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return DecoratedBox(
      key: const Key('splash-fallback-background'),
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
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.content});

  final SplashContent content;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.tokens.textPrimary),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 56,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                content.title,
                textAlign: TextAlign.center,
                style: context.typography.heroTitle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                content.subtitle,
                textAlign: TextAlign.center,
                style: context.typography.feedMeta.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
