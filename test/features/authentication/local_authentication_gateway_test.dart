import 'dart:convert';

import 'package:admin9_app_flutter/app/session/session.dart';
import 'package:admin9_app_flutter/app/session/session_store.dart';
import 'package:admin9_app_flutter/features/authentication/data/local_authentication_gateway.dart';
import 'package:admin9_app_flutter/features/authentication/domain/authentication_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late SharedPreferencesAsyncPlatform? previous;
  late LocalAuthenticationGateway gateway;

  setUp(() {
    previous = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final preferences = SharedPreferencesAsync();
    gateway = LocalAuthenticationGateway(
      preferences: preferences,
      sessionStore: SharedPreferencesSessionStore(preferences),
    );
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = previous;
  });

  test('registers, restores, and logs out a local account', () async {
    final session = await gateway.register(
      identifier: 'user@example.com',
      password: 'local-pass-123',
    );
    expect((await gateway.restore())?.accountId, session.accountId);

    await gateway.logout();
    expect(await gateway.restore(), isNull);
  });

  test('rejects duplicate and invalid credentials', () async {
    await gateway.register(identifier: 'user', password: 'local-pass-123');
    await expectLater(
      gateway.register(identifier: 'user', password: 'local-pass-123'),
      throwsA(isA<AuthenticationFailure>()),
    );
    await expectLater(
      gateway.login(identifier: 'user', password: 'wrong-pass-123'),
      throwsA(isA<AuthenticationFailure>()),
    );
  });

  for (final hasExistingAccount in [false, true]) {
    test(
      'failed session write allows registration retry${hasExistingAccount ? ' and preserves existing accounts' : ''}',
      () async {
        final preferences = SharedPreferencesAsync();
        SessionSnapshot? existingSession;
        if (hasExistingAccount) {
          existingSession = await gateway.register(
            identifier: 'existing@example.com',
            password: 'existing-password',
          );
        }
        final originalAccounts = jsonDecode(
          await preferences.getString(LocalAuthenticationGateway.accountsKey) ??
              '[]',
        );
        final store = _FailingSessionStore(
          SharedPreferencesSessionStore(preferences),
        );
        final failingGateway = LocalAuthenticationGateway(
          preferences: preferences,
          sessionStore: store,
        );

        await expectLater(
          failingGateway.register(
            identifier: 'new@example.com',
            password: 'new-password',
          ),
          throwsA(same(store.error)),
        );
        expect(
          jsonDecode(
            await preferences.getString(
                  LocalAuthenticationGateway.accountsKey,
                ) ??
                '[]',
          ),
          originalAccounts,
        );
        expect(
          (await gateway.restore())?.accountId,
          existingSession?.accountId,
        );
        await expectLater(
          gateway.login(
            identifier: 'new@example.com',
            password: 'new-password',
          ),
          throwsA(
            isA<AuthenticationFailure>().having(
              (error) => error.code,
              'code',
              'invalid_credentials',
            ),
          ),
        );

        store.failWrites = false;
        final retried = await failingGateway.register(
          identifier: 'new@example.com',
          password: 'new-password',
        );
        expect((await gateway.restore())?.accountId, retried.accountId);
        if (existingSession != null) {
          final existing = await gateway.login(
            identifier: 'existing@example.com',
            password: 'existing-password',
          );
          expect(existing.accountId, existingSession.accountId);
        }
      },
    );
  }
}

final class _FailingSessionStore implements SessionStore {
  _FailingSessionStore(this.delegate);

  final SessionStore delegate;
  final error = StateError('session write failed');
  bool failWrites = true;

  @override
  Future<SessionSnapshot?> read() => delegate.read();

  @override
  Future<void> write(SessionSnapshot session) async {
    if (failWrites) throw error;
    await delegate.write(session);
  }

  @override
  Future<void> clear() => delegate.clear();
}
