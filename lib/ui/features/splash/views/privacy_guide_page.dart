import 'package:flutter/material.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';

class PrivacyGuidePage extends StatelessWidget {
  const PrivacyGuidePage({
    super.key,
    required this.onAccept,
    required this.onDecline,
    required this.onOpenAgreement,
  });

  final Future<void> Function() onAccept;
  final VoidCallback onDecline;
  final ValueChanged<String> onOpenAgreement;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      key: const Key('privacy-guide-page'),
      backgroundColor: Colors.black.withValues(alpha: 0.38),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.contentMaxWidth,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.dialog),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                        AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              '个人隐私保护指引',
                              style: context.typography.sectionTitle.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text.rich(
                            TextSpan(
                              style: context.typography.bodyText.copyWith(
                                color: tokens.textPrimary,
                                height: 1.7,
                              ),
                              children: [
                                const TextSpan(text: '欢迎您使用西昌发布客户端！\n'),
                                const TextSpan(
                                  text:
                                      '为了更好地为您提供相关服务，我们会根据您使用服务的具体功能需要，收集必要的用户信息。您可通过阅读',
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: _AgreementLink(
                                    label: '《用户协议》',
                                    onTap: () => onOpenAgreement('user'),
                                  ),
                                ),
                                const TextSpan(text: '和'),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: _AgreementLink(
                                    label: '《隐私政策》',
                                    onTap: () => onOpenAgreement('privacy'),
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      '了解我们收集、使用、存储个人信息的情况，以及对您个人隐私的保护措施。西昌发布客户端深知个人信息对您的重要性，我们将以最高标准遵守法律法规要求，尽全力保护您的个人信息安全。\n\n如您同意，请点击“同意”开始接受服务。',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            key: const Key('privacy-decline'),
                            onPressed: onDecline,
                            style: TextButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              foregroundColor: tokens.textDisabled,
                              textStyle: context.typography.buttonLabel,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(AppRadius.dialog),
                                ),
                              ),
                            ),
                            child: const Text('暂不使用'),
                          ),
                        ),
                        Expanded(
                          child: FilledButton(
                            key: const Key('privacy-accept'),
                            onPressed: onAccept,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(
                                    AppRadius.dialog,
                                  ),
                                ),
                              ),
                            ),
                            child: const Text('同意'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AgreementLink extends StatelessWidget {
  const _AgreementLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: context.typography.bodyText.copyWith(
          color: context.tokens.danger,
          height: 1.7,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
