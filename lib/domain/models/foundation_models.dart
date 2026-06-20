enum MessageCategory { comments, likes, system }

class FoundationMessage {
  const FoundationMessage({
    required this.id,
    required this.category,
    required this.title,
    required this.time,
    this.unread = false,
  });

  final String id;
  final MessageCategory category;
  final String title;
  final String time;
  final bool unread;
}

class AgreementDocument {
  const AgreementDocument({
    required this.id,
    required this.title,
    required this.content,
  });

  final String id;
  final String title;
  final String content;
}

class ReportContact {
  const ReportContact({
    required this.label,
    required this.value,
    required this.iconKey,
  });

  final String label;
  final String value;
  final String iconKey;
}
