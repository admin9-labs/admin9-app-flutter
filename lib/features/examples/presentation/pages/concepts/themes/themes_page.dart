import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_provider.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/error_state_view.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_badge.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_item.dart';
import 'package:admin9_app_flutter/shared/ui/loading_state_view.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

@RoutePage()
class ThemesPage extends ConsumerStatefulWidget {
  const ThemesPage({super.key});

  @override
  ConsumerState<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends ConsumerState<ThemesPage> {
  bool _selected = true;

  @override
  Widget build(BuildContext context) {
    final appearance = ref.watch(appAppearanceProvider);
    return Column(
      children: [
        FHeader.nested(
          title: Text('examples.foundation.concepts.themes.title'.tr()),
          prefixes: [FHeaderAction.back(onPress: context.maybePop)],
        ),
        Expanded(
          child: appearance.when(
            data: (state) => _workbench(state.preference, state.saving),
            error: (error, stackTrace) => ErrorStateView(
              title: 'common.error_title'.tr(),
              message: 'settings.load_failed'.tr(),
              retryLabel: 'common.retry'.tr(),
              onRetry: ref.read(appAppearanceProvider.notifier).reload,
            ),
            loading: () => LoadingStateView(label: 'common.loading'.tr()),
          ),
        ),
      ],
    );
  }

  Widget _workbench(AppAppearancePreference preference, bool saving) =>
      ResponsivePageBody(
        safeAreaBottom: false,
        children: [
          _ChoiceSection<AppThemePreset>(
            title: 'settings.theme_preset'.tr(),
            groupKey: 'theme-preset',
            enabled: !saving,
            value: preference.preset,
            values: AppThemePreset.values,
            label: _presetLabel,
            onChanged: (value) => _save(preference.copyWith(preset: value)),
          ),
          _ChoiceSection<AppBrightnessPreference>(
            title: 'settings.theme_mode'.tr(),
            groupKey: 'theme-brightness',
            enabled: !saving,
            value: preference.brightness,
            values: AppBrightnessPreference.values,
            label: _brightnessLabel,
            onChanged: (value) => _save(preference.copyWith(brightness: value)),
          ),
          _ChoiceSection<AppFontSizePreference>(
            title: 'settings.font_size'.tr(),
            groupKey: 'theme-font-size',
            enabled: !saving,
            value: preference.fontSize,
            values: AppFontSizePreference.values,
            label: _fontSizeLabel,
            onChanged: (value) => _save(preference.copyWith(fontSize: value)),
          ),
          _ChoiceSection<AppRadiusPreference>(
            title: 'settings.theme_radius'.tr(),
            groupKey: 'theme-radius',
            enabled: !saving,
            value: preference.radius,
            values: AppRadiusPreference.values,
            label: _radiusLabel,
            onChanged: (value) => _save(preference.copyWith(radius: value)),
          ),
          PlaygroundPreview(
            title: 'examples.foundation.concepts.themes.preview'.tr(),
            status: saving
                ? 'examples.foundation.concepts.themes.saving'.tr()
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FButton(
                      key: const ValueKey('theme-preview-primary'),
                      mainAxisSize: MainAxisSize.min,
                      builder: _flexibleButtonLabel,
                      selected: _selected,
                      onPress: () => setState(() => _selected = !_selected),
                      child: Text('common.confirm'.tr()),
                    ),
                    FButton(
                      mainAxisSize: MainAxisSize.min,
                      builder: _flexibleButtonLabel,
                      variant: .outline,
                      onPress: () => _showPreviewDialog(context),
                      child: Text(
                        'examples.foundation.concepts.themes.open_dialog'.tr(),
                      ),
                    ),
                    FButton(
                      mainAxisSize: MainAxisSize.min,
                      builder: _flexibleButtonLabel,
                      variant: .destructive,
                      onPress: null,
                      child: Text('common.error_title'.tr()),
                    ),
                    FButton(
                      key: const ValueKey('theme-style-delta'),
                      mainAxisSize: MainAxisSize.min,
                      builder: _flexibleButtonLabel,
                      style: const .delta(
                        contentStyle: .delta(
                          padding: .add(EdgeInsets.symmetric(horizontal: 8)),
                        ),
                      ),
                      onPress: () {},
                      child: Text(
                        'examples.foundation.concepts.themes.style_delta'.tr(),
                      ),
                    ),
                    FButton(
                      key: const ValueKey('theme-style-replacement'),
                      variant: .destructive,
                      size: .lg,
                      mainAxisSize: MainAxisSize.min,
                      builder: _flexibleButtonLabel,
                      style: context.theme.buttonStyles.outline.sm,
                      onPress: () {},
                      child: Text(
                        'examples.foundation.concepts.themes.style_replacement'
                            .tr(),
                      ),
                    ),
                  ],
                ),
                FTextField(
                  label: Text(
                    'examples.foundation.concepts.themes.input_label'.tr(),
                  ),
                  hint: 'examples.foundation.concepts.themes.input_hint'.tr(),
                ),
                FTileGroup(
                  children: [
                    FTile(
                      prefix: const Icon(FLucideIcons.palette),
                      title: Text(_presetLabel(preference.preset)),
                      subtitle: Text(_radiusLabel(preference.radius)),
                    ),
                  ],
                ),
                _StatusColors(),
                AGrid(
                  columns: 3,
                  surface: AGridSurface.outlined,
                  children: [
                    AGridItem(
                      icon: const Icon(FLucideIcons.house),
                      label: Text(
                        'examples.foundation.concepts.themes.grid_home'.tr(),
                      ),
                      selected: true,
                      onPress: () {},
                    ),
                    AGridItem(
                      icon: const Icon(FLucideIcons.bell),
                      label: Text(
                        'examples.foundation.concepts.themes.grid_alerts'.tr(),
                      ),
                      badge: AGridBadge.count(
                        3,
                        semanticsLabel: 'examples.foundation.layout.grid.playground.badge_count_semantics'
                            .tr(namedArgs: {'count': '3'}),
                      ),
                      onPress: () {},
                    ),
                    AGridItem(
                      icon: const Icon(FLucideIcons.settings),
                      label: Text(
                        'examples.foundation.concepts.themes.grid_settings'
                            .tr(),
                      ),
                      onPress: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          PlaygroundActionBar(
            resetLabel: 'settings.reset'.tr(),
            enabled: !saving,
            onReset: _reset,
          ),
        ],
      );

  Future<void> _save(AppAppearancePreference preference) async {
    try {
      final saved = await ref
          .read(appAppearanceProvider.notifier)
          .savePreference(preference);
      if (mounted && saved) {
        showFToast(
          context: context,
          alignment: .bottomCenter,
          title: Text('common.saved'.tr()),
        );
      }
    } on Object {
      if (mounted) {
        showFToast(
          context: context,
          alignment: .bottomCenter,
          variant: FToastVariant.destructive,
          title: Text('common.save_failed'.tr()),
        );
      }
    }
  }

  Future<void> _reset() async {
    setState(() => _selected = true);
    await _save(AppAppearancePreference.defaults);
  }

  Future<void> _showPreviewDialog(BuildContext context) => showFDialog<void>(
    context: context,
    useSafeArea: true,
    builder: (dialogContext, _, animation) => FDialog(
      animation: animation,
      semanticsLabel: 'examples.foundation.concepts.themes.dialog_title'.tr(),
      builder: (_, style) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text(
              'examples.foundation.concepts.themes.dialog_title'.tr(),
              style: style.titleTextStyle,
            ),
            Text(
              'examples.foundation.concepts.themes.dialog_body'.tr(),
              style: style.bodyTextStyle,
            ),
            FButton(
              onPress: () => Navigator.of(dialogContext).pop(),
              child: Text('common.confirm'.tr()),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ChoiceSection<T extends Enum> extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.groupKey,
    required this.enabled,
    required this.value,
    required this.values,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final String groupKey;
  final bool enabled;
  final T value;
  final List<T> values;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      Text(title, style: context.theme.typography.body.md),
      FSelectTileGroup<T>(
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
              key: ValueKey('$groupKey-${option.name}'),
              title: Text(label(option)),
              value: option,
            ),
        ],
      ),
    ],
  );
}

class _StatusColors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      spacing: 8,
      children: [
        _ColorSample(label: 'Primary', color: colors.primary),
        _ColorSample(label: 'Muted', color: colors.muted),
        _ColorSample(label: 'Error', color: colors.error),
      ],
    );
  }
}

class _ColorSample extends StatelessWidget {
  const _ColorSample({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      label: label,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: context.theme.colors.border),
          borderRadius: context.theme.style.borderRadius.sm,
        ),
      ),
    ),
  );
}

Widget _flexibleButtonLabel(
  BuildContext context,
  FButtonStyle style,
  TextStyle textStyle,
  IconThemeData iconStyle,
  FCircularProgressStyle progressStyle,
  Widget? child,
) => Flexible(child: child!);

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
