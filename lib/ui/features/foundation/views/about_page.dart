import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/foundation_page.dart';
import '../../../../core/widgets/settings_group.dart';
import '../../../../data/repositories/foundation_repository.dart';
import '../../../../domain/models/foundation_models.dart';
import 'agreement_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<FoundationRepository>();

    return FoundationPage(
      title: '关于西昌发布',
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Center(
          child: Semantics(
            label: '西昌发布',
            image: true,
            child: ClipRRect(
              key: const Key('about-brand-icon'),
              borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
              child: Image.asset(
                AppAssets.xichangPublishIcon,
                width: 92,
                height: 92,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Center(
          child: Text('权威发布，服务西昌', style: context.typography.feedTitleCompact),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        SettingsGroup(
          children: [
            SettingsRow(
              title: '用户协议',
              onTap: () => AppNavigator.push(
                context,
                AgreementPage(document: repository.agreement('user')),
              ),
            ),
            SettingsRow(
              title: '隐私政策',
              onTap: () => AppNavigator.push(
                context,
                AgreementPage(document: repository.agreement('privacy')),
              ),
            ),
            SettingsRow(
              title: 'APP 自律管理承诺',
              onTap: () => AppNavigator.push(
                context,
                AgreementPage(
                  document: const AgreementDocument(
                    id: 'self-discipline',
                    title: 'APP 自律管理承诺',
                    content: '我们将持续完善内容审核、投诉处理、未成年人保护和账号治理机制。',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SectionGap(),
        const SettingsGroup(
          children: [SettingsRow(title: '软件版本', value: 'V1.0.0')],
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Text(
          '互联网新闻信息服务许可证号：\n51120200128',
          textAlign: TextAlign.center,
          style: context.typography.feedMeta,
        ),
      ],
    );
  }
}
