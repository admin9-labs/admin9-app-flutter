import 'dart:io';

import 'package:admin9_app_flutter/app/startup/startup_preferences.dart';
import 'package:admin9_app_flutter/features/home/presentation/pages/home_page.dart';
import 'package:admin9_app_flutter/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:admin9_app_flutter/features/privacy/presentation/pages/privacy_page.dart';
import 'package:admin9_app_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/models/startup_ad_campaign.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/repositories/startup_ad_repository.dart';
import 'package:admin9_app_flutter/features/startup_ad/presentation/pages/startup_ad_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_admin9_app.dart';

void main() {
  testWidgets(
    'first launch accepts privacy, skips onboarding, and opens Home',
    (tester) async {
      final startup = FakeCompletedStartupRepository(
        preferences: const StartupPreferences(),
      );
      await pumpTestAdmin9App(tester, startupRepository: startup);

      expect(find.byType(PrivacyPage), findsOneWidget);
      expect(find.byType(StartupAdPage), findsNothing);

      await tester.tap(find.byKey(const ValueKey('privacy-accept')));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingPage), findsOneWidget);
      expect(find.text('准备完成'), findsNothing);
      expect(find.text('进入应用'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('onboarding-skip')));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byKey(const ValueKey('home-limited-mode')), findsNothing);
      expect(startup.value.onboardingVersion, 1);
    },
  );

  testWidgets('declining privacy reaches a useful limited Home', (
    tester,
  ) async {
    await pumpTestAdmin9App(
      tester,
      startupRepository: FakeCompletedStartupRepository(
        preferences: const StartupPreferences(),
      ),
      size: const Size(320, 844),
      textScale: 2,
    );

    await tester.tap(find.byKey(const ValueKey('privacy-limited')));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byKey(const ValueKey('home-limited-mode')), findsOneWidget);
    expect(find.text('媒体'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home opens Settings without stopping on the Showroom', (
    tester,
  ) async {
    await pumpTestAdmin9App(tester);

    await tester.tap(find.byKey(const ValueKey('home-open-settings')));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('privacy and onboarding remain usable at 320px and 2x text', (
    tester,
  ) async {
    await pumpTestAdmin9App(
      tester,
      startupRepository: FakeCompletedStartupRepository(
        preferences: const StartupPreferences(),
      ),
      size: const Size(320, 844),
      textScale: 2,
    );
    expect(find.byType(PrivacyPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('privacy-accept')));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('eligible media has an immediate skip and reaches Home', (
    tester,
  ) async {
    final preferences = FakeCompletedStartupRepository();
    await pumpTestAdmin9App(
      tester,
      startupRepository: preferences,
      startupAdRepository: _CampaignRepository(_campaign()),
    );

    expect(find.byType(StartupAdPage), findsOneWidget);
    expect(find.byKey(const ValueKey('startup-ad-skip')), findsOneWidget);
    expect(
      File('assets/images/onboarding/collaborate.jpg').existsSync(),
      isTrue,
    );
    await tester.tap(find.byKey(const ValueKey('startup-ad-skip')));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('reduced motion uses the static fallback before video starts', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpTestAdmin9App(
      tester,
      startupAdRepository: _CampaignRepository(_campaign(video: true)),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.semanticLabel, '静态备用图');
    expect(tester.takeException(), isNull);
  });
}

final class _CampaignRepository implements StartupAdRepository {
  const _CampaignRepository(this.campaign);

  final StartupAdCampaign campaign;

  @override
  Future<int> cacheSize() async => 0;

  @override
  Future<void> clearCache() async {}

  @override
  Future<StartupAdCampaign?> loadCachedEligible({
    required DateTime now,
    required String platform,
    required String appVersion,
    required String channel,
    required StartupPreferences preferences,
  }) async => campaign;

  @override
  Future<void> refresh() async {}
}

StartupAdCampaign _campaign({bool video = false}) {
  final now = DateTime.now().toUtc();
  return StartupAdCampaign(
    schemaVersion: 1,
    placementId: StartupAdCampaign.placement,
    campaignId: 'campaign',
    creativeId: 'creative',
    active: true,
    priority: 1,
    startsAt: now.subtract(const Duration(hours: 1)),
    endsAt: now.add(const Duration(hours: 1)),
    serverTime: now,
    updatedAt: now,
    freshUntil: now.add(const Duration(hours: 1)),
    displayDuration: const Duration(seconds: 3),
    frequencyCap: const StartupAdFrequencyCap(
      maxImpressions: 1,
      window: Duration(days: 1),
    ),
    platforms: const {'ios', 'android'},
    channels: const {'official'},
    media: StartupAdMedia(
      type: video ? StartupAdMediaType.video : StartupAdMediaType.image,
      url: Uri.parse(
        video
            ? 'https://cdn.example.com/creative.mp4'
            : 'https://cdn.example.com/creative.jpg',
      ),
      mimeType: video ? 'video/mp4' : 'image/jpeg',
      byteLength: 1,
      width: 1080,
      height: 1600,
      sha256: 'a' * 64,
      semanticLabel: '团队协作推广图',
      duration: video ? const Duration(seconds: 5) : null,
      localPath: video
          ? '/cache/creative.mp4'
          : File('assets/images/onboarding/collaborate.jpg').absolute.path,
    ),
    fallbackImage: video
        ? StartupAdMedia(
            type: StartupAdMediaType.image,
            url: Uri.parse('https://cdn.example.com/fallback.jpg'),
            mimeType: 'image/jpeg',
            byteLength: 1,
            width: 1080,
            height: 1600,
            sha256: 'b' * 64,
            semanticLabel: '静态备用图',
            localPath: File('assets/images/onboarding/read.jpg').absolute.path,
          )
        : null,
    action: const StartupAdAction.none(),
  );
}
