import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/startup_ad_campaign.dart';
import 'startup_ad_http.dart';
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

  Future<void> _pending = Future<void>.value();
  int _pendingOperations = 0;

  // Reads/clears must not remove a refresh's staged files or partial promotion.
  Future<T> _exclusive<T>(Future<T> Function() operation) {
    _pendingOperations++;
    final result = _pending.then((_) => operation()).whenComplete(() {
      _pendingOperations--;
    });
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  // Startup must never wait for an in-flight refresh/download.
  Future<StartupAdCampaign?> readValidated() =>
      _pendingOperations == 0 ? _exclusive(_readValidated) : Future.value(null);

  Future<StartupAdCampaign?> _readValidated() async {
    final directory = await _cacheDirectory();
    final manifest = File('${directory.path}/$_manifestName');
    try {
      if (await FileSystemEntity.type(manifest.path, followLinks: false) !=
              FileSystemEntityType.file ||
          await manifest.length() > maxTotalBytes) {
        await _clear();
        return null;
      }
      final campaign = StartupAdCampaign.fromJson(
        jsonDecode(await manifest.readAsString()),
      );
      if (campaign == null || !_validMetadata(campaign)) {
        await _clear();
        return null;
      }
      if (await manifest.length() +
              campaign.media.byteLength +
              (campaign.fallbackImage?.byteLength ?? 0) >
          maxTotalBytes) {
        await _clear();
        return null;
      }
      final primaryValid = await _validFile(directory, campaign.media);
      final fallback = campaign.fallbackImage;
      final fallbackValid =
          fallback != null && await _validFile(directory, fallback);
      StartupAdCampaign retained = campaign;
      if (!primaryValid) {
        if (!fallbackValid) {
          await _clear();
          return null;
        }
        retained = campaign.copyWith(media: fallback, clearFallbackImage: true);
      } else if (fallback != null && !fallbackValid) {
        if (campaign.media.type != StartupAdMediaType.image) {
          await _clear();
          return null;
        }
        retained = campaign.copyWith(clearFallbackImage: true);
      }
      if (!identical(retained, campaign)) {
        await _writeManifest(directory, retained);
      }
      await _removeUnreferenced(directory, retained);
      if (await _size() > maxTotalBytes) {
        await _clear();
        return null;
      }
      return retained;
    } on Object {
      await _clear();
      return null;
    }
  }

  Future<void> store(StartupAdCampaign campaign) =>
      _exclusive(() => _store(campaign));

  Future<void> _store(StartupAdCampaign campaign) async {
    // Constructors are also used by callers: validate them as strictly as JSON.
    if (StartupAdCampaign.fromJson(campaign.toJson()) == null ||
        !_validMetadata(campaign)) {
      throw const FormatException('Invalid startup-ad campaign metadata.');
    }
    final directory = await _cacheDirectory();
    await directory.create(recursive: true);
    final staging = await directory.createTemp('.staging-');
    final promoted = <String>[];
    var committed = false;
    final stopwatch = Stopwatch()..start();
    try {
      final stagedMedia = await _download(
        directory: staging,
        media: campaign.media,
        suffix: 'primary',
        timeout: const Duration(seconds: 8) - stopwatch.elapsed,
      );
      final stagedFallback = campaign.fallbackImage == null
          ? null
          : await _download(
              directory: staging,
              media: campaign.fallbackImage!,
              suffix: 'fallback',
              timeout: const Duration(seconds: 8) - stopwatch.elapsed,
            );
      final media = await _promote(directory, stagedMedia);
      promoted.add(media.localPath!);
      final fallback = stagedFallback == null
          ? null
          : await _promote(directory, stagedFallback);
      if (fallback != null) promoted.add(fallback.localPath!);
      final cached = campaign.copyWith(media: media, fallbackImage: fallback);
      if (media.byteLength +
              (fallback?.byteLength ?? 0) +
              utf8.encode(jsonEncode(cached.toJson())).length >
          maxTotalBytes) {
        throw const FormatException(
          'Startup-ad cache exceeds its total budget.',
        );
      }
      await _writeManifest(directory, cached);
      committed = true;
      await _removeUnreferenced(directory, cached, staging: staging.path);
    } finally {
      stopwatch.stop();
      if (!committed) {
        for (final path in promoted) {
          final file = File(path);
          if (await file.exists()) await file.delete();
        }
        final temporaryManifest = File('${directory.path}/$_manifestName.part');
        if (await temporaryManifest.exists()) await temporaryManifest.delete();
      }
      if (await staging.exists()) await staging.delete(recursive: true);
    }
  }

  bool _validMetadata(StartupAdCampaign campaign) {
    final media = [
      campaign.media,
      if (campaign.fallbackImage != null) campaign.fallbackImage!,
    ];
    return media.every(
          (item) =>
              startupAdUriAllowed(item.url, allowedMediaHosts) &&
              item.byteLength > 0 &&
              item.byteLength <= _maximumBytes(item.type),
        ) &&
        media.fold<int>(0, (sum, item) => sum + item.byteLength) <=
            maxTotalBytes;
  }

  Future<void> _writeManifest(
    Directory directory,
    StartupAdCampaign campaign,
  ) async {
    final manifest = File('${directory.path}/$_manifestName');
    final temporary = File('${manifest.path}.part');
    await temporary.writeAsString(jsonEncode(campaign.toJson()), flush: true);
    await temporary.rename(manifest.path);
  }

  Future<int> size() => _exclusive(_size);

  Future<int> _size() async {
    final directory = await _cacheDirectory();
    if (!await directory.exists()) return 0;
    var total = 0;
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  Future<void> clear() => _exclusive(_clear);

  Future<void> _clear() async {
    final directory = await _cacheDirectory();
    if (await directory.exists()) await directory.delete(recursive: true);
  }

  Future<StartupAdMedia> _download({
    required Directory directory,
    required StartupAdMedia media,
    required String suffix,
    required Duration timeout,
  }) async {
    if (!startupAdUriAllowed(media.url, allowedMediaHosts)) {
      throw const FormatException('Untrusted startup-ad media URL.');
    }
    final maximum = _maximumBytes(media.type);
    if (media.byteLength > maximum) {
      throw const FormatException('Startup-ad media exceeds its type budget.');
    }

    if (timeout <= Duration.zero) {
      throw TimeoutException('Startup-ad media expired.');
    }
    final response = await startupAdResponse(
      client: client,
      uri: media.url,
      allowedHosts: allowedMediaHosts,
      timeout: timeout,
      expectedMime: media.mimeType,
      expectedLength: media.byteLength,
    );
    if (response.statusCode != 200) {
      throw StartupAdServiceException(response.statusCode);
    }
    final bytes = response.bodyBytes;
    if (bytes.length != media.byteLength ||
        sha256.convert(bytes).toString() != media.sha256 ||
        !_matchesSignature(bytes, media) ||
        !_matchesDimensions(bytes, media)) {
      throw const FormatException('Startup-ad media integrity check failed.');
    }

    final extension = switch (media.type) {
      StartupAdMediaType.image => media.mimeType == 'image/png' ? 'png' : 'jpg',
      StartupAdMediaType.gif => 'gif',
      StartupAdMediaType.video => 'mp4',
    };
    final generation = directory.uri.pathSegments
        .where((part) => part.isNotEmpty)
        .last;
    final target = File(
      '${directory.path}/${generation}_${media.sha256}_$suffix.$extension',
    );
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
    await staged.rename(target.path);
    return media.copyWith(localPath: target.path);
  }

  Future<bool> _validFile(Directory directory, StartupAdMedia media) async {
    final path = media.localPath;
    if (path == null ||
        !startupAdUriAllowed(media.url, allowedMediaHosts) ||
        media.byteLength > _maximumBytes(media.type) ||
        File(path).parent.absolute.path != directory.absolute.path ||
        await FileSystemEntity.type(path, followLinks: false) !=
            FileSystemEntityType.file) {
      return false;
    }
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
        _matchesSignature(bytes, media) &&
        _matchesDimensions(bytes, media);
  }

  Future<void> _removeUnreferenced(
    Directory directory,
    StartupAdCampaign campaign, {
    String? staging,
  }) async {
    final retained = {
      '${directory.path}/$_manifestName',
      campaign.media.localPath,
      campaign.fallbackImage?.localPath,
      staging,
    };
    await for (final entity in directory.list(followLinks: false)) {
      if (!retained.contains(entity.path)) {
        await entity.delete(recursive: true);
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

bool _matchesSignature(
  Uint8List bytes,
  StartupAdMedia media,
) => switch (media.mimeType) {
  'image/jpeg' =>
    media.type == StartupAdMediaType.image &&
        bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff,
  'image/png' =>
    media.type == StartupAdMediaType.image &&
        bytes.length >= 33 &&
        _hasBytes(bytes, 0, const [
          0x89,
          0x50,
          0x4e,
          0x47,
          0x0d,
          0x0a,
          0x1a,
          0x0a,
        ]) &&
        _bigEndian32(bytes, 8) == 13 &&
        _fourCC(bytes, 12) == 'IHDR',
  'image/gif' =>
    media.type == StartupAdMediaType.gif &&
        bytes.length >= 13 &&
        (ascii.decode(bytes.sublist(0, 6), allowInvalid: true) == 'GIF87a' ||
            ascii.decode(bytes.sublist(0, 6), allowInvalid: true) == 'GIF89a'),
  'video/mp4' =>
    media.type == StartupAdMediaType.video && _matchesMp4Signature(bytes),
  _ => false,
};

bool _hasBytes(Uint8List bytes, int offset, List<int> expected) {
  if (offset + expected.length > bytes.length) return false;
  for (var index = 0; index < expected.length; index++) {
    if (bytes[offset + index] != expected[index]) return false;
  }
  return true;
}

String _fourCC(Uint8List bytes, int offset) =>
    ascii.decode(bytes.sublist(offset, offset + 4), allowInvalid: true);

bool _matchesDimensions(Uint8List bytes, StartupAdMedia media) {
  // The platform decoder checks actual video dimensions during initialization.
  if (media.type == StartupAdMediaType.video) return true;
  final dimensions = switch (media.type) {
    StartupAdMediaType.gif => _gifDimensions(bytes),
    StartupAdMediaType.image =>
      media.mimeType == 'image/png'
          ? _pngDimensions(bytes)
          : _jpegDimensions(bytes),
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
      if (segmentLength < 8) return null;
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

bool _matchesMp4Signature(Uint8List bytes) {
  if (bytes.length < 16 || _fourCC(bytes, 4) != 'ftyp') return false;
  final size = _bigEndian32(bytes, 0);
  if (size < 16 || size > bytes.length || size % 4 != 0) return false;
  // ISO-BMFF is also used by HEIF/AVIF and QuickTime; require an MP4 brand.
  const brands = {
    'isom',
    'iso2',
    'iso3',
    'iso4',
    'iso5',
    'iso6',
    'iso7',
    'iso8',
    'iso9',
    'mp41',
    'mp42',
    'avc1',
    'M4V ',
    'dash',
  };
  if (brands.contains(_fourCC(bytes, 8))) return true;
  for (var offset = 16; offset < size; offset += 4) {
    if (brands.contains(_fourCC(bytes, offset))) return true;
  }
  return false;
}
