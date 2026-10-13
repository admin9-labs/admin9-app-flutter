import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:admin9_ui/admin9_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class CarouselPage extends StatefulWidget {
  const CarouselPage({super.key});
  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  ACarouselCaption _caption = ACarouselCaption.overlay;
  bool _autoplay = false, _loop = true, _indicators = true;
  double _ratio = 5 / 3;
  int _seconds = 5, _reset = 0;
  String? _status;
  static const _assets = [
    ('read', 'examples.admin9.carousel.item_1'),
    ('collaborate', 'examples.admin9.carousel.item_2'),
    ('act', 'examples.admin9.carousel.item_3'),
  ];
  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.admin9.carousel.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: context.maybePop)],
    ),
    child: ResponsivePageBody(
      children: [
        PlaygroundPreview(
          title: 'examples.playground.preview'.tr(),
          status: _status,
          child: ACarousel(
            key: ValueKey(('carousel-preview', _reset)),
            aspectRatio: _ratio,
            caption: _caption,
            autoplay: _autoplay,
            loop: _loop,
            showIndicators: _indicators,
            interval: Duration(seconds: _seconds),
            onChanged: (index) => setState(
              () => _status = 'examples.admin9.carousel.position'.tr(
                namedArgs: {'index': '${index + 1}'},
              ),
            ),
            items: [
              for (var i = 0; i < _assets.length; i++)
                ACarouselItem(
                  id: _assets[i].$1,
                  title: _assets[i].$2.tr(),
                  semanticsLabel: _assets[i].$2.tr(),
                  child: Image.asset(
                    'assets/images/onboarding/${_assets[i].$1}.jpg',
                    fit: BoxFit.cover,
                  ),
                  onPress: () => setState(
                    () => _status = 'examples.admin9.carousel.opened'.tr(
                      namedArgs: {'label': _assets[i].$2.tr()},
                    ),
                  ),
                ),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'examples.playground.configuration'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: context.theme.buttonStyles.ghost.md.contentStyle.spacing,
            children: [
              Text(
                'examples.admin9.carousel.caption'.tr(),
                style: context.theme.typography.body.md,
              ),
              Wrap(
                spacing:
                    context.theme.buttonStyles.ghost.md.contentStyle.spacing,
                runSpacing:
                    context.theme.buttonStyles.ghost.md.contentStyle.spacing,
                children: [
                  for (final caption in ACarouselCaption.values)
                    FButton(
                      key: ValueKey('carousel-caption-${caption.name}'),
                      variant: caption == _caption ? .primary : .outline,
                      mainAxisSize: MainAxisSize.min,
                      onPress: () => setState(() => _caption = caption),
                      child: Text(switch (caption) {
                        ACarouselCaption.none =>
                          'examples.admin9.carousel.caption_none'.tr(),
                        ACarouselCaption.overlay =>
                          'examples.admin9.carousel.caption_overlay'.tr(),
                        ACarouselCaption.below =>
                          'examples.admin9.carousel.caption_below'.tr(),
                      }),
                    ),
                ],
              ),
              _toggle(
                'autoplay',
                'examples.admin9.carousel.autoplay'.tr(),
                _autoplay,
                (value) => _autoplay = value,
              ),
              _toggle(
                'loop',
                'examples.admin9.carousel.loop'.tr(),
                _loop,
                (value) => _loop = value,
              ),
              _toggle(
                'indicators',
                'examples.admin9.carousel.indicators'.tr(),
                _indicators,
                (value) => _indicators = value,
              ),
              Wrap(
                spacing:
                    context.theme.buttonStyles.ghost.md.contentStyle.spacing,
                runSpacing:
                    context.theme.buttonStyles.ghost.md.contentStyle.spacing,
                children: [
                  for (final ratio in [5 / 3, 16 / 9, 1.0])
                    FButton(
                      key: ValueKey('carousel-ratio-$ratio'),
                      variant: _ratio == ratio ? .primary : .outline,
                      mainAxisSize: MainAxisSize.min,
                      onPress: () => setState(() => _ratio = ratio),
                      child: Text(
                        ratio == 1
                            ? '1:1'
                            : ratio == 5 / 3
                            ? '5:3'
                            : '16:9',
                      ),
                    ),
                ],
              ),
              FButton(
                key: const ValueKey('carousel-interval'),
                variant: .outline,
                onPress: () => setState(() => _seconds = _seconds == 5 ? 2 : 5),
                child: Text(
                  'examples.admin9.carousel.interval'.tr(
                    namedArgs: {'seconds': '$_seconds'},
                  ),
                ),
              ),
            ],
          ),
        ),
        PlaygroundActionBar(
          resetLabel: 'examples.playground.reset'.tr(),
          onReset: () => setState(() {
            _caption = ACarouselCaption.overlay;
            _autoplay = false;
            _loop = true;
            _indicators = true;
            _ratio = 5 / 3;
            _seconds = 5;
            _reset++;
            _status = 'examples.playground.reset_done'.tr();
          }),
        ),
      ],
    ),
  );
  Widget _toggle(
    String key,
    String label,
    bool value,
    ValueChanged<bool> change,
  ) => FSwitch(
    key: ValueKey('carousel-$key'),
    label: Text(label),
    value: value,
    onChange: (value) => setState(() => change(value)),
  );
}
