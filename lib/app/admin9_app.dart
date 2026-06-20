import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/appearance_controller.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/live_stream_player.dart';
import '../data/repositories/channel_repository.dart';
import '../data/repositories/foundation_repository.dart';
import '../data/repositories/home_content_repository.dart';
import '../data/repositories/live_repository.dart';
import '../data/repositories/points_repository.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/service_repository.dart';
import '../data/repositories/splash_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/local_storage_service.dart';
import '../ui/features/home/view_models/channel_view_model.dart';
import '../ui/features/home/views/channel_h5_tab.dart';
import '../ui/features/mine/view_models/session_view_model.dart';
import '../ui/features/splash/view_models/launch_view_model.dart';
import '../ui/features/splash/view_models/splash_view_model.dart';
import '../ui/features/splash/views/launch_gate.dart';
import '../ui/features/splash/views/splash_gate.dart';
import '../ui/shared/app_state_controller.dart';
import 'admin9_shell.dart';

class Admin9App extends StatelessWidget {
  const Admin9App({
    super.key,
    required this.preferences,
    this.channelH5WebViewBuilder = ChannelH5Tab.defaultWebViewBuilder,
    this.liveStreamPlayerBuilder,
  });

  final SharedPreferences preferences;
  final ChannelH5WebViewBuilder channelH5WebViewBuilder;
  final LiveStreamPlayerBuilder? liveStreamPlayerBuilder;

  @override
  Widget build(BuildContext context) {
    final storage = LocalStorageService(preferences);

    return MultiProvider(
      providers: [
        Provider.value(value: storage),
        ChangeNotifierProvider(
          create: (_) => AppearanceController(storage: storage),
        ),
        Provider(create: (_) => const HomeContentRepository()),
        Provider(create: (_) => const FoundationRepository()),
        Provider(create: (_) => const LiveRepository()),
        Provider(create: (_) => const PointsRepository()),
        Provider(create: (_) => const ReportRepository()),
        Provider(create: (_) => const ServiceRepository()),
        Provider(create: (_) => const UserRepository()),
        Provider(
          create: (context) =>
              SplashRepository(context.read<LocalStorageService>()),
        ),
        Provider(
          create: (context) =>
              ChannelRepository(storage: context.read<LocalStorageService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ChannelViewModel(repository: context.read<ChannelRepository>())
                ..loadChannels(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              SessionViewModel(repository: context.read<UserRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              LaunchViewModel(storage: context.read<LocalStorageService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              SplashViewModel(repository: context.read<SplashRepository>()),
        ),
        ChangeNotifierProxyProvider<SessionViewModel, AppStateController>(
          create: (context) => AppStateController(
            storage: context.read<LocalStorageService>(),
            pointsRepository: context.read<PointsRepository>(),
          ),
          update: (_, session, state) =>
              state!..setPointsUserKey(session.user?.phone),
        ),
      ],
      child: Consumer<AppearanceController>(
        builder: (context, appearance, _) {
          final settings = appearance.settings;
          final brand = appearance.brand;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: '西昌发布',
            theme: AppTheme.light(brand: brand, fontLevel: settings.fontLevel),
            darkTheme: AppTheme.dark(
              brand: brand,
              fontLevel: settings.fontLevel,
            ),
            themeMode: settings.themeMode.materialMode,
            builder: (context, child) {
              final launch = context.watch<LaunchViewModel>();
              final content = SplashGate(
                showOnFirstBuild: launch.canShowSplashThisLaunch,
                canShowOnResume:
                    launch.privacyAccepted && launch.onboardingCompleted,
                onResumeWithoutContent: () {
                  if (!kIsWeb &&
                      launch.privacyAccepted &&
                      launch.onboardingCompleted) {
                    launch.preloadSplash(context.read<SplashRepository>());
                  }
                },
                child: child ?? const SizedBox.shrink(),
              );
              if (!settings.grayscale) return content;

              return ColorFiltered(
                key: const Key('global-grayscale-filter'),
                colorFilter: const ColorFilter.matrix(<double>[
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
            },
            home: LaunchGate(
              child: Admin9Shell(
                channelH5WebViewBuilder: channelH5WebViewBuilder,
                liveStreamPlayerBuilder: liveStreamPlayerBuilder,
              ),
            ),
          );
        },
      ),
    );
  }
}
