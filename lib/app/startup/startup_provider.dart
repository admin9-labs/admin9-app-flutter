import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/startup_ad/data/models/startup_ad_campaign.dart';
import '../../features/startup_ad/presentation/providers/startup_ad_provider.dart';
import 'startup_exposure_context.dart';
import 'startup_metrics.dart';
import 'startup_preferences.dart';
import 'startup_preferences_repository.dart';
import 'startup_preferences_service.dart';
import 'startup_state.dart';

const currentPrivacyPolicyVersion = 1;
const currentOnboardingVersion = 1;

final startupPreferencesServiceProvider = Provider<StartupPreferencesService>(
  (ref) => StartupPreferencesService(SharedPreferencesAsync()),
);

final startupPreferencesRepositoryProvider =
    Provider<StartupPreferencesRepository>(
      (ref) => SharedPreferencesStartupRepository(
        ref.watch(startupPreferencesServiceProvider),
      ),
    );

final startupExposureContextProvider = Provider<StartupExposureContext>(
  (ref) => StartupExposureContext(),
);

final startupMetricsSinkProvider = Provider<StartupMetricsSink>(
  (ref) => const NoopStartupMetricsSink(),
);

final startupCoordinatorProvider =
    NotifierProvider<StartupCoordinator, StartupState>(StartupCoordinator.new);

final class StartupCoordinator extends Notifier<StartupState> {
  StartupPreferences _preferences = const StartupPreferences();
  int _generation = 0;
  bool _homeInteractiveRecorded = false;

  @override
  StartupState build() => const StartupState.initializing();

  Future<void> begin({
    LaunchReason launchReason = LaunchReason.icon,
    PendingDestination? pendingDestination,
  }) async {
    final startedAt = DateTime.now();
    final generation = ++_generation;
    _homeInteractiveRecorded = false;
    state = StartupState.initializing(
      launchReason: launchReason,
      pendingDestination: pendingDestination,
    );

    var preferencesFailed = false;
    try {
      _preferences = await ref
          .read(startupPreferencesRepositoryProvider)
          .load();
    } on Object {
      _preferences = const StartupPreferences();
      preferencesFailed = true;
    }
    if (generation != _generation) return;

    final consented =
        _preferences.privacyConsent?.policyVersion ==
        currentPrivacyPolicyVersion;
    if (!consented) {
      state = StartupState(
        phase: StartupPhase.privacy,
        launchReason: launchReason,
        accessMode: AccessMode.limited,
        pendingDestination: pendingDestination,
        persistenceWarning: preferencesFailed,
      );
      return;
    }

    _recordMetric(
      StartupMetricName.initialized,
      fields: {
        'launchReason': launchReason.name,
        'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
      },
    );

    if (launchReason != LaunchReason.icon) {
      state = StartupState(
        phase: StartupPhase.ready,
        launchReason: launchReason,
        accessMode: AccessMode.full,
        pendingDestination: pendingDestination,
      );
      return;
    }

    if (_preferences.onboardingVersion != currentOnboardingVersion) {
      state = StartupState(
        phase: StartupPhase.onboarding,
        launchReason: launchReason,
        accessMode: AccessMode.full,
      );
      return;
    }

    StartupAdCampaign? campaign;
    try {
      campaign = await ref
          .read(startupAdRepositoryProvider)
          .loadCachedEligible(
            now: DateTime.now().toUtc(),
            platform: Platform.isIOS ? 'ios' : 'android',
            appVersion: startupAdAppVersion,
            channel: startupAdChannel,
            preferences: _preferences,
          );
    } on Object {
      campaign = null;
    }
    if (generation != _generation) return;
    state = StartupState(
      phase: campaign == null ? StartupPhase.ready : StartupPhase.startupAd,
      launchReason: launchReason,
      accessMode: AccessMode.full,
      campaign: campaign,
    );
  }

  Future<void> acceptPrivacy() async {
    final record = PrivacyConsentRecord(
      policyVersion: currentPrivacyPolicyVersion,
      acceptedAt: DateTime.now().toUtc(),
    );
    final next = _preferences.copyWith(privacyConsent: record);
    try {
      await ref.read(startupPreferencesRepositoryProvider).save(next);
      _preferences = next;
    } on Object {
      state = state.copyWith(
        phase: StartupPhase.ready,
        accessMode: AccessMode.limited,
        clearCampaign: true,
        clearPendingDestination:
            state.pendingDestination?.requiredAccess !=
            DestinationAccess.public,
        persistenceWarning: true,
      );
      return;
    }

    _recordMetric(StartupMetricName.privacyAccepted);

    if (state.launchReason != LaunchReason.icon) {
      state = state.copyWith(
        phase: StartupPhase.ready,
        accessMode: AccessMode.full,
        clearCampaign: true,
      );
      return;
    }
    state = state.copyWith(
      phase: _preferences.onboardingVersion == currentOnboardingVersion
          ? StartupPhase.ready
          : StartupPhase.onboarding,
      accessMode: AccessMode.full,
      clearCampaign: true,
    );
  }

  void continueLimited() {
    state = state.copyWith(
      phase: StartupPhase.ready,
      accessMode: AccessMode.limited,
      clearCampaign: true,
      clearPendingDestination:
          state.pendingDestination?.requiredAccess != DestinationAccess.public,
    );
  }

  Future<void> completeOnboarding({bool skipped = false}) async {
    final next = _preferences.copyWith(
      onboardingVersion: currentOnboardingVersion,
    );
    var persistenceWarning = false;
    try {
      await ref.read(startupPreferencesRepositoryProvider).save(next);
      _preferences = next;
    } on Object {
      persistenceWarning = true;
    }
    state = state.copyWith(
      phase: StartupPhase.ready,
      accessMode: AccessMode.full,
      clearCampaign: true,
      persistenceWarning: persistenceWarning,
    );
    _recordMetric(
      skipped
          ? StartupMetricName.onboardingSkipped
          : StartupMetricName.onboardingCompleted,
    );
  }

  Future<void> markCampaignVisible() async {
    final campaign = state.campaign;
    if (campaign == null) return;
    ref
        .read(startupExposureContextProvider)
        .record(
          campaignId: campaign.campaignId,
          creativeId: campaign.creativeId,
        );
    final exposures = <String, List<DateTime>>{
      ..._preferences.exposures,
      campaign.exposureKey: [
        ...?_preferences.exposures[campaign.exposureKey]?.where(
          (value) => value.isAfter(
            DateTime.now().toUtc().subtract(campaign.frequencyCap.window),
          ),
        ),
        DateTime.now().toUtc(),
      ],
    };
    final next = _preferences.copyWith(exposures: exposures);
    try {
      await ref.read(startupPreferencesRepositoryProvider).save(next);
      _preferences = next;
    } on Object {
      // Exposure persistence must not keep the user on an advertisement.
    }
    _recordMetric(
      StartupMetricName.campaignVisible,
      fields: {
        'campaignId': campaign.campaignId,
        'creativeId': campaign.creativeId,
      },
    );
  }

  void finishCampaign({
    PendingDestination? destination,
    String reason = 'skip',
  }) {
    final campaign = state.campaign;
    state = state.copyWith(
      phase: StartupPhase.ready,
      pendingDestination: destination,
      clearCampaign: true,
    );
    if (campaign != null) {
      _recordMetric(
        StartupMetricName.campaignFinished,
        fields: {
          'campaignId': campaign.campaignId,
          'creativeId': campaign.creativeId,
          'reason': reason,
        },
      );
    }
  }

  void handleBackgrounded() {
    if (state.phase == StartupPhase.startupAd) {
      finishCampaign(reason: 'backgrounded');
    }
  }

  void requestPrivacyReview() {
    state = state.copyWith(phase: StartupPhase.privacy, clearCampaign: true);
  }

  Future<bool> withdrawPrivacy() async {
    final next = _preferences.copyWith(clearPrivacyConsent: true);
    try {
      await ref.read(startupPreferencesRepositoryProvider).save(next);
      _preferences = next;
      state = state.copyWith(
        phase: StartupPhase.ready,
        accessMode: AccessMode.limited,
        clearCampaign: true,
      );
      return true;
    } on Object {
      return false;
    }
  }

  Future<void> refreshCampaign() async {
    if (state.accessMode != AccessMode.full ||
        state.phase != StartupPhase.ready) {
      return;
    }
    try {
      await ref.read(startupAdRepositoryProvider).refresh();
    } on Object {
      // Prefetch failure never interrupts the current route or enables an ad.
    }
  }

  void markHomeInteractive() {
    if (_homeInteractiveRecorded) return;
    _homeInteractiveRecorded = true;
    _recordMetric(StartupMetricName.homeInteractive);
  }

  void _recordMetric(
    StartupMetricName name, {
    Map<String, Object> fields = const {},
  }) {
    if (_preferences.privacyConsent?.policyVersion !=
        currentPrivacyPolicyVersion) {
      return;
    }
    unawaited(
      _sendMetric(
        StartupMetric(
          name: name,
          recordedAt: DateTime.now().toUtc(),
          fields: fields,
        ),
      ),
    );
  }

  Future<void> _sendMetric(StartupMetric metric) async {
    try {
      await ref.read(startupMetricsSinkProvider).record(metric);
    } on Object {
      // Telemetry can never interrupt startup or navigation.
    }
  }
}
