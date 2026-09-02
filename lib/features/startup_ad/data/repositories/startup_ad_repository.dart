import '../../../../app/startup/startup_preferences.dart';
import '../models/startup_ad_campaign.dart';

abstract interface class StartupAdRepository {
  Future<StartupAdCampaign?> loadCachedEligible({
    required DateTime now,
    required String platform,
    required String appVersion,
    required String channel,
    required StartupPreferences preferences,
  });

  Future<void> refresh();

  Future<int> cacheSize();

  Future<void> clearCache();
}

final class DisabledStartupAdRepository implements StartupAdRepository {
  const DisabledStartupAdRepository();

  @override
  Future<int> cacheSize() async => 0;

  @override
  Future<void> clearCache() async {}

  @override
  Future<StartupAdCampaign?> loadCachedEligible({
    required DateTime now,
    required String platform,
    required String appVersion,
    required String channel,
    required StartupPreferences preferences,
  }) async => null;

  @override
  Future<void> refresh() async {}
}
