import 'package:flutter/foundation.dart';

import '../../../../data/repositories/splash_repository.dart';
import '../../../../data/services/local_storage_service.dart';

class LaunchViewModel extends ChangeNotifier {
  LaunchViewModel({required LocalStorageService storage})
    : _storage = storage,
      _privacyAccepted = storage.loadPrivacyGuideAccepted(),
      _onboardingCompleted = storage.loadOnboardingCompleted(),
      _canShowSplashThisLaunch =
          storage.loadPrivacyGuideAccepted() &&
          storage.loadOnboardingCompleted();

  final LocalStorageService _storage;
  bool _privacyAccepted;
  bool _onboardingCompleted;
  bool _privacyDeclinedThisLaunch = false;
  final bool _canShowSplashThisLaunch;

  bool get privacyAccepted => _privacyAccepted;

  bool get onboardingCompleted => _onboardingCompleted;

  bool get privacyDeclinedThisLaunch => _privacyDeclinedThisLaunch;

  bool get canShowSplashThisLaunch => _canShowSplashThisLaunch;

  Future<void> acceptPrivacy() async {
    _privacyAccepted = true;
    _privacyDeclinedThisLaunch = false;
    notifyListeners();
    await _storage.savePrivacyGuideAccepted(true);
  }

  void declinePrivacy() {
    if (_privacyDeclinedThisLaunch) return;
    _privacyDeclinedThisLaunch = true;
    notifyListeners();
  }

  void reviewPrivacyGuide() {
    if (!_privacyDeclinedThisLaunch) return;
    _privacyDeclinedThisLaunch = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    notifyListeners();
    await _storage.saveOnboardingCompleted(true);
  }

  Future<void> preloadSplash(SplashRepository repository) {
    if (!_privacyAccepted || !_onboardingCompleted) {
      return Future.value();
    }
    return repository.preloadNextContent();
  }
}
