import '../../domain/models/user_profile.dart';

class PrototypeAuthConfig {
  const PrototypeAuthConfig({
    this.enabled = true,
    this.smsCode = '123456',
    this.oneTapPhone = '15881551001',
    this.oneTapMaskedPhone = '158****1001',
  });

  final bool enabled;
  final String smsCode;
  final String oneTapPhone;
  final String oneTapMaskedPhone;
}

class UserRepository {
  const UserRepository({
    this.prototypeAuthConfig = const PrototypeAuthConfig(),
  });

  final PrototypeAuthConfig prototypeAuthConfig;

  UserProfile login({required String phone, required String nickname}) {
    return UserProfile(nickname: nickname, phone: phone);
  }
}
