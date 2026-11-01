import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:admin9_app_flutter/features/startup_ad/data/models/startup_ad_campaign.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/services/startup_ad_cache.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/services/startup_ad_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory directory;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('admin9-startup-ad-test-');
  });

  tearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  test(
    'stores verified media atomically and restores a valid manifest',
    () async {
      final bytes = _jpegBytes(width: 1080, height: 1920);
      final cache = StartupAdCache(
        client: MockClient(
          (_) async => http.Response.bytes(
            bytes,
            200,
            headers: const {'content-type': 'image/jpeg'},
          ),
        ),
        allowedMediaHosts: const {'cdn.example.com'},
        cacheDirectory: () async => directory,
      );

      await cache.store(_campaign(bytes));
      final restored = await cache.readValidated();

      expect(restored, isNotNull);
      expect(restored?.media.localPath, isNotNull);
      expect(File(restored!.media.localPath!).existsSync(), isTrue);
      expect(
        directory.listSync().whereType<File>().any(
          (file) => file.path.endsWith('.part'),
        ),
        isFalse,
      );
      expect(await cache.size(), greaterThan(bytes.length));
    },
  );

  test('drops metadata and files after cached media is corrupted', () async {
    final bytes = _jpegBytes(width: 1080, height: 1920);
    final cache = StartupAdCache(
      client: MockClient(
        (_) async => http.Response.bytes(
          bytes,
          200,
          headers: const {'content-type': 'image/jpeg'},
        ),
      ),
      allowedMediaHosts: const {'cdn.example.com'},
      cacheDirectory: () async => directory,
    );
    await cache.store(_campaign(bytes));
    final stored = await cache.readValidated();
    await File(stored!.media.localPath!).writeAsBytes([0]);

    expect(await cache.readValidated(), isNull);
    expect(directory.existsSync(), isFalse);
  });

  test('rejects a redirect that leaves the media host allowlist', () async {
    final bytes = _jpegBytes(width: 1080, height: 1920);
    final cache = StartupAdCache(
      client: MockClient(
        (_) async => http.Response(
          '',
          302,
          headers: const {'location': 'https://untrusted.example/file.jpg'},
        ),
      ),
      allowedMediaHosts: const {'cdn.example.com'},
      cacheDirectory: () async => directory,
    );

    await expectLater(cache.store(_campaign(bytes)), throwsFormatException);
    expect(File('${directory.path}/manifest.json').existsSync(), isFalse);
  });

  test('failed refresh preserves the previous verified campaign', () async {
    final bytes = _jpegBytes(width: 1080, height: 1920);
    final working = StartupAdCache(
      client: MockClient(
        (_) async => http.Response.bytes(
          bytes,
          200,
          headers: const {'content-type': 'image/jpeg'},
        ),
      ),
      allowedMediaHosts: const {'cdn.example.com'},
      cacheDirectory: () async => directory,
    );
    await working.store(_campaign(bytes));
    final failing = StartupAdCache(
      client: MockClient((_) async => http.Response('', 503)),
      allowedMediaHosts: const {'cdn.example.com'},
      cacheDirectory: () async => directory,
    );

    await expectLater(
      failing.store(_campaign(bytes)),
      throwsA(isA<StartupAdServiceException>()),
    );

    final restored = await working.readValidated();
    expect(restored?.campaignId, 'campaign');
    expect(restored?.media.localPath, isNotNull);
  });

  test(
    'uses a verified fallback when the primary file becomes invalid',
    () async {
      final primary = _jpegBytes(width: 1080, height: 1920);
      final fallback = Uint8List.fromList([
        ..._jpegBytes(width: 1080, height: 1920),
        0x00,
      ]);
      final cache = StartupAdCache(
        client: MockClient((request) async {
          final bytes = request.url.path.endsWith('fallback.jpg')
              ? fallback
              : primary;
          return http.Response.bytes(
            bytes,
            200,
            headers: const {'content-type': 'image/jpeg'},
          );
        }),
        allowedMediaHosts: const {'cdn.example.com'},
        cacheDirectory: () async => directory,
      );
      await cache.store(_campaign(primary, fallbackBytes: fallback));
      final stored = await cache.readValidated();
      await File(stored!.media.localPath!).writeAsBytes([0]);

      final restored = await cache.readValidated();

      expect(restored?.media.semanticLabel, '备用图');
      expect(restored?.media.localPath, contains('fallback'));
    },
  );

  StartupAdCache cacheFor(
    Uint8List bytes, {
    Set<String> hosts = const {'cdn.example.com'},
    String mime = 'image/jpeg',
  }) => StartupAdCache(
    client: MockClient(
      (_) async =>
          http.Response.bytes(bytes, 200, headers: {'content-type': mime}),
    ),
    allowedMediaHosts: hosts,
    cacheDirectory: () async => directory,
  );

  test('cache read rechecks the current media host allowlist', () async {
    final bytes = _jpegBytes(width: 1080, height: 1920);
    await cacheFor(bytes).store(_campaign(bytes));
    expect(
      await cacheFor(bytes, hosts: {'new.example.com'}).readValidated(),
      isNull,
    );
    expect(directory.existsSync(), isFalse);
  });

  for (final field in ['byteLength', 'mimeType', 'width', 'sha256', 'url']) {
    test('cache read rejects tampered $field metadata', () async {
      final bytes = _jpegBytes(width: 1080, height: 1920);
      final cache = cacheFor(bytes);
      await cache.store(_campaign(bytes));
      final manifest = File('${directory.path}/manifest.json');
      final json =
          jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
      final media = json['media'] as Map<String, dynamic>;
      media[field] = switch (field) {
        'byteLength' => StartupAdCache.maxImageBytes + 1,
        'mimeType' => 'image/png',
        'width' => 1,
        'sha256' => 'f' * 64,
        _ => 'https://user@cdn.example.com/a',
      };
      await manifest.writeAsString(jsonEncode(json));
      expect(await cache.readValidated(), isNull);
      expect(directory.existsSync(), isFalse);
    });
  }

  test('read removes orphan files, nested staging and symlinks', () async {
    final bytes = _jpegBytes(width: 1080, height: 1920);
    final cache = cacheFor(bytes);
    await cache.store(_campaign(bytes));
    await File('${directory.path}/orphan.part').writeAsBytes([1]);
    final staging = await Directory('${directory.path}/.staging-old').create();
    await File('${staging.path}/partial').writeAsBytes([1]);
    final outside = await Directory.systemTemp.createTemp(
      'startup-ad-outside-',
    );
    addTearDown(() => outside.delete(recursive: true));
    final protected = await File('${outside.path}/protected').writeAsBytes([7]);
    await Link('${directory.path}/orphan-link').create(outside.path);
    expect(await cache.readValidated(), isNotNull);
    expect(directory.listSync().length, 2);
    expect(await protected.readAsBytes(), [7]);
  });

  test('missing or malformed manifest removes all orphan data', () async {
    final cache = cacheFor(_jpegBytes(width: 1080, height: 1920));
    await File('${directory.path}/orphan').writeAsBytes([1]);
    expect(await cache.readValidated(), isNull);
    expect(directory.existsSync(), isFalse);
    await directory.create();
    await File('${directory.path}/manifest.json').writeAsString('{');
    expect(await cache.readValidated(), isNull);
    expect(directory.existsSync(), isFalse);
  });

  test(
    'fallback recovery deletes corrupt primary and persists repaired manifest',
    () async {
      final bytes = _jpegBytes(width: 1080, height: 1920);
      final cache = cacheFor(bytes);
      await cache.store(_campaign(bytes, fallbackBytes: bytes));
      final stored = (await cache.readValidated())!;
      await File(stored.media.localPath!).writeAsBytes([1]);
      final restored = (await cache.readValidated())!;
      expect(restored.media.semanticLabel, '备用图');
      expect(restored.fallbackImage, isNull);
      expect(File(stored.media.localPath!).existsSync(), isFalse);
      expect(directory.listSync().length, 2);
      expect(
        (await cache.readValidated())!.media.localPath,
        restored.media.localPath,
      );
    },
  );

  test(
    'invalid optional fallback is removed while a valid image is retained',
    () async {
      final bytes = _jpegBytes(width: 1080, height: 1920);
      final cache = cacheFor(bytes);
      await cache.store(_campaign(bytes, fallbackBytes: bytes));
      final stored = (await cache.readValidated())!;
      await File(stored.fallbackImage!.localPath!).writeAsBytes([1]);
      final restored = (await cache.readValidated())!;
      expect(restored.media.localPath, stored.media.localPath);
      expect(restored.fallbackImage, isNull);
      expect(File(stored.fallbackImage!.localPath!).existsSync(), isFalse);
    },
  );

  test(
    'rejects MIME/signature confusion even with matching hash and header',
    () async {
      final jpeg = _jpegBytes(width: 1080, height: 1920);
      final json = _campaign(jpeg).toJson();
      (json['media'] as Map<String, Object?>)['mimeType'] = 'image/png';
      final campaign = StartupAdCampaign.fromJson(json)!;
      await expectLater(
        cacheFor(jpeg, mime: 'image/png').store(campaign),
        throwsFormatException,
      );
      expect(File('${directory.path}/manifest.json').existsSync(), isFalse);
    },
  );

  for (final field in ['byteLength', 'width', 'height', 'sha256']) {
    test('download enforces exact $field', () async {
      final bytes = _jpegBytes(width: 1080, height: 1920);
      final json = _campaign(bytes).toJson();
      (json['media'] as Map<String, Object?>)[field] = field == 'sha256'
          ? 'f' * 64
          : 1;
      final campaign = StartupAdCampaign.fromJson(json)!;
      await expectLater(cacheFor(bytes).store(campaign), throwsFormatException);
      expect(directory.listSync(), isEmpty);
    });
  }

  for (final type in StartupAdMediaType.values) {
    test('rejects ${type.name} over budget before making a request', () async {
      var requests = 0;
      final bytes = _jpegBytes(width: 1080, height: 1920);
      final json = _campaign(bytes, fallbackBytes: bytes).toJson();
      final media = json['media'] as Map<String, Object?>;
      media['type'] = type.name;
      media['mimeType'] = switch (type) {
        StartupAdMediaType.image => 'image/jpeg',
        StartupAdMediaType.gif => 'image/gif',
        StartupAdMediaType.video => 'video/mp4',
      };
      media['durationMs'] = 3000;
      media['byteLength'] = switch (type) {
        StartupAdMediaType.image => StartupAdCache.maxImageBytes + 1,
        StartupAdMediaType.gif => StartupAdCache.maxGifBytes + 1,
        StartupAdMediaType.video => StartupAdCache.maxVideoBytes + 1,
      };
      final cache = StartupAdCache(
        client: MockClient((_) async {
          requests++;
          return http.Response('', 200);
        }),
        allowedMediaHosts: {'cdn.example.com'},
        cacheDirectory: () async => directory,
      );
      await expectLater(
        cache.store(StartupAdCampaign.fromJson(json)!),
        throwsFormatException,
      );
      expect(requests, 0);
    });
  }

  test(
    'manifest write failure preserves old generation and removes new files',
    () async {
      final bytes = _jpegBytes(width: 1080, height: 1920);
      final cache = cacheFor(bytes);
      await cache.store(_campaign(bytes));
      final old = (await cache.readValidated())!;
      final blocked = await Directory('${directory.path}/manifest.json.part')
          .create();
      await expectLater(
        cache.store(_campaign(bytes)),
        throwsA(isA<FileSystemException>()),
      );
      expect(await File(old.media.localPath!).readAsBytes(), bytes);
      await blocked.delete();
      final restored = (await cache.readValidated())!;
      expect(restored.media.localPath, old.media.localPath);
      expect(directory.listSync().length, 2);
    },
  );

  test(
    'clear waits for an active store and removes its completed generation',
    () async {
      final bytes = _jpegBytes(width: 1080, height: 1920);
      final entered = Completer<void>();
      final release = Completer<void>();
      final cache = StartupAdCache(
        client: MockClient((_) async {
          entered.complete();
          await release.future;
          return http.Response.bytes(
            bytes,
            200,
            headers: {'content-type': 'image/jpeg'},
          );
        }),
        allowedMediaHosts: {'cdn.example.com'},
        cacheDirectory: () async => directory,
      );
      final storing = cache.store(_campaign(bytes));
      await entered.future;
      expect(await cache.readValidated(), isNull);
      final clearing = cache.clear();
      release.complete();
      await storing;
      await clearing;
      expect(directory.existsSync(), isFalse);
      expect(await cache.readValidated(), isNull);
    },
  );
}

StartupAdCampaign _campaign(Uint8List bytes, {Uint8List? fallbackBytes}) {
  final now = DateTime.now().toUtc();
  return StartupAdCampaign(
    schemaVersion: 1,
    placementId: StartupAdCampaign.placement,
    campaignId: 'campaign',
    creativeId: 'creative',
    active: true,
    priority: 1,
    startsAt: now.subtract(const Duration(hours: 1)),
    endsAt: now.add(const Duration(hours: 1)),
    serverTime: now,
    updatedAt: now,
    freshUntil: now.add(const Duration(hours: 1)),
    displayDuration: const Duration(seconds: 3),
    frequencyCap: const StartupAdFrequencyCap(
      maxImpressions: 1,
      window: Duration(days: 1),
    ),
    platforms: const {'ios', 'android'},
    channels: const {'official'},
    media: StartupAdMedia(
      type: StartupAdMediaType.image,
      url: Uri.parse('https://cdn.example.com/creative.jpg'),
      mimeType: 'image/jpeg',
      byteLength: bytes.length,
      width: 1080,
      height: 1920,
      sha256: sha256.convert(bytes).toString(),
      semanticLabel: '推广图',
    ),
    fallbackImage: fallbackBytes == null
        ? null
        : StartupAdMedia(
            type: StartupAdMediaType.image,
            url: Uri.parse('https://cdn.example.com/fallback.jpg'),
            mimeType: 'image/jpeg',
            byteLength: fallbackBytes.length,
            width: 1080,
            height: 1920,
            sha256: sha256.convert(fallbackBytes).toString(),
            semanticLabel: '备用图',
          ),
    action: const StartupAdAction.none(),
  );
}

Uint8List _jpegBytes({required int width, required int height}) =>
    Uint8List.fromList([
      0xff,
      0xd8,
      0xff,
      0xc0,
      0x00,
      0x11,
      0x08,
      height >> 8,
      height & 0xff,
      width >> 8,
      width & 0xff,
      0x03,
      0x01,
      0x11,
      0x00,
      0x02,
      0x11,
      0x00,
      0x03,
      0x11,
      0x00,
      0xff,
      0xd9,
    ]);
