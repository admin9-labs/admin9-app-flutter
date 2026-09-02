import '../../features/startup_ad/data/models/startup_ad_campaign.dart';

enum LaunchReason { icon, notification, share, deepLink }

enum AccessMode { full, limited }

enum StartupPhase { initializing, privacy, onboarding, startupAd, ready }

enum DestinationAccess { public, consented, authenticated }

final class PendingDestination {
  const PendingDestination({
    required this.routeKey,
    this.parameters = const {},
    this.requiredAccess = DestinationAccess.public,
  });

  static const home = PendingDestination(routeKey: 'home');

  final String routeKey;
  final Map<String, String> parameters;
  final DestinationAccess requiredAccess;

  static PendingDestination? fromPath(String? path) {
    final uri = path == null ? null : Uri.tryParse(path);
    if (uri == null) return null;

    return switch (uri.path) {
      '/' || '/app' || '/app/home' => home,
      // examples:begin
      '/app/components' => const PendingDestination(routeKey: 'components'),
      // examples:end
      '/app/media' => const PendingDestination(routeKey: 'media'),
      '/app/settings' => const PendingDestination(routeKey: 'settings'),
      _ => null,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingDestination &&
          routeKey == other.routeKey &&
          requiredAccess == other.requiredAccess &&
          _mapsEqual(parameters, other.parameters);

  @override
  int get hashCode => Object.hash(
    routeKey,
    requiredAccess,
    Object.hashAllUnordered(parameters.entries),
  );
}

final class StartupState {
  const StartupState({
    required this.phase,
    required this.launchReason,
    required this.accessMode,
    this.pendingDestination,
    this.campaign,
    this.persistenceWarning = false,
  });

  const StartupState.initializing({
    this.launchReason = LaunchReason.icon,
    this.pendingDestination,
  }) : phase = StartupPhase.initializing,
       accessMode = AccessMode.limited,
       campaign = null,
       persistenceWarning = false;

  final StartupPhase phase;
  final LaunchReason launchReason;
  final AccessMode accessMode;
  final PendingDestination? pendingDestination;
  final StartupAdCampaign? campaign;
  final bool persistenceWarning;

  bool get bypassesAd => launchReason != LaunchReason.icon;

  StartupState copyWith({
    StartupPhase? phase,
    AccessMode? accessMode,
    PendingDestination? pendingDestination,
    bool clearPendingDestination = false,
    StartupAdCampaign? campaign,
    bool clearCampaign = false,
    bool? persistenceWarning,
  }) => StartupState(
    phase: phase ?? this.phase,
    launchReason: launchReason,
    accessMode: accessMode ?? this.accessMode,
    pendingDestination: clearPendingDestination
        ? null
        : pendingDestination ?? this.pendingDestination,
    campaign: clearCampaign ? null : campaign ?? this.campaign,
    persistenceWarning: persistenceWarning ?? this.persistenceWarning,
  );
}

bool _mapsEqual(Map<String, String> left, Map<String, String> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}
