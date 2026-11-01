import '../../../../app/startup/startup_preferences.dart';
import '../models/startup_ad_campaign.dart';
import '../services/startup_ad_cache.dart';
import '../services/startup_ad_service.dart';
import 'startup_ad_repository.dart';

final class CachedStartupAdRepository implements StartupAdRepository {
  const CachedStartupAdRepository({
    required this.service,
    required this.cache,
    required this.platform,
    required this.appVersion,
    required this.channel,
    this.allowedExternalHosts = const {},
  });

  final StartupAdService service;
  final StartupAdCache cache;
  final String platform;
  final String appVersion;
  final String channel;
  final Set<String> allowedExternalHosts;

  @override
  Future<StartupAdCampaign?> loadCachedEligible({
    required DateTime now,
    required String platform,
    required String appVersion,
    required String channel,
    required StartupPreferences preferences,
  }) async {
    final campaign = await cache.readValidated();
    if (campaign == null) return null;
    if (!_allowedAction(campaign)) {
      await cache.clear();
      return null;
    }
    final eligible = campaign.isEligible(
      now: now,
      platform: platform,
      appVersion: appVersion,
      channel: channel,
      exposures: preferences.exposures[campaign.exposureKey] ?? const [],
    );
    return eligible ? campaign : null;
  }

  @override
  Future<void> refresh() async {
    final campaign = await service.fetchCampaign();
    if (campaign == null || !campaign.active) {
      await cache.clear();
      return;
    }
    if (!_allowedAction(campaign)) {
      await cache.clear();
      throw const FormatException('Untrusted startup-ad action.');
    }
    await cache.store(campaign);
  }

  bool _allowedAction(StartupAdCampaign campaign) {
    final action = StartupAdAction.fromJson(campaign.action.toJson());
    if (action == null) return false;
    return action.type != StartupAdActionType.externalHttps ||
        startupAdUriAllowed(action.url!, allowedExternalHosts);
  }

  @override
  Future<int> cacheSize() => cache.size();

  @override
  Future<void> clearCache() => cache.clear();
}
