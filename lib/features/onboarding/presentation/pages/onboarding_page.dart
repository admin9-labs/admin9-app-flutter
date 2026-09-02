import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.onSkip,
    required this.onComplete,
  });

  final Future<void> Function() onSkip;
  final Future<void> Function() onComplete;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _slides = [
    (
      asset: 'assets/images/onboarding/collaborate.jpg',
      titleKey: 'onboarding.collaborate_title',
      bodyKey: 'onboarding.collaborate_body',
    ),
    (
      asset: 'assets/images/onboarding/read.jpg',
      titleKey: 'onboarding.read_title',
      bodyKey: 'onboarding.read_body',
    ),
    (
      asset: 'assets/images/onboarding/act.jpg',
      titleKey: 'onboarding.act_title',
      bodyKey: 'onboarding.act_body',
    ),
  ];

  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final slide = _slides[_index];
    return ColoredBox(
      key: const ValueKey('onboarding-page'),
      color: theme.colors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) => Semantics(
                  image: true,
                  label: context.tr(_slides[index].titleKey),
                  child: Image.asset(
                    _slides[index].asset,
                    key: ValueKey('onboarding-image-$index'),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: FButton(
                        key: const ValueKey('onboarding-skip'),
                        variant: .ghost,
                        mainAxisSize: MainAxisSize.min,
                        onPress: widget.onSkip,
                        child: Text(context.tr('onboarding.skip')),
                      ),
                    ),
                    Text(
                      context.tr(slide.titleKey),
                      style: theme.typography.display.lg,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr(slide.bodyKey),
                      style: theme.typography.body.md.copyWith(
                        color: theme.colors.mutedForeground,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        Semantics(
                          label: context.tr(
                            'onboarding.progress',
                            namedArgs: {
                              'current': '${_index + 1}',
                              'total': '${_slides.length}',
                            },
                          ),
                          child: Row(
                            spacing: 6,
                            children: [
                              for (
                                var index = 0;
                                index < _slides.length;
                                index++
                              )
                                SizedBox(
                                  width: 24,
                                  height: 3,
                                  child: ColoredBox(
                                    color: index == _index
                                        ? theme.colors.primary
                                        : theme.colors.border,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        FButton(
                          key: const ValueKey('onboarding-next'),
                          onPress: _advance,
                          suffix: Icon(
                            _index == _slides.length - 1
                                ? FLucideIcons.check
                                : FLucideIcons.arrowRight,
                          ),
                          child: Text(
                            context.tr(
                              _index == _slides.length - 1
                                  ? 'onboarding.finish'
                                  : 'onboarding.next',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _advance() async {
    if (_index == _slides.length - 1) {
      await widget.onComplete();
      return;
    }
    await _controller.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }
}
