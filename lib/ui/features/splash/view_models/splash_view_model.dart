import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/splash_repository.dart';
import '../../../../domain/models/splash_content.dart';

class SplashViewModel extends ChangeNotifier {
  SplashViewModel({required this.repository});

  final SplashRepository repository;

  Timer? _timer;
  SplashContent? _content;
  int _remainingSeconds = 0;
  bool _isLoading = false;
  bool _isVisible = false;

  SplashContent? get content => _content;

  int get remainingSeconds => _remainingSeconds;

  bool get isLoading => _isLoading;

  bool get shouldShowSplash => _isVisible && _content != null;

  Future<bool> showCachedContent({bool blockWhileLoading = false}) async {
    _timer?.cancel();
    _timer = null;
    _content = null;
    _remainingSeconds = 0;
    _isLoading = blockWhileLoading;
    if (blockWhileLoading) {
      notifyListeners();
    }

    final activeContent = await repository.loadCachedContent();
    _content = activeContent;
    _isLoading = false;

    if (activeContent == null) {
      _isVisible = false;
      notifyListeners();
      return false;
    }

    _remainingSeconds = activeContent.duration.inSeconds;
    _isVisible = true;
    notifyListeners();
    _startCountdown();
    return true;
  }

  void skip() {
    _timer?.cancel();
    _timer = null;
    _isVisible = false;
    notifyListeners();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        skip();
        return;
      }

      _remainingSeconds -= 1;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
