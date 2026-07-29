import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/branding/app_brand.dart';
import '../core/lifecycle/app_lifecycle_controller.dart';
import '../core/navigation/app_routes.dart';
import '../core/preferences/app_preferences.dart';
import '../core/theme/app_appearance.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/appearance_controller.dart';
import '../ui/features/account/view_models/session_controller.dart';
import 'admin9_shell.dart';
import 'privacy_gate.dart';

class Admin9App extends StatelessWidget {
  const Admin9App({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final appPreferences = AppPreferences(preferences);
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
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppBrand.name,
            theme: AppTheme.light(
              highContrast: appearance.highContrast,
              reduceMotion: appearance.reduceMotion,
            ),
            darkTheme: AppTheme.dark(
              highContrast: appearance.highContrast,
              reduceMotion: appearance.reduceMotion,
            ),
            themeMode: appearance.theme.themeMode,
            themeAnimationDuration: appearance.reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 200),
            onGenerateRoute: AppRoutes.onGenerateRoute,
            builder: (context, child) {
              final media = MediaQuery.of(context);
              Widget content = MediaQuery(
                data: media.copyWith(
                  textScaler: AppTextScaler(
                    system: media.textScaler,
                    preferenceFactor: appearance.fontScale.factor,
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
              if (appearance.grayscale) {
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
}
