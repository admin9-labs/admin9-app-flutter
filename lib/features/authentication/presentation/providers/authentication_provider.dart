import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/session/session_store.dart';
import '../../../../app/startup/startup_provider.dart';
import '../../../../app/startup/startup_state.dart';
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
  int _generation = 0;
  Future<Object?>? _pendingOperation;

  @override
  AuthenticationState build() => const AuthenticationState.signedOut();

  Future<void> restore() async {
    final generation = ++_generation;
    state = const AuthenticationState(status: AuthenticationStatus.restoring);
    final operation = Future.sync(
      () => ref.read(authenticationGatewayProvider).restore(),
    );
    _pendingOperation = operation;
    try {
      final session = await operation;
      if (generation != _generation) return;
      state = session == null
          ? const AuthenticationState.signedOut()
          : AuthenticationState(
              status: AuthenticationStatus.signedIn,
              session: session,
            );
    } on Object {
      if (generation != _generation) return;
      state = const AuthenticationState(
        status: AuthenticationStatus.failure,
        errorCode: 'restore_failed',
      );
    } finally {
      if (identical(_pendingOperation, operation)) _pendingOperation = null;
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
    final generation = ++_generation;
    final pending = _pendingOperation;
    final session = state.session;
    state = AuthenticationState(
      status: AuthenticationStatus.submitting,
      session: session,
    );
    try {
      if (pending != null) {
        try {
          await pending;
        } on Object {
          // A failed pending operation must not prevent session clearing.
        }
      }
      await ref.read(authenticationGatewayProvider).logout();
      if (generation != _generation) return;
      state = const AuthenticationState.signedOut();
    } on Object {
      if (generation != _generation) return;
      state = AuthenticationState(
        status: AuthenticationStatus.failure,
        session: session,
        errorCode: 'logout_failed',
      );
    }
  }

  Future<bool> _submit(Future<dynamic> Function() action) async {
    if (ref.read(startupCoordinatorProvider).accessMode != AccessMode.full ||
        state.status == AuthenticationStatus.submitting ||
        state.status == AuthenticationStatus.restoring) {
      return false;
    }
    final generation = ++_generation;
    state = const AuthenticationState(status: AuthenticationStatus.submitting);
    final operation = Future.sync(action);
    _pendingOperation = operation;
    try {
      final session = await operation;
      if (generation != _generation) return false;
      if (ref.read(startupCoordinatorProvider).accessMode != AccessMode.full) {
        await ref.read(authenticationGatewayProvider).logout();
        if (generation == _generation) {
          state = const AuthenticationState.signedOut();
        }
        return false;
      }
      state = AuthenticationState(
        status: AuthenticationStatus.signedIn,
        session: session,
      );
      return true;
    } on AuthenticationFailure catch (error) {
      if (generation != _generation) return false;
      state = AuthenticationState(
        status: AuthenticationStatus.failure,
        errorCode: error.code,
      );
      return false;
    } on Object {
      if (generation != _generation) return false;
      state = const AuthenticationState(
        status: AuthenticationStatus.failure,
        errorCode: 'unknown',
      );
      return false;
    } finally {
      if (identical(_pendingOperation, operation)) _pendingOperation = null;
    }
  }
}
