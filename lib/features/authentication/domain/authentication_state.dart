import '../../../app/session/session.dart';

enum AuthenticationStatus {
  signedOut,
  restoring,
  signedIn,
  submitting,
  failure,
}

final class AuthenticationState {
  const AuthenticationState({
    required this.status,
    this.session,
    this.errorCode,
  });

  const AuthenticationState.signedOut()
    : status = AuthenticationStatus.signedOut,
      session = null,
      errorCode = null;

  final AuthenticationStatus status;
  final SessionSnapshot? session;
  final String? errorCode;
}
