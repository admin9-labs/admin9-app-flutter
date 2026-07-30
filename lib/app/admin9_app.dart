import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin9_ui.dart';
import '../core/design_system/components/app_feedback.dart';
import '../core/design_system/components/app_interaction.dart';
import '../core/design_system/foundation/app_theme.dart';
import '../core/design_system/foundation/app_appearance_resolution.dart';
import '../core/design_system/foundation/appearance_controller.dart';
import '../core/lifecycle/app_lifecycle_controller.dart';
import '../core/preferences/app_preferences.dart';
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final AppFeedbackPresenterController _feedbackController =
      AppFeedbackPresenterController();
  late final AppInteractionPresenterController _interactionController =
      AppInteractionPresenterController(navigatorKey: _navigatorKey);

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
        ChangeNotifierProvider<AppAppearanceController>(
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
      child: Consumer<AppAppearanceController>(
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
            navigatorKey: _navigatorKey,
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
            themeMode: _themeMode(appearance.theme),
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
              content = AppFeedback(
                controller: _feedbackController,
                navigatorKey: _navigatorKey,
                child: content,
              );
              content = AppInteractionHost(
                controller: _interactionController,
                child: content,
              );
              content = AppDesignScope(tokens: resolved.tokens, child: content);
              content = ColorFiltered(
                key: const Key('global-grayscale-filter'),
                colorFilter: effective.grayscale
                    ? _grayscaleColorFilter
                    : _identityColorFilter,
                child: content,
              );
              return AnnotatedRegion<SystemUiOverlayStyle>(
                key: const Key('global-system-ui-style'),
                value: _systemUiStyle(effective.brightness),
                child: content,
              );
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

const _identityColorFilter = ColorFilter.matrix([
  1,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

const _grayscaleColorFilter = ColorFilter.matrix([
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
]);

SystemUiOverlayStyle _systemUiStyle(Brightness brightness) {
  final iconBrightness = brightness == Brightness.dark
      ? Brightness.light
      : Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: iconBrightness,
    statusBarBrightness: brightness,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: iconBrightness,
    systemNavigationBarContrastEnforced: true,
  );
}

ThemeMode _themeMode(AppThemePreference preference) => switch (preference) {
  AppThemePreference.system => ThemeMode.system,
  AppThemePreference.light => ThemeMode.light,
  AppThemePreference.dark => ThemeMode.dark,
};
