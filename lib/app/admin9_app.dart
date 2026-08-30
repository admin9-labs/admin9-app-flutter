import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../features/settings/data/models/theme_preference.dart';
import '../features/settings/presentation/providers/theme_preference_provider.dart';
import '../theme/theme.dart';
import 'routing/app_router.dart';

class Admin9App extends ConsumerStatefulWidget {
  const Admin9App({super.key});

  @override
  ConsumerState<Admin9App> createState() => _Admin9AppState();
}

class _Admin9AppState extends ConsumerState<Admin9App> {
  final AppRouter _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    final preference = ref
        .watch(themePreferenceProvider)
        .when(
          data: (value) => value,
          error: (error, stackTrace) => ThemePreference.system,
          loading: () => ThemePreference.system,
        );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.tr('app.name'),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: [
        ...context.localizationDelegates,
        ...GlobalMaterialLocalizations.delegates,
        FLocalizations.delegate,
      ],
      routerConfig: _router.config(),
      theme: lightTheme.toApproximateMaterialTheme(),
      darkTheme: darkTheme.toApproximateMaterialTheme(),
      themeMode: switch (preference) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      },
      builder: (context, child) {
        final theme = Theme.brightnessOf(context) == Brightness.light
            ? lightTheme
            : darkTheme;
        final toasterBottomOffset =
            (96 - MediaQuery.viewPaddingOf(context).bottom)
                .clamp(48, 96)
                .toDouble();
        return FTheme(
          data: theme,
          child: FToaster(
            style: .delta(
              padding: .add(EdgeInsets.only(bottom: toasterBottomOffset)),
            ),
            child: FTooltipGroup(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}
