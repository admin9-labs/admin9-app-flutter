final class SessionSnapshot {
  const SessionSnapshot({required this.accountId, required this.identifier});

  final String accountId;
  final String identifier;

  Map<String, String> toJson() => {
    'accountId': accountId,
    'identifier': identifier,
  };

  static SessionSnapshot? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final accountId = value['accountId'];
    final identifier = value['identifier'];
    if (accountId is! String ||
        accountId.isEmpty ||
        identifier is! String ||
        identifier.isEmpty) {
      return null;
    }
    return SessionSnapshot(accountId: accountId, identifier: identifier);
  }
}
