import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/foundation_page.dart';
import '../../../../core/widgets/settings_group.dart';
import '../../../../data/repositories/foundation_repository.dart';

class HarmfulReportPage extends StatelessWidget {
  const HarmfulReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<FoundationRepository>();
    final contacts = repository.reportContacts;
    final phoneContacts = contacts
        .where((item) => item.iconKey == 'phone')
        .toList();
    final mailContact = contacts.firstWhere((item) => item.iconKey == 'mail');
    final tokens = context.tokens;

    return FoundationPage(
      title: '有害信息举报',
      children: [
        SettingsGroup(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('举报电话', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (
                        var index = 0;
                        index < phoneContacts.length;
                        index++
                      ) ...[
                        if (index > 0) const SizedBox(width: 12),
                        Expanded(
                          child: _ContactButton(
                            value: phoneContacts[index].value,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SectionGap(height: 14),
        SettingsGroup(
          children: [SettingsRow(title: '举报邮箱', value: mailContact.value)],
        ),
        const SectionGap(height: 14),
        SettingsGroup(
          children: const [
            SettingsRow(title: '中央网信办不良信息举报中心'),
            SettingsRow(title: '省级互联网不良信息举报中心'),
            SettingsRow(title: '举报 APP 下载'),
          ],
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          key: const Key('submit-harmful-report'),
          onPressed: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('举报已提交'))),
          icon: const Icon(Icons.flag_outlined),
          label: const Text('提交举报'),
        ),
        const SizedBox(height: 18),
        Text(
          '举报信息将用于内容治理。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.textTertiary),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      height: AppSpacing.rowMinHeight,
      decoration: BoxDecoration(
        color: tokens.brand.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_in_talk, color: tokens.brand.primary),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: tokens.brand.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
