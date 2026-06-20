import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/quick_action_grid.dart';
import '../../../../core/widgets/top_level_page_config.dart';
import '../../../../core/widgets/top_level_page_scaffold.dart';
import '../../../../data/repositories/service_repository.dart';
import '../../../../domain/models/service_item.dart';
import '../../../shared/app_state_controller.dart';
import 'service_apply_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key, this.scrollToTopRequest = 0});

  final int scrollToTopRequest;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ServiceRepository>();

    return ConfiguredTopLevelPage(
      scrollToTopRequest: scrollToTopRequest,
      config: TopLevelPageConfig(
        title: '服务',
        surfaceBuilder: _sharedImageSurface,
        scrollEdgeTitleBehavior: TopLevelScrollEdgeTitleBehavior.visibleAtEdge,
        scrollEdgeTitleAlignment: TopLevelScrollEdgeTitleAlignment.center,
        plainSliversBuilder: (context) => [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageX,
              AppSpacing.sectionGap,
              AppSpacing.pageX,
              AppSpacing.bottomNavPagePadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ServiceNavigationSections(
                  key: const Key('service-channel-sections'),
                  sections: repository.sections,
                  showRecent: true,
                  defaultRecentItems: repository.defaultRecentItems,
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
}

class HomeServiceNavigationBlock extends StatelessWidget {
  const HomeServiceNavigationBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ServiceRepository>();

    return ServiceNavigationSections(
      key: const Key('home-service-navigation'),
      sections: repository.sections,
      sectionLimit: 2,
      sectionPadding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      borderlessSections: true,
      sectionRadius: AppRadius.input,
      lightTileStyle: true,
    );
  }
}

class ServiceNavigationSections extends StatelessWidget {
  const ServiceNavigationSections({
    super.key,
    required this.sections,
    this.showRecent = false,
    this.defaultRecentItems = const [],
    this.sectionLimit,
    this.sectionPadding = AppInsets.section,
    this.borderlessSections = false,
    this.sectionRadius = AppRadius.card,
    this.lightTileStyle = false,
  });

  final List<ServiceSection> sections;
  final bool showRecent;
  final List<ServiceItem> defaultRecentItems;
  final int? sectionLimit;
  final EdgeInsetsGeometry sectionPadding;
  final bool borderlessSections;
  final double sectionRadius;
  final bool lightTileStyle;

  @override
  Widget build(BuildContext context) {
    final visibleSections = sectionLimit == null
        ? sections
        : sections.take(sectionLimit!).toList(growable: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showRecent) ...[
          _buildRecentServiceSection(context),
          const SizedBox(height: AppSpacing.cardGap),
        ],
        for (var index = 0; index < visibleSections.length; index++) ...[
          _buildServiceSection(context, visibleSections[index]),
          if (index != visibleSections.length - 1)
            const SizedBox(height: AppSpacing.cardGap),
        ],
      ],
    );
  }

  Widget _buildRecentServiceSection(BuildContext context) {
    final repository = context.read<ServiceRepository>();
    final recentIds = context.watch<AppStateController>().recentServiceIds;
    final recentItems = recentIds
        .map(repository.findById)
        .whereType<ServiceItem>()
        .toList(growable: false);
    final items = recentItems.isEmpty ? defaultRecentItems : recentItems;

    return QuickActionSection(
      key: const Key('service-section-recent'),
      title: '最近使用',
      cardPadding: sectionPadding,
      cardRadius: sectionRadius,
      showCardBorder: !borderlessSections,
      gridKey: const Key('quick-action-grid-service-recent'),
      items: _serviceQuickActionItems(context, items),
      maxItems: 4,
      shrinkToItemCount: true,
    );
  }

  Widget _buildServiceSection(BuildContext context, ServiceSection section) {
    final displayLimit = section.displayLimit;
    final items = displayLimit == null
        ? section.items
        : section.items.take(displayLimit).toList(growable: false);
    final showsMore = section.showMore && section.items.length > items.length;

    return QuickActionSection(
      key: Key('service-section-${section.id}'),
      title: section.title,
      cardPadding: sectionPadding,
      cardRadius: sectionRadius,
      showCardBorder: !borderlessSections,
      actionLabel: showsMore ? section.moreLabel : null,
      onActionTap: showsMore
          ? () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ServiceSectionPage(section: section),
              ),
            )
          : null,
      gridKey: Key('quick-action-grid-service-${section.id}'),
      items: _serviceQuickActionItems(context, items),
      shrinkToItemCount: lightTileStyle,
    );
  }
}

void openServiceEntry(BuildContext context, ServiceItem item) {
  context.read<AppStateController>().recordServiceUse(item);
  switch (item.target.type) {
    case ServiceTargetType.h5:
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ServiceWebPlaceholderPage(item: item),
        ),
      );
    case ServiceTargetType.internalPage:
      _openInternalService(context, item);
    case ServiceTargetType.phone:
    case ServiceTargetType.email:
    case ServiceTargetType.externalApp:
    case ServiceTargetType.miniProgram:
    case ServiceTargetType.page:
    case ServiceTargetType.placeholder:
      _showServiceFeedback(context, item.target.feedback);
  }
}

class ServiceWebPlaceholderPage extends StatelessWidget {
  const ServiceWebPlaceholderPage({super.key, required this.item});

  final ServiceItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: context.typography.sectionTitle),
                const SizedBox(height: AppSpacing.sm),
                Text(item.description, style: context.typography.feedSummary),
                const SizedBox(height: AppSpacing.md),
                Text(item.target.value, style: context.typography.feedMeta),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceSectionPage extends StatelessWidget {
  const ServiceSectionPage({super.key, required this.section});

  final ServiceSection section;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          Text(section.title, style: context.typography.pageTitle),
          const SizedBox(height: AppSpacing.sectionGap),
          QuickActionSection(
            title: null,
            gridKey: const Key('quick-action-grid-service-section-detail'),
            items: _serviceQuickActionItems(context, section.items),
          ),
        ],
      ),
    );
  }
}

class ServiceInternalPlaceholderPage extends StatelessWidget {
  const ServiceInternalPlaceholderPage({super.key, required this.item});

  final ServiceItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: context.typography.sectionTitle),
                const SizedBox(height: AppSpacing.sm),
                Text(item.description, style: context.typography.feedSummary),
                const SizedBox(height: AppSpacing.md),
                Text(item.target.value, style: context.typography.feedMeta),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _openInternalService(BuildContext context, ServiceItem item) {
  switch (item.target.value) {
    case 'service-apply':
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ServiceApplyPage(service: item)),
      );
    default:
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ServiceInternalPlaceholderPage(item: item),
        ),
      );
  }
}

void _showServiceFeedback(BuildContext context, String message) {
  showAppSnackBar(context, message);
}

List<QuickActionItem> _serviceQuickActionItems(
  BuildContext context,
  Iterable<ServiceItem> items,
) {
  return [
    for (final item in items)
      QuickActionItem(
        key: Key('service-entry-${item.id}'),
        icon: _serviceIcon(item.iconKey),
        label: item.title,
        color: _iconColor(context, item.iconKey),
        imageUrl: item.iconUrl,
        onTap: () => openServiceEntry(context, item),
      ),
  ];
}

IconData _serviceIcon(String key) {
  return switch (key) {
    'study' => Icons.menu_book_outlined,
    'party' => Icons.flag_outlined,
    'badge' => Icons.workspace_premium_outlined,
    'government' => Icons.account_balance_outlined,
    'mailbox' => Icons.markunread_mailbox_outlined,
    'people' => Icons.groups_outlined,
    'tax' => Icons.receipt_long_outlined,
    'marriage' => Icons.favorite_border,
    'phone' => Icons.phone_in_talk_outlined,
    'performance' => Icons.trending_up_outlined,
    'easy' => Icons.dashboard_customize_outlined,
    'rescue' => Icons.volunteer_activism_outlined,
    'hospital' => Icons.local_hospital_outlined,
    'medical' => Icons.medical_services_outlined,
    'pharmacy' => Icons.local_pharmacy_outlined,
    'drug' => Icons.medication_outlined,
    'register' => Icons.event_available_outlined,
    'insurance' => Icons.health_and_safety_outlined,
    'oil' => Icons.local_gas_station_outlined,
    'weather' => Icons.wb_sunny_outlined,
    'traffic' => Icons.traffic_outlined,
    'culture' => Icons.map_outlined,
    'life' => Icons.home_repair_service_outlined,
    'education' => Icons.school_outlined,
    'travel' => Icons.landscape_outlined,
    'news' => Icons.newspaper_outlined,
    _ => Icons.apps_outlined,
  };
}

Color _iconColor(BuildContext context, String key) {
  final tokens = context.tokens;

  return switch (key) {
    'study' || 'party' || 'mailbox' || 'rescue' => tokens.danger,
    'hospital' ||
    'medical' ||
    'pharmacy' ||
    'drug' ||
    'register' => tokens.success,
    'oil' ||
    'weather' ||
    'traffic' ||
    'culture' ||
    'education' ||
    'travel' ||
    'news' => tokens.info,
    'performance' || 'easy' => tokens.warning,
    _ => tokens.brand.primary,
  };
}
