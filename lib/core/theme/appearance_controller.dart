import 'package:flutter/foundation.dart';

import '../../data/services/local_storage_service.dart';
import 'app_appearance.dart';

class AppearanceController extends ChangeNotifier {
  AppearanceController({required LocalStorageService storage})
    : _storage = storage,
      _settings = storage.loadAppearance();

  final LocalStorageService _storage;
  AppAppearanceSettings _settings;

  AppAppearanceSettings get settings => _settings;
  AppBrand get brand => AppBrand.byId(_settings.brandId);

  Future<void> setBrand(AppBrandId brandId) {
    return _update(_settings.copyWith(brandId: brandId));
  }

  Future<void> setThemeMode(AppThemeMode themeMode) {
    return _update(_settings.copyWith(themeMode: themeMode));
  }

  Future<void> setFontLevel(AppFontLevel fontLevel) {
    return _update(_settings.copyWith(fontLevel: fontLevel));
  }

  Future<void> setGrayscale(bool grayscale) {
    return _update(_settings.copyWith(grayscale: grayscale));
  }

  Future<void> _update(AppAppearanceSettings next) async {
    if (_isSame(next, _settings)) return;
    _settings = next;
    notifyListeners();
    await _storage.saveAppearance(next);
  }

  bool _isSame(AppAppearanceSettings a, AppAppearanceSettings b) {
    return a.brandId == b.brandId &&
        a.themeMode == b.themeMode &&
        a.fontLevel == b.fontLevel &&
        a.grayscale == b.grayscale;
  }
}
