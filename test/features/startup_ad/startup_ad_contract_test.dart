import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/features/startup_ad/data/models/startup_ad_campaign.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/services/startup_ad_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final invalidFields = <String, List<Object?>>{
    'schemaVersion': [null, '1', 1.0, 2],
    'placementId': ['other', 1],
    'campaignId': ['', '  ', 1],
    'active': [null, 1, 'true'],
    'priority': [null, '1', 1.0],
    'startsAt': [123, '2026-09-01T00:00:00', '2026-09-32T00:00:00Z'],
    'endsAt': [[], '2026-08-01T00:00:00Z'],
    'serverTime': [false],
    'updatedAt': [{}],
    'freshUntil': [[]],
    'platforms': [
      null,
      'ios',
      [1],
      ['ios', 1],
      ['windows'],
    ],
    'channels': [
      null,
      'official',
      [true],
      [''],
    ],
    'minimumAppVersion': [1, '1.nope.0'],
    'maximumAppVersion': [[], '0.9.0'],
    'fallbackImage': [
      false,
      {},
      {'type': 'image'},
    ],
  };
  for (final field in invalidFields.entries) {
    for (final value in field.value) {
      test('fails closed for ${field.key} = $value (${value.runtimeType})', () {
        final json = _fixture()..[field.key] = value;
        expect(StartupAdCampaign.fromJson(json), isNull);
      });
    }
  }

  final invalidMediaFields = <String, List<Object?>>{
    'url': [
      42,
      [],
      'https://user:pass@cdn.example.com/a',
      'https://cdn.example.com:444/a',
      'https:///a',
    ],
    'mimeType': ['image/png', 'application/octet-stream'],
    'byteLength': [0, -1, 1.0],
    'width': [0, -1, '1080'],
    'height': [0, false],
    'durationMs': [-1, '5000', null],
    'sha256': ['oops', 1],
    'focalX': [null, -0.1, 1.1, double.nan, '0.5'],
    'focalY': [double.infinity, []],
    'semanticLabel': [' ', false],
    'localPath': [false, []],
  };
  for (final field in invalidMediaFields.entries) {
    for (final value in field.value) {
      test(
        'fails closed for media ${field.key} = $value (${value.runtimeType})',
        () {
          final json = _fixture();
          (json['media'] as Map<String, dynamic>)[field.key] = value;
          expect(StartupAdCampaign.fromJson(json), isNull);
        },
      );
    }
  }

  for (final action in [
    {
      'type': 'internalRoute',
      'routeKey': 'home',
      'parameters': {'id': 1},
    },
    {
      'type': 'internalRoute',
      'routeKey': 'home',
      'parameters': {'id': '1'},
    },
    {'type': 'internalRoute', 'routeKey': 'home', 'parameters': []},
    {'type': 'internalRoute', 'routeKey': 'home', 'parameters': null},
    {'type': 'internalRoute', 'routeKey': 'UnknownPage', 'parameters': {}},
    {'type': 'none', 'url': 'https://example.com/'},
    {
      'type': 'none',
      'parameters': {'unexpected': 'value'},
    },
    {'type': 'externalHttps', 'url': 5},
    {'type': 'externalHttps', 'url': 'https://user@www.example.com/'},
    {'type': 'externalHttps', 'url': 'https://www.example.com:8443/'},
  ]) {
    test('rejects malformed action without stripping fields: $action', () {
      expect(StartupAdAction.fromJson(action), isNull);
    });
  }

  test('valid campaigns round-trip without weakening filters or metadata', () {
    final campaign = StartupAdCampaign.fromJson(_fixture())!;
    final restored = StartupAdCampaign.fromJson(campaign.toJson())!;
    expect(restored.toJson(), campaign.toJson());
  });

  for (final url in [
    'http://cdn.example.com/a',
    'https://user:secret@cdn.example.com/a',
    'https://cdn.example.com:8443/a',
    'https://cdn.example.com.evil.test/a',
    'https:///a',
    'https://cdn.example.com/a#fragment',
  ]) {
    test('rejects unsafe HTTPS authority: $url', () {
      expect(startupAdUriAllowed(Uri.parse(url), {'cdn.example.com'}), isFalse);
    });
  }
  test('accepts an explicit standard HTTPS port', () {
    expect(
      startupAdUriAllowed(Uri.parse('https://cdn.example.com:443/a'), {
        'cdn.example.com',
      }),
      isTrue,
    );
  });
}

Map<String, dynamic> _fixture() => jsonDecode(
  File('test/fixtures/startup_ad/campaign.json').readAsStringSync(),
) as Map<String, dynamic>;
