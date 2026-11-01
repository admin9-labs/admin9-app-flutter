import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/app/startup/startup_preferences.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/models/startup_ad_campaign.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/repositories/cached_startup_ad_repository.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/services/startup_ad_cache.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/services/startup_ad_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory directory;
  late StartupAdCache cache;
  late _Service service;
  late int downloads;
  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Wl6AAAAAElFTkSuQmCC',
  );

  setUp(() {
    directory = Directory.systemTemp.createTempSync('startup-ad-repository-');
    downloads = 0;
    cache = StartupAdCache(
      client: MockClient((_) async {
        downloads++;
        return http.Response.bytes(
          png,
          200,
          headers: {'content-type': 'image/png'},
        );
      }),
      allowedMediaHosts: {'cdn.example.com'},
      cacheDirectory: () async => directory,
    );
    service = _Service();
  });
  tearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  CachedStartupAdRepository repository({Set<String> external = const {}}) =>
      CachedStartupAdRepository(
        service: service,
        cache: cache,
        platform: 'ios',
        appVersion: '1.1.0',
        channel: 'official',
        allowedExternalHosts: external,
      );

  StartupAdCampaign campaign({
    bool active = true,
    StartupAdAction action = const StartupAdAction.none(),
  }) {
    final json = jsonDecode(
      File('test/fixtures/startup_ad/campaign.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    json['active'] = active;
    json['fallbackImage'] = null;
    json['media'] = {
      'type': 'image',
      'url': 'https://cdn.example.com/a.png',
      'mimeType': 'image/png',
      'byteLength': png.length,
      'width': 1,
      'height': 1,
      'sha256': sha256.convert(png).toString(),
      'semanticLabel': 'Campaign image',
      'focalX': 0.5,
      'focalY': 0.5,
    };
    json['action'] = action.toJson();
    return StartupAdCampaign.fromJson(json)!;
  }

  Future<StartupAdCampaign?> load(
    CachedStartupAdRepository repo, {
    String platform = 'ios',
    String channel = 'official',
    String appVersion = '1.1.0',
  }) => repo.loadCachedEligible(
    now: DateTime.utc(2026, 9, 1, 9),
    platform: platform,
    appVersion: appVersion,
    channel: channel,
    preferences: const StartupPreferences(),
  );

  test(
    'empty external allowlist rejects external actions before media download',
    () async {
      service.campaign = campaign(
        action: StartupAdAction.externalHttps(
          Uri.parse('https://www.example.com/a'),
        ),
      );
      await expectLater(repository().refresh(), throwsFormatException);
      expect(downloads, 0);
      expect(await load(repository()), isNull);
    },
  );

  test(
    'injected external allowlist is enforced again for cached campaigns',
    () async {
      service.campaign = campaign(
        action: StartupAdAction.externalHttps(
          Uri.parse('https://www.example.com/a'),
        ),
      );
      final allowed = repository(external: {'www.example.com'});
      await allowed.refresh();
      expect((await load(allowed))?.action.url?.host, 'www.example.com');
      expect(downloads, 1);
      expect(await load(repository(external: {'other.example.com'})), isNull);
      expect(directory.existsSync(), isFalse);
    },
  );

  for (final inactive in [false, true]) {
    test(
      '${inactive ? 'inactive' : '204'} response clears cached campaign',
      () async {
        service.campaign = campaign();
        final repo = repository();
        await repo.refresh();
        expect(await load(repo), isNotNull);
        service.campaign = inactive ? campaign(active: false) : null;
        await repo.refresh();
        expect(await load(repo), isNull);
        expect(await repo.cacheSize(), 0);
        expect(downloads, 1);
      },
    );
  }

  test('cached eligibility enforces platform, version and channel without fetching', () async {
    service.campaign = campaign();
    final repo = repository();
    await repo.refresh();
    expect(await load(repo), isNotNull);
    expect(await load(repo, platform: 'windows'), isNull);
    expect(await load(repo, channel: 'other'), isNull);
    expect(await load(repo, appVersion: '9.0.0'), isNull);
    expect(service.calls, 1);
    expect(downloads, 1);
  });

  test('refresh failure retains the last complete valid generation', () async {
    service.campaign = campaign();
    final repo = repository();
    await repo.refresh();
    final before = (await load(repo))!;
    service.failure = const FormatException('Malformed response.');
    await expectLater(repo.refresh(), throwsFormatException);
    expect((await load(repo))!.media.localPath, before.media.localPath);
  });
}

final class _Service implements StartupAdService {
  StartupAdCampaign? campaign;
  Object? failure;
  int calls = 0;
  @override
  Future<StartupAdCampaign?> fetchCampaign() async {
    calls++;
    if (failure case final error?) throw error;
    return campaign;
  }
}
