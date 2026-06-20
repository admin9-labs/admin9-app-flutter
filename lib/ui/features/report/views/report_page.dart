import 'package:flutter/material.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_info_list_item.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/top_level_page_config.dart';
import '../../../../core/widgets/top_level_page_scaffold.dart';
import 'report_form_page.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key, this.scrollToTopRequest = 0});

  final int scrollToTopRequest;

  @override
  Widget build(BuildContext context) {
    return ConfiguredTopLevelPage(
      scrollToTopRequest: scrollToTopRequest,
      config: TopLevelPageConfig(
        title: '爆料',
        surfaceBuilder: _sharedImageSurface,
        scrollEdgeTitleBehavior: TopLevelScrollEdgeTitleBehavior.visibleAtEdge,
        scrollEdgeTitleAlignment: TopLevelScrollEdgeTitleAlignment.center,
        plainSliversBuilder: (context) => [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageX,
              AppSpacing.sm,
              AppSpacing.pageX,
              AppSpacing.bottomNavPagePadding + AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ReportEntryHero(
                  onCreateReport: () => _openReportForm(context),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  PageSurface _sharedImageSurface(
    BuildContext context,
    TabController? controller,
  ) {
    return PageSurface(
      backdrop: PageBackdrop.image(
        tokens: context.tokens,
        endColor: context.tokens.pageBackground,
        assetName: AppAssets.topLevelHeaderImage(context.tokens.brand.id),
        strength: 0.42,
        imageAlignment: Alignment.topCenter,
      ),
    );
  }

  void _openReportForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ReportFormPage()));
  }
}

class _ReportEntryHero extends StatelessWidget {
  const _ReportEntryHero({required this.onCreateReport});

  final VoidCallback onCreateReport;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final typography = context.typography;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final headerStartColor = dark
        ? tokens.elevatedBackground
        : Colors.white.withValues(alpha: 0.84);
    final headerEndColor = dark
        ? Color.lerp(tokens.cardBackground, tokens.brand.primary, 0.18)!
        : tokens.brand.gradientMiddle.withValues(alpha: 0.38);
    final iconBackground = tokens.brand.primary.withValues(
      alpha: dark ? 0.18 : 0.12,
    );

    return Column(
      key: const Key('report-entry-page'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.md),
        Container(
          key: const Key('report-entry-header'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [headerStartColor, headerEndColor],
            ),
            border: Border.all(
              color: dark ? tokens.divider : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: iconBackground,
                child: Icon(
                  Icons.campaign,
                  color: tokens.brand.primary,
                  size: AppIconSize.feature,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                '有线索，来爆料',
                style: typography.heroTitle.copyWith(color: tokens.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '提交身边线索、民生问题或现场照片、视频，让有价值的信息被看见。',
                style: typography.bodyText.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        const _ReportNoticeCard(),
        const SizedBox(height: AppSpacing.xxl),
        _CreateReportButton(onTap: onCreateReport),
      ],
    );
  }
}

class _ReportNoticeCard extends StatelessWidget {
  const _ReportNoticeCard();

  static const _items = [
    (
      icon: Icons.fact_check_outlined,
      title: '受理范围',
      body: '欢迎提交民生服务、公共安全、城市治理等真实线索。',
    ),
    (
      icon: Icons.photo_camera_outlined,
      title: '提交要求',
      body: '请尽量写清时间、地点和经过，可补充现场照片或视频材料。',
    ),
    (
      icon: Icons.verified_user_outlined,
      title: '处理说明',
      body: '平台会保护个人信息，并对线索进行核实后再推进处理。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppCard(
      key: const Key('report-notice-card'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      backgroundColor: tokens.cardBackground.withValues(alpha: 0.92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(title: '爆料须知'),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < _items.length; index++) ...[
            AppInfoListItem(
              icon: _items[index].icon,
              title: _items[index].title,
              subtitle: _items[index].body,
            ),
            if (index != _items.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _CreateReportButton extends StatelessWidget {
  const _CreateReportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '我要爆料，进入爆料表单',
      child: FilledButton.icon(
        key: const Key('report-create-card'),
        onPressed: onTap,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: context.typography.buttonLabel.copyWith(fontSize: 17),
        ),
        icon: const Icon(Icons.edit_note_outlined),
        label: const Text('我要爆料'),
      ),
    );
  }
}
