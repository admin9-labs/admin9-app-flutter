import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/appearance_controller.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/foundation_page.dart';
import '../../../../core/widgets/settings_group.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceController>();
    final settings = appearance.settings;

    return FoundationPage(
      title: '外观主题',
      children: [
        const SectionHeader(title: '主题样式'),
        SettingsGroup(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tileWidth = (constraints.maxWidth - AppSpacing.md) / 2;

                  return Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final brand in AppBrand.all)
                        _ThemePreviewTile(
                          brand: brand,
                          selected: settings.brandId == brand.id,
                          width: tileWidth,
                          onTap: () => appearance.setBrand(brand.id),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SectionGap(),
        const SectionHeader(title: '显示模式'),
        SettingsGroup(
          children: [
            for (final mode in AppThemeMode.values)
              SettingsRow(
                title: _modeLabel(mode),
                trailing: settings.themeMode == mode
                    ? Icon(Icons.check, color: context.tokens.brand.primary)
                    : const SizedBox.shrink(),
                onTap: () => appearance.setThemeMode(mode),
              ),
          ],
        ),
        const SectionGap(),
        SettingsGroup(
          children: [
            SettingsRow(
              title: '一键全局灰',
              value: '节日/纪念日使用',
              trailing: Switch(
                value: settings.grayscale,
                onChanged: appearance.setGrayscale,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _modeLabel(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => '跟随系统',
      AppThemeMode.light => '浅色模式',
      AppThemeMode.dark => '深色模式',
    };
  }
}

class _ThemePreviewTile extends StatelessWidget {
  const _ThemePreviewTile({
    required this.brand,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  static const _previewAspectRatio = 1683 / 489;

  final AppBrand brand;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final borderColor = selected
        ? tokens.brand.primary
        : tokens.divider.withValues(alpha: 0.75);

    return SizedBox(
      width: width,
      child: InkWell(
        key: Key('brand-${brand.id.name}'),
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.2 : AppSpacing.dividerThickness,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.dividerThickness),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card - 1),
              child: AspectRatio(
                aspectRatio: _previewAspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      AppAssets.topLevelHeaderImage(brand.id),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, _, _) =>
                          _BrandPreviewFallback(brand: brand),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          0,
                          AppSpacing.sm,
                          AppSpacing.xs,
                        ),
                        child: Text(
                          brand.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.typography.label.copyWith(
                            color: tokens.textPrimary.withValues(alpha: 0.74),
                            fontWeight: FontWeight.w600,
                            shadows: const [
                              Shadow(
                                color: Color(0xCCFFFFFF),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
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

class _BrandPreviewFallback extends StatelessWidget {
  const _BrandPreviewFallback({required this.brand});

  final AppBrand brand;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            brand.gradientStart,
            brand.gradientMiddle,
            brand.gradientEnd,
          ],
        ),
      ),
    );
  }
}
