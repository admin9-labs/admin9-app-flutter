import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/legal/domain/legal_document.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/privacy/presentation/pages/privacy_page.dart';
import '../../features/startup_ad/data/models/startup_ad_campaign.dart';
import '../../features/startup_ad/presentation/pages/startup_ad_page.dart';
import '../../features/startup_ad/presentation/providers/startup_ad_provider.dart';
import '../startup/initialization_view.dart';
import '../startup/startup_provider.dart';
import '../startup/startup_state.dart';
import 'app_router.gr.dart';
import 'main_destination.dart';

@RoutePage()
class StartupGatePage extends ConsumerStatefulWidget {
  const StartupGatePage({
    super.key,
    this.launchReason = LaunchReason.icon,
    this.initialPath,
    this.reviewPrivacy = false,
  });

  final LaunchReason launchReason;
  final String? initialPath;
  final bool reviewPrivacy;

  @override
  ConsumerState<StartupGatePage> createState() => _StartupGatePageState();
}

class _StartupGatePageState extends ConsumerState<StartupGatePage> {
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.reviewPrivacy) {
        ref.read(startupCoordinatorProvider.notifier).requestPrivacyReview();
      } else {
        ref
            .read(startupCoordinatorProvider.notifier)
            .begin(
              launchReason: widget.launchReason,
              pendingDestination: PendingDestination.fromPath(
                widget.initialPath,
              ),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startupCoordinatorProvider);
    return switch (state.phase) {
      StartupPhase.initializing => const InitializationView(),
      StartupPhase.privacy => PrivacyPage(
        persistenceWarning: state.persistenceWarning,
        onAccept: ref.read(startupCoordinatorProvider.notifier).acceptPrivacy,
        onContinueLimited: ref
            .read(startupCoordinatorProvider.notifier)
            .continueLimited,
        onOpenUserAgreement: () => context.pushRoute(
          LegalDocumentRoute(document: LegalDocument.userAgreement),
        ),
        onOpenPrivacyPolicy: () => context.pushRoute(
          LegalDocumentRoute(document: LegalDocument.privacyPolicy),
        ),
      ),
      StartupPhase.onboarding => OnboardingPage(
        onSkip: () => ref
            .read(startupCoordinatorProvider.notifier)
            .completeOnboarding(skipped: true),
        onComplete: () =>
            ref.read(startupCoordinatorProvider.notifier).completeOnboarding(),
      ),
      StartupPhase.startupAd => StartupAdPage(
        campaign: state.campaign!,
        onVisible: ref
            .read(startupCoordinatorProvider.notifier)
            .markCampaignVisible,
        onSkip: () => ref
            .read(startupCoordinatorProvider.notifier)
            .finishCampaign(reason: 'skip'),
        onAction: _openCampaignAction,
        onFailure: () => ref
            .read(startupCoordinatorProvider.notifier)
            .finishCampaign(reason: 'failure'),
      ),
      StartupPhase.ready => _finishNavigation(state),
    };
  }

  Widget _finishNavigation(StartupState state) {
    if (!_navigating) {
      _navigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.router.replaceAll(_routesFor(state.pendingDestination));
      });
    }
    return const InitializationView();
  }

  List<PageRouteInfo> _routesFor(PendingDestination? destination) =>
      switch (destination?.routeKey) {
        // examples:begin
        'components' => [
          MainShellRoute(initialDestination: MainDestination.components),
        ],
        // examples:end
        'media' => [MainShellRoute(initialDestination: MainDestination.media)],
        'settings' => [
          MainShellRoute(initialDestination: MainDestination.settings),
        ],
        _ => [MainShellRoute()],
      };

  Future<void> _openCampaignAction(StartupAdAction action) async {
    final coordinator = ref.read(startupCoordinatorProvider.notifier);
    switch (action.type) {
      case StartupAdActionType.none:
        coordinator.finishCampaign(reason: 'complete');
      case StartupAdActionType.internalRoute:
        coordinator.finishCampaign(
          destination: PendingDestination(
            routeKey: action.routeKey!,
            parameters: action.parameters,
          ),
          reason: 'click',
        );
      case StartupAdActionType.externalHttps:
        final url = action.url!;
        final allowed = ref.read(startupAdExternalHostsProvider);
        if (allowed.contains(url.host)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
        if (mounted) coordinator.finishCampaign(reason: 'click');
    }
  }
}
