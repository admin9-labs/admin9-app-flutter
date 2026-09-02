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
