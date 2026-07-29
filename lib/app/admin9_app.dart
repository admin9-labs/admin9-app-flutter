import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin9_ui.dart';
import '../core/design_system/foundation/app_theme.dart';
import '../core/lifecycle/app_lifecycle_controller.dart';
import '../core/preferences/app_preferences.dart';
import '../core/theme/app_appearance.dart';
import '../core/theme/appearance_controller.dart';
import '../ui/features/account/view_models/session_controller.dart';
import 'admin9_shell.dart';
import 'app_routes.dart';
import 'app_identity.dart';
import 'privacy_gate.dart';
import 'brand/app_brand_theme.dart';

class Admin9App extends StatefulWidget {
  const Admin9App({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  State<Admin9App> createState() => _Admin9AppState();
}

class _Admin9AppState extends State<Admin9App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAccessibilityFeatures() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appPreferences = AppPreferences(widget.preferences);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppearanceController(appPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => PrivacyController(appPreferences),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => AppLifecycleController(),
        ),
        ChangeNotifierProvider(create: (_) => SessionController()),
      ],
      child: Consumer<AppearanceController>(
        builder: (context, controller, _) {
          final appearance = controller.appearance;
          final light = _resolveTheme(
            brightness: Brightness.light,
            appearance: appearance,
          );
          final dark = _resolveTheme(
            brightness: Brightness.dark,
            appearance: appearance,
          );
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppIdentity.name,
            locale: const Locale('zh', 'CN'),
            supportedLocales: const [Locale('zh', 'CN')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: light.material,
            darkTheme: dark.material,
            themeMode: appearance.theme.themeMode,
            themeAnimationDuration:
                (appearance.reduceMotion ||
                    WidgetsBinding
                        .instance
                        .platformDispatcher
                        .accessibilityFeatures
                        .disableAnimations)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            onGenerateRoute: AppRouteFactory.onGenerateRoute,
            builder: (context, child) {
              final media = MediaQuery.of(context);
              final effective = EffectiveAppearance.resolve(
                app: appearance,
                system: media,
                resolvedBrightness: Theme.of(context).brightness,
              );
              final resolved = _resolveTheme(
                brightness: effective.brightness,
                appearance: appearance,
                highContrast: effective.highContrast,
                reduceMotion: effective.reduceMotion,
                boldText: effective.boldText,
              );
              Widget content = MediaQuery(
                data: media.copyWith(
                  textScaler: AppTextScaler(
                    system: media.textScaler,
                    preferenceFactor: effective.fontScale.factor,
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
              content = Theme(data: resolved.material, child: content);
              content = AppDesignScope(tokens: resolved.tokens, child: content);
              if (effective.grayscale) {
                content = ColorFiltered(
                  key: const Key('global-grayscale-filter'),
                  colorFilter: const ColorFilter.matrix([
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: content,
                );
              }
              return content;
            },
            home: const PrivacyGate(child: Admin9Shell()),
          );
        },
      ),
    );
  }

  AppResolvedTheme _resolveTheme({
    required Brightness brightness,
    required AppAppearance appearance,
    bool? highContrast,
    bool? reduceMotion,
    bool boldText = false,
  }) => AppTheme.resolve(
    brightness: brightness,
    highContrast: highContrast ?? appearance.highContrast,
    reduceMotion: reduceMotion ?? appearance.reduceMotion,
    boldText: boldText,
    brandPrimary: brightness == Brightness.dark
        ? appBrandTheme.primaryDark
        : appBrandTheme.primaryLight,
    brandSecondary: brightness == Brightness.dark
        ? appBrandTheme.secondaryDark
        : appBrandTheme.secondaryLight,
    brandFontFamily: appBrandTheme.fontFamily,
    brandRadiusDelta: appBrandTheme.radiusDelta,
  );
}
