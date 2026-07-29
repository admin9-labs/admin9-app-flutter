import 'package:flutter/foundation.dart';

enum AuthSubmissionState { idle, unavailable }

class AuthFormViewModel extends ChangeNotifier {
  AuthSubmissionState _state = AuthSubmissionState.idle;

  AuthSubmissionState get state => _state;

  void submitValidatedForm() {
    if (_state == AuthSubmissionState.unavailable) return;
    _state = AuthSubmissionState.unavailable;
    notifyListeners();
  }

  void resetStatus() {
    if (_state == AuthSubmissionState.idle) return;
    _state = AuthSubmissionState.idle;
    notifyListeners();
  }
}
