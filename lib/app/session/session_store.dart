import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'session.dart';

abstract interface class SessionStore {
  Future<SessionSnapshot?> read();

  Future<void> write(SessionSnapshot session);

  Future<void> clear();
}

final class SharedPreferencesSessionStore implements SessionStore {
  const SharedPreferencesSessionStore(this.preferences);

  static const key = 'admin9.starter.session';

  final SharedPreferencesAsync preferences;

  @override
  Future<SessionSnapshot?> read() async {
    final value = await preferences.getString(key);
    if (value == null) return null;
    try {
      return SessionSnapshot.fromJson(jsonDecode(value));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(SessionSnapshot session) =>
      preferences.setString(key, jsonEncode(session.toJson()));

  @override
  Future<void> clear() => preferences.remove(key);
}
