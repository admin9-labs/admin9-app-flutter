class ReportItem {
  const ReportItem({
    required this.id,
    required this.title,
    required this.location,
    required this.status,
    required this.time,
    this.content,
  });

  final String id;
  final String title;
  final String location;
  final String status;
  final String time;
  final String? content;
}
