import 'package:admin9_app_flutter/app/session/session.dart';
import 'package:admin9_app_flutter/features/authentication/domain/authentication_gateway.dart';

final class TestAuthenticationGateway implements AuthenticationGateway {
  const TestAuthenticationGateway();

  @override
  Future<SessionSnapshot> register({
    required String identifier,
    required String password,
  }) async =>
      SessionSnapshot(accountId: 'test-account', identifier: identifier);

  @override
  Future<SessionSnapshot> login({
    required String identifier,
    required String password,
  }) async =>
      SessionSnapshot(accountId: 'test-account', identifier: identifier);

  @override
  Future<SessionSnapshot?> restore() async => null;

  @override
  Future<void> logout() async {}
}
