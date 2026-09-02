import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/app/app_metadata.dart';
import 'package:admin9_app_flutter/app/routing/main_destination.dart';
import 'package:admin9_app_flutter/app/startup/startup_provider.dart';
import 'package:admin9_app_flutter/app/startup/startup_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final coordinator = ref.read(startupCoordinatorProvider.notifier);
        coordinator.markHomeInteractive();
        coordinator.refreshCampaign();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final startup = ref.watch(startupCoordinatorProvider);
    final theme = FTheme.of(context);
    return Column(
      children: [
        FHeader(
          title: Text(context.tr('home.title')),
          suffixes: [
            FHeaderAction(
              icon: const Icon(FLucideIcons.settings),
              semanticsLabel: context.tr('home.open_settings'),
              onPress: () => context.tabsRouter.setActiveIndex(
                MainDestination.settings.index,
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (startup.accessMode == AccessMode.limited)
                ColoredBox(
                  key: const ValueKey('home-limited-mode'),
                  color: theme.colors.muted,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        const Icon(FLucideIcons.shield),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6,
                            children: [
                              Text(
                                context.tr('home.limited_title'),
                                style: theme.typography.display.sm,
                              ),
                              Text(
                                context.tr('home.limited_body'),
                                style: theme.typography.body.sm,
                              ),
                              if (startup.persistenceWarning)
                                Text(
                                  context.tr('privacy.storage_warning'),
                                  key: const ValueKey(
                                    'home-privacy-storage-warning',
                                  ),
                                  style: theme.typography.body.sm.copyWith(
                                    color: theme.colors.destructive,
                                  ),
                                ),
                              FButton(
                                key: const ValueKey('home-review-privacy'),
                                variant: .outline,
                                mainAxisSize: MainAxisSize.min,
                                onPress: () {
                                  ref
                                      .read(startupCoordinatorProvider.notifier)
                                      .requestPrivacyReview();
                                  context.router.replaceAll([
                                    StartupGateRoute(reviewPrivacy: true),
                                  ]);
                                },
                                child: Text(context.tr('home.enable_full')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                context.tr('home.product_name'),
                key: const ValueKey('home-product-name'),
                style: theme.typography.display.lg,
              ),
              const SizedBox(height: 6),
              Text(
                context.tr(
                  'home.product_version',
                  namedArgs: {'version': admin9AppVersion},
                ),
                key: const ValueKey('home-product-version'),
                style: theme.typography.body.sm,
              ),
              const SizedBox(height: 24),
              // examples:begin
              Text(
                context.tr('home.components_title'),
                style: theme.typography.body.lg,
              ),
              const SizedBox(height: 10),
              FItemGroup(
                children: [
                  FItem(
                    key: const ValueKey('home-open-components'),
                    prefix: const Icon(FLucideIcons.layoutGrid),
                    title: Text(context.tr('home.components_grid')),
                    subtitle: Text(context.tr('home.components_grid_body')),
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: () => context.tabsRouter.setActiveIndex(
                      MainDestination.components.index,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // examples:end
              Text(
                context.tr('home.media_title'),
                style: theme.typography.body.lg,
              ),
              const SizedBox(height: 10),
              FItemGroup(
                children: [
                  FItem(
                    key: const ValueKey('home-open-media'),
                    prefix: const Icon(FLucideIcons.play),
                    title: Text(context.tr('home.media')),
                    subtitle: Text(context.tr('home.media_body')),
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: () => context.tabsRouter.setActiveIndex(
                      MainDestination.media.index,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('home.workspace'),
                style: theme.typography.body.lg,
              ),
              const SizedBox(height: 12),
              FItemGroup(
                divider: .indented,
                children: [
                  FItem(
                    key: const ValueKey('home-open-settings'),
                    prefix: const Icon(FLucideIcons.slidersHorizontal),
                    title: Text(context.tr('home.settings')),
                    subtitle: Text(context.tr('home.settings_body')),
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: () => context.tabsRouter.setActiveIndex(
                      MainDestination.settings.index,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
