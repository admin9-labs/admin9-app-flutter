final class PrivacyConsentRecord {
  const PrivacyConsentRecord({
    required this.policyVersion,
    required this.acceptedAt,
  });

  final int policyVersion;
  final DateTime acceptedAt;

  Map<String, Object> toJson() => {
    'policyVersion': policyVersion,
    'acceptedAt': acceptedAt.toUtc().toIso8601String(),
  };

  static PrivacyConsentRecord? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final policyVersion = value['policyVersion'];
    final acceptedAt = DateTime.tryParse(value['acceptedAt'] as String? ?? '');
    if (policyVersion is! int || acceptedAt == null) return null;
    return PrivacyConsentRecord(
      policyVersion: policyVersion,
      acceptedAt: acceptedAt.toUtc(),
    );
  }
}

final class StartupPreferences {
  const StartupPreferences({
    this.privacyConsent,
    this.onboardingVersion,
    this.exposures = const {},
  });

  final PrivacyConsentRecord? privacyConsent;
  final int? onboardingVersion;
  final Map<String, List<DateTime>> exposures;

  StartupPreferences copyWith({
    PrivacyConsentRecord? privacyConsent,
    bool clearPrivacyConsent = false,
    int? onboardingVersion,
    Map<String, List<DateTime>>? exposures,
  }) => StartupPreferences(
    privacyConsent: clearPrivacyConsent
        ? null
        : privacyConsent ?? this.privacyConsent,
    onboardingVersion: onboardingVersion ?? this.onboardingVersion,
    exposures: exposures ?? this.exposures,
  );
}
