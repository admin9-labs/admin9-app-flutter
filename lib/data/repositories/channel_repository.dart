import 'dart:ui';

import '../../core/assets/app_assets.dart';
import '../../domain/models/media_channel.dart';
import '../services/local_storage_service.dart';

class ChannelRepository {
  const ChannelRepository({required this.storage});

  final LocalStorageService storage;

  static const topicH5Url = 'https://wx.wifixc.com/h5/ymapp_subject/#/32/home';
  static const _defaultChannelMigrationVersion = 1;
  static const _newDefaultChannelIds = <String>{'torch_festival'};
  static const _cultureSolidGreen = Color(0xff2fbf71);
  static const _cultureAccent = Color(0xff0f5132);
  static const _torchFestivalRed = Color(0xffb71f2d);
  static const _cultureStyle = MediaChannelStyle(
    visualProfile: MediaChannelVisualProfile.standard,
    topBackground: MediaChannelTopBackground(
      mode: MediaChannelTopBackgroundMode.color,
      endColor: _cultureSolidGreen,
      height: 260,
    ),
    backdropBlendMode: MediaChannelBackdropBlendMode.none,
    backgroundColor: _cultureSolidGreen,
    accentColor: _cultureAccent,
  );
  static const _torchFestivalStyle = MediaChannelStyle(
    visualProfile: MediaChannelVisualProfile.campaignImmersive,
    chromeBehavior: MediaChannelChromeBehavior.transparentToSolid,
    topBackground: MediaChannelTopBackground(
      mode: MediaChannelTopBackgroundMode.customImage,
    ),
    backdropBlendMode: MediaChannelBackdropBlendMode.fadeToColor,
    pullEffect: MediaChannelPullEffect.stretchBackdrop,
    surfaceMode: MediaChannelSurfaceMode.immersive,
    topSurfaceMode: MediaChannelTopSurfaceMode.customImage,
    backgroundColor: _torchFestivalRed,
    accentColor: _torchFestivalRed,
    backdropAssetName: AppAssets.topLevelMainstreamRedHeader,
    immersiveBackdropAssetName: AppAssets.topLevelMainstreamRedHeader,
    immersiveBackdropHeight: 232,
    immersiveContentTopInset: 10,
  );

  static const defaultChannels = [
    MediaChannel(id: 'recommend', label: '推荐', fixed: true),
    MediaChannel(id: 'politics', label: '政声'),
    MediaChannel(id: 'video', label: '视频'),
    MediaChannel(id: 'local', label: '本地'),
    MediaChannel(id: 'culture', label: '文旅', style: _cultureStyle),
    MediaChannel(
      id: 'topic',
      label: '专题',
      content: MediaChannelContent.h5(url: topicH5Url),
    ),
    MediaChannel(
      id: 'torch_festival',
      label: '火把节',
      style: _torchFestivalStyle,
    ),
    MediaChannel(id: 'live', label: '直播'),
  ];

  static const extraChannels = [
    MediaChannel(id: 'discover', label: '发现'),
    MediaChannel(id: 'headline', label: '要闻'),
    MediaChannel(id: 'network', label: '联播'),
    MediaChannel(id: 'spark', label: '星火'),
    MediaChannel(id: 'short_drama', label: '短剧'),
    MediaChannel(id: 'education', label: '教育'),
    MediaChannel(id: 'health', label: '健康'),
    MediaChannel(id: 'city_circle', label: '市州圈'),
    MediaChannel(id: 'rural', label: '乡村'),
    MediaChannel(id: 'current', label: '时事'),
  ];

  static const allChannels = [...defaultChannels, ...extraChannels];

  Future<List<MediaChannel>> loadMyChannels() async {
    final savedIds = storage.loadChannelIds();
    if (savedIds == null || savedIds.isEmpty) return defaultChannels;

    final channels = <MediaChannel>[];
    for (final id in savedIds) {
      final channel = _findById(id);
      if (channel != null && !channels.any((item) => item.id == id)) {
        channels.add(channel);
      }
    }

    if (channels.isEmpty || channels.first.id != 'recommend') {
      channels.removeWhere((channel) => channel.id == 'recommend');
      channels.insert(0, defaultChannels.first);
    }

    if (storage.loadChannelDefaultsVersion() <
        _defaultChannelMigrationVersion) {
      final migratedChannels = _mergeNewDefaultChannels(channels);
      await _saveChannelSelection(migratedChannels);
      return migratedChannels;
    }

    return _ensureRecommendFirst(channels);
  }

  Future<void> saveMyChannels(List<MediaChannel> channels) async {
    final safeChannels = _ensureRecommendFirst(channels);
    await _saveChannelSelection(safeChannels);
  }

  Future<List<MediaChannel>> resetDefaultChannels() async {
    await saveMyChannels(defaultChannels);
    return defaultChannels;
  }

  List<MediaChannel> availableMoreChannels(List<MediaChannel> myChannels) {
    final selectedIds = myChannels.map((channel) => channel.id).toSet();
    return allChannels
        .where((channel) => !selectedIds.contains(channel.id))
        .toList(growable: false);
  }

  MediaChannel? findById(String id) => _findById(id);

  MediaChannel? _findById(String id) {
    for (final channel in allChannels) {
      if (channel.id == id) return channel;
    }
    return null;
  }

  List<MediaChannel> _ensureRecommendFirst(List<MediaChannel> channels) {
    final result = [
      for (final channel in channels)
        if (channel.id != 'recommend') channel,
    ];
    result.insert(0, defaultChannels.first);
    return result;
  }

  List<MediaChannel> _mergeNewDefaultChannels(List<MediaChannel> channels) {
    var result = _ensureRecommendFirst(channels);
    for (final defaultChannel in defaultChannels) {
      if (!_newDefaultChannelIds.contains(defaultChannel.id)) continue;
      if (result.any((channel) => channel.id == defaultChannel.id)) continue;

      final defaultIndex = defaultChannels.indexWhere(
        (channel) => channel.id == defaultChannel.id,
      );
      var insertIndex = result.length;
      for (
        var index = defaultIndex + 1;
        index < defaultChannels.length;
        index++
      ) {
        final nextDefaultId = defaultChannels[index].id;
        final existingIndex = result.indexWhere(
          (channel) => channel.id == nextDefaultId,
        );
        if (existingIndex >= 0) {
          insertIndex = existingIndex;
          break;
        }
      }
      result = [
        ...result.take(insertIndex),
        defaultChannel,
        ...result.skip(insertIndex),
      ];
    }
    return result;
  }

  Future<void> _saveChannelSelection(List<MediaChannel> channels) async {
    await storage.saveChannelIds([for (final channel in channels) channel.id]);
    await storage.saveChannelDefaultsVersion(_defaultChannelMigrationVersion);
  }
}
