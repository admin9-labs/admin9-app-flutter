import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_appearance.dart';

class LocalStorageService {
  const LocalStorageService(this._preferences);

  static const _channelIdsKey = 'home_channel_ids';
  static const _channelDefaultsVersionKey = 'home_channel_defaults_version';
  static const _brandKey = 'appearance_brand';
  static const _themeModeKey = 'appearance_theme_mode';
  static const _fontLevelKey = 'appearance_font_level';
  static const _grayscaleKey = 'appearance_grayscale';
  static const _pushEnabledKey = 'settings_push_enabled';
  static const _recentServiceIdsKey = 'recent_service_ids';
  static const _pointsBalanceKey = 'points_balance';
  static const _pointsLastCheckInDateKey = 'points_last_check_in_date';
  static const _pointsClaimedTaskIdsKey = 'points_claimed_task_ids';
  static const _pointsPendingTaskIdsKey = 'points_pending_task_ids';
  static const _pointsUsedOrderIdsKey = 'points_used_order_ids';
  static const _pointsOrdersKey = 'points_orders';
  static const _pointsTransactionsKey = 'points_transactions';
  static const _privacyGuideAcceptedKey = 'privacy_guide_accepted';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _splashCacheMetadataKey = 'splash_cache_metadata';

  final SharedPreferences _preferences;

  List<String>? loadChannelIds() {
    return _preferences.getStringList(_channelIdsKey);
  }

  Future<void> saveChannelIds(List<String> ids) {
    return _preferences.setStringList(_channelIdsKey, ids);
  }

  int loadChannelDefaultsVersion() {
    return _preferences.getInt(_channelDefaultsVersionKey) ?? 0;
  }

  Future<void> saveChannelDefaultsVersion(int version) {
    return _preferences.setInt(_channelDefaultsVersionKey, version);
  }

  Future<void> clearChannelIds() {
    return _preferences.remove(_channelIdsKey);
  }

  AppAppearanceSettings loadAppearance() {
    return AppAppearanceSettings(
      brandId: AppBrandId.parse(_preferences.getString(_brandKey)),
      themeMode: AppThemeMode.parse(_preferences.getString(_themeModeKey)),
      fontLevel: AppFontLevel.parse(_preferences.getString(_fontLevelKey)),
      grayscale: _preferences.getBool(_grayscaleKey) ?? false,
    );
  }

  Future<void> saveAppearance(AppAppearanceSettings settings) async {
    await _preferences.setString(_brandKey, settings.brandId.name);
    await _preferences.setString(_themeModeKey, settings.themeMode.name);
    await _preferences.setString(_fontLevelKey, settings.fontLevel.name);
    await _preferences.setBool(_grayscaleKey, settings.grayscale);
  }

  bool loadPushEnabled() {
    return _preferences.getBool(_pushEnabledKey) ?? false;
  }

  Future<void> savePushEnabled(bool value) {
    return _preferences.setBool(_pushEnabledKey, value);
  }

  List<String> loadRecentServiceIds() {
    return _preferences.getStringList(_recentServiceIdsKey) ?? const [];
  }

  Future<void> saveRecentServiceIds(List<String> ids) {
    return _preferences.setStringList(_recentServiceIdsKey, ids);
  }

  bool loadPrivacyGuideAccepted() {
    return _preferences.getBool(_privacyGuideAcceptedKey) ?? false;
  }

  Future<void> savePrivacyGuideAccepted(bool value) {
    return _preferences.setBool(_privacyGuideAcceptedKey, value);
  }

  bool loadOnboardingCompleted() {
    return _preferences.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> saveOnboardingCompleted(bool value) {
    return _preferences.setBool(_onboardingCompletedKey, value);
  }

  String? loadSplashCacheMetadata() {
    return _preferences.getString(_splashCacheMetadataKey);
  }

  Future<void> saveSplashCacheMetadata(String value) {
    return _preferences.setString(_splashCacheMetadataKey, value);
  }

  Future<void> clearSplashCacheMetadata() {
    return _preferences.remove(_splashCacheMetadataKey);
  }

  int? loadPointsBalance(String? userKey) {
    return _preferences.getInt(_scopedPointsKey(_pointsBalanceKey, userKey));
  }

  Future<void> savePointsBalance(String? userKey, int value) {
    return _preferences.setInt(
      _scopedPointsKey(_pointsBalanceKey, userKey),
      value,
    );
  }

  String? loadPointsLastCheckInDate(String? userKey) {
    return _preferences.getString(
      _scopedPointsKey(_pointsLastCheckInDateKey, userKey),
    );
  }

  Future<void> savePointsLastCheckInDate(String? userKey, String value) {
    return _preferences.setString(
      _scopedPointsKey(_pointsLastCheckInDateKey, userKey),
      value,
    );
  }

  List<String> loadClaimedPointTaskIds(String? userKey) {
    return _preferences.getStringList(
          _scopedPointsKey(_pointsClaimedTaskIdsKey, userKey),
        ) ??
        const [];
  }

  Future<void> saveClaimedPointTaskIds(String? userKey, List<String> ids) {
    return _preferences.setStringList(
      _scopedPointsKey(_pointsClaimedTaskIdsKey, userKey),
      ids,
    );
  }

  List<String> loadPendingPointTaskIds(String? userKey) {
    return _preferences.getStringList(
          _scopedPointsKey(_pointsPendingTaskIdsKey, userKey),
        ) ??
        const [];
  }

  Future<void> savePendingPointTaskIds(String? userKey, List<String> ids) {
    return _preferences.setStringList(
      _scopedPointsKey(_pointsPendingTaskIdsKey, userKey),
      ids,
    );
  }

  List<String> loadUsedPointOrderIds(String? userKey) {
    return _preferences.getStringList(
          _scopedPointsKey(_pointsUsedOrderIdsKey, userKey),
        ) ??
        const [];
  }

  Future<void> saveUsedPointOrderIds(String? userKey, List<String> ids) {
    return _preferences.setStringList(
      _scopedPointsKey(_pointsUsedOrderIdsKey, userKey),
      ids,
    );
  }

  List<String> loadPointOrderPayloads(String? userKey) {
    return _preferences.getStringList(
          _scopedPointsKey(_pointsOrdersKey, userKey),
        ) ??
        const [];
  }

  Future<void> savePointOrderPayloads(String? userKey, List<String> payloads) {
    return _preferences.setStringList(
      _scopedPointsKey(_pointsOrdersKey, userKey),
      payloads,
    );
  }

  List<String> loadPointTransactionPayloads(String? userKey) {
    return _preferences.getStringList(
          _scopedPointsKey(_pointsTransactionsKey, userKey),
        ) ??
        const [];
  }

  Future<void> savePointTransactionPayloads(
    String? userKey,
    List<String> payloads,
  ) {
    return _preferences.setStringList(
      _scopedPointsKey(_pointsTransactionsKey, userKey),
      payloads,
    );
  }

  String _scopedPointsKey(String baseKey, String? userKey) {
    final normalized = userKey?.trim();
    final scope = normalized == null || normalized.isEmpty
        ? 'guest'
        : normalized.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return '$baseKey:$scope';
  }
}
