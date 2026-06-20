import '../../domain/models/article.dart';
import '../../domain/models/home_block.dart';

class HomeContentRepository {
  const HomeContentRepository();

  static const _cityImage =
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1000&q=80';
  static const _meetingImage =
      'https://images.unsplash.com/photo-1573164713714-d95e436ab8d6?auto=format&fit=crop&w=1000&q=80';
  static const _ruralImage =
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1000&q=80';
  static const _cultureImage =
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1000&q=80';
  static const _sportsImage =
      'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?auto=format&fit=crop&w=1000&q=80';
  static const _serviceImage =
      'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1000&q=80';
  static const _portraitImage =
      'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=600&q=80';
  static const _specialEntryUrl =
      'https://wx.wifixc.com/h5/ymapp_subject/#/32/subject?id=45';
  static const List<SpecialEntryItem> _homeSpecialEntries = [
    SpecialEntryItem(
      id: '2026633285145427970',
      specialId: '2026633285145427970',
      title: '树立和践行正确政绩观学习教育',
      visual: ArticleVisualAsset(
        label: '树立和践行正确政绩观学习教育',
        type: ArticleVisualType.politics,
        imageUrl:
            'https://kscgc.scgchc.com/layout/image/2026/02/25/1772024861566_zJ3HYcm3.jpg',
      ),
      targetUrl: _specialEntryUrl,
    ),
    SpecialEntryItem(
      id: '1981556111125553153',
      specialId: '1981556111125553153',
      title: '学习贯彻党的二十届四中全会精神',
      visual: ArticleVisualAsset(
        label: '学习贯彻党的二十届四中全会精神',
        type: ArticleVisualType.politics,
        imageUrl:
            'https://kscgc.scgchc.com/layout/image/2026/01/01/1767239914012_ewWQcPwa.png',
      ),
      targetUrl: _specialEntryUrl,
    ),
    SpecialEntryItem(
      id: '1914478926265573377',
      specialId: '1914478926265573377',
      title: '习习春风',
      visual: ArticleVisualAsset(
        label: '习习春风',
        type: ArticleVisualType.politics,
        imageUrl:
            'https://kscgc.scgchc.com/layout/image/2026/01/01/1767239920478_WYhh4zGZ.png',
      ),
      targetUrl: _specialEntryUrl,
    ),
    SpecialEntryItem(
      id: '1914469447098347522',
      specialId: '1914469447098347522',
      title: '新思想领航四川新实践',
      visual: ArticleVisualAsset(
        label: '新思想领航四川新实践',
        type: ArticleVisualType.politics,
        imageUrl:
            'https://kscgc.scgchc.com/layout/image/2026/01/01/1767239926574_rHZimzS3.png',
      ),
      targetUrl: _specialEntryUrl,
    ),
    SpecialEntryItem(
      id: '1004478',
      specialId: '1004478',
      title: '学习新天地',
      visual: ArticleVisualAsset(
        label: '学习新天地',
        type: ArticleVisualType.politics,
        imageUrl:
            'https://kscgc.scgchc.com/layout/image/2026/01/01/1767239931722_rpp4fKeK.png',
      ),
      targetUrl: _specialEntryUrl,
    ),
  ];

  List<PageBlock> blocksForChannel(String channelId) {
    return switch (channelId) {
      'recommend' => _recommendBlocks,
      'politics' => _politicsBlocks,
      'video' => _videoBlocks,
      'local' => _localBlocks,
      'culture' => _cultureBlocks,
      'topic' => const [],
      'torch_festival' => _torchFestivalBlocks,
      'live' => _liveBlocks,
      _ => const [],
    };
  }

  List<Article> get allArticles {
    final articles = <String, Article>{};
    for (final block in [
      ..._recommendBlocks,
      ..._politicsBlocks,
      ..._videoBlocks,
      ..._localBlocks,
      ..._cultureBlocks,
      ..._torchFestivalBlocks,
      ..._liveBlocks,
    ]) {
      for (final item in block.items) {
        articles[item.article.id] = item.article;
        final mediaFeature = item.mediaFeature;
        if (mediaFeature != null) {
          for (final article in mediaFeature.articles) {
            articles[article.id] = article;
          }
        }
      }
    }
    return articles.values.toList(growable: false);
  }

  List<ContentItem> get allContentItems {
    return [
      for (final block in [
        ..._recommendBlocks,
        ..._politicsBlocks,
        ..._videoBlocks,
        ..._localBlocks,
        ..._cultureBlocks,
        ..._torchFestivalBlocks,
        ..._liveBlocks,
      ])
        ...block.items,
    ];
  }

  Article? articleById(String id) {
    return switch (id) {
      'laos-meeting' => _laosMeeting,
      'service-industry' => _serviceIndustry,
      'daily-video' => _dailyVideo,
      'rural-gallery' => _ruralGallery,
      'football' => _football,
      'politics-standing-committee' => _politicsStandingCommittee,
      'politics-service-meeting' => _politicsServiceMeeting,
      'local-brief' => _localBrief,
      'city-update' => _cityUpdate,
      'morning-live-article' => _morningLiveArticle,
      'rural-replay-article' => _ruralReplayArticle,
      'service-guide-article' => _serviceGuideArticle,
      'culture-walk' => _cultureWalk,
      'culture-night-market' => _cultureNightMarket,
      'culture-heritage-route' => _cultureHeritageRoute,
      'culture-mountain-stay' => _cultureMountainStay,
      'torch-opening-night' => _torchOpeningNight,
      'torch-parade-route' => _torchParadeRoute,
      'torch-market-guide' => _torchMarketGuide,
      'torch-volunteer-story' => _torchVolunteerStory,
      'carousel-city' => _cityUpdate,
      'carousel-rural' => _ruralGallery,
      'carousel-service' => _serviceIndustry,
      'morning-live' => _morningLiveArticle,
      _ => null,
    };
  }

  List<ContentItem> search(String keyword) {
    final normalized = keyword.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    return allContentItems
        .where((item) {
          final haystack = [
            item.title,
            item.article.title,
            item.article.source,
            item.article.summary,
            item.contentKind.name,
            item.mediaFeature?.title ?? '',
            item.mediaFeature?.subtitle ?? '',
          ].join(' ').toLowerCase();
          return haystack.contains(normalized);
        })
        .toList(growable: false);
  }

  static const List<PageBlock> _recommendBlocks = [
    PageBlock(
      id: 'notice-bar-headlines',
      type: PageBlockType.noticeBar,
      adminName: '首页要闻公告条',
      sort: 10,
      channelId: 'recommend',
      noticeBarConfig: NoticeBarConfig(intervalMs: 2500),
      noticeItems: [
        NoticeItem(
          id: 'notice-laos',
          title: '习近平同老挝人民革命党中央总书记、国家主席通伦举行会谈',
          sort: 10,
        ),
        NoticeItem(id: 'notice-ecology', title: '践行习近平生态文明思想的时代答卷', sort: 20),
        NoticeItem(
          id: 'notice-friendship',
          title: '重情重义的领袖，实干家和老挝人民的老朋友',
          sort: 30,
        ),
      ],
    ),
    PageBlock(
      id: 'notice-bar-local',
      type: PageBlockType.noticeBar,
      adminName: '首页本地服务公告条',
      sort: 11,
      channelId: 'recommend',
      noticeBarConfig: NoticeBarConfig(intervalMs: 2800),
      noticeItems: [
        NoticeItem(id: 'notice-traffic', title: '本周末主城区部分道路临时交通管制', sort: 10),
        NoticeItem(id: 'notice-service', title: '政务服务中心延时办理窗口开放', sort: 20),
      ],
    ),
    PageBlock(
      id: 'notice-bar-live',
      type: PageBlockType.noticeBar,
      adminName: '首页直播活动公告条',
      sort: 12,
      channelId: 'recommend',
      noticeBarConfig: NoticeBarConfig(intervalMs: 3200),
      noticeItems: [
        NoticeItem(id: 'notice-live', title: '今晚 20:00 直播城市更新发布会', sort: 10),
        NoticeItem(id: 'notice-activity', title: '周末惠民演出预约通道已开启', sort: 20),
      ],
    ),
    PageBlock(
      id: 'focus-carousel',
      type: PageBlockType.imageCarousel,
      adminName: '首页焦点轮播',
      sort: 20,
      channelId: 'recommend',
      carousel: ImageCarousel(
        items: [
          ImageCarouselItem(
            id: 'carousel-city',
            title: '城市更新进行时：看见身边的民生变化',
            subtitle: '专题报道',
            visual: ArticleVisualAsset(
              label: '城市更新',
              type: ArticleVisualType.city,
              imageUrl: _cityImage,
            ),
          ),
          ImageCarouselItem(
            id: 'carousel-rural',
            title: '一线调研行：乡村产业迎来新活力',
            subtitle: '本地观察',
            visual: ArticleVisualAsset(
              label: '乡村振兴',
              type: ArticleVisualType.rural,
              imageUrl: _ruralImage,
            ),
          ),
          ImageCarouselItem(
            id: 'carousel-service',
            title: '服务业大会观察：新场景带动新消费',
            subtitle: '融媒聚焦',
            visual: ArticleVisualAsset(
              label: '服务业',
              type: ArticleVisualType.service,
              imageUrl: _serviceImage,
            ),
          ),
        ],
      ),
    ),
    PageBlock(
      id: 'special-entry-single',
      type: PageBlockType.specialEntry,
      adminName: '首页专题单图入口',
      sort: 30,
      specialEntries: _homeSpecialEntries,
    ),
    PageBlock(
      id: 'home-top-service-navigation',
      type: PageBlockType.serviceNavigation,
      adminName: '首页顶部服务导航',
      sort: 35,
      displayTitle: '服务导航',
      showHeader: true,
    ),
    PageBlock(
      id: 'icon-navigation',
      type: PageBlockType.iconNavigation,
      adminName: '首页图标导航',
      sort: 40,
      actions: [
        PageAction(id: 'politics', label: '政声', icon: PageActionIcon.politics),
        PageAction(id: 'live', label: '直播', icon: PageActionIcon.live),
        PageAction(id: 'report', label: '爆料', icon: PageActionIcon.report),
        PageAction(id: 'service', label: '服务', icon: PageActionIcon.service),
        PageAction(id: 'travel', label: '文旅', icon: PageActionIcon.travel),
      ],
    ),
    PageBlock(
      id: 'tile-grid',
      type: PageBlockType.tileGrid,
      adminName: '首页瓷片入口',
      sort: 50,
      displayTitle: '便民服务',
      showHeader: true,
      tiles: [
        TileGridItem(
          id: 'weather',
          title: '天气',
          subtitle: '未来三天',
          visual: ArticleVisualAsset(
            label: '天气',
            type: ArticleVisualType.service,
            imageUrl: _serviceImage,
          ),
        ),
        TileGridItem(
          id: 'education',
          title: '教育',
          subtitle: '招生政策',
          visual: ArticleVisualAsset(
            label: '教育',
            type: ArticleVisualType.city,
            imageUrl: _cityImage,
          ),
        ),
        TileGridItem(
          id: 'health',
          title: '健康',
          subtitle: '便民服务',
          visual: ArticleVisualAsset(
            label: '健康',
            type: ArticleVisualType.culture,
            imageUrl: _cultureImage,
          ),
          badge: '新',
        ),
      ],
    ),
    PageBlock(
      id: 'media-showcase',
      type: PageBlockType.mediaShowcase,
      adminName: '首页媒体展示',
      sort: 60,
      displayTitle: '正在关注',
      showHeader: true,
      mediaItems: [
        MediaShowcaseItem(
          id: 'morning-live',
          kind: MediaKind.live,
          title: '新闻早班车直播：直击城市更新重点项目',
          visual: ArticleVisualAsset(
            label: '直播现场',
            type: ArticleVisualType.live,
            imageUrl: _meetingImage,
          ),
          durationText: 'LIVE',
          badge: '直播中',
        ),
        MediaShowcaseItem(
          id: 'daily-video',
          kind: MediaKind.video,
          title: '视频｜今日《四川新闻联播》速览〔2026年6月5日〕',
          visual: ArticleVisualAsset(
            label: '视频速览',
            type: ArticleVisualType.live,
            imageUrl: _meetingImage,
          ),
          durationText: '06:55',
          badge: '视频',
        ),
      ],
    ),
    PageBlock(
      id: 'content-feed-main',
      type: PageBlockType.contentFeed,
      adminName: '首页内容信息流',
      sort: 70,
      channelId: 'recommend',
      moreLabel: '查看更多',
      moreTarget: 'app://prototype/channel/recommend/feed',
      items: [
        ContentItem(
          id: 'laos-meeting',
          title: '习近平同老挝人民革命党中央总书记、国家主席通伦举行会谈',
          contentKind: ContentKind.article,
          layout: ContentItemLayout.largeImage,
          article: _laosMeeting,
        ),
        ContentItem(
          id: 'local-brief-text',
          title: '早知道｜今天这些民生提醒和交通变化请留意',
          contentKind: ContentKind.article,
          layout: ContentItemLayout.text,
          article: _localBrief,
        ),
        ContentItem(
          id: 'service-industry',
          title: '四川新闻联播｜加快构建具有地方特色和优势的现代服务业体系',
          contentKind: ContentKind.video,
          layout: ContentItemLayout.sideImage,
          article: _serviceIndustry,
        ),
        ContentItem(
          id: 'daily-video',
          title: '视频｜今日《四川新闻联播》速览〔2026年6月5日〕',
          contentKind: ContentKind.video,
          layout: ContentItemLayout.largeImage,
          article: _dailyVideo,
        ),
        ContentItem(
          id: 'rural-gallery',
          title: '一组图看见乡村新变化：小院、田野和新产业同框入画',
          contentKind: ContentKind.gallery,
          layout: ContentItemLayout.imageGrid,
          article: _ruralGallery,
        ),
        ContentItem(
          id: 'football',
          title: '国足热身赛 2 比 1 战胜新加坡队',
          contentKind: ContentKind.article,
          layout: ContentItemLayout.sideImage,
          article: _football,
        ),
        ContentItem(
          id: 'live-brief',
          title: '今晚 20:00 直播城市更新发布会',
          contentKind: ContentKind.live,
          layout: ContentItemLayout.sideImage,
          article: _morningLiveArticle,
        ),
        ContentItem(
          id: 'service-entry',
          title: '政务服务中心延时办理窗口开放',
          contentKind: ContentKind.service,
          layout: ContentItemLayout.sideImage,
          article: _serviceGuideArticle,
        ),
      ],
    ),
  ];

  static const List<PageBlock> _politicsBlocks = [
    PageBlock(
      id: 'politics-special-group-main',
      type: PageBlockType.specialContentGroup,
      adminName: '政声专题内容组',
      sort: 10,
      channelId: 'politics',
      moreLabel: '进入专题',
      moreTarget: 'app://prototype/channel/politics/special',
      displayTitle: '政声专题',
      showHeader: false,
      items: [
        ContentItem(
          id: 'politics-media-feature-main',
          title: '王晓晖',
          contentKind: ContentKind.special,
          layout: ContentItemLayout.mediaFeature,
          article: _politicsServiceMeeting,
          mediaFeature: MediaFeatureContent(
            title: '王晓晖',
            subtitle: '四川省委书记',
            visual: ArticleVisualAsset(
              label: '王晓晖',
              type: ArticleVisualType.politics,
              imageUrl: _portraitImage,
            ),
            actions: [
              PageAction(
                id: 'instruction',
                label: '工作指示',
                icon: PageActionIcon.politics,
              ),
              PageAction(
                id: 'events',
                label: '重要活动',
                icon: PageActionIcon.live,
              ),
              PageAction(
                id: 'signed',
                label: '署名文章',
                icon: PageActionIcon.report,
              ),
              PageAction(
                id: 'meeting-talk',
                label: '会见座谈',
                icon: PageActionIcon.service,
              ),
              PageAction(
                id: 'meetings',
                label: '重要会议',
                icon: PageActionIcon.travel,
              ),
              PageAction(
                id: 'research',
                label: '调研考察',
                icon: PageActionIcon.education,
              ),
            ],
            articles: [_politicsStandingCommittee, _politicsServiceMeeting],
            moreLabel: '查看更多',
          ),
        ),
      ],
    ),
  ];

  static const List<PageBlock> _videoBlocks = [
    PageBlock(
      id: 'video-feed-main',
      type: PageBlockType.contentFeed,
      adminName: '视频频道信息流',
      sort: 10,
      channelId: 'video',
      items: [
        ContentItem(
          id: 'daily-video-channel',
          title: '视频｜今日《四川新闻联播》速览〔2026年6月5日〕',
          contentKind: ContentKind.video,
          layout: ContentItemLayout.largeImage,
          article: _dailyVideo,
        ),
        ContentItem(
          id: 'service-video-channel',
          title: '视频｜服务业大会现场连线',
          contentKind: ContentKind.video,
          layout: ContentItemLayout.sideImage,
          article: _serviceIndustry,
        ),
      ],
    ),
  ];

  static const List<PageBlock> _localBlocks = [
    PageBlock(
      id: 'local-feed-main',
      type: PageBlockType.contentFeed,
      adminName: '本地频道信息流',
      sort: 10,
      channelId: 'local',
      items: [
        ContentItem(
          id: 'city-update-local',
          title: '城市更新进行时：看见身边的民生变化',
          contentKind: ContentKind.article,
          layout: ContentItemLayout.largeImage,
          article: _cityUpdate,
        ),
        ContentItem(
          id: 'local-brief-channel',
          title: '早知道｜今天这些民生提醒和交通变化请留意',
          contentKind: ContentKind.article,
          layout: ContentItemLayout.text,
          article: _localBrief,
        ),
      ],
    ),
  ];

  static const List<PageBlock> _cultureBlocks = [
    PageBlock(
      id: 'culture-feature-carousel',
      type: PageBlockType.imageCarousel,
      adminName: '文旅频道焦点',
      sort: 5,
      channelId: 'culture',
      carousel: ImageCarousel(
        variant: ImageCarouselVariant.medium,
        indicatorStyle: CarouselIndicatorStyle.dots,
        items: [
          ImageCarouselItem(
            id: 'culture-walk',
            title: '周末去哪儿：城市绿道和乡村集市上新',
            subtitle: '文旅活动',
            visual: ArticleVisualAsset(
              label: '文旅活动',
              type: ArticleVisualType.culture,
              imageUrl: _cultureImage,
            ),
          ),
          ImageCarouselItem(
            id: 'culture-night-market',
            title: '夜游消费季开启，街区演艺和市集连成线',
            subtitle: '夜间消费',
            visual: ArticleVisualAsset(
              label: '夜游市集',
              type: ArticleVisualType.city,
              imageUrl: _cityImage,
            ),
          ),
        ],
      ),
    ),
    PageBlock(
      id: 'culture-feed-main',
      type: PageBlockType.contentFeed,
      adminName: '文旅频道信息流',
      sort: 10,
      channelId: 'culture',
      items: [
        ContentItem(
          id: 'rural-gallery-culture',
          title: '一组图看见乡村新变化：小院、田野和新产业同框入画',
          contentKind: ContentKind.gallery,
          layout: ContentItemLayout.imageGrid,
          article: _ruralGallery,
        ),
        ContentItem(
          id: 'culture-walk',
          title: '周末去哪儿：城市绿道和乡村集市上新',
          contentKind: ContentKind.article,
          layout: ContentItemLayout.sideImage,
          article: _cultureWalk,
        ),
        ContentItem(
          id: 'culture-night-market',
          title: '夜游消费季开启，街区演艺和市集连成线',
          contentKind: ContentKind.article,
          layout: ContentItemLayout.largeImage,
          article: _cultureNightMarket,
        ),
        ContentItem(
          id: 'culture-heritage-route',
          title: '非遗体验线路更新：从展馆走进社区工坊',
          contentKind: ContentKind.gallery,
          layout: ContentItemLayout.imageGrid,
          article: _cultureHeritageRoute,
        ),
        ContentItem(
          id: 'culture-mountain-stay',
          title: '高山民宿预约升温，避暑线路进入旺季',
          contentKind: ContentKind.article,
          layout: ContentItemLayout.sideImage,
          article: _cultureMountainStay,
        ),
      ],
    ),
  ];

  static const List<PageBlock> _torchFestivalBlocks = [
    PageBlock(
      id: 'topic-special-entry',
      type: PageBlockType.specialEntry,
      adminName: '火把节活动入口',
      sort: 10,
      channelId: 'torch_festival',
      specialEntries: [
        SpecialEntryItem(
          id: 'torch-opening-entry',
          specialId: 'special-torch-opening',
          title: '火把节开幕夜直播',
          visual: ArticleVisualAsset(
            label: '火把节',
            type: ArticleVisualType.culture,
            imageUrl: _cultureImage,
          ),
          subtitle: '活动频道',
          badge: '直播',
        ),
        SpecialEntryItem(
          id: 'torch-market-entry',
          specialId: 'special-torch-market',
          title: '火把市集与非遗体验',
          visual: ArticleVisualAsset(
            label: '火把市集',
            type: ArticleVisualType.rural,
            imageUrl: _ruralImage,
          ),
          subtitle: '活动指南',
          badge: '预约',
        ),
      ],
    ),
    PageBlock(
      id: 'torch-media-showcase',
      type: PageBlockType.mediaShowcase,
      adminName: '火把节媒体现场',
      sort: 15,
      channelId: 'torch_festival',
      displayTitle: '现场直击',
      showHeader: true,
      mediaItems: [
        MediaShowcaseItem(
          id: 'torch-opening-night',
          kind: MediaKind.live,
          title: '火把节开幕夜：主会场点火仪式直播',
          visual: ArticleVisualAsset(
            label: '点火仪式',
            type: ArticleVisualType.live,
            imageUrl: _meetingImage,
          ),
          durationText: 'LIVE',
          badge: '直播中',
        ),
        MediaShowcaseItem(
          id: 'torch-parade-route',
          kind: MediaKind.video,
          title: '巡游线路提前看：交通组织和观演点位发布',
          visual: ArticleVisualAsset(
            label: '巡游线路',
            type: ArticleVisualType.city,
            imageUrl: _cityImage,
          ),
          durationText: '02:36',
          badge: '指南',
        ),
      ],
    ),
    PageBlock(
      id: 'topic-feed-main',
      type: PageBlockType.contentFeed,
      adminName: '火把节信息流',
      sort: 20,
      channelId: 'torch_festival',
      items: [
        ContentItem(
          id: 'torch-opening-night',
          title: '火把节开幕夜：主会场点火仪式直播',
          contentKind: ContentKind.live,
          layout: ContentItemLayout.largeImage,
          article: _torchOpeningNight,
        ),
        ContentItem(
          id: 'torch-parade-route',
          title: '巡游线路提前看：交通组织和观演点位发布',
          contentKind: ContentKind.special,
          layout: ContentItemLayout.sideImage,
          article: _torchParadeRoute,
        ),
        ContentItem(
          id: 'torch-market-guide',
          title: '火把市集逛吃指南：非遗、音乐和夜间消费',
          contentKind: ContentKind.service,
          layout: ContentItemLayout.imageGrid,
          article: _torchMarketGuide,
        ),
        ContentItem(
          id: 'torch-volunteer-story',
          title: '志愿者上岗：多语导览和便民服务点准备就绪',
          contentKind: ContentKind.special,
          layout: ContentItemLayout.sideImage,
          article: _torchVolunteerStory,
        ),
      ],
    ),
  ];

  static const List<PageBlock> _liveBlocks = [
    PageBlock(
      id: 'live-channel-showcase',
      type: PageBlockType.mediaShowcase,
      adminName: '直播频道媒体展示',
      sort: 10,
      channelId: 'live',
      displayTitle: '直播与回放',
      showHeader: true,
      mediaItems: [
        MediaShowcaseItem(
          id: 'morning-live-channel',
          kind: MediaKind.live,
          title: '新闻早班车直播：直击城市更新重点项目',
          visual: ArticleVisualAsset(
            label: '直播现场',
            type: ArticleVisualType.live,
            imageUrl: _meetingImage,
          ),
          durationText: 'LIVE',
          badge: '直播中',
        ),
        MediaShowcaseItem(
          id: 'rural-replay-channel',
          kind: MediaKind.replay,
          title: '我的乡村超安逸 共创活动回放',
          visual: ArticleVisualAsset(
            label: '回放',
            type: ArticleVisualType.rural,
            imageUrl: _ruralImage,
          ),
          durationText: '42:18',
          badge: '回放',
        ),
      ],
    ),
    PageBlock(
      id: 'live-feed-main',
      type: PageBlockType.contentFeed,
      adminName: '直播频道信息流',
      sort: 20,
      channelId: 'live',
      items: [
        ContentItem(
          id: 'morning-live-feed',
          title: '新闻早班车直播：直击城市更新重点项目',
          contentKind: ContentKind.live,
          layout: ContentItemLayout.sideImage,
          article: _morningLiveArticle,
        ),
        ContentItem(
          id: 'rural-replay-feed',
          title: '我的乡村超安逸 共创活动回放',
          contentKind: ContentKind.replay,
          layout: ContentItemLayout.largeImage,
          article: _ruralReplayArticle,
        ),
      ],
    ),
  ];

  static const _laosMeeting = Article(
    id: 'laos-meeting',
    contentTag: ArticleContentTag.politics,
    title: '习近平同老挝人民革命党中央总书记、国家主席通伦举行会谈',
    source: '四川新闻联播',
    time: '刚刚',
    summary: '双方围绕高质量共建命运共同体、深化务实合作等议题交换意见。',
    visuals: [
      ArticleVisualAsset(
        label: '时政要闻',
        type: ArticleVisualType.politics,
        imageUrl: _meetingImage,
      ),
    ],
    paragraphs: [
      '双方围绕高质量共建命运共同体、深化务实合作等议题交换意见。',
      '会谈强调，要持续拓展互联互通、产业协作和民生交流，推动合作成果惠及两国人民。',
      '双方还就共同关心的地区和国际问题交换了意见。',
    ],
  );

  static const _localBrief = Article(
    id: 'local-brief',
    contentTag: ArticleContentTag.politics,
    title: '早知道｜今天这些民生提醒和交通变化请留意',
    source: '本地融媒',
    time: '今天 07:30',
    summary: '交通、天气、政务窗口和社区活动信息，一屏了解今日生活提醒。',
    visuals: [
      ArticleVisualAsset(
        label: '民生提醒',
        type: ArticleVisualType.service,
        imageUrl: _serviceImage,
      ),
    ],
    paragraphs: [
      '主城区部分道路早晚高峰会出现短时拥堵，建议市民提前规划出行。',
      '政务服务中心延时窗口继续开放，身份证、社保和企业登记事项可预约办理。',
      '社区便民活动将在多个街道同步开展，居民可就近参加。',
    ],
  );

  static const _cityUpdate = Article(
    id: 'city-update',
    contentTag: ArticleContentTag.politics,
    title: '城市更新进行时：看见身边的民生变化',
    source: '城市观察',
    time: '今天 10:20',
    summary: '从老旧小区改造到街角空间更新，城市治理正变得更可感。',
    visuals: [
      ArticleVisualAsset(
        label: '城市更新',
        type: ArticleVisualType.city,
        imageUrl: _cityImage,
      ),
    ],
    paragraphs: [
      '记者走访多个街区，记录居民身边正在发生的城市更新变化。',
      '项目将公共空间、便民服务和基层治理结合起来，让改造效果更贴近日常生活。',
      '专题页可继续聚合政策解读、现场报道和居民反馈。',
    ],
  );

  static const _serviceIndustry = Article(
    id: 'service-industry',
    contentTag: ArticleContentTag.video,
    title: '四川新闻联播｜加快构建具有地方特色和优势的现代服务业体系',
    source: '四川观察',
    time: '昨天 18:49',
    summary: '聚焦现代服务业高质量发展，推动区域资源、产业和消费场景联动。',
    mediaType: ArticleMediaType.video,
    duration: '06:55',
    visuals: [
      ArticleVisualAsset(
        label: '联播现场',
        type: ArticleVisualType.live,
        imageUrl: _meetingImage,
      ),
    ],
    paragraphs: ['大会提出，要持续提升生产性服务业能级，培育更多消费新场景。', '多地将围绕文旅、康养、数字服务等领域推出配套举措。'],
  );

  static const _dailyVideo = Article(
    id: 'daily-video',
    contentTag: ArticleContentTag.video,
    title: '视频｜今日《四川新闻联播》速览〔2026年6月5日〕',
    source: '四川观察',
    time: '昨天 19:28',
    summary: '一屏速览当天重点新闻，适合放在融媒体 App 首页推荐流。',
    mediaType: ArticleMediaType.video,
    duration: '24:00',
    visuals: [
      ArticleVisualAsset(
        label: '速览',
        type: ArticleVisualType.culture,
        imageUrl: _cultureImage,
      ),
    ],
    paragraphs: ['今日联播聚焦产业发展、城市治理和民生服务。', '多个重点项目进入关键阶段，基层治理创新案例持续涌现。'],
  );

  static const _morningLiveArticle = Article(
    id: 'morning-live-article',
    contentTag: ArticleContentTag.live,
    title: '新闻早班车直播：直击城市更新重点项目',
    source: '融媒直播间',
    time: '正在直播',
    summary: '聚合今日要闻、交通天气和民生服务提醒。',
    mediaType: ArticleMediaType.video,
    duration: 'LIVE',
    visuals: [
      ArticleVisualAsset(
        label: '直播现场',
        type: ArticleVisualType.live,
        imageUrl: _meetingImage,
      ),
    ],
    paragraphs: ['直播连线城市更新重点点位，关注交通组织、配套服务和居民反馈。', '节目还将滚动播报天气、出行和政务服务提醒。'],
  );

  static const _ruralReplayArticle = Article(
    id: 'rural-replay-article',
    contentTag: ArticleContentTag.live,
    title: '我的乡村超安逸 共创活动回放',
    source: '文旅频道',
    time: '昨天 20:00',
    summary: '走进乡村新场景，记录基层治理与文旅融合。',
    mediaType: ArticleMediaType.video,
    duration: '42:18',
    visuals: [
      ArticleVisualAsset(
        label: '乡村回放',
        type: ArticleVisualType.rural,
        imageUrl: _ruralImage,
      ),
    ],
    paragraphs: ['活动回放记录乡村共创现场，展示新场景、新业态和新服务。', '多位基层代表分享了乡村治理与文旅融合经验。'],
  );

  static const _serviceGuideArticle = Article(
    id: 'service-guide-article',
    contentTag: ArticleContentTag.politics,
    title: '政务服务中心延时办理窗口开放',
    source: '便民服务',
    time: '今天 08:30',
    summary: '工作日晚间和周末提供延时办理，覆盖证照、社保和企业服务。',
    visuals: [
      ArticleVisualAsset(
        label: '服务窗口',
        type: ArticleVisualType.service,
        imageUrl: _serviceImage,
      ),
    ],
    paragraphs: ['市民可提前线上预约，也可在现场取号办理。', '延时服务覆盖企业登记、社保咨询和证照办理等高频事项。'],
  );

  static const _cultureWalk = Article(
    id: 'culture-walk',
    contentTag: ArticleContentTag.cultureTourism,
    title: '周末去哪儿：城市绿道和乡村集市上新',
    source: '文旅频道',
    time: '今天 11:05',
    summary: '文旅服务、活动预约和本地消费场景共同组成周末出行指南。',
    visuals: [
      ArticleVisualAsset(
        label: '文旅活动',
        type: ArticleVisualType.culture,
        imageUrl: _cultureImage,
      ),
    ],
    paragraphs: ['绿道骑行、亲子市集和乡村露营线路已经更新。', '多个文旅点位推出预约导览、非遗体验和夜间消费活动。'],
  );

  static const _cultureNightMarket = Article(
    id: 'culture-night-market',
    contentTag: ArticleContentTag.cultureTourism,
    title: '夜游消费季开启，街区演艺和市集连成线',
    source: '文旅频道',
    time: '今天 19:30',
    summary: '主街区、滨河步道和社区舞台联动推出夜游线路。',
    visuals: [
      ArticleVisualAsset(
        label: '夜游市集',
        type: ArticleVisualType.city,
        imageUrl: _cityImage,
      ),
    ],
    paragraphs: [
      '夜游消费季将街区演艺、市集餐饮和文创展陈串联成线。',
      '游客可以按线路预约导览，也可以在小程序查看停车、公交和活动时段。',
    ],
  );

  static const _cultureHeritageRoute = Article(
    id: 'culture-heritage-route',
    contentTag: ArticleContentTag.cultureTourism,
    title: '非遗体验线路更新：从展馆走进社区工坊',
    source: '文旅频道',
    time: '今天 15:20',
    summary: '非遗传承人开放体验课，社区工坊同步推出预约名额。',
    visuals: [
      ArticleVisualAsset(
        label: '非遗展馆',
        type: ArticleVisualType.culture,
        imageUrl: _cultureImage,
      ),
      ArticleVisualAsset(
        label: '社区工坊',
        type: ArticleVisualType.service,
        imageUrl: _serviceImage,
      ),
      ArticleVisualAsset(
        label: '乡村体验',
        type: ArticleVisualType.rural,
        imageUrl: _ruralImage,
      ),
    ],
    paragraphs: ['线路从非遗展馆延伸到社区工坊，适合亲子体验和研学团队。', '平台将持续更新预约余量、活动地址和讲解时段。'],
  );

  static const _cultureMountainStay = Article(
    id: 'culture-mountain-stay',
    contentTag: ArticleContentTag.cultureTourism,
    title: '高山民宿预约升温，避暑线路进入旺季',
    source: '本地融媒',
    time: '昨天 21:10',
    summary: '避暑民宿、森林步道和乡村餐饮组成两日游推荐。',
    visuals: [
      ArticleVisualAsset(
        label: '高山民宿',
        type: ArticleVisualType.rural,
        imageUrl: _ruralImage,
      ),
    ],
    paragraphs: ['多个高山民宿片区进入暑期预约高峰，周末房源较为紧张。', '文旅部门提醒游客提前确认天气、交通和森林防火要求。'],
  );

  static const _ruralGallery = Article(
    id: 'rural-gallery',
    contentTag: ArticleContentTag.cultureTourism,
    title: '一组图看见乡村新变化：小院、田野和新产业同框入画',
    source: '本地融媒',
    time: '今天 09:12',
    summary: '记者走访多个村镇，用三图卡片展示乡村振兴现场。',
    visuals: [
      ArticleVisualAsset(
        label: '小院',
        type: ArticleVisualType.rural,
        imageUrl: _ruralImage,
      ),
      ArticleVisualAsset(
        label: '田野',
        type: ArticleVisualType.city,
        imageUrl: _cityImage,
      ),
      ArticleVisualAsset(
        label: '产业',
        type: ArticleVisualType.service,
        imageUrl: _serviceImage,
      ),
    ],
    paragraphs: ['记者走访村镇小院、田野和产业基地，记录乡村新变化。', '图集中呈现了庭院经济、研学体验和农产品加工场景。'],
  );

  static const _torchOpeningNight = Article(
    id: 'torch-opening-night',
    contentTag: ArticleContentTag.cultureTourism,
    title: '火把节开幕夜：主会场点火仪式直播',
    source: '火把节频道',
    time: '今晚 20:00',
    summary: '主会场点火仪式、群众展演和无人机画面将同步直播。',
    mediaType: ArticleMediaType.video,
    duration: 'LIVE',
    visuals: [
      ArticleVisualAsset(
        label: '点火仪式',
        type: ArticleVisualType.live,
        imageUrl: _meetingImage,
      ),
    ],
    paragraphs: ['火把节开幕夜将通过多机位直播呈现主会场点火仪式。', '频道内同步更新观演提醒、交通组织和现场服务信息。'],
  );

  static const _torchParadeRoute = Article(
    id: 'torch-parade-route',
    contentTag: ArticleContentTag.cultureTourism,
    title: '巡游线路提前看：交通组织和观演点位发布',
    source: '火把节频道',
    time: '今天 16:45',
    summary: '巡游线路、临时交通管制和推荐观演点位已整理。',
    visuals: [
      ArticleVisualAsset(
        label: '巡游线路',
        type: ArticleVisualType.city,
        imageUrl: _cityImage,
      ),
    ],
    paragraphs: ['巡游线路将经过主街区和滨河广场，沿线设置多个观演点。', '市民游客可根据交通组织提示提前规划出行时间。'],
  );

  static const _torchMarketGuide = Article(
    id: 'torch-market-guide',
    contentTag: ArticleContentTag.cultureTourism,
    title: '火把市集逛吃指南：非遗、音乐和夜间消费',
    source: '火把节频道',
    time: '今天 14:10',
    summary: '火把市集集中呈现非遗体验、地方美食和青年音乐现场。',
    visuals: [
      ArticleVisualAsset(
        label: '非遗体验',
        type: ArticleVisualType.culture,
        imageUrl: _cultureImage,
      ),
      ArticleVisualAsset(
        label: '火把市集',
        type: ArticleVisualType.rural,
        imageUrl: _ruralImage,
      ),
      ArticleVisualAsset(
        label: '夜间消费',
        type: ArticleVisualType.city,
        imageUrl: _cityImage,
      ),
    ],
    paragraphs: [
      '市集区域将设置非遗体验、地方美食和文创售卖摊位。',
      '夜间消费区增加了导览标识和志愿服务点，便于游客快速找到活动区域。',
    ],
  );

  static const _torchVolunteerStory = Article(
    id: 'torch-volunteer-story',
    contentTag: ArticleContentTag.cultureTourism,
    title: '志愿者上岗：多语导览和便民服务点准备就绪',
    source: '火把节频道',
    time: '今天 10:35',
    summary: '志愿者将在重点点位提供路线咨询、应急协助和活动引导。',
    visuals: [
      ArticleVisualAsset(
        label: '志愿服务',
        type: ArticleVisualType.service,
        imageUrl: _serviceImage,
      ),
    ],
    paragraphs: ['志愿服务点将覆盖主会场、巡游线路和火把市集等重点区域。', '现场提供路线咨询、应急协助、失物登记和活动引导服务。'],
  );

  static const _football = Article(
    id: 'football',
    contentTag: ArticleContentTag.sports,
    title: '国足热身赛 2 比 1 战胜新加坡队',
    source: '体育频道',
    time: '昨天 22:47',
    summary: '球队通过多轮换人演练阵容，年轻球员表现活跃。',
    visuals: [
      ArticleVisualAsset(
        label: '体育现场',
        type: ArticleVisualType.sports,
        imageUrl: _sportsImage,
      ),
    ],
    paragraphs: [
      '体育、文旅、教育、健康等频道可以使用相同的信息流展示结构。',
      '不同频道的数据来源可以由 Repository 替换，不需要重写 UI。',
    ],
  );

  static const _politicsStandingCommittee = Article(
    id: 'politics-standing-committee',
    contentTag: ArticleContentTag.politicalVoice,
    title: '四川新闻联播｜省委常委会召开会议 坚决拥护党中央对王凤朝的处理决定',
    source: '四川新闻联播',
    time: '前天 18:46',
    summary: '会议强调要把思想和行动统一到党中央决定精神上来。',
    mediaType: ArticleMediaType.video,
    duration: '03:15',
    visuals: [
      ArticleVisualAsset(
        label: '新闻联播',
        type: ArticleVisualType.live,
        imageUrl: _serviceImage,
      ),
    ],
    paragraphs: [
      '政声频道可以通过频道页配置聚合领导活动、重要会议、署名文章等权威内容。',
      '真实项目中可由接口按专题、机构或人物返回分类入口和关联稿件。',
    ],
  );

  static const _politicsServiceMeeting = Article(
    id: 'politics-service-meeting',
    contentTag: ArticleContentTag.politicalVoice,
    title: '四川新闻联播｜王晓晖在全省服务业大会上强调 加快构建具有四川特色和优势的现代服务业体系 奋力开创我省服务业高质量发展新局面',
    source: '四川新闻联播',
    time: '3天前',
    summary: '会议强调找准优势领域和主攻方向，以更大力度夯实基础研究。',
    mediaType: ArticleMediaType.video,
    duration: '06:55',
    visuals: [
      ArticleVisualAsset(
        label: '会议现场',
        type: ArticleVisualType.live,
        imageUrl: _meetingImage,
      ),
    ],
    paragraphs: [
      '政声频道可以通过频道页配置聚合领导活动、重要会议、署名文章等权威内容。',
      '真实项目中可由接口按专题、机构或人物返回分类入口和关联稿件。',
    ],
  );
}
