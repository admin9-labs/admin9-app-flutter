import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../app/app_metadata.dart';
import '../../data/repositories/cached_startup_ad_repository.dart';
import '../../data/repositories/startup_ad_repository.dart';
import '../../data/services/startup_ad_cache.dart';
import '../../data/services/startup_ad_service.dart';

const startupAdAppVersion = admin9AppVersion;

final startupAdPlatformProvider = Provider<String>(
  (ref) => Platform.isIOS ? 'ios' : 'android',
);
const startupAdChannel = String.fromEnvironment(
  'APP_CHANNEL',
  defaultValue: 'official',
);

final startupAdExternalHostsProvider = Provider<Set<String>>(
  (ref) => _hostSet(const String.fromEnvironment('STARTUP_AD_EXTERNAL_HOSTS')),
);

final startupAdRepositoryProvider = Provider<StartupAdRepository>((ref) {
  const endpointValue = String.fromEnvironment('STARTUP_AD_ENDPOINT');
  final endpoint = Uri.tryParse(endpointValue);
  final apiHosts = _hostSet(
    const String.fromEnvironment('STARTUP_AD_API_HOSTS'),
  );
  final mediaHosts = _hostSet(
    const String.fromEnvironment('STARTUP_AD_MEDIA_HOSTS'),
  );
  if (endpoint == null ||
      !startupAdUriAllowed(endpoint, apiHosts) ||
      mediaHosts.isEmpty) {
    return const DisabledStartupAdRepository();
  }
  final client = http.Client();
  ref.onDispose(client.close);
  final cache = StartupAdCache(client: client, allowedMediaHosts: mediaHosts);
  final service = HttpStartupAdService(
    client: client,
    endpoint: endpoint,
    allowedApiHosts: apiHosts,
    platform: ref.watch(startupAdPlatformProvider),
    appVersion: startupAdAppVersion,
    channel: startupAdChannel,
  );
  return CachedStartupAdRepository(
    service: service,
    cache: cache,
    platform: ref.watch(startupAdPlatformProvider),
    appVersion: startupAdAppVersion,
    channel: startupAdChannel,
    allowedExternalHosts: ref.watch(startupAdExternalHostsProvider),
  );
});

final startupAdCacheSizeProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(startupAdRepositoryProvider).cacheSize(),
);

Set<String> _hostSet(String value) => value
    .split(',')
    .map((host) => host.trim().toLowerCase())
    .where((host) => host.isNotEmpty)
    .toSet();
