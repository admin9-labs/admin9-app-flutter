import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/models/user_activity.dart';
import '../../../shared/app_state_controller.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _contentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _attachments = <ReportAttachment>[];

  int get _imageCount => _attachments
      .where((item) => item.type == ReportAttachmentType.image)
      .length;
  bool get _hasVideo =>
      _attachments.any((item) => item.type == ReportAttachmentType.video);

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _contentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('填写线索')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                _ReportFormField(
                  label: '线索标题',
                  hintText: '一句话说明发生了什么',
                  fieldKey: const Key('report-title-field'),
                  controller: _titleController,
                  validator: _required('请输入线索标题'),
                ),
                const SizedBox(height: AppSpacing.md),
                _ReportFormField(
                  label: '发生地点',
                  hintText: '尽量填写街道、小区或地标',
                  fieldKey: const Key('report-location-field'),
                  controller: _locationController,
                  validator: _required('请输入发生地点'),
                ),
                const SizedBox(height: AppSpacing.md),
                _ReportFormField(
                  label: '具体情况',
                  hintText: '补充时间、经过、现场情况或希望我们关注的重点',
                  fieldKey: const Key('report-content-field'),
                  controller: _contentController,
                  minLines: 4,
                  maxLines: 6,
                  textAlignVertical: TextAlignVertical.top,
                  validator: _required('请输入具体情况'),
                ),
                const SizedBox(height: AppSpacing.md),
                _AttachmentField(
                  attachments: _attachments,
                  onAddImage: _addImage,
                  onAddVideo: _addVideo,
                  onRemove: _removeAttachment,
                ),
                const SizedBox(height: AppSpacing.md),
                _ReportFormField(
                  label: '联系方式',
                  hintText: '仅用于必要核实',
                  fieldKey: const Key('report-phone-field'),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _required('请输入联系方式'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            key: const Key('submit-report'),
            onPressed: _submit,
            child: const Text('提交爆料'),
          ),
        ],
      ),
    );
  }

  FormFieldValidator<String> _required(String message) {
    return (value) {
      if ((value ?? '').trim().isEmpty) return message;
      return null;
    };
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('爆料已提交，等待编辑审核')));
    context.read<AppStateController>().submitReport(
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      content: _contentController.text.trim(),
      attachments: List.unmodifiable(_attachments),
    );
    Navigator.of(context).pop();
  }

  void _addImage() {
    if (_imageCount >= 9) return;
    setState(() {
      final next = _imageCount + 1;
      _attachments.add(
        ReportAttachment(
          id: 'image-${DateTime.now().microsecondsSinceEpoch}-$next',
          type: ReportAttachmentType.image,
          name: '现场照片$next',
        ),
      );
    });
  }

  void _addVideo() {
    if (_hasVideo) return;
    setState(() {
      _attachments.add(
        ReportAttachment(
          id: 'video-${DateTime.now().microsecondsSinceEpoch}',
          type: ReportAttachmentType.video,
          name: '现场视频',
        ),
      );
    });
  }

  void _removeAttachment(ReportAttachment attachment) {
    setState(() {
      _attachments.removeWhere((item) => item.id == attachment.id);
    });
  }
}

class _ReportFormField extends StatelessWidget {
  const _ReportFormField({
    required this.label,
    required this.hintText,
    required this.fieldKey,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
    this.textAlignVertical,
  });

  final String label;
  final String hintText;
  final Key fieldKey;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final TextAlignVertical? textAlignVertical;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.typography.label.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          textAlignVertical: textAlignVertical,
          decoration: InputDecoration(hintText: hintText),
          validator: validator,
        ),
      ],
    );
  }
}

class _AttachmentField extends StatelessWidget {
  const _AttachmentField({
    required this.attachments,
    required this.onAddImage,
    required this.onAddVideo,
    required this.onRemove,
  });

  final List<ReportAttachment> attachments;
  final VoidCallback onAddImage;
  final VoidCallback onAddVideo;
  final ValueChanged<ReportAttachment> onRemove;

  List<ReportAttachment> get _images => attachments
      .where((item) => item.type == ReportAttachmentType.image)
      .toList();
  ReportAttachment? get _video {
    for (final item in attachments) {
      if (item.type == ReportAttachmentType.video) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final images = _images;
    final video = _video;
    final canAddImage = images.length < 9;
    final canAddVideo = video == null;

    return Column(
      key: const Key('report-attachment-field'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '附件',
          style: context.typography.label.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '照片 ${images.length}/9，视频 ${video == null ? 0 : 1}/1',
          style: context.typography.feedMeta.copyWith(
            color: tokens.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          key: const Key('report-image-grid'),
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          children: [
            for (final image in images)
              _AttachmentTile(
                key: Key('report-image-${image.id}'),
                attachment: image,
                onRemove: () => onRemove(image),
              ),
            if (canAddImage)
              _AttachmentAddTile(
                key: const Key('add-report-image'),
                label: '图片',
                icon: Icons.add_photo_alternate_outlined,
                onTap: onAddImage,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (video == null)
          _VideoAddRow(enabled: canAddVideo, onTap: onAddVideo)
        else
          _VideoAttachmentRow(
            key: Key('report-video-${video.id}'),
            attachment: video,
            onRemove: () => onRemove(video),
          ),
      ],
    );
  }
}

class _AttachmentAddTile extends StatelessWidget {
  const _AttachmentAddTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: tokens.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: tokens.textTertiary, size: AppIconSize.lg),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style: context.typography.feedMeta.copyWith(
                color: tokens.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    super.key,
    required this.attachment,
    required this.onRemove,
  });

  final ReportAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.softFill,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: tokens.divider),
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: tokens.brand.primary,
              size: AppIconSize.lg,
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: _RemoveButton(
            key: Key('remove-report-attachment-${attachment.id}'),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}

class _VideoAddRow extends StatelessWidget {
  const _VideoAddRow({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return InkWell(
      key: const Key('add-report-video'),
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: tokens.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: tokens.divider),
        ),
        child: Row(
          children: [
            Icon(
              Icons.video_call_outlined,
              color: tokens.textTertiary,
              size: AppIconSize.lg,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '添加视频',
                style: context.typography.bodyText.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
            ),
            Text(
              '最多 1 个',
              style: context.typography.feedMeta.copyWith(
                color: tokens.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoAttachmentRow extends StatelessWidget {
  const _VideoAttachmentRow({
    super.key,
    required this.attachment,
    required this.onRemove,
  });

  final ReportAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.softFill,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: tokens.divider),
      ),
      child: Row(
        children: [
          Icon(
            Icons.play_circle_outline,
            color: tokens.brand.primary,
            size: AppIconSize.lg,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              attachment.name,
              style: context.typography.bodyText.copyWith(
                color: tokens.textPrimary,
              ),
            ),
          ),
          _RemoveButton(
            key: Key('remove-report-attachment-${attachment.id}'),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.58),
        foregroundColor: Colors.white,
        minimumSize: const Size(28, 28),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.close, size: AppIconSize.xs),
      tooltip: '删除附件',
    );
  }
}
