import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/startup_ad_campaign.dart';
import 'startup_ad_service.dart';

typedef StartupAdCacheDirectory = Future<Directory> Function();

final class StartupAdCache {
  StartupAdCache({
    required this.client,
    required this.allowedMediaHosts,
    StartupAdCacheDirectory? cacheDirectory,
  }) : _cacheDirectory = cacheDirectory ?? _defaultCacheDirectory;

  static const maxImageBytes = 8 * 1024 * 1024;
  static const maxGifBytes = 15 * 1024 * 1024;
  static const maxVideoBytes = 30 * 1024 * 1024;
  static const maxTotalBytes = 50 * 1024 * 1024;
  static const _manifestName = 'manifest.json';

  final http.Client client;
  final Set<String> allowedMediaHosts;
  final StartupAdCacheDirectory _cacheDirectory;

  Future<StartupAdCampaign?> readValidated() async {
    final directory = await _cacheDirectory();
    final manifest = File('${directory.path}/$_manifestName');
    if (!await manifest.exists()) return null;
    try {
      final campaign = StartupAdCampaign.fromJson(
        jsonDecode(await manifest.readAsString()),
      );
      if (campaign == null) {
        await clear();
        return null;
      }
      final primaryValid = await _validFile(directory, campaign.media);
      final fallbackValid =
          campaign.fallbackImage != null &&
          await _validFile(directory, campaign.fallbackImage!);
      if (!primaryValid) {
        if (fallbackValid) {
          return campaign.copyWith(media: campaign.fallbackImage!);
        }
        await clear();
        return null;
      }
      if ((campaign.media.type == StartupAdMediaType.gif ||
              campaign.media.type == StartupAdMediaType.video) &&
          !fallbackValid) {
        await clear();
        return null;
      }
      return campaign;
    } on Object {
      await clear();
      return null;
    }
  }

  Future<void> store(StartupAdCampaign campaign) async {
    final directory = await _cacheDirectory();
    await directory.create(recursive: true);
    final staging = Directory('${directory.path}/.staging');
    if (await staging.exists()) await staging.delete(recursive: true);
    await staging.create();
    try {
      final stagedMedia = await _download(
        directory: staging,
        campaign: campaign,
        media: campaign.media,
        suffix: 'primary',
      );
      final stagedFallback = campaign.fallbackImage == null
          ? null
          : await _download(
              directory: staging,
              campaign: campaign,
              media: campaign.fallbackImage!,
              suffix: 'fallback',
            );
      if ((campaign.media.type == StartupAdMediaType.gif ||
              campaign.media.type == StartupAdMediaType.video) &&
          stagedFallback == null) {
        throw const FormatException('Moving startup media needs a fallback.');
      }

      final media = await _promote(directory, stagedMedia);
      final fallback = stagedFallback == null
          ? null
          : await _promote(directory, stagedFallback);
      final cached = campaign.copyWith(media: media, fallbackImage: fallback);
      final manifest = File('${directory.path}/$_manifestName');
      final temporaryManifest = File('${manifest.path}.part');
      await temporaryManifest.writeAsString(
        jsonEncode(cached.toJson()),
        flush: true,
      );
      await temporaryManifest.rename(manifest.path);
      await _removeUnreferenced(directory, cached);
      if (await size() > maxTotalBytes) {
        await clear();
        throw const FileSystemException('Startup-ad cache exceeds its budget.');
      }
    } finally {
      if (await staging.exists()) await staging.delete(recursive: true);
    }
  }

  Future<int> size() async {
    final directory = await _cacheDirectory();
    if (!await directory.exists()) return 0;
    var total = 0;
    await for (final entity in directory.list()) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  Future<void> clear() async {
    final directory = await _cacheDirectory();
    if (await directory.exists()) await directory.delete(recursive: true);
  }

  Future<StartupAdMedia> _download({
    required Directory directory,
    required StartupAdCampaign campaign,
    required StartupAdMedia media,
    required String suffix,
  }) async {
    if (!startupAdUriAllowed(media.url, allowedMediaHosts)) {
      throw const FormatException('Untrusted startup-ad media URL.');
    }
    final maximum = _maximumBytes(media.type);
    if (media.byteLength > maximum) {
      throw const FormatException('Startup-ad media exceeds its type budget.');
    }

    var uri = media.url;
    http.StreamedResponse? response;
    for (var redirect = 0; redirect <= 3; redirect++) {
      final request = http.Request('GET', uri)..followRedirects = false;
      response = await client.send(request).timeout(const Duration(seconds: 8));
      if (!_redirectStatus(response.statusCode)) break;
      final location = response.headers['location'];
      await response.stream.drain<void>();
      if (location == null) {
        throw const FormatException('Startup-ad redirect has no location.');
      }
      uri = uri.resolve(location);
      if (!startupAdUriAllowed(uri, allowedMediaHosts)) {
        throw const FormatException('Startup-ad redirect left the allowlist.');
      }
      response = null;
    }
    if (response == null || response.statusCode != 200) {
      throw StartupAdServiceException(response?.statusCode ?? 310);
    }
    final contentType = response.headers['content-type']
        ?.split(';')
        .first
        .trim();
    if (contentType != media.mimeType) {
      await response.stream.drain<void>();
      throw const FormatException('Startup-ad media MIME does not match.');
    }
    final builder = BytesBuilder(copy: false);
    var length = 0;
    await for (final chunk in response.stream) {
      length += chunk.length;
      if (length > maximum || length > media.byteLength) {
        throw const FormatException('Startup-ad media download is too large.');
      }
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();
    if (bytes.length != media.byteLength ||
        sha256.convert(bytes).toString() != media.sha256 ||
        !_matchesSignature(bytes, media.type) ||
        !_matchesDimensions(bytes, media)) {
      throw const FormatException('Startup-ad media integrity check failed.');
    }

    final extension = switch (media.type) {
      StartupAdMediaType.image => contentType == 'image/png' ? 'png' : 'jpg',
      StartupAdMediaType.gif => 'gif',
      StartupAdMediaType.video => 'mp4',
    };
    final basename = _safeName(
      '${campaign.campaignId}_${campaign.creativeId}_${media.sha256.substring(0, 12)}',
    );
    final target = File('${directory.path}/${basename}_$suffix.$extension');
    final temporary = File('${target.path}.part');
    await temporary.writeAsBytes(bytes, flush: true);
    await temporary.rename(target.path);
    return media.copyWith(localPath: target.path);
  }

  Future<StartupAdMedia> _promote(
    Directory directory,
    StartupAdMedia media,
  ) async {
    final staged = File(media.localPath!);
    final filename = staged.uri.pathSegments.last;
    final target = File('${directory.path}/$filename');
    if (await target.exists()) await target.delete();
    await staged.rename(target.path);
    return media.copyWith(localPath: target.path);
  }

  Future<bool> _validFile(Directory directory, StartupAdMedia media) async {
    final path = media.localPath;
    if (path == null) return false;
    final file = File(path);
    if (!await file.exists() || await file.length() != media.byteLength) {
      return false;
    }
    final cacheRoot = await directory.resolveSymbolicLinks();
    final resolved = await file.resolveSymbolicLinks();
    if (!resolved.startsWith('$cacheRoot${Platform.pathSeparator}')) {
      return false;
    }
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString() == media.sha256 &&
        _matchesSignature(bytes, media.type) &&
        _matchesDimensions(bytes, media);
  }

  Future<void> _removeUnreferenced(
    Directory directory,
    StartupAdCampaign campaign,
  ) async {
    final retained = {
      '${directory.path}/$_manifestName',
      campaign.media.localPath,
      campaign.fallbackImage?.localPath,
    };
    await for (final entity in directory.list()) {
      if (entity is File && !retained.contains(entity.path)) {
        await entity.delete();
      }
    }
  }
}

Future<Directory> _defaultCacheDirectory() async {
  final root = await getTemporaryDirectory();
  return Directory('${root.path}/admin9-startup-ad');
}

int _maximumBytes(StartupAdMediaType type) => switch (type) {
  StartupAdMediaType.image => StartupAdCache.maxImageBytes,
  StartupAdMediaType.gif => StartupAdCache.maxGifBytes,
  StartupAdMediaType.video => StartupAdCache.maxVideoBytes,
};

bool _redirectStatus(int status) =>
    status == 301 ||
    status == 302 ||
    status == 303 ||
    status == 307 ||
    status == 308;

bool _matchesSignature(
  Uint8List bytes,
  StartupAdMediaType type,
) => switch (type) {
  StartupAdMediaType.image =>
    (bytes.length >= 3 &&
            bytes[0] == 0xff &&
            bytes[1] == 0xd8 &&
            bytes[2] == 0xff) ||
        (bytes.length >= 8 &&
            bytes[0] == 0x89 &&
            utf8.decode(bytes.sublist(1, 4), allowMalformed: true) == 'PNG'),
  StartupAdMediaType.gif =>
    bytes.length >= 6 &&
        (ascii.decode(bytes.sublist(0, 6), allowInvalid: true) == 'GIF87a' ||
            ascii.decode(bytes.sublist(0, 6), allowInvalid: true) == 'GIF89a'),
  StartupAdMediaType.video =>
    bytes.length >= 12 &&
        ascii.decode(bytes.sublist(4, 8), allowInvalid: true) == 'ftyp',
};

bool _matchesDimensions(Uint8List bytes, StartupAdMedia media) {
  if (media.type == StartupAdMediaType.video) return true;
  final dimensions = switch (media.type) {
    StartupAdMediaType.gif => _gifDimensions(bytes),
    StartupAdMediaType.image => _pngDimensions(bytes) ?? _jpegDimensions(bytes),
    StartupAdMediaType.video => null,
  };
  return dimensions != null &&
      dimensions.$1 == media.width &&
      dimensions.$2 == media.height;
}

(int, int)? _pngDimensions(Uint8List bytes) {
  if (bytes.length < 24 || bytes[0] != 0x89) return null;
  return (_bigEndian32(bytes, 16), _bigEndian32(bytes, 20));
}

(int, int)? _gifDimensions(Uint8List bytes) {
  if (bytes.length < 10) return null;
  return (bytes[6] | (bytes[7] << 8), bytes[8] | (bytes[9] << 8));
}

(int, int)? _jpegDimensions(Uint8List bytes) {
  if (bytes.length < 10 || bytes[0] != 0xff || bytes[1] != 0xd8) {
    return null;
  }
  var index = 2;
  const frameMarkers = {
    0xc0,
    0xc1,
    0xc2,
    0xc3,
    0xc5,
    0xc6,
    0xc7,
    0xc9,
    0xca,
    0xcb,
    0xcd,
    0xce,
    0xcf,
  };
  while (index + 8 < bytes.length) {
    if (bytes[index] != 0xff) {
      index++;
      continue;
    }
    final marker = bytes[index + 1];
    if (marker == 0xd8 || marker == 0xd9) {
      index += 2;
      continue;
    }
    final segmentLength = (bytes[index + 2] << 8) | bytes[index + 3];
    if (segmentLength < 2 || index + 2 + segmentLength > bytes.length) {
      return null;
    }
    if (frameMarkers.contains(marker)) {
      final height = (bytes[index + 5] << 8) | bytes[index + 6];
      final width = (bytes[index + 7] << 8) | bytes[index + 8];
      return (width, height);
    }
    index += 2 + segmentLength;
  }
  return null;
}

int _bigEndian32(Uint8List bytes, int offset) =>
    (bytes[offset] << 24) |
    (bytes[offset + 1] << 16) |
    (bytes[offset + 2] << 8) |
    bytes[offset + 3];

String _safeName(String value) =>
    value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
