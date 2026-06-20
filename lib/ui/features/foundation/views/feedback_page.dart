import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/foundation_page.dart';
import '../../../../core/widgets/primary_pill_button.dart';
import '../../../shared/app_state_controller.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const maxLength = 140;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textLength = _controller.text.characters.length;
    final canSubmit = textLength > 0 && textLength <= maxLength;

    return FoundationPage(
      title: '意见反馈',
      children: [
        TextField(
          key: const Key('feedback-input'),
          controller: _controller,
          minLines: 5,
          maxLines: 7,
          maxLength: maxLength,
          decoration: const InputDecoration(
            hintText: '帮助我们做得更好',
            counterText: '',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '最多可输入140个中文、数字、英文 ($textLength/$maxLength)',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.textTertiary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryPillButton(
          key: const Key('submit-feedback'),
          onPressed: canSubmit ? _submit : null,
          label: '提交',
        ),
      ],
    );
  }

  void _submit() {
    context.read<AppStateController>().addFeedback(_controller.text);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('反馈已提交')));
    Navigator.of(context).pop();
  }
}
