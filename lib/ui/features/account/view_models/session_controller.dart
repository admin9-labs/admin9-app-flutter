import 'package:flutter/foundation.dart';

enum SessionStatus { guest, authenticated }

class SessionController extends ChangeNotifier {
  SessionController({SessionStatus initialStatus = SessionStatus.guest})
    : _status = initialStatus;

  SessionStatus _status;

  SessionStatus get status => _status;
  bool get isAuthenticated => _status == SessionStatus.authenticated;

  void signOut() {
    if (_status == SessionStatus.guest) return;
    _status = SessionStatus.guest;
    notifyListeners();
  }
}
