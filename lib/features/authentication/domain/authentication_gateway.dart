import '../../../app/session/session.dart';

final class AuthenticationFailure implements Exception {
  const AuthenticationFailure(this.code);

  final String code;
}

abstract interface class AuthenticationGateway {
  Future<SessionSnapshot> register({
    required String identifier,
    required String password,
  });

  Future<SessionSnapshot> login({
    required String identifier,
    required String password,
  });

  Future<SessionSnapshot?> restore();

  Future<void> logout();
}
