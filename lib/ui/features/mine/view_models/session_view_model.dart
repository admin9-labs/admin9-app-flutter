import 'package:flutter/foundation.dart';

import '../../../../data/repositories/user_repository.dart';
import '../../../../domain/models/user_profile.dart';

class SessionViewModel extends ChangeNotifier {
  SessionViewModel({required this.repository});

  final UserRepository repository;

  UserProfile? _user;
  UserProfile? get user => _user;
  bool get isLoggedIn => _user != null;

  void login({required String phone, String nickname = '新闻用户'}) {
    _user = repository.login(phone: phone, nickname: nickname);
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
