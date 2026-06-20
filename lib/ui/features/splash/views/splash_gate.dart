import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/models/splash_content.dart';
import '../view_models/splash_view_model.dart';
import 'splash_page.dart';

class SplashGate extends StatefulWidget {
  const SplashGate({
    super.key,
    required this.child,
    required this.showOnFirstBuild,
    required this.canShowOnResume,
    this.onResumeWithoutContent,
  });

  final Widget child;
  final bool showOnFirstBuild;
  final bool canShowOnResume;
  final VoidCallback? onResumeWithoutContent;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> with WidgetsBindingObserver {
  SplashContent? _previewContent;
  bool _didTryFirstBuildSplash = false;
  bool _wasBackgrounded = false;
  bool _isShowingContent = false;

  bool get _hasOverlay {
    final viewModel = context.read<SplashViewModel>();
    return _previewContent != null ||
        viewModel.isLoading ||
        viewModel.shouldShowSplash;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tryShowFirstBuildSplash();
    });
  }

  @override
  void didUpdateWidget(covariant SplashGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_didTryFirstBuildSplash && widget.showOnFirstBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _tryShowFirstBuildSplash();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _wasBackgrounded = true;
      return;
    }

    if (state != AppLifecycleState.resumed || !_wasBackgrounded) {
      return;
    }

    _wasBackgrounded = false;
    if (kIsWeb || !widget.canShowOnResume || _hasOverlay) {
      return;
    }

    _showCachedContent(blockWhileLoading: false, notifyWhenMissing: true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashViewModel>(
      builder: (context, viewModel, _) {
        Widget? overlay;
        if (_previewContent != null) {
          overlay = SplashActionPreviewPage(
            content: _previewContent!,
            onContinue: () {
              viewModel.skip();
              setState(() {
                _previewContent = null;
              });
            },
          );
        } else if (viewModel.isLoading) {
          overlay = const ColoredBox(
            key: Key('splash-loading-blocker'),
            color: Colors.white,
          );
        } else if (viewModel.shouldShowSplash) {
          overlay = SplashPage(
            content: viewModel.content!,
            remainingSeconds: viewModel.remainingSeconds,
            onSkip: viewModel.skip,
            onAction: (content) {
              setState(() {
                _previewContent = content;
              });
            },
          );
        }

        if (overlay == null) {
          return widget.child;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            Positioned.fill(child: overlay),
          ],
        );
      },
    );
  }

  void _tryShowFirstBuildSplash() {
    if (_didTryFirstBuildSplash || !widget.showOnFirstBuild || kIsWeb) {
      return;
    }
    _didTryFirstBuildSplash = true;
    _showCachedContent(blockWhileLoading: false);
  }

  Future<void> _showCachedContent({
    required bool blockWhileLoading,
    bool notifyWhenMissing = false,
  }) async {
    if (_isShowingContent || _hasOverlay) {
      return;
    }

    _isShowingContent = true;
    try {
      final didShow = await context.read<SplashViewModel>().showCachedContent(
        blockWhileLoading: blockWhileLoading,
      );
      if (!didShow && notifyWhenMissing) {
        widget.onResumeWithoutContent?.call();
      }
    } finally {
      _isShowingContent = false;
    }
  }
}

class SplashActionPreviewPage extends StatelessWidget {
  const SplashActionPreviewPage({
    super.key,
    required this.content,
    required this.onContinue,
  });

  final SplashContent content;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final title = content.targetTitle ?? content.callToAction;

    return Scaffold(
      key: const Key('splash-action-preview'),
      backgroundColor: context.tokens.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              Text('已打开开屏目标', style: context.typography.heroTitle),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                key: const Key('splash-action-target-title'),
                style: context.typography.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              SelectableText(
                content.actionUrl ?? '',
                key: const Key('splash-action-url'),
                style: context.typography.feedMeta.copyWith(
                  color: context.tokens.textSecondary,
                ),
              ),
              const Spacer(),
              FilledButton(
                key: const Key('splash-action-continue'),
                onPressed: onContinue,
                child: const Text('继续使用'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
