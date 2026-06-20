class UserProfile {
  const UserProfile({required this.nickname, required this.phone});

  final String nickname;
  final String phone;

  String get maskedPhone {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }
}
