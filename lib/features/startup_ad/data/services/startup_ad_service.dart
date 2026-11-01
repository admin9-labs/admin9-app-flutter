import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/startup_ad_campaign.dart';
import 'startup_ad_http.dart';

abstract interface class StartupAdService {
  Future<StartupAdCampaign?> fetchCampaign();
}

final class HttpStartupAdService implements StartupAdService {
  const HttpStartupAdService({
    required this.client,
    required this.endpoint,
    required this.allowedApiHosts,
    required this.platform,
    required this.appVersion,
    required this.channel,
    this.locale = 'zh-CN',
  });

  final http.Client client;
  final Uri endpoint;
  final Set<String> allowedApiHosts;
  final String platform;
  final String appVersion;
  final String channel;
  final String locale;

  @override
  Future<StartupAdCampaign?> fetchCampaign() async {
    if (!_allowed(endpoint, allowedApiHosts)) {
      throw const FormatException('Untrusted startup-ad API endpoint.');
    }
    final uri = endpoint.replace(
      queryParameters: {
        'placement': StartupAdCampaign.placement,
        'platform': platform,
        'app_version': appVersion,
        'channel': channel,
        'locale': locale,
      },
    );
    final response = await startupAdResponse(
      client: client,
      uri: uri,
      allowedHosts: allowedApiHosts,
      timeout: const Duration(milliseconds: 800),
      accept: 'application/json',
    );
    if (response.statusCode == 204) return null;
    if (response.statusCode != 200) {
      throw StartupAdServiceException(response.statusCode);
    }
    if (response.headers['content-type']?.split(';').first.trim() !=
        'application/json') {
      throw const FormatException('Startup-ad API must return JSON.');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final campaign = StartupAdCampaign.fromJson(decoded);
    if (campaign == null) {
      throw const FormatException('Invalid startup-ad response.');
    }
    return campaign;
  }
}

final class StartupAdServiceException implements Exception {
  const StartupAdServiceException(this.statusCode);

  final int statusCode;
}

bool startupAdUriAllowed(Uri uri, Set<String> hosts) => _allowed(uri, hosts);

bool _allowed(Uri uri, Set<String> hosts) =>
    startupAdHttpsUriValid(uri) && hosts.contains(uri.host);
