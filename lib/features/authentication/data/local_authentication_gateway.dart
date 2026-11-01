import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/session/session.dart';
import '../../../app/session/session_store.dart';
import '../domain/authentication_gateway.dart';

/// Development/test-only local authentication, not for production use.
/// Unsalted password hashes are not suitable for production authentication.
final class LocalAuthenticationGateway implements AuthenticationGateway {
  LocalAuthenticationGateway({
    required this.preferences,
    required this.sessionStore,
    this.secureStorage = const FlutterSecureStorage(),
  });

  static const accountsKey = 'admin9.starter.accounts';

  final SharedPreferencesAsync preferences;
  final SessionStore sessionStore;
  final FlutterSecureStorage secureStorage;

  @override
  Future<SessionSnapshot> register({
    required String identifier,
    required String password,
  }) async {
    final accounts = await _accounts();
    if (accounts.any((account) => account['identifier'] == identifier)) {
      throw const AuthenticationFailure('account_exists');
    }
    final accountId = 'local-${DateTime.now().microsecondsSinceEpoch}';
    accounts.add({
      'accountId': accountId,
      'identifier': identifier,
      'passwordDigest': _digest(password),
    });
    await secureStorage.write(key: accountsKey, value: jsonEncode(accounts));
    final session = SessionSnapshot(
      accountId: accountId,
      identifier: identifier,
    );
    try {
      await sessionStore.write(session);
    } on Object {
      // Remove only this registration; do not restore a stale account-list snapshot.
      final currentAccounts = await _accounts();
      currentAccounts.removeWhere(
        (account) => account['accountId'] == accountId,
      );
      await secureStorage.write(
        key: accountsKey,
        value: jsonEncode(currentAccounts),
      );
      rethrow;
    }
    return session;
  }

  @override
  Future<SessionSnapshot> login({
    required String identifier,
    required String password,
  }) async {
    final accounts = await _accounts();
    Map<String, Object?>? account;
    for (final candidate in accounts) {
      if (candidate['identifier'] == identifier &&
          candidate['passwordDigest'] == _digest(password)) {
        account = candidate;
        break;
      }
    }
    if (account == null) {
      throw const AuthenticationFailure('invalid_credentials');
    }
    final session = SessionSnapshot(
      accountId: account['accountId']! as String,
      identifier: identifier,
    );
    await sessionStore.write(session);
    return session;
  }

  @override
  Future<SessionSnapshot?> restore() async {
    await _accounts();
    return sessionStore.read();
  }

  @override
  Future<void> logout() => sessionStore.clear();

  Future<List<Map<String, Object?>>> _accounts() async {
    var value = await secureStorage.read(key: accountsKey);
    final legacy = await preferences.getString(accountsKey);
    if (legacy != null) {
      if (value == null) {
        await secureStorage.write(key: accountsKey, value: legacy);
        value = legacy;
      } else if (value != legacy) {
        throw StateError('Conflicting local account stores');
      }
      await preferences.remove(accountsKey);
    }
    if (value == null) return [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List<dynamic>) return [];
      return [
        for (final item in decoded)
          if (item is Map<String, dynamic>) item,
      ];
    } on FormatException {
      return [];
    }
  }

  String _digest(String value) => sha256.convert(utf8.encode(value)).toString();
}
