import 'package:flutter/material.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/models/service_item.dart';
import 'services_page.dart';

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({super.key, required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(service.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          Text(service.title, style: context.typography.heroTitle),
          const SizedBox(height: AppSpacing.sm),
          Text(service.description, style: context.typography.feedSummary),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('导航入口', style: context.typography.sectionTitle),
                const SizedBox(height: AppSpacing.sm),
                Text('按服务类型打开入口。', style: context.typography.feedMeta),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            key: const Key('open-service-target'),
            onPressed: () => openServiceEntry(context, service),
            icon: const Icon(Icons.open_in_new),
            label: const Text('打开入口'),
          ),
        ],
      ),
    );
  }
}
