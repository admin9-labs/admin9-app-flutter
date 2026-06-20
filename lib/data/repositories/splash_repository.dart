import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/models/splash_content.dart';
import '../services/local_storage_service.dart';
import 'splash_platform.dart';
import 'splash_remote_content.dart';

export 'splash_remote_content.dart';

class SplashRepository {
  const SplashRepository(
    this._storage, {
    this.cacheDirectory,
    this.previewImageUrl = _remotePreviewImage,
    this.loadRemoteBytes,
    this.loadRemoteContent,
  });

  static const _campaignId = 'xichang-splash-20250320';
  static const _remotePreviewImage =
      'https://xcfb.screx.com.cn:18081/group1/M00/11/DA/rBIEDWfbqNuAYFvPAAPd6K69nrM544.jpg';
  static const _maxAge = Duration(days: 7);
  static const _downloadTimeout = Duration(seconds: 8);
  static const _maxDownloadBytes = 3 * 1024 * 1024;
  static const _allowedPreviewHosts = {'xcfb.screx.com.cn'};

  final LocalStorageService _storage;
  final SplashCacheDirectory? cacheDirectory;
  final String previewImageUrl;
  final Future<Uint8List?> Function(Uri uri)? loadRemoteBytes;
  final Future<SplashRemoteContent?> Function(Uri uri)? loadRemoteContent;

  Future<SplashContent?> loadCachedContent() async {
    if (kIsWeb) {
      return null;
    }

    final metadataPayload = _storage.loadSplashCacheMetadata();
    if (metadataPayload == null || metadataPayload.isEmpty) {
      return null;
    }

    final metadata = _SplashCacheMetadata.decode(metadataPayload);
    if (metadata == null) {
      await _dropInvalidCache('invalid splash cache metadata');
      return null;
    }

    if (metadata.id != _campaignId) {
      await _dropInvalidCache('stale splash campaign ${metadata.id}');
      return null;
    }

    if (metadata.isExpired(DateTime.now())) {
      await _dropInvalidCache('expired splash cache ${metadata.id}');
      return null;
    }

    if (metadata.mediaType == SplashMediaType.video) {
      await _dropInvalidCache('unsupported splash media ${metadata.mediaType}');
      return null;
    }

    final isAvailable = await _sourceExists(metadata);
    if (!isAvailable) {
      await _dropInvalidCache('missing splash source ${metadata.source}');
      return null;
    }

    return metadata.toContent();
  }

  Future<void> preloadNextContent() async {
    if (kIsWeb) {
      return;
    }

    final candidate = await _fetchNextCandidate();
    if (candidate == null || candidate.mediaType == SplashMediaType.video) {
      return;
    }

    final remoteUrl = candidate.remoteUrl;
    if (remoteUrl == null || remoteUrl.isEmpty) {
      return;
    }

    try {
      final file = await _download(remoteUrl, candidate.id);
      if (file == null) {
        _debugLog('splash preload skipped because download returned no file');
        return;
      }

      await _storage.saveSplashCacheMetadata(
        _SplashCacheMetadata.fromCandidate(
          candidate,
          sourceType: SplashSourceType.file,
          source: file.path,
          cachedAt: DateTime.now(),
        ).encode(),
      );
    } on Object catch (error) {
      _debugLog('splash preload failed', error);
    }
  }

  Future<_SplashCandidate?> _fetchNextCandidate() async {
    return _SplashCandidate(
      id: _campaignId,
      title: '城市更新进行时',
      subtitle: '关注身边变化，发现美好生活',
      mediaType: SplashMediaType.image,
      duration: Duration(seconds: 5),
      callToAction: '立即查看',
      remoteUrl: previewImageUrl,
      targetTitle: '城市更新专题',
      actionUrl: 'admin9://preview/city-renewal',
    );
  }

  Future<SplashCacheFile?> _download(String url, String id) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !_isAllowedRemoteUri(uri)) {
      _debugLog('splash preload rejected URL $url');
      return null;
    }

    final directory = await _resolveCacheDirectory();
    await createSplashCacheDirectory(directory);

    final extension = _fileExtension(uri.path);
    final file = splashCacheFile(
      splashCacheFilePath(directory, '$id$extension'),
    );
    final payload = await _loadRemoteContent(uri);
    if (!_isValidRemoteContent(payload)) {
      _debugLog('splash download rejected unsafe payload');
      return null;
    }

    await file.writeAsBytes(payload!.bytes, flush: true);
    return file;
  }

  Future<SplashRemoteContent?> _loadRemoteContent(Uri uri) async {
    if (loadRemoteContent != null) {
      return loadRemoteContent!(uri);
    }

    if (loadRemoteBytes != null) {
      final bytes = await loadRemoteBytes!(uri);
      return bytes == null
          ? null
          : SplashRemoteContent(bytes: bytes, contentType: 'image/jpeg');
    }

    return _downloadRemoteContent(uri);
  }

  Future<SplashRemoteContent?> _downloadRemoteContent(Uri uri) async {
    return downloadSplashRemoteContent(
      uri: uri,
      timeout: _downloadTimeout,
      maxBytes: _maxDownloadBytes,
      isImageContentType: _isImageContentType,
      debugLog: _debugLog,
    );
  }

  Future<SplashCacheDirectory> _resolveCacheDirectory() async {
    if (cacheDirectory != null) {
      return cacheDirectory!;
    }
    return defaultSplashCacheDirectory();
  }

  Future<bool> _sourceExists(_SplashCacheMetadata metadata) async {
    return switch (metadata.sourceType) {
      SplashSourceType.asset => _assetExists(metadata.source),
      SplashSourceType.file => _fileExists(metadata.source),
    };
  }

  Future<bool> _assetExists(String source) async {
    try {
      final data = await rootBundle.load(source);
      return data.lengthInBytes > 0;
    } on Object catch (error) {
      _debugLog('splash asset unavailable', error);
      return false;
    }
  }

  Future<bool> _fileExists(String source) async {
    final file = splashCacheFile(source);
    try {
      if (!await file.exists()) {
        return false;
      }
      return await file.length() > 0;
    } on Object catch (error) {
      _debugLog('splash file unavailable', error);
      return false;
    }
  }

  Future<void> _dropInvalidCache(String reason) async {
    _debugLog(reason);
    await _storage.clearSplashCacheMetadata();
  }

  void _debugLog(String message, [Object? error]) {
    if (!kDebugMode) return;
    if (error == null) {
      debugPrint('SplashRepository: $message');
      return;
    }
    debugPrint('SplashRepository: $message ($error)');
  }

  String _fileExtension(String path) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) {
      return '.jpg';
    }
    final extension = name.substring(dot);
    if (extension.length > 8) {
      return '.jpg';
    }
    return extension;
  }

  bool _isAllowedRemoteUri(Uri uri) {
    return uri.scheme == 'https' && _allowedPreviewHosts.contains(uri.host);
  }

  bool _isValidRemoteContent(SplashRemoteContent? content) {
    if (content == null || content.bytes.isEmpty) {
      return false;
    }

    if (!_isImageContentType(content.contentType)) {
      return false;
    }

    return content.bytes.lengthInBytes <= _maxDownloadBytes;
  }

  bool _isImageContentType(String? contentType) {
    return contentType != null &&
        contentType.toLowerCase().trim().startsWith('image/');
  }
}

class _SplashCandidate {
  const _SplashCandidate({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.mediaType,
    required this.duration,
    required this.callToAction,
    this.remoteUrl,
    this.targetTitle,
    this.actionUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final SplashMediaType mediaType;
  final Duration duration;
  final String callToAction;
  final String? remoteUrl;
  final String? targetTitle;
  final String? actionUrl;
}

class _SplashCacheMetadata {
  const _SplashCacheMetadata({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.mediaType,
    required this.durationSeconds,
    required this.callToAction,
    required this.sourceType,
    required this.source,
    required this.cachedAt,
    this.targetTitle,
    this.actionUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final SplashMediaType mediaType;
  final int durationSeconds;
  final String callToAction;
  final SplashSourceType sourceType;
  final String source;
  final DateTime cachedAt;
  final String? targetTitle;
  final String? actionUrl;

  static _SplashCacheMetadata fromCandidate(
    _SplashCandidate candidate, {
    required SplashSourceType sourceType,
    required String source,
    required DateTime cachedAt,
  }) {
    return _SplashCacheMetadata(
      id: candidate.id,
      title: candidate.title,
      subtitle: candidate.subtitle,
      mediaType: candidate.mediaType,
      durationSeconds: candidate.duration.inSeconds,
      callToAction: candidate.callToAction,
      sourceType: sourceType,
      source: source,
      cachedAt: cachedAt,
      targetTitle: candidate.targetTitle,
      actionUrl: candidate.actionUrl,
    );
  }

  static _SplashCacheMetadata? decode(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(payload);
      if (json is! Map<String, Object?>) {
        return null;
      }

      final id = json['id'];
      final title = json['title'];
      final subtitle = json['subtitle'];
      final mediaType = _parseMediaType(json['media_type']);
      final durationSeconds = json['duration_seconds'];
      final callToAction = json['call_to_action'];
      final sourceType = _parseSourceType(json['source_type']);
      final source = json['source'];
      final cachedAt = DateTime.tryParse('${json['cached_at']}');
      final targetTitle = json['target_title'];
      final actionUrl = json['action_url'];

      if (id is! String ||
          title is! String ||
          subtitle is! String ||
          mediaType == null ||
          durationSeconds is! int ||
          callToAction is! String ||
          sourceType == null ||
          source is! String ||
          cachedAt == null) {
        return null;
      }

      return _SplashCacheMetadata(
        id: id,
        title: title,
        subtitle: subtitle,
        mediaType: mediaType,
        durationSeconds: durationSeconds,
        callToAction: callToAction,
        sourceType: sourceType,
        source: source,
        cachedAt: cachedAt,
        targetTitle: targetTitle is String ? targetTitle : null,
        actionUrl: actionUrl is String ? actionUrl : null,
      );
    } on Object {
      return null;
    }
  }

  bool isExpired(DateTime now) {
    return now.difference(cachedAt) > SplashRepository._maxAge;
  }

  String encode() {
    return jsonEncode({
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'media_type': mediaType.name,
      'duration_seconds': durationSeconds,
      'call_to_action': callToAction,
      'source_type': sourceType.name,
      'source': source,
      'cached_at': cachedAt.toIso8601String(),
      if (targetTitle != null) 'target_title': targetTitle,
      if (actionUrl != null) 'action_url': actionUrl,
    });
  }

  SplashContent toContent() {
    return SplashContent(
      id: id,
      title: title,
      subtitle: subtitle,
      mediaType: mediaType,
      duration: Duration(seconds: durationSeconds),
      callToAction: callToAction,
      sourceType: sourceType,
      source: source,
      targetTitle: targetTitle,
      actionUrl: actionUrl,
    );
  }

  static SplashMediaType? _parseMediaType(Object? value) {
    for (final type in SplashMediaType.values) {
      if (type.name == value) return type;
    }
    return null;
  }

  static SplashSourceType? _parseSourceType(Object? value) {
    for (final type in SplashSourceType.values) {
      if (type.name == value) return type;
    }
    return null;
  }
}
