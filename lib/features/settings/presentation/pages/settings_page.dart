import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_provider.dart';
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

String _radiusLabel(AppRadiusPreference value) => switch (value) {
  AppRadiusPreference.small => 'settings.theme_radius_small'.tr(),
  AppRadiusPreference.medium => 'settings.theme_radius_medium'.tr(),
  AppRadiusPreference.large => 'settings.theme_radius_large'.tr(),
};
