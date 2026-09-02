final class StartupExposureContext {
  String? _campaignId;
  String? _creativeId;

  String? get campaignId => _campaignId;

  String? get creativeId => _creativeId;

  bool matches({required String campaignId, required String creativeId}) =>
      _campaignId == campaignId && _creativeId == creativeId;

  void record({required String campaignId, required String creativeId}) {
    _campaignId = campaignId;
    _creativeId = creativeId;
  }
}
