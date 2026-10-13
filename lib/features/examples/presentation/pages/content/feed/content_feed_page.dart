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
class ContentFeedPage extends StatefulWidget {
  const ContentFeedPage({super.key});
  @override
  State<ContentFeedPage> createState() => _ContentFeedPageState();
}

class _ContentFeedPageState extends State<ContentFeedPage> {
  AFeedCardLayout? _layout;
  bool _noticeAutoplay = false, _bannerRotating = false, _badge = true;
  int _imageCount = 3, _seconds = 5, _reset = 0;
  String? _status;
  static const _assets = ['read', 'collaborate', 'act'];
  void _opened(String label) => setState(
    () => _status = 'examples.admin9.content_feed.opened'.tr(
      namedArgs: {'label': label},
    ),
  );
  void _changed(String kind, int index) => setState(
    () => _status = 'examples.admin9.content_feed.position'.tr(
      namedArgs: {'kind': kind, 'index': '${index + 1}'},
    ),
  );
  Widget _image(int index) => Image.asset(
    'assets/images/onboarding/${_assets[index % _assets.length]}.jpg',
    fit: BoxFit.cover,
  );
  @override
  Widget build(BuildContext context) {
    final bannerTitles = [
      'examples.admin9.content_feed.banner_1'.tr(),
      'examples.admin9.content_feed.banner_2'.tr(),
    ];
    final noticeTitles = [
      'examples.admin9.content_feed.notice_1'.tr(),
      'examples.admin9.content_feed.notice_2'.tr(),
    ];
    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text('examples.admin9.content_feed.title'.tr()),
        prefixes: [FHeaderAction.back(onPress: context.maybePop)],
      ),
      child: ResponsivePageBody(
        children: [
          PlaygroundPreview(
            title: 'examples.playground.preview'.tr(),
            status: _status,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: context.theme.buttonStyles.ghost.md.contentStyle.spacing,
              children: [
                ABanner(
                  key: ValueKey(('content-banner', _reset)),
                  display: _bannerRotating
                      ? ABannerDisplay.rotating
                      : ABannerDisplay.stacked,
                  interval: Duration(seconds: _seconds),
                  onChanged: (index) => _changed(
                    'examples.admin9.content_feed.banner'.tr(),
                    index,
                  ),
                  items: [
                    for (var i = 0; i < 2; i++)
                      ABannerItem(
                        id: i,
                        child: _image(i),
                        semanticsLabel: bannerTitles[i],
                        onPress: () => _opened(bannerTitles[i]),
                      ),
                  ],
                ),
                AAnnouncement(
                  key: ValueKey(('content-notice', _reset)),
                  autoplay: _noticeAutoplay,
                  interval: Duration(seconds: _seconds),
                  onChanged: (index) => _changed(
                    'examples.admin9.content_feed.notice'.tr(),
                    index,
                  ),
                  items: [
                    for (var i = 0; i < 2; i++)
                      AAnnouncementItem(
                        id: i,
                        title: noticeTitles[i],
                        onPress: () => _opened(noticeTitles[i]),
                      ),
                  ],
                ),
                AFeedCard(
                  key: const ValueKey('content-feed-card'),
                  title: 'examples.admin9.content_feed.article_title'.tr(),
                  semanticsLabel:
                      '${'examples.admin9.content_feed.article_title'.tr()}，${'examples.admin9.content_feed.metadata'.tr()}${_badge ? '，${'examples.admin9.content_feed.duration'.tr()}' : ''}',
                  metadata: 'examples.admin9.content_feed.metadata'.tr(),
                  layout: _layout,
                  images: [for (var i = 0; i < _imageCount; i++) _image(i)],
                  mediaBadge: _badge
                      ? Row(
                          spacing: context
                              .theme
                              .buttonStyles
                              .ghost
                              .md
                              .contentStyle
                              .spacing,
                          children: [
                            const Icon(FLucideIcons.video),
                            Expanded(
                              child: Text(
                                'examples.admin9.content_feed.duration'.tr(),
                                style: context.theme.typography.body.xs2
                                    .copyWith(
                                      color:
                                          context.theme.colors.mutedForeground,
                                    ),
                              ),
                            ),
                          ],
                        )
                      : null,
                  onPress: () => _opened(
                    'examples.admin9.content_feed.article_title'.tr(),
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
                  'examples.admin9.content_feed.layout'.tr(),
                  style: context.theme.typography.body.md,
                ),
                Wrap(
                  spacing:
                      context.theme.buttonStyles.ghost.md.contentStyle.spacing,
                  runSpacing:
                      context.theme.buttonStyles.ghost.md.contentStyle.spacing,
                  children: [
                    for (final layout in [null, ...AFeedCardLayout.values])
                      FButton(
                        key: ValueKey('feed-layout-${layout?.name ?? 'auto'}'),
                        variant: _layout == layout ? .primary : .outline,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => setState(() => _layout = layout),
                        child: Text(switch (layout) {
                          null =>
                            'examples.admin9.content_feed.layout_auto'.tr(),
                          AFeedCardLayout.textOnly =>
                            'examples.admin9.content_feed.layout_textOnly'.tr(),
                          AFeedCardLayout.trailingImage =>
                            'examples.admin9.content_feed.layout_trailingImage'
                                .tr(),
                          AFeedCardLayout.threeImages =>
                            'examples.admin9.content_feed.layout_threeImages'
                                .tr(),
                          AFeedCardLayout.largeImage =>
                            'examples.admin9.content_feed.layout_largeImage'
                                .tr(),
                        }),
                      ),
                  ],
                ),
                FButton(
                  key: const ValueKey('feed-image-count'),
                  variant: .outline,
                  onPress: () => setState(
                    () => _imageCount = switch (_imageCount) {
                      0 => 1,
                      1 => 3,
                      _ => 0,
                    },
                  ),
                  child: Text(
                    'examples.admin9.content_feed.image_count'.tr(
                      namedArgs: {'count': '$_imageCount'},
                    ),
                  ),
                ),
                _toggle(
                  'media-badge',
                  'examples.admin9.content_feed.media_badge'.tr(),
                  _badge,
                  (value) => _badge = value,
                ),
                _toggle(
                  'notice-autoplay',
                  'examples.admin9.content_feed.notice_autoplay'.tr(),
                  _noticeAutoplay,
                  (value) => _noticeAutoplay = value,
                ),
                _toggle(
                  'banner-rotating',
                  'examples.admin9.content_feed.banner_rotating'.tr(),
                  _bannerRotating,
                  (value) => _bannerRotating = value,
                ),
                FButton(
                  key: const ValueKey('content-interval'),
                  variant: .outline,
                  onPress: () =>
                      setState(() => _seconds = _seconds == 5 ? 2 : 5),
                  child: Text(
                    'examples.admin9.content_feed.interval'.tr(
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
              _layout = null;
              _noticeAutoplay = false;
              _bannerRotating = false;
              _badge = true;
              _imageCount = 3;
              _seconds = 5;
              _reset++;
              _status = 'examples.playground.reset_done'.tr();
            }),
          ),
        ],
      ),
    );
  }

  Widget _toggle(
    String id,
    String label,
    bool value,
    ValueChanged<bool> change,
  ) => FSwitch(
    key: ValueKey('content-$id'),
    label: Text(label),
    value: value,
    onChange: (value) => setState(() => change(value)),
  );
}
