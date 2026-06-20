import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin9_app_flutter/core/theme/app_appearance.dart';
import 'package:admin9_app_flutter/core/theme/app_spacing.dart';
import 'package:admin9_app_flutter/core/theme/app_theme.dart';
import 'package:admin9_app_flutter/core/widgets/media_cover.dart';
import 'package:admin9_app_flutter/core/widgets/quick_action_grid.dart';
import 'package:admin9_app_flutter/domain/models/article.dart';
import 'package:admin9_app_flutter/domain/models/home_block.dart';
import 'package:admin9_app_flutter/domain/models/live_program.dart';
import 'package:admin9_app_flutter/ui/features/home/views/channel_content_blocks.dart';
import 'package:admin9_app_flutter/ui/features/live/views/tv_live_detail_page.dart';

void main() {
  testWidgets('QuickActionGrid network icons request cache-sized images', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        dpr: 3,
        child: Material(
          child: QuickActionGrid(
            items: [
              QuickActionItem(
                icon: Icons.settings,
                label: '设置',
                imageUrl: 'https://example.com/icon.png',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(
      find.byKey(const Key('quick-action-image-设置')),
    );
    expect(image.fit, BoxFit.cover);
    final provider = image.image;
    expect(provider, isA<ResizeImage>());
    final resized = provider as ResizeImage;
    expect(resized.width, (AppSpacing.functionIconContainer * 3).ceil());
    expect(resized.height, (AppSpacing.functionIconContainer * 3).ceil());
    expect(
      resized.imageProvider,
      isA<NetworkImage>().having(
        (image) => image.url,
        'url',
        'https://example.com/icon.png',
      ),
    );
  });

  testWidgets('MediaCover derives network cache size from rendered bounds', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        dpr: 2.5,
        child: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 90,
              child: MediaCover(
                label: '有限图',
                type: ArticleVisualType.city,
                height: 90,
                imageUrl: 'https://example.com/cover.jpg',
              ),
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(
      find.byKey(const Key('network-image-有限图')),
    );
    expect(image.fit, BoxFit.cover);
    final provider = image.image;
    expect(provider, isA<ResizeImage>());
    final resized = provider as ResizeImage;
    expect(resized.width, 400);
    expect(resized.height, 225);
    expect(
      resized.imageProvider,
      isA<NetworkImage>().having(
        (image) => image.url,
        'url',
        'https://example.com/cover.jpg',
      ),
    );
  });

  testWidgets(
    'SpecialEntryCarousel exposes a descriptive button semantic label',
    (tester) async {
      final semantics = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          _harness(
            child: const Scaffold(
              body: SpecialEntryCarousel(
                entries: [
                  SpecialEntryItem(
                    id: 'special-a',
                    specialId: 'special-a',
                    title: '专题入口标题',
                    visual: ArticleVisualAsset(
                      label: '专题入口',
                      type: ArticleVisualType.politics,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final node = tester.getSemantics(
          find.bySemanticsLabel('专题入口：专题入口标题，第 1 个，共 1 个，双击打开'),
        );
        expect(node.label, '专题入口：专题入口标题，第 1 个，共 1 个，双击打开');
        expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'TvLiveDetailPage marks chat prototype as read-only coming soon',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          child: Center(
            child: SizedBox(
              width: 390,
              height: 844,
              child: TvLiveDetailPage(
                channel: _channel,
                streamPlayerBuilder: (context, config, muted, onMutedChanged) {
                  return ColoredBox(
                    key: Key('fake-player-${config.title}'),
                    color: Colors.black,
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('聊天室'), findsOneWidget);
      expect(find.byKey(const Key('tv-live-chat-coming-soon')), findsOneWidget);
      expect(find.text('互动功能即将开放，当前仅展示模拟评论。'), findsOneWidget);

      final input = tester.widget<TextField>(
        find.byKey(const Key('tv-live-chat-input')),
      );
      expect(input.readOnly, isTrue);
      expect(input.decoration?.hintText, '互动评论即将开放');
      expect(input.decoration?.helperText, isNull);

      final likeButtons = tester.widgetList<IconButton>(
        find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == '点赞功能即将开放',
        ),
      );
      expect(likeButtons, isNotEmpty);
      for (final button in likeButtons) {
        expect(button.onPressed, isNull);
      }
    },
  );
}

Widget _harness({required Widget child, double dpr = 1}) {
  return MediaQuery(
    data: MediaQueryData(size: const Size(390, 844), devicePixelRatio: dpr),
    child: MaterialApp(
      theme: AppTheme.light(
        brand: AppBrand.newsBlueBrand,
        fontLevel: AppFontLevel.standard,
      ),
      home: child,
    ),
  );
}

const _channel = LiveTvChannel(
  id: 'test-tv',
  name: '测试频道',
  logoLabel: '测',
  streamUrl: 'https://example.com/live.m3u8',
  nowTitle: '测试直播',
  nowSubtitle: '测试说明',
  accentColor: 0xff2563eb,
);
