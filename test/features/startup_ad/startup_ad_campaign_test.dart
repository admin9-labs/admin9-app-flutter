import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/features/startup_ad/data/models/startup_ad_campaign.dart';
import 'package:admin9_app_flutter/features/startup_ad/presentation/providers/startup_ad_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runtime app version matches pubspec release version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*([^+\s]+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);

    expect(startupAdAppVersion, version);
  });

  test('parses the checked-in backend consumer fixture', () {
    final fixture = jsonDecode(
      File('test/fixtures/startup_ad/campaign.json').readAsStringSync(),
    );

    final campaign = StartupAdCampaign.fromJson(fixture);

    expect(campaign?.placementId, StartupAdCampaign.placement);
    expect(campaign?.media.type, StartupAdMediaType.video);
    expect(campaign?.fallbackImage?.type, StartupAdMediaType.image);
    expect(campaign?.action.routeKey, 'components');
  });

  test('rejects moving media without a static fallback', () {
    final campaign = StartupAdCampaign.fromJson(
      _campaignJson(mediaType: 'video', includeFallback: false),
    );

    expect(campaign, isNull);
  });

  test('rejects a display duration outside the operational range', () {
    final campaign = StartupAdCampaign.fromJson(
      _campaignJson(displayDurationMs: 9000),
    );

    expect(campaign, isNull);
  });

  test('enforces time, version, channel, and frequency eligibility', () {
    final campaign = StartupAdCampaign.fromJson(_campaignJson())!;
    final now = DateTime.utc(2026, 9, 1, 8);

    expect(
      campaign.isEligible(
        now: now,
        platform: 'ios',
        appVersion: '1.1.0',
        channel: 'official',
        exposures: const [],
      ),
      isTrue,
    );
    expect(
      campaign.isEligible(
        now: now,
        platform: 'ios',
        appVersion: '1.1.0',
        channel: 'official',
        exposures: [now.subtract(const Duration(hours: 1))],
      ),
      isFalse,
    );
    expect(
      campaign.isEligible(
        now: now,
        platform: 'ios',
        appVersion: '1.1.0',
        channel: 'store',
        exposures: const [],
      ),
      isFalse,
    );
  });
}

Map<String, Object?> _campaignJson({
  String mediaType = 'image',
  int displayDurationMs = 3000,
  bool includeFallback = true,
}) => {
  'schemaVersion': 1,
  'placementId': 'app_startup',
  'campaignId': 'campaign',
  'creativeId': 'creative',
  'active': true,
  'priority': 1,
  'startsAt': '2026-09-01T00:00:00Z',
  'endsAt': '2026-09-02T00:00:00Z',
  'serverTime': '2026-09-01T08:00:00Z',
  'updatedAt': '2026-09-01T07:00:00Z',
  'freshUntil': '2026-09-01T12:00:00Z',
  'displayDurationMs': displayDurationMs,
  'frequencyCap': {
    'maxImpressions': 1,
    'windowSeconds': 86400,
    'minimumIntervalSeconds': 3600,
  },
  'platforms': ['ios', 'android'],
  'channels': ['official'],
  'minimumAppVersion': '1.0.0',
  'maximumAppVersion': '2.0.0',
  'media': {
    'type': mediaType,
    'url': 'https://cdn.example.com/creative.mp4',
    'mimeType': mediaType == 'video' ? 'video/mp4' : 'image/jpeg',
    'byteLength': 100,
    'width': 1080,
    'height': 1920,
    'sha256': 'a' * 64,
    'semanticLabel': '推广内容',
    'durationMs': mediaType == 'video' ? 5000 : null,
    'localPath': '/cache/creative',
  },
  'fallbackImage': includeFallback
      ? {
          'type': 'image',
          'url': 'https://cdn.example.com/fallback.jpg',
          'mimeType': 'image/jpeg',
          'byteLength': 100,
          'width': 1080,
          'height': 1920,
          'sha256': 'b' * 64,
          'semanticLabel': '推广备用图片',
          'localPath': '/cache/fallback.jpg',
        }
      : null,
  'action': {'type': 'none'},
};
