import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/startup_ad_campaign.dart';

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
  Future<StartupAdCampaign?> fetchCampaign() =>
      _fetchCampaign().timeout(const Duration(milliseconds: 800));

  Future<StartupAdCampaign?> _fetchCampaign() async {
    if (!_allowed(endpoint, allowedApiHosts)) {
      throw const FormatException('Untrusted startup-ad API endpoint.');
    }
    final uri = endpoint.replace(
      queryParameters: {
        ...endpoint.queryParameters,
        'placement': StartupAdCampaign.placement,
        'platform': platform,
        'app_version': appVersion,
        'channel': channel,
        'locale': locale,
      },
    );
    var current = uri;
    http.StreamedResponse? streamed;
    for (var redirect = 0; redirect <= 3; redirect++) {
      final request = http.Request('GET', current)
        ..followRedirects = false
        ..headers['accept'] = 'application/json';
      streamed = await client.send(request);
      if (!_redirectStatus(streamed.statusCode)) break;
      final location = streamed.headers['location'];
      await streamed.stream.drain<void>();
      if (location == null) {
        throw const FormatException('Startup-ad API redirect has no location.');
      }
      current = current.resolve(location);
      if (!_allowed(current, allowedApiHosts)) {
        throw const FormatException(
          'Startup-ad API redirect left the allowlist.',
        );
      }
      streamed = null;
    }
    if (streamed == null) throw const StartupAdServiceException(310);
    final response = await http.Response.fromStream(streamed);
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
    uri.scheme == 'https' && uri.hasAuthority && hosts.contains(uri.host);

bool _redirectStatus(int status) =>
    status == 301 ||
    status == 302 ||
    status == 303 ||
    status == 307 ||
    status == 308;
