import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/models/service_item.dart';
import '../../../shared/app_state_controller.dart';

class ServiceApplyPage extends StatefulWidget {
  const ServiceApplyPage({super.key, required this.service});

  final ServiceItem service;

  @override
  State<ServiceApplyPage> createState() => _ServiceApplyPageState();
}

class _ServiceApplyPageState extends State<ServiceApplyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: '新闻用户');
  final _phoneController = TextEditingController(text: '13800138000');
  final _remarkController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.service.title}办理')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          Text('办理信息', style: context.typography.pageTitle),
          const SizedBox(height: AppSpacing.sectionGap),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  key: const Key('service-applicant-field'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '办理人'),
                  validator: _required('请输入办理人'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  key: const Key('service-phone-field'),
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: '联系方式'),
                  keyboardType: TextInputType.phone,
                  validator: _required('请输入联系方式'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _remarkController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: '办理说明'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            key: const Key('submit-service-application'),
            onPressed: _submit,
            child: const Text('提交办理'),
          ),
        ],
      ),
    );
  }

  FormFieldValidator<String> _required(String message) {
    return (value) => (value ?? '').trim().isEmpty ? message : null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AppStateController>().applyService(
      service: widget.service,
      applicant: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('办理已提交，本地生成进度记录')));
    Navigator.of(context).pop();
  }
}
