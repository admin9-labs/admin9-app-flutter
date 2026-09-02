enum StartupMetricName {
  initialized,
  privacyAccepted,
  onboardingCompleted,
  onboardingSkipped,
  campaignVisible,
  campaignFinished,
  homeInteractive,
}

final class StartupMetric {
  const StartupMetric({
    required this.name,
    required this.recordedAt,
    this.fields = const {},
  });

  final StartupMetricName name;
  final DateTime recordedAt;
  final Map<String, Object> fields;
}

abstract interface class StartupMetricsSink {
  Future<void> record(StartupMetric metric);
}

final class NoopStartupMetricsSink implements StartupMetricsSink {
  const NoopStartupMetricsSink();

  @override
  Future<void> record(StartupMetric metric) async {}
}
