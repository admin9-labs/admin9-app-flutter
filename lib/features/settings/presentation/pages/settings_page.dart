import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_provider.dart';
import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/app/startup/startup_provider.dart';
import 'package:admin9_app_flutter/app/startup/startup_state.dart';
import 'package:admin9_app_flutter/features/legal/domain/legal_document.dart';
import 'package:admin9_app_flutter/features/startup_ad/presentation/providers/startup_ad_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../shared/ui/component_example_section.dart';
import '../../../../shared/ui/error_state_view.dart';
import '../../../../shared/ui/loading_state_view.dart';
import '../../../../shared/ui/responsive_page_body.dart';

@RoutePage()
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appAppearanceProvider);
    return Column(
      children: [
        FHeader(title: Text(context.tr('settings.title'))),
        Expanded(
          child: appearance.when(
            data: (state) =>
                _body(context, ref, state.preference, state.saving),
            error: (error, stackTrace) => ErrorStateView(
              title: context.tr('common.error_title'),
              message: context.tr('settings.load_failed'),
              retryLabel: context.tr('common.retry'),
              onRetry: ref.read(appAppearanceProvider.notifier).reload,
            ),
            loading: () =>
                LoadingStateView(label: context.tr('common.loading')),
          ),
        ),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AppAppearancePreference preference,
    bool saving,
  ) => ResponsivePageBody(
    children: [
      ComponentExampleSection(
        title: context.tr('settings.theme_mode'),
        description: context.tr('settings.theme_description'),
        child: _ChoiceGroup<AppBrightnessPreference>(
          groupKey: 'settings-brightness',
          enabled: !saving,
          value: preference.brightness,
          values: AppBrightnessPreference.values,
          label: _brightnessLabel,
          onChanged: (value) =>
              _save(context, ref, preference.copyWith(brightness: value)),
        ),
      ),
      ComponentExampleSection(
        title: context.tr('settings.theme_preset'),
        description: context.tr('settings.theme_preset_description'),
        child: _ChoiceGroup<AppThemePreset>(
          groupKey: 'settings-preset',
          enabled: !saving,
          value: preference.preset,
          values: AppThemePreset.values,
          label: _presetLabel,
          onChanged: (value) =>
              _save(context, ref, preference.copyWith(preset: value)),
        ),
      ),
      ComponentExampleSection(
        title: context.tr('settings.font_size'),
        description: context.tr('settings.font_size_description'),
        child: _ChoiceGroup<AppFontSizePreference>(
          groupKey: 'settings-font-size',
          enabled: !saving,
          value: preference.fontSize,
          values: AppFontSizePreference.values,
          label: _fontSizeLabel,
          onChanged: (value) =>
              _save(context, ref, preference.copyWith(fontSize: value)),
        ),
      ),
      ComponentExampleSection(
        title: context.tr('settings.theme_radius'),
        description: context.tr('settings.theme_radius_description'),
        child: _ChoiceGroup<AppRadiusPreference>(
          groupKey: 'settings-radius',
          enabled: !saving,
          value: preference.radius,
          values: AppRadiusPreference.values,
          label: _radiusLabel,
          onChanged: (value) =>
              _save(context, ref, preference.copyWith(radius: value)),
        ),
      ),
      const _PrivacyAndCacheSettings(),
      FButton(
        key: const ValueKey('settings-reset'),
        variant: .outline,
        onPress: saving || preference == AppAppearancePreference.defaults
            ? null
            : () => _confirmReset(context, ref),
        child: Text(context.tr('settings.reset')),
      ),
    ],
  );

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    AppAppearancePreference preference,
  ) async {
    try {
      final saved = await ref
          .read(appAppearanceProvider.notifier)
          .savePreference(preference);
      if (context.mounted && saved) {
        showFToast(
          context: context,
          alignment: .bottomCenter,
          title: Text(context.tr('common.saved')),
        );
      }
    } on Object {
      if (context.mounted) {
        showFToast(
          context: context,
          alignment: .bottomCenter,
          variant: .destructive,
          title: Text(context.tr('common.save_failed')),
        );
      }
    }
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showFDialog<bool>(
      context: context,
      useSafeArea: true,
      builder: (dialogContext, _, animation) => FDialog(
        animation: animation,
        semanticsLabel: context.tr('settings.reset_title'),
        builder: (_, style) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(
                context.tr('settings.reset_title'),
                style: style.titleTextStyle,
              ),
              Text(
                context.tr('settings.reset_message'),
                style: style.bodyTextStyle,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  FButton(
                    variant: .outline,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () => Navigator.of(dialogContext).pop(false),
                    child: Text(context.tr('common.cancel')),
                  ),
                  FButton(
                    key: const ValueKey('settings-reset-confirm'),
                    mainAxisSize: MainAxisSize.min,
                    onPress: () => Navigator.of(dialogContext).pop(true),
                    child: Text(context.tr('common.confirm')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      await _save(context, ref, AppAppearancePreference.defaults);
    }
  }
}

class _PrivacyAndCacheSettings extends ConsumerWidget {
  const _PrivacyAndCacheSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(startupCoordinatorProvider);
    final cacheSize = ref.watch(startupAdCacheSizeProvider);
    return ComponentExampleSection(
      title: context.tr('settings.privacy_title'),
      description: context.tr('settings.privacy_description'),
      child: FItemGroup(
        divider: .indented,
        children: [
          FItem(
            key: const ValueKey('settings-privacy-policy'),
            prefix: const Icon(FLucideIcons.fileText),
            title: Text(context.tr('privacy.policy')),
            suffix: const Icon(FLucideIcons.chevronRight),
            onPress: () => context.pushRoute(
              LegalDocumentRoute(document: LegalDocument.privacyPolicy),
            ),
          ),
          FItem(
            key: const ValueKey('settings-privacy-consent'),
            variant: startup.accessMode == AccessMode.full
                ? .destructive
                : .primary,
            prefix: Icon(
              startup.accessMode == AccessMode.full
                  ? FLucideIcons.shieldOff
                  : FLucideIcons.shieldCheck,
            ),
            title: Text(
              context.tr(
                startup.accessMode == AccessMode.full
                    ? 'settings.privacy_withdraw'
                    : 'settings.privacy_enable',
              ),
            ),
            subtitle: Text(
              context.tr(
                startup.accessMode == AccessMode.full
                    ? 'settings.privacy_full'
                    : 'settings.privacy_limited',
              ),
            ),
            suffix: const Icon(FLucideIcons.chevronRight),
            onPress: () => startup.accessMode == AccessMode.full
                ? _withdraw(context, ref)
                : _review(context, ref),
          ),
          FItem(
            key: const ValueKey('settings-startup-ad-cache'),
            prefix: const Icon(FLucideIcons.database),
            title: Text(context.tr('settings.startup_cache')),
            subtitle: Text(context.tr('settings.startup_cache_description')),
            details: Text(
              cacheSize.when(
                data: _formatBytes,
                error: (_, _) => context.tr('settings.cache_unknown'),
                loading: () => context.tr('common.loading'),
              ),
            ),
            suffix: const Icon(FLucideIcons.trash2),
            onPress: cacheSize.isLoading
                ? null
                : () => _clearCache(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final confirmed = await showFDialog<bool>(
      context: context,
      useSafeArea: true,
      builder: (dialogContext, _, animation) => FDialog(
        animation: animation,
        semanticsLabel: context.tr('settings.privacy_withdraw'),
        builder: (_, style) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(
                context.tr('settings.privacy_withdraw'),
                style: style.titleTextStyle,
              ),
              Text(
                context.tr('settings.privacy_withdraw_message'),
                style: style.bodyTextStyle,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  FButton(
                    variant: .outline,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () => Navigator.of(dialogContext).pop(false),
                    child: Text(context.tr('common.cancel')),
                  ),
                  FButton(
                    key: const ValueKey('settings-privacy-withdraw-confirm'),
                    variant: .destructive,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () => Navigator.of(dialogContext).pop(true),
                    child: Text(context.tr('common.confirm')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final succeeded = await ref
        .read(startupCoordinatorProvider.notifier)
        .withdrawPrivacy();
    if (!context.mounted) return;
    showFToast(
      context: context,
      alignment: .bottomCenter,
      variant: succeeded ? .primary : .destructive,
      title: Text(
        context.tr(
          succeeded ? 'settings.privacy_withdrawn' : 'common.save_failed',
        ),
      ),
    );
  }

  void _review(BuildContext context, WidgetRef ref) {
    ref.read(startupCoordinatorProvider.notifier).requestPrivacyReview();
    context.router.replaceAll([StartupGateRoute(reviewPrivacy: true)]);
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(startupAdRepositoryProvider).clearCache();
      ref.invalidate(startupAdCacheSizeProvider);
      final remaining = await ref.read(startupAdRepositoryProvider).cacheSize();
      if (!context.mounted) return;
      showFToast(
        context: context,
        alignment: .bottomCenter,
        title: Text(
          context.tr(
            remaining == 0
                ? 'settings.cache_cleared'
                : 'settings.cache_clear_partial',
          ),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      showFToast(
        context: context,
        alignment: .bottomCenter,
        variant: .destructive,
        title: Text(context.tr('settings.cache_clear_failed')),
      );
    }
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class _ChoiceGroup<T> extends StatelessWidget {
  const _ChoiceGroup({
    required this.groupKey,
    required this.enabled,
    required this.value,
    required this.values,
    required this.label,
    required this.onChanged,
  });

  final String groupKey;
  final bool enabled;
  final T value;
  final List<T> values;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => FSelectTileGroup<T>(
    key: ValueKey((groupKey, value, enabled)),
    enabled: enabled,
    control: .managedRadio(
      initial: value,
      onChange: (values) {
        if (values.length == 1) onChanged(values.single);
      },
    ),
    children: [
      for (final option in values)
        FSelectTile<T>(
          key: ValueKey('$groupKey-${(option as Enum).name}'),
          title: Text(label(option)),
          value: option,
        ),
    ],
  );
}

String _brightnessLabel(AppBrightnessPreference value) => switch (value) {
  AppBrightnessPreference.system => 'settings.theme_system'.tr(),
  AppBrightnessPreference.light => 'settings.theme_light'.tr(),
  AppBrightnessPreference.dark => 'settings.theme_dark'.tr(),
};

String _presetLabel(AppThemePreset value) => switch (value) {
  AppThemePreset.neutral => 'settings.theme_preset_neutral'.tr(),
  AppThemePreset.ocean => 'settings.theme_preset_ocean'.tr(),
  AppThemePreset.forest => 'settings.theme_preset_forest'.tr(),
};

String _fontSizeLabel(AppFontSizePreference value) => switch (value) {
  AppFontSizePreference.extraSmall => 'settings.font_size_extra_small'.tr(),
  AppFontSizePreference.small => 'settings.font_size_small'.tr(),
  AppFontSizePreference.standard => 'settings.font_size_standard'.tr(),
  AppFontSizePreference.large => 'settings.font_size_large'.tr(),
  AppFontSizePreference.extraLarge => 'settings.font_size_extra_large'.tr(),
};

String _radiusLabel(AppRadiusPreference value) => switch (value) {
  AppRadiusPreference.small => 'settings.theme_radius_small'.tr(),
  AppRadiusPreference.medium => 'settings.theme_radius_medium'.tr(),
  AppRadiusPreference.large => 'settings.theme_radius_large'.tr(),
};
