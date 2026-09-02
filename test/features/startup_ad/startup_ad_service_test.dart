import 'dart:io';

import 'package:admin9_app_flutter/features/startup_ad/data/models/startup_ad_campaign.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/services/startup_ad_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('requests only the approved coarse startup placement fields', () async {
    late Uri requested;
    final fixture = File('test/fixtures/startup_ad/campaign.json')
        .readAsStringSync();
    final service = HttpStartupAdService(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(
          fixture,
          200,
          headers: const {'content-type': 'application/json'},
        );
      }),
      endpoint: Uri.parse('https://api.example.com/v1/placements/startup'),
      allowedApiHosts: const {'api.example.com'},
      platform: 'ios',
      appVersion: '1.1.0',
      channel: 'official',
    );

    final campaign = await service.fetchCampaign();

    expect(campaign?.placementId, StartupAdCampaign.placement);
    expect(requested.queryParameters, {
      'placement': 'app_startup',
      'platform': 'ios',
      'app_version': '1.1.0',
      'channel': 'official',
      'locale': 'zh-CN',
    });
    expect(
      requested.queryParameters.keys,
      isNot(containsAll(['device_id', 'install_id', 'ad_id', 'location'])),
    );
  });

  test('does not contact an API endpoint outside the allowlist', () async {
    var contacted = false;
    final service = HttpStartupAdService(
      client: MockClient((_) async {
        contacted = true;
        return http.Response('', 204);
      }),
      endpoint: Uri.parse('https://untrusted.example/startup'),
      allowedApiHosts: const {'api.example.com'},
      platform: 'android',
      appVersion: '1.1.0',
      channel: 'official',
    );

    await expectLater(service.fetchCampaign(), throwsFormatException);
    expect(contacted, isFalse);
  });
}
