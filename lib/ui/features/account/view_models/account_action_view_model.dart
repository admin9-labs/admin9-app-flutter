import 'package:flutter/foundation.dart';

class AccountActionViewModel extends ChangeNotifier {
  bool _unavailable = false;

  bool get unavailable => _unavailable;

  void submitValidatedAction() {
    if (_unavailable) return;
    _unavailable = true;
    notifyListeners();
  }

  void resetStatus() {
    if (!_unavailable) return;
    _unavailable = false;
    notifyListeners();
  }
}
