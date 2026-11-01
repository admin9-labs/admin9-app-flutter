import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/session/session_store.dart';
import '../../data/local_authentication_gateway.dart';
import '../../domain/authentication_gateway.dart';
import '../../domain/authentication_state.dart';

final authenticationGatewayProvider = Provider<AuthenticationGateway>((ref) {
  final preferences = SharedPreferencesAsync();
  return LocalAuthenticationGateway(
    preferences: preferences,
    sessionStore: SharedPreferencesSessionStore(preferences),
  );
});

final authenticationProvider =
    NotifierProvider<AuthenticationController, AuthenticationState>(
      AuthenticationController.new,
    );

final class AuthenticationController extends Notifier<AuthenticationState> {
  @override
  AuthenticationState build() => const AuthenticationState.signedOut();

  Future<void> restore() async {
    state = const AuthenticationState(status: AuthenticationStatus.restoring);
    try {
      final session = await ref.read(authenticationGatewayProvider).restore();
      state = session == null
          ? const AuthenticationState.signedOut()
          : AuthenticationState(
              status: AuthenticationStatus.signedIn,
              session: session,
            );
    } on Object {
      state = const AuthenticationState(
        status: AuthenticationStatus.failure,
        errorCode: 'restore_failed',
      );
    }
  }

  Future<bool> register(String identifier, String password) => _submit(
    () => ref
        .read(authenticationGatewayProvider)
        .register(identifier: identifier, password: password),
  );

  Future<bool> login(String identifier, String password) => _submit(
    () => ref
        .read(authenticationGatewayProvider)
        .login(identifier: identifier, password: password),
  );

  Future<void> logout() async {
    final session = state.session;
    state = AuthenticationState(
      status: AuthenticationStatus.submitting,
      session: session,
    );
    try {
      await ref.read(authenticationGatewayProvider).logout();
      state = const AuthenticationState.signedOut();
    } on Object {
      state = AuthenticationState(
        status: AuthenticationStatus.failure,
        session: session,
        errorCode: 'logout_failed',
      );
    }
  }

  Future<bool> _submit(Future<dynamic> Function() action) async {
    state = const AuthenticationState(status: AuthenticationStatus.submitting);
    try {
      final session = await action();
      state = AuthenticationState(
        status: AuthenticationStatus.signedIn,
        session: session,
      );
      return true;
    } on AuthenticationFailure catch (error) {
      state = AuthenticationState(
        status: AuthenticationStatus.failure,
        errorCode: error.code,
      );
      return false;
    } on Object {
      state = const AuthenticationState(
        status: AuthenticationStatus.failure,
        errorCode: 'unknown',
      );
      return false;
    }
  }
}
