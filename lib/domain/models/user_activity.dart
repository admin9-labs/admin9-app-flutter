import 'article.dart';
import 'live_program.dart';
import 'report_item.dart';
import 'service_item.dart';

class UserComment {
  const UserComment({
    required this.id,
    required this.article,
    required this.content,
    required this.time,
    this.replyTo,
    this.liked = false,
  });

  final String id;
  final Article article;
  final String content;
  final String time;
  final String? replyTo;
  final bool liked;

  UserComment copyWith({bool? liked}) {
    return UserComment(
      id: id,
      article: article,
      content: content,
      time: time,
      replyTo: replyTo,
      liked: liked ?? this.liked,
    );
  }
}

class FeedbackRecord {
  const FeedbackRecord({
    required this.id,
    required this.content,
    required this.time,
    required this.status,
    this.reply,
  });

  final String id;
  final String content;
  final String time;
  final String status;
  final String? reply;
}

class ServiceApplicationRecord {
  const ServiceApplicationRecord({
    required this.id,
    required this.service,
    required this.applicant,
    required this.phone,
    required this.time,
    required this.status,
    required this.progress,
  });

  final String id;
  final ServiceItem service;
  final String applicant;
  final String phone;
  final String time;
  final String status;
  final List<String> progress;
}

class ReportSubmission {
  const ReportSubmission({
    required this.item,
    required this.content,
    this.attachments = const [],
  });

  final ReportItem item;
  final String content;
  final List<ReportAttachment> attachments;
}

enum ReportAttachmentType { image, video }

class ReportAttachment {
  const ReportAttachment({
    required this.id,
    required this.type,
    required this.name,
  });

  final String id;
  final ReportAttachmentType type;
  final String name;
}

class LiveReservation {
  const LiveReservation({required this.program, required this.time});

  final LiveProgram program;
  final String time;
}
