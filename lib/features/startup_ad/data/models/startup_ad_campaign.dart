enum StartupAdMediaType { image, gif, video }

enum StartupAdActionType { none, internalRoute, externalHttps }

final class StartupAdFrequencyCap {
  const StartupAdFrequencyCap({
    required this.maxImpressions,
    required this.window,
    this.minimumInterval = Duration.zero,
  });

  final int maxImpressions;
  final Duration window;
  final Duration minimumInterval;

  Map<String, Object> toJson() => {
    'maxImpressions': maxImpressions,
    'windowSeconds': window.inSeconds,
    'minimumIntervalSeconds': minimumInterval.inSeconds,
  };

  static StartupAdFrequencyCap? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final maxImpressions = value['maxImpressions'];
    final windowSeconds = value['windowSeconds'];
    final intervalSeconds = value['minimumIntervalSeconds'] ?? 0;
    if (maxImpressions is! int ||
        maxImpressions < 1 ||
        windowSeconds is! int ||
        windowSeconds < 1 ||
        intervalSeconds is! int ||
        intervalSeconds < 0) {
      return null;
    }
    return StartupAdFrequencyCap(
      maxImpressions: maxImpressions,
      window: Duration(seconds: windowSeconds),
      minimumInterval: Duration(seconds: intervalSeconds),
    );
  }
}

final class StartupAdMedia {
  const StartupAdMedia({
    required this.type,
    required this.url,
    required this.mimeType,
    required this.byteLength,
    required this.width,
    required this.height,
    required this.sha256,
    required this.semanticLabel,
    this.duration,
    this.focalX = 0.5,
    this.focalY = 0.5,
    this.localPath,
  });

  final StartupAdMediaType type;
  final Uri url;
  final String mimeType;
  final int byteLength;
  final int width;
  final int height;
  final String sha256;
  final String semanticLabel;
  final Duration? duration;
  final double focalX;
  final double focalY;
  final String? localPath;

  StartupAdMedia copyWith({String? localPath}) => StartupAdMedia(
    type: type,
    url: url,
    mimeType: mimeType,
    byteLength: byteLength,
    width: width,
    height: height,
    sha256: sha256,
    semanticLabel: semanticLabel,
    duration: duration,
    focalX: focalX,
    focalY: focalY,
    localPath: localPath ?? this.localPath,
  );

  Map<String, Object?> toJson() => {
    'type': type.name,
    'url': url.toString(),
    'mimeType': mimeType,
    'byteLength': byteLength,
    'width': width,
    'height': height,
    'sha256': sha256,
    'semanticLabel': semanticLabel,
    'durationMs': duration?.inMilliseconds,
    'focalX': focalX,
    'focalY': focalY,
    'localPath': localPath,
  };

  static StartupAdMedia? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final type = _enumByName(StartupAdMediaType.values, value['type']);
    final url = Uri.tryParse(value['url'] as String? ?? '');
    final mimeType = value['mimeType'];
    final byteLength = value['byteLength'];
    final width = value['width'];
    final height = value['height'];
    final sha256 = value['sha256'];
    final semanticLabel = value['semanticLabel'];
    if (type == null ||
        url == null ||
        url.scheme != 'https' ||
        mimeType is! String ||
        byteLength is! int ||
        byteLength < 1 ||
        width is! int ||
        width < 1 ||
        height is! int ||
        height < 1 ||
        sha256 is! String ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(sha256) ||
        semanticLabel is! String ||
        semanticLabel.trim().isEmpty) {
      return null;
    }
    final durationMs = value['durationMs'];
    return StartupAdMedia(
      type: type,
      url: url,
      mimeType: mimeType,
      byteLength: byteLength,
      width: width,
      height: height,
      sha256: sha256.toLowerCase(),
      semanticLabel: semanticLabel.trim(),
      duration: durationMs is int && durationMs > 0
          ? Duration(milliseconds: durationMs)
          : null,
      focalX: _unitDouble(value['focalX'], 0.5),
      focalY: _unitDouble(value['focalY'], 0.5),
      localPath: value['localPath'] is String
          ? value['localPath'] as String
          : null,
    );
  }
}

final class StartupAdAction {
  const StartupAdAction._({
    required this.type,
    this.routeKey,
    this.parameters = const {},
    this.url,
  });

  const StartupAdAction.none() : this._(type: StartupAdActionType.none);

  const StartupAdAction.internalRoute({
    required String routeKey,
    Map<String, String> parameters = const {},
  }) : this._(
         type: StartupAdActionType.internalRoute,
         routeKey: routeKey,
         parameters: parameters,
       );

  StartupAdAction.externalHttps(Uri url)
    : this._(type: StartupAdActionType.externalHttps, url: url);

  final StartupAdActionType type;
  final String? routeKey;
  final Map<String, String> parameters;
  final Uri? url;

  Map<String, Object?> toJson() => {
    'type': type.name,
    'routeKey': routeKey,
    'parameters': parameters,
    'url': url?.toString(),
  };

  static StartupAdAction? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final type = _enumByName(StartupAdActionType.values, value['type']);
    if (type == null) return null;
    return switch (type) {
      StartupAdActionType.none => const StartupAdAction.none(),
      StartupAdActionType.internalRoute => switch (value['routeKey']) {
        final String routeKey when _allowedRouteKeys.contains(routeKey) =>
          StartupAdAction.internalRoute(
            routeKey: routeKey,
            parameters: _stringMap(value['parameters']),
          ),
        _ => null,
      },
      StartupAdActionType.externalHttps => switch (Uri.tryParse(
        value['url'] as String? ?? '',
      )) {
        final uri? when uri.scheme == 'https' => StartupAdAction.externalHttps(
          uri,
        ),
        _ => null,
      },
    };
  }
}

final class StartupAdCampaign {
  const StartupAdCampaign({
    required this.schemaVersion,
    required this.placementId,
    required this.campaignId,
    required this.creativeId,
    required this.active,
    required this.priority,
    required this.startsAt,
    required this.endsAt,
    required this.serverTime,
    required this.updatedAt,
    required this.freshUntil,
    required this.displayDuration,
    required this.frequencyCap,
    required this.platforms,
    required this.channels,
    required this.media,
    required this.action,
    this.minimumAppVersion,
    this.maximumAppVersion,
    this.fallbackImage,
  });

  static const placement = 'app_startup';

  final int schemaVersion;
  final String placementId;
  final String campaignId;
  final String creativeId;
  final bool active;
  final int priority;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime serverTime;
  final DateTime updatedAt;
  final DateTime freshUntil;
  final Duration displayDuration;
  final StartupAdFrequencyCap frequencyCap;
  final Set<String> platforms;
  final Set<String> channels;
  final String? minimumAppVersion;
  final String? maximumAppVersion;
  final StartupAdMedia media;
  final StartupAdMedia? fallbackImage;
  final StartupAdAction action;

  String get exposureKey => '$campaignId:$creativeId';

  bool isEligible({
    required DateTime now,
    required String platform,
    required String appVersion,
    required String channel,
    required List<DateTime> exposures,
  }) {
    final utcNow = now.toUtc();
    if (!active ||
        schemaVersion != 1 ||
        placementId != placement ||
        utcNow.isBefore(startsAt) ||
        !utcNow.isBefore(endsAt) ||
        !utcNow.isBefore(freshUntil) ||
        (platforms.isNotEmpty && !platforms.contains(platform)) ||
        (channels.isNotEmpty && !channels.contains(channel)) ||
        !_versionInRange(appVersion, minimumAppVersion, maximumAppVersion)) {
      return false;
    }

    final windowStart = utcNow.subtract(frequencyCap.window);
    final recent =
        exposures.where((value) => value.isAfter(windowStart)).toList()..sort();
    if (recent.length >= frequencyCap.maxImpressions) return false;
    if (recent.isNotEmpty &&
        utcNow.difference(recent.last) < frequencyCap.minimumInterval) {
      return false;
    }
    return media.localPath != null;
  }

  StartupAdCampaign copyWith({
    StartupAdMedia? media,
    StartupAdMedia? fallbackImage,
  }) => StartupAdCampaign(
    schemaVersion: schemaVersion,
    placementId: placementId,
    campaignId: campaignId,
    creativeId: creativeId,
    active: active,
    priority: priority,
    startsAt: startsAt,
    endsAt: endsAt,
    serverTime: serverTime,
    updatedAt: updatedAt,
    freshUntil: freshUntil,
    displayDuration: displayDuration,
    frequencyCap: frequencyCap,
    platforms: platforms,
    channels: channels,
    minimumAppVersion: minimumAppVersion,
    maximumAppVersion: maximumAppVersion,
    media: media ?? this.media,
    fallbackImage: fallbackImage ?? this.fallbackImage,
    action: action,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'placementId': placementId,
    'campaignId': campaignId,
    'creativeId': creativeId,
    'active': active,
    'priority': priority,
    'startsAt': startsAt.toUtc().toIso8601String(),
    'endsAt': endsAt.toUtc().toIso8601String(),
    'serverTime': serverTime.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'freshUntil': freshUntil.toUtc().toIso8601String(),
    'displayDurationMs': displayDuration.inMilliseconds,
    'frequencyCap': frequencyCap.toJson(),
    'platforms': platforms.toList(),
    'channels': channels.toList(),
    'minimumAppVersion': minimumAppVersion,
    'maximumAppVersion': maximumAppVersion,
    'media': media.toJson(),
    'fallbackImage': fallbackImage?.toJson(),
    'action': action.toJson(),
  };

  static StartupAdCampaign? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final startsAt = DateTime.tryParse(value['startsAt'] as String? ?? '');
    final endsAt = DateTime.tryParse(value['endsAt'] as String? ?? '');
    final serverTime = DateTime.tryParse(value['serverTime'] as String? ?? '');
    final updatedAt = DateTime.tryParse(value['updatedAt'] as String? ?? '');
    final freshUntil = DateTime.tryParse(value['freshUntil'] as String? ?? '');
    final frequencyCap = StartupAdFrequencyCap.fromJson(value['frequencyCap']);
    final media = StartupAdMedia.fromJson(value['media']);
    final fallbackImage = StartupAdMedia.fromJson(value['fallbackImage']);
    final action = StartupAdAction.fromJson(value['action']);
    final displayDuration = _displayDuration(value['displayDurationMs']);
    if (value['schemaVersion'] is! int ||
        value['placementId'] is! String ||
        value['campaignId'] is! String ||
        (value['campaignId'] as String).isEmpty ||
        value['creativeId'] is! String ||
        (value['creativeId'] as String).isEmpty ||
        value['active'] is! bool ||
        value['priority'] is! int ||
        startsAt == null ||
        endsAt == null ||
        !endsAt.isAfter(startsAt) ||
        serverTime == null ||
        updatedAt == null ||
        freshUntil == null ||
        frequencyCap == null ||
        media == null ||
        action == null ||
        displayDuration == null) {
      return null;
    }
    if ((media.type == StartupAdMediaType.gif ||
            media.type == StartupAdMediaType.video) &&
        (fallbackImage == null ||
            fallbackImage.type != StartupAdMediaType.image)) {
      return null;
    }
    return StartupAdCampaign(
      schemaVersion: value['schemaVersion'] as int,
      placementId: value['placementId'] as String,
      campaignId: value['campaignId'] as String,
      creativeId: value['creativeId'] as String,
      active: value['active'] as bool,
      priority: value['priority'] as int,
      startsAt: startsAt.toUtc(),
      endsAt: endsAt.toUtc(),
      serverTime: serverTime.toUtc(),
      updatedAt: updatedAt.toUtc(),
      freshUntil: freshUntil.toUtc(),
      displayDuration: displayDuration,
      frequencyCap: frequencyCap,
      platforms: _stringSet(value['platforms']),
      channels: _stringSet(value['channels']),
      minimumAppVersion: value['minimumAppVersion'] is String
          ? value['minimumAppVersion'] as String
          : null,
      maximumAppVersion: value['maximumAppVersion'] is String
          ? value['maximumAppVersion'] as String
          : null,
      media: media,
      fallbackImage: fallbackImage,
      action: action,
    );
  }
}

const _allowedRouteKeys = {'home', 'components', 'media', 'settings'};

Duration? _displayDuration(Object? milliseconds) =>
    milliseconds is int && milliseconds >= 3000 && milliseconds <= 5000
    ? Duration(milliseconds: milliseconds)
    : null;

T? _enumByName<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

double _unitDouble(Object? value, double fallback) {
  if (value is! num) return fallback;
  final result = value.toDouble();
  return result >= 0 && result <= 1 ? result : fallback;
}

Set<String> _stringSet(Object? value) => value is List<dynamic>
    ? value.whereType<String>().where((item) => item.isNotEmpty).toSet()
    : const {};

Map<String, String> _stringMap(Object? value) => value is Map<String, dynamic>
    ? {
        for (final entry in value.entries)
          if (entry.value is String) entry.key: entry.value as String,
      }
    : const {};

bool _versionInRange(String value, String? minimum, String? maximum) {
  if (minimum != null && _compareVersions(value, minimum) < 0) return false;
  if (maximum != null && _compareVersions(value, maximum) > 0) return false;
  return true;
}

int _compareVersions(String left, String right) {
  final leftParts = left.split('.').map(_versionPart).toList();
  final rightParts = right.split('.').map(_versionPart).toList();
  final length = leftParts.length > rightParts.length
      ? leftParts.length
      : rightParts.length;
  for (var index = 0; index < length; index++) {
    final leftPart = index < leftParts.length ? leftParts[index] : 0;
    final rightPart = index < rightParts.length ? rightParts[index] : 0;
    final comparison = leftPart.compareTo(rightPart);
    if (comparison != 0) return comparison;
  }
  return 0;
}

int _versionPart(String value) =>
    int.tryParse(RegExp(r'^\d+').stringMatch(value) ?? '') ?? 0;
