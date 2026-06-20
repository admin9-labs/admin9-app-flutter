import 'package:flutter/material.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_pill_button.dart';
import '../../../../domain/models/article.dart';

class ContentReportPage extends StatefulWidget {
  const ContentReportPage({super.key, required this.article});

  final Article article;

  @override
  State<ContentReportPage> createState() => _ContentReportPageState();
}

class _ContentReportPageState extends State<ContentReportPage> {
  final _controller = TextEditingController();
  String _reason = '内容不实';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('举报内容')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          Text(
            widget.article.title,
            style: context.typography.feedTitleCompact,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          DropdownButtonFormField<String>(
            initialValue: _reason,
            decoration: const InputDecoration(labelText: '举报原因'),
            items: const [
              DropdownMenuItem(value: '内容不实', child: Text('内容不实')),
              DropdownMenuItem(value: '低俗有害', child: Text('低俗有害')),
              DropdownMenuItem(value: '侵权投诉', child: Text('侵权投诉')),
              DropdownMenuItem(value: '其他问题', child: Text('其他问题')),
            ],
            onChanged: (value) => setState(() => _reason = value ?? _reason),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(labelText: '补充说明'),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryPillButton(
            key: const Key('submit-content-report'),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('举报已提交：$_reason')));
              Navigator.of(context).pop();
            },
            label: '提交举报',
          ),
        ],
      ),
    );
  }
}
