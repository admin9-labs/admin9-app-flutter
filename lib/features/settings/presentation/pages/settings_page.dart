import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../shared/ui/component_example_section.dart';
import '../../../../shared/ui/error_state_view.dart';
import '../../../../shared/ui/loading_state_view.dart';
import '../../../../shared/ui/responsive_page_body.dart';
import '../../data/models/theme_preference.dart';
import '../providers/theme_preference_provider.dart';

@RoutePage()
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final preference = ref.watch(themePreferenceProvider);
    return Column(
      children: [
        FHeader(title: Text(context.tr('settings.title'))),
        Expanded(
          child: preference.when(
            data: (value) => _body(value),
            error: (error, stackTrace) => ErrorStateView(
              title: context.tr('common.error_title'),
              message: context.tr('settings.load_failed'),
              retryLabel: context.tr('common.retry'),
              onRetry: ref.read(themePreferenceProvider.notifier).reload,
            ),
            loading: () =>
                LoadingStateView(label: context.tr('common.loading')),
          ),
        ),
      ],
    );
  }

  Widget _body(ThemePreference preference) => ResponsivePageBody(
    children: [
      ComponentExampleSection(
        title: context.tr('settings.appearance'),
        description: context.tr('settings.theme_description'),
        child: FSelectTileGroup<ThemePreference>(
          key: ValueKey((preference, _saving)),
          enabled: !_saving,
          control: .managedRadio(
            initial: preference,
            onChange: (values) {
              if (values.length == 1) {
                _save(values.single);
              }
            },
          ),
          children: [
            FSelectTile(
              title: Text(context.tr('settings.theme_system')),
              value: ThemePreference.system,
            ),
            FSelectTile(
              title: Text(context.tr('settings.theme_light')),
              value: ThemePreference.light,
            ),
            FSelectTile(
              title: Text(context.tr('settings.theme_dark')),
              value: ThemePreference.dark,
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> _save(ThemePreference preference) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(themePreferenceProvider.notifier)
          .setPreference(preference);
      if (mounted) {
        showFToast(
          context: context,
          alignment: .bottomCenter,
          title: Text(context.tr('common.saved')),
        );
      }
    } on Object {
      if (mounted) {
        showFToast(
          context: context,
          alignment: .bottomCenter,
          variant: .destructive,
          title: Text(context.tr('common.save_failed')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
