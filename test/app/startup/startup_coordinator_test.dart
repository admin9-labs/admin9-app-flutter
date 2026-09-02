import 'package:admin9_app_flutter/app/startup/startup_preferences.dart';
import 'package:admin9_app_flutter/app/startup/startup_preferences_repository.dart';
import 'package:admin9_app_flutter/app/startup/startup_provider.dart';
import 'package:admin9_app_flutter/app/startup/startup_state.dart';
import 'package:admin9_app_flutter/app/startup/startup_metrics.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/models/startup_ad_campaign.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/repositories/startup_ad_repository.dart';
import 'package:admin9_app_flutter/features/startup_ad/presentation/providers/startup_ad_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'first icon launch requires privacy and suppresses advertising',
    () async {
      final harness = _Harness(
        const StartupPreferences(),
        campaign: _campaign(),
      );

      await harness.coordinator.begin();

      expect(harness.state.phase, StartupPhase.privacy);
      expect(harness.ads.loadCalls, 0);
    },
  );

  test(
    'accepting privacy opens onboarding and completing it goes home',
    () async {
      final harness = _Harness(const StartupPreferences());
      await harness.coordinator.begin();

      await harness.coordinator.acceptPrivacy();
      expect(harness.state.phase, StartupPhase.onboarding);

      await harness.coordinator.completeOnboarding();
      expect(harness.state.phase, StartupPhase.ready);
      expect(harness.state.accessMode, AccessMode.full);
      expect(harness.ads.loadCalls, 0);
    },
  );

  test('declining privacy reaches limited home without persistence', () async {
    final harness = _Harness(const StartupPreferences());
    await harness.coordinator.begin();

    harness.coordinator.continueLimited();

    expect(harness.state.phase, StartupPhase.ready);
    expect(harness.state.accessMode, AccessMode.limited);
    expect(harness.preferences.saved, isEmpty);
  });

  test('ordinary cold launch shows one eligible cached campaign', () async {
    final campaign = _campaign();
    final harness = _Harness(_completedPreferences(), campaign: campaign);

    await harness.coordinator.begin();

    expect(harness.state.phase, StartupPhase.startupAd);
    expect(harness.state.campaign, same(campaign));
    expect(harness.ads.loadCalls, 1);
  });

  test('campaign lookup failure goes directly to Home', () async {
    final harness = _Harness(
      _completedPreferences(),
      adLoadError: StateError('cache unavailable'),
    );

    await harness.coordinator.begin();

    expect(harness.state.phase, StartupPhase.ready);
    expect(harness.state.campaign, isNull);
  });

  test(
    'all external launch reasons bypass onboarding and advertising',
    () async {
      for (final reason in [
        LaunchReason.notification,
        LaunchReason.share,
        LaunchReason.deepLink,
      ]) {
        final harness = _Harness(
          StartupPreferences(
            privacyConsent: PrivacyConsentRecord(
              policyVersion: currentPrivacyPolicyVersion,
              acceptedAt: DateTime.utc(2026, 9, 1),
            ),
          ),
          campaign: _campaign(),
        );
        const destination = PendingDestination(routeKey: 'settings');

        await harness.coordinator.begin(
          launchReason: reason,
          pendingDestination: destination,
        );

        expect(harness.state.phase, StartupPhase.ready);
        expect(harness.state.pendingDestination, destination);
        expect(harness.ads.loadCalls, 0);
      }
    },
  );

  test(
    'a superseded privacy policy requires a new decision and no ad',
    () async {
      final harness = _Harness(
        StartupPreferences(
          privacyConsent: PrivacyConsentRecord(
            policyVersion: currentPrivacyPolicyVersion - 1,
            acceptedAt: DateTime.utc(2026, 8, 1),
          ),
          onboardingVersion: currentOnboardingVersion,
        ),
        campaign: _campaign(),
      );

      await harness.coordinator.begin();

      expect(harness.state.phase, StartupPhase.privacy);
      expect(harness.ads.loadCalls, 0);
    },
  );

  test('unknown external paths are discarded', () {
    expect(PendingDestination.fromPath('/unknown'), isNull);
    expect(PendingDestination.fromPath('javascript:alert(1)'), isNull);
  });

  test('limited mode drops targets that require consent', () async {
    final harness = _Harness(const StartupPreferences());
    await harness.coordinator.begin(
      launchReason: LaunchReason.notification,
      pendingDestination: const PendingDestination(
        routeKey: 'settings',
        requiredAccess: DestinationAccess.consented,
      ),
    );

    harness.coordinator.continueLimited();

    expect(harness.state.pendingDestination, isNull);
    expect(harness.state.accessMode, AccessMode.limited);
  });

  test('returning from background dismisses an active campaign', () async {
    final harness = _Harness(_completedPreferences(), campaign: _campaign());
    await harness.coordinator.begin();
    expect(harness.state.phase, StartupPhase.startupAd);

    harness.coordinator.handleBackgrounded();

    expect(harness.state.phase, StartupPhase.ready);
    expect(harness.state.campaign, isNull);
  });

  test('records frequency only after media reports a visible frame', () async {
    final harness = _Harness(_completedPreferences(), campaign: _campaign());
    await harness.coordinator.begin();
    expect(harness.preferences.value.exposures, isEmpty);

    await harness.coordinator.markCampaignVisible();

    expect(
      harness.preferences.value.exposures['campaign:creative'],
      hasLength(1),
    );
    expect(
      harness.container
          .read(startupExposureContextProvider)
          .matches(campaignId: 'campaign', creativeId: 'creative'),
      isTrue,
    );
  });

  test(
    'failed consent persistence stays limited and reports warning',
    () async {
      final harness = _Harness(
        const StartupPreferences(),
        saveError: StateError('disk unavailable'),
      );
      await harness.coordinator.begin();

      await harness.coordinator.acceptPrivacy();

      expect(harness.state.phase, StartupPhase.ready);
      expect(harness.state.accessMode, AccessMode.limited);
      expect(harness.state.persistenceWarning, isTrue);
    },
  );

  test(
    'does not emit metrics before consent and starts after acceptance',
    () async {
      final metrics = _FakeMetricsSink();
      final harness = _Harness(const StartupPreferences(), metrics: metrics);

      await harness.coordinator.begin();
      expect(metrics.events, isEmpty);

      await harness.coordinator.acceptPrivacy();
      expect(metrics.events.map((event) => event.name), [
        StartupMetricName.privacyAccepted,
      ]);
    },
  );
}

final class _Harness {
  _Harness(
    StartupPreferences preferences, {
    StartupAdCampaign? campaign,
    Object? saveError,
    StartupMetricsSink? metrics,
    Object? adLoadError,
  }) : preferences = _FakePreferencesRepository(
         preferences,
         saveError: saveError,
       ),
       ads = _FakeAdRepository(campaign, loadError: adLoadError) {
    container = ProviderContainer(
      overrides: [
        startupPreferencesRepositoryProvider.overrideWithValue(
          this.preferences,
        ),
        startupAdRepositoryProvider.overrideWithValue(ads),
        if (metrics != null)
          startupMetricsSinkProvider.overrideWithValue(metrics),
      ],
    );
    addTearDown(container.dispose);
  }

  final _FakePreferencesRepository preferences;
  final _FakeAdRepository ads;
  late final ProviderContainer container;

  StartupCoordinator get coordinator =>
      container.read(startupCoordinatorProvider.notifier);

  StartupState get state => container.read(startupCoordinatorProvider);
}

final class _FakeMetricsSink implements StartupMetricsSink {
  final List<StartupMetric> events = [];

  @override
  Future<void> record(StartupMetric metric) async {
    events.add(metric);
  }
}

final class _FakePreferencesRepository implements StartupPreferencesRepository {
  _FakePreferencesRepository(this.value, {this.saveError});

  StartupPreferences value;
  final Object? saveError;
  final List<StartupPreferences> saved = [];

  @override
  Future<StartupPreferences> load() async => value;

  @override
  Future<void> save(StartupPreferences preferences) async {
    saved.add(preferences);
    if (saveError case final error?) throw error;
    value = preferences;
  }
}

final class _FakeAdRepository implements StartupAdRepository {
  _FakeAdRepository(this.campaign, {this.loadError});

  final StartupAdCampaign? campaign;
  final Object? loadError;
  int loadCalls = 0;

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
  }) async {
    loadCalls++;
    if (loadError case final error?) throw error;
    return campaign;
  }

  @override
  Future<void> refresh() async {}
}

StartupPreferences _completedPreferences() => StartupPreferences(
  privacyConsent: PrivacyConsentRecord(
    policyVersion: currentPrivacyPolicyVersion,
    acceptedAt: DateTime.utc(2026, 9, 1),
  ),
  onboardingVersion: currentOnboardingVersion,
);

StartupAdCampaign _campaign() {
  final now = DateTime.utc(2026, 9, 1);
  return StartupAdCampaign(
    schemaVersion: 1,
    placementId: StartupAdCampaign.placement,
    campaignId: 'campaign',
    creativeId: 'creative',
    active: true,
    priority: 1,
    startsAt: now.subtract(const Duration(days: 1)),
    endsAt: now.add(const Duration(days: 1)),
    serverTime: now,
    updatedAt: now,
    freshUntil: now.add(const Duration(days: 1)),
    displayDuration: const Duration(seconds: 3),
    frequencyCap: const StartupAdFrequencyCap(
      maxImpressions: 1,
      window: Duration(days: 1),
    ),
    platforms: const {'ios', 'android'},
    channels: const {'official'},
    media: StartupAdMedia(
      type: StartupAdMediaType.image,
      url: Uri.parse('https://cdn.example.com/creative.jpg'),
      mimeType: 'image/jpeg',
      byteLength: 100,
      width: 1080,
      height: 1920,
      sha256: 'a' * 64,
      semanticLabel: '推广图片',
      localPath: '/cached/creative.jpg',
    ),
    action: const StartupAdAction.none(),
  );
}
