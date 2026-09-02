import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../app/app_metadata.dart';
import '../../data/repositories/cached_startup_ad_repository.dart';
import '../../data/repositories/startup_ad_repository.dart';
import '../../data/services/startup_ad_cache.dart';
import '../../data/services/startup_ad_service.dart';

const startupAdAppVersion = admin9AppVersion;
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
  if (endpoint == null || apiHosts.isEmpty || mediaHosts.isEmpty) {
    return const DisabledStartupAdRepository();
  }
  final client = http.Client();
  ref.onDispose(client.close);
  final cache = StartupAdCache(client: client, allowedMediaHosts: mediaHosts);
  final service = HttpStartupAdService(
    client: client,
    endpoint: endpoint,
    allowedApiHosts: apiHosts,
    platform: Platform.isIOS ? 'ios' : 'android',
    appVersion: startupAdAppVersion,
    channel: startupAdChannel,
  );
  return CachedStartupAdRepository(
    service: service,
    cache: cache,
    platform: Platform.isIOS ? 'ios' : 'android',
    appVersion: startupAdAppVersion,
    channel: startupAdChannel,
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
