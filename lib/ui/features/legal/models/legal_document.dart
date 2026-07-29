enum LegalDocumentType {
  userAgreement('用户协议', 'legal.user-agreement'),
  privacyPolicy('隐私政策', 'legal.privacy-policy');

  const LegalDocumentType(this.title, this.resourceKey);

  final String title;
  final String resourceKey;
}

class LegalDocument {
  const LegalDocument({required this.type, this.content});

  final LegalDocumentType type;
  final String? content;

  bool get hasContent => content != null && content!.trim().isNotEmpty;
}
