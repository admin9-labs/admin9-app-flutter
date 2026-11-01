import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_provider.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_repository.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_service.dart';
import 'package:admin9_app_flutter/app/session/session_store.dart';
import 'package:admin9_app_flutter/app/startup/startup_metrics.dart';
import 'package:admin9_app_flutter/app/startup/startup_preferences.dart';
import 'package:admin9_app_flutter/app/startup/startup_preferences_repository.dart';
import 'package:admin9_app_flutter/app/startup/startup_preferences_service.dart';
import 'package:admin9_app_flutter/app/startup/startup_provider.dart';
import 'package:admin9_app_flutter/app/startup/startup_state.dart';
import 'package:admin9_app_flutter/features/authentication/data/local_authentication_gateway.dart';
import 'package:admin9_app_flutter/features/authentication/domain/authentication_state.dart';
import 'package:admin9_app_flutter/features/authentication/presentation/pages/login_page.dart';
import 'package:admin9_app_flutter/features/authentication/presentation/pages/register_page.dart';
import 'package:admin9_app_flutter/features/authentication/presentation/providers/authentication_provider.dart';
import 'package:admin9_app_flutter/features/home/presentation/pages/home_page.dart';
import 'package:admin9_app_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/models/startup_ad_campaign.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/repositories/cached_startup_ad_repository.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/services/startup_ad_cache.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/services/startup_ad_service.dart';
import 'package:admin9_app_flutter/features/startup_ad/presentation/pages/startup_ad_page.dart';
import 'package:admin9_app_flutter/features/startup_ad/presentation/providers/startup_ad_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

// Device integration of the real local Starter auth/preferences/cache, with
// test-only HTTP and provider wiring. This is not backend/service acceptance,
// native bootstrap acceptance, or OS process-death restoration evidence.
// An unconfigured production build has a disabled ad repository. Only these
// tests inject a CachedStartupAdRepository; no endpoint build flags are needed.
// Capture PNGs on the host with:
// SHOWROOM_SCREENSHOT_DIR=build/ui_evidence/starter_contract flutter drive \
//   --driver=test_driver/showroom_screenshot_driver.dart \
//   --target=integration_test/starter_contract_test.dart -d <device-id>
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(EasyLocalization.ensureInitialized);

  testWidgets('first launch, auth return, logout and persisted App rebuild', (
    tester,
  ) async {
    await _withFixture(tester, binding, (fixture) async {
      var container = await fixture.mount(tester);
      await _until(tester, () => _key('privacy-page').evaluate().isNotEmpty);
      expect(find.byType(StartupAdPage), findsNothing);
      await fixture.screenshot(tester, '01_privacy');
      await _tap(tester, 'privacy-accept');

      for (var index = 0; index < 3; index++) {
        await _until(
          tester,
          () =>
              _key('onboarding-image-$index')
                  .hitTestable()
                  .evaluate()
                  .isNotEmpty,
        );
        await tester.pumpAndSettle();
        expect(_key('onboarding-skip'), findsOneWidget);
        expect(find.byType(StartupAdPage), findsNothing);
        await fixture.screenshot(tester, '02_onboarding_${index + 1}');
        await _tap(tester, 'onboarding-next');
      }
      await _home(tester);
      expect(fixture.phases, isNot(contains(StartupPhase.startupAd)));
      expect((await fixture.startup.load()).exposures, isEmpty);
      // A valid cached candidate was present before privacy. Home's test-only
      // 204 refresh removes it, so the rebuild can test session restoration.
      await _until(
        tester,
        () async => await fixture.cache.readValidated() == null,
      );
      await fixture.screenshot(tester, '03_first_home');

      await tester.tap(
        find.descendant(
          of: find.byType(FBottomNavigationBar),
          matching: find.text('设置'),
        ),
      );
      await _until(
        tester,
        () => _key('settings-account').evaluate().isNotEmpty,
      );
      await _until(
        tester,
        () =>
            container.read(authenticationProvider).status ==
            AuthenticationStatus.signedOut,
      );
      final originalSettings = tester.element(find.byType(SettingsPage));
      await _tap(tester, 'settings-account');
      await _until(tester, () => find.byType(LoginPage).evaluate().isNotEmpty);
      await _tap(tester, 'authentication-switch-mode');
      await _until(
        tester,
        () => find.byType(RegisterPage).evaluate().isNotEmpty,
      );
      await _submitCredentials(tester, fixture.identifier);
      await _signedInSettings(tester, fixture.identifier);
      expect(tester.element(find.byType(SettingsPage)), same(originalSettings));
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(RegisterPage), findsNothing);
      final registered = await SharedPreferencesSessionStore(
        SharedPreferencesAsync(),
      ).read();
      expect(registered?.identifier, fixture.identifier);
      await fixture.screenshot(tester, '04_registered_settings');

      await _tap(tester, 'authentication-logout');
      await _until(
        tester,
        () =>
            container.read(authenticationProvider).status ==
            AuthenticationStatus.signedOut,
      );
      await tester.pump();
      expect(_key('authentication-logout'), findsNothing);
      expect(
        await SharedPreferencesSessionStore(SharedPreferencesAsync()).read(),
        isNull,
      );
      expect(tester.element(find.byType(SettingsPage)), same(originalSettings));
      await _tap(tester, 'settings-account');
      await _until(tester, () => find.byType(LoginPage).evaluate().isNotEmpty);
      await _submitCredentials(tester, fixture.identifier);
      await _signedInSettings(tester, fixture.identifier);
      expect(tester.element(find.byType(SettingsPage)), same(originalSettings));
      expect(
        container.read(authenticationProvider).session?.accountId,
        registered?.accountId,
      );

      final before = container
          .read(appAppearanceProvider)
          .requireValue
          .preference;
      final brightness = before.brightness == AppBrightnessPreference.dark
          ? AppBrightnessPreference.light
          : AppBrightnessPreference.dark;
      await _tap(tester, 'settings-brightness-${brightness.name}');
      await _until(tester, () {
        final state = container.read(appAppearanceProvider).requireValue;
        return !state.saving && state.preference.brightness == brightness;
      });
      final savedPreference = before.copyWith(brightness: brightness);
      expect(
        await SharedPreferencesAppAppearanceRepository(
          AppAppearanceService(SharedPreferencesAsync()),
        ).load(),
        savedPreference,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      container = await fixture.mount(tester);
      await _home(tester);
      await _until(
        tester,
        () =>
            container.read(authenticationProvider).status ==
                AuthenticationStatus.signedIn &&
            container.read(appAppearanceProvider).hasValue,
      );
      expect(
        container.read(authenticationProvider).session?.identifier,
        fixture.identifier,
      );
      expect(
        container.read(authenticationProvider).session?.accountId,
        registered?.accountId,
      );
      expect(
        container.read(appAppearanceProvider).requireValue.preference,
        savedPreference,
      );
      final startup = await SharedPreferencesStartupRepository(
        StartupPreferencesService(SharedPreferencesAsync()),
      ).load();
      expect(
        startup.privacyConsent?.policyVersion,
        currentPrivacyPolicyVersion,
      );
      expect(startup.onboardingVersion, currentOnboardingVersion);
      expect(_key('privacy-page'), findsNothing);
      expect(_key('onboarding-page'), findsNothing);
      await fixture.screenshot(tester, '05_restored_home');
      await tester.tap(
        find.descendant(
          of: find.byType(FBottomNavigationBar),
          matching: find.text('设置'),
        ),
      );
      await _signedInSettings(tester, fixture.identifier);
      await fixture.screenshot(tester, '06_restored_settings');
    }, firstLaunch: true);
  });

  testWidgets('cached advertisement can be skipped on its first UI frame', (
    tester,
  ) async {
    await _withFixture(tester, binding, (fixture) async {
      await fixture.mount(tester);
      // Deliberately do not settle, capture, or wait for countdown/image decode.
      await _until(tester, () => _key('startup-ad-skip').evaluate().isNotEmpty);
      expect(
        tester.widget<FButton>(_key('startup-ad-skip')).onPress,
        isNotNull,
      );
      await tester.tap(_key('startup-ad-skip'));
      await _home(tester);
      fixture.expectFinished('skip');
      await fixture.screenshot(tester, '07_immediate_skip_home');
    });
  });

  testWidgets(
    'cached advertisement ends automatically after its visible frame',
    (tester) async {
      await _withFixture(tester, binding, (fixture) async {
        await fixture.mount(tester);
        await fixture.waitForExposure(tester);
        await fixture.screenshot(tester, '08_cached_advertisement');
        await _home(tester);
        fixture.expectFinished('complete');
        expect(
          (await fixture.startup.load()).exposures[fixture
              .campaign
              .exposureKey],
          hasLength(1),
        );
        await fixture.screenshot(tester, '09_automatic_end_home');
      });
    },
  );

  testWidgets('background lifecycle ends advertisement and resume stays Home', (
    tester,
  ) async {
    await _withFixture(tester, binding, (fixture) async {
      final container = await fixture.mount(tester);
      await fixture.waitForExposure(tester);
      if (const bool.fromEnvironment('STARTER_OS_LIFECYCLE')) {
        final deadline = DateTime.now().add(const Duration(seconds: 30));
        Future<void> waitForOs(bool Function() condition) async {
          while (!condition()) {
            if (DateTime.now().isAfter(deadline)) {
              fail(
                'Host must background and resume the App within 30 seconds. '
                'Current lifecycleState: ${binding.lifecycleState}.',
              );
            }
            // Android may need a first frame while inactive before the window
            // gains focus and delivers resumed. Never pump while backgrounded.
            if (binding.lifecycleState == AppLifecycleState.inactive ||
                binding.lifecycleState == AppLifecycleState.resumed) {
              await tester.pump();
            }
            await Future<void>.delayed(const Duration(milliseconds: 25));
          }
        }

        final lifecycleListener = AppLifecycleListener(
          binding: binding,
          onStateChange: (state) => debugPrint(
            'STARTER_OS_LIFECYCLE_CHANGE '
            'at=${DateTime.now().toUtc().toIso8601String()} '
            'state=$state binding=${binding.lifecycleState}',
          ),
        );
        try {
          debugPrint(
            'STARTER_OS_LIFECYCLE_INITIAL state=${binding.lifecycleState}',
          );
          debugPrint('STARTER_AD_READY_FOR_OS_BACKGROUND');
          await waitForOs(
            () =>
                container.read(startupCoordinatorProvider).phase ==
                StartupPhase.ready,
          );
          // Reject an elapsed ad timer before waiting for foreground delivery.
          fixture.expectFinished('backgrounded');
          await waitForOs(
            () => binding.lifecycleState == AppLifecycleState.resumed,
          );
        } catch (_) {
          debugPrint(
            'STARTER_OS_LIFECYCLE_FAILURE state=${binding.lifecycleState}',
          );
          rethrow;
        } finally {
          lifecycleListener.dispose();
        }
      } else {
        // Default mode injects notifications; it does not claim OS acceptance.
        try {
          binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
          binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
          binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
          expect(
            container.read(startupCoordinatorProvider).phase,
            StartupPhase.ready,
          );
        } finally {
          binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
          binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
          binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        }
      }
      await _home(tester);
      fixture.expectFinished('backgrounded');
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(StartupAdPage), findsNothing);
      await fixture.screenshot(tester, '10_background_resume_home');
    });
  });

  testWidgets('corrupt cached media goes directly Home', (tester) async {
    await _withFixture(tester, binding, (fixture) async {
      final cached = (await fixture.cache.readValidated())!;
      final file = File(cached.media.localPath!);
      final bytes = await file.readAsBytes();
      bytes[bytes.length ~/ 2] ^= 0xff;
      await file.writeAsBytes(bytes, flush: true);
      // Keep length/signature intact so production SHA validation rejects it.
      await fixture.mount(tester);
      await _home(tester);
      expect(fixture.phases, isNot(contains(StartupPhase.startupAd)));
      expect(await fixture.cache.readValidated(), isNull);
      expect((await fixture.startup.load()).exposures, isEmpty);
      await fixture.screenshot(tester, '11_corrupt_cache_home');
    });
  });

  testWidgets('reduced motion renders the validated static video fallback', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    try {
      await _withFixture(tester, binding, (fixture) async {
        await fixture.mount(tester);
        await fixture.waitForExposure(tester);
        final image = tester.widget<Image>(
          find.descendant(
            of: find.byType(StartupAdPage),
            matching: find.byType(Image),
          ),
        );
        expect(image.semanticLabel, 'Integration static fallback');
        expect(
          (image.image as FileImage).file.path,
          fixture.campaign.fallbackImage!.localPath,
        );
        expect(_key('startup-ad-mute'), findsNothing);
        await fixture.screenshot(tester, '12_reduced_motion_fallback');
        await _home(tester);
      }, video: true);
    } finally {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    }
  });

  testWidgets(
    'cached video plays muted or uses its deadline fallback, then ends',
    (tester) async {
      // Exercise native video even if the device normally requests less motion.
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: false);
      try {
        await _withFixture(tester, binding, (fixture) async {
          await fixture.mount(tester);
          final fallback = find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.semanticLabel == 'Integration static fallback',
          );
          await _until(
            tester,
            () =>
                find.byType(VideoPlayer).evaluate().isNotEmpty ||
                fallback.evaluate().isNotEmpty,
          );
          if (find.byType(VideoPlayer).evaluate().isNotEmpty) {
            final controller = tester
                .widget<VideoPlayer>(find.byType(VideoPlayer))
                .controller;
            await _until(
              tester,
              () =>
                  controller.value.isInitialized &&
                  controller.value.isPlaying &&
                  controller.value.position > Duration.zero,
            );
            expect(controller.value.hasError, isFalse);
            expect(controller.value.volume, 0);
            expect(controller.value.size, const Size(1280, 720));
            await fixture.waitForExposure(tester);
            expect(_key('startup-ad-mute'), findsOneWidget);
            await tester.tap(_key('startup-ad-mute'));
            await _until(tester, () => controller.value.volume == 1);
            expect(find.byType(VideoPlayer), findsOneWidget);
            debugPrint(
              'STARTER_NATIVE_VIDEO_OUTCOME=playing_muted_then_unmuted',
            );
            await fixture.screenshot(tester, '13_native_video_unmuted');
          } else {
            // A cold/slow native decoder is required to yield to the verified
            // static fallback, not extend the production 800ms deadline.
            await fixture.waitForExposure(tester);
            expect(fallback, findsOneWidget);
            expect(_key('startup-ad-mute'), findsNothing);
            debugPrint(
              'STARTER_NATIVE_VIDEO_OUTCOME=validated_static_fallback',
            );
            await fixture.screenshot(tester, '13_video_deadline_fallback');
          }
          await _home(tester);
          fixture.expectFinished('complete');
          expect(find.byType(VideoPlayer), findsNothing);
          expect(
            (await fixture.startup.load()).exposures[fixture
                .campaign
                .exposureKey],
            hasLength(1),
          );
          await fixture.screenshot(tester, '14_video_automatic_end_home');
        }, video: true);
      } finally {
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      }
    },
  );
}

Finder _key(String value) => find.byKey(ValueKey(value));

Future<void> _until(
  WidgetTester tester,
  FutureOr<bool> Function() condition,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 15));
  while (!await condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Starter contract condition was not met within 15 seconds.');
    }
    await tester.pump(const Duration(milliseconds: 25));
    expect(tester.takeException(), isNull);
  }
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.pumpAndSettle();
  await tester.tap(_key(key));
  await tester.pump();
}

Future<void> _home(WidgetTester tester) async {
  await _until(tester, () async => find.byType(HomePage).evaluate().isNotEmpty);
  await tester.pumpAndSettle();
  expect(find.byType(StartupAdPage), findsNothing);
  expect(_key('home-limited-mode'), findsNothing);
  expect(tester.takeException(), isNull);
}

Future<void> _signedInSettings(WidgetTester tester, String identifier) async {
  await _until(
    tester,
    () async => _key('authentication-logout').evaluate().isNotEmpty,
  );
  await tester.pumpAndSettle();
  expect(find.byType(SettingsPage), findsOneWidget);
  expect(find.text(identifier), findsOneWidget);
}

Future<void> _submitCredentials(WidgetTester tester, String identifier) async {
  await tester.pumpAndSettle();
  await tester.enterText(_key('authentication-identifier'), identifier);
  await tester.enterText(
    _key('authentication-password'),
    'Starter-contract-123',
  );
  // Dismiss the real IME without a navigation pop before scrolling to submit.
  FocusManager.instance.primaryFocus?.unfocus();
  await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  await _tap(tester, 'authentication-submit');
}

Future<void> _withFixture(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  Future<void> Function(_DeviceFixture) body, {
  bool firstLaunch = false,
  bool video = false,
}) async {
  final fixture = _DeviceFixture(binding);
  try {
    await fixture.prepare(firstLaunch: firstLaunch, video: video);
    await body(fixture);
    expect(tester.takeException(), isNull);
  } finally {
    try {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    } finally {
      await fixture.dispose();
    }
  }
}

final class _DeviceFixture {
  _DeviceFixture(this.binding);

  final IntegrationTestWidgetsFlutterBinding binding;
  final preferences = SharedPreferencesAsync();
  final secureStorage = const FlutterSecureStorage();
  final identifier =
      'starter-it-${DateTime.now().microsecondsSinceEpoch}@example.invalid';
  final _original = <String, String?>{};
  final phases = <StartupPhase>[];
  final metrics = _RecordedMetrics();
  Directory? _directory;
  MockClient? _client;
  bool _authentication = false;
  String? _originalSecureAccounts;
  String? _originalLegacyAccounts;
  bool _surfaceConverted = false;
  late StartupAdCache cache;
  late StartupAdCampaign campaign;
  late CachedStartupAdRepository repository;

  SharedPreferencesStartupRepository get startup =>
      SharedPreferencesStartupRepository(
        StartupPreferencesService(preferences),
      );

  Future<void> prepare({required bool firstLaunch, required bool video}) async {
    // No platform substitution or preferences.clear(): only the named Starter
    // record is reset. Session/appearance are restored after the auth UI test.
    for (final key in [
      StartupPreferencesService.key,
      if (firstLaunch) ...[
        SharedPreferencesSessionStore.key,
        AppAppearanceService.key,
      ],
    ]) {
      _original[key] = await preferences.getString(key);
    }
    if (firstLaunch) {
      _originalSecureAccounts = await secureStorage.read(
        key: LocalAuthenticationGateway.accountsKey,
      );
      _originalLegacyAccounts = await preferences.getString(
        LocalAuthenticationGateway.accountsKey,
      );
      if (_originalSecureAccounts != null) {
        expect(jsonDecode(_originalSecureAccounts!), isA<List<dynamic>>());
      }
      _authentication = true;
      await SharedPreferencesSessionStore(preferences).clear();
    }
    final now = DateTime.now().toUtc();
    await startup.save(
      firstLaunch
          ? const StartupPreferences()
          : StartupPreferences(
              privacyConsent: PrivacyConsentRecord(
                policyVersion: currentPrivacyPolicyVersion,
                acceptedAt: now,
              ),
              onboardingVersion: currentOnboardingVersion,
            ),
    );

    final photo = Uint8List.sublistView(
      await rootBundle.load('assets/images/onboarding/collaborate.jpg'),
    );
    final codec = await ui.instantiateImageCodec(photo);
    final frame = await codec.getNextFrame();
    final width = frame.image.width;
    final height = frame.image.height;
    frame.image.dispose();
    codec.dispose();
    final movie = video
        ? Uint8List.sublistView(
            await rootBundle.load('assets/media/admin9_video_fixture.mp4'),
          )
        : null;
    final image = StartupAdMedia(
      type: StartupAdMediaType.image,
      url: Uri.parse('https://starter-contract.invalid/photo.jpg'),
      mimeType: 'image/jpeg',
      byteLength: photo.length,
      width: width,
      height: height,
      sha256: sha256.convert(photo).toString(),
      semanticLabel: video
          ? 'Integration static fallback'
          : 'Integration cached photograph',
    );
    final candidate = StartupAdCampaign(
      schemaVersion: 1,
      placementId: StartupAdCampaign.placement,
      campaignId: 'starter-contract',
      creativeId: video ? 'video' : 'photograph',
      active: true,
      priority: 1,
      startsAt: now.subtract(const Duration(hours: 1)),
      endsAt: now.add(const Duration(hours: 1)),
      serverTime: now,
      updatedAt: now,
      freshUntil: now.add(const Duration(hours: 1)),
      displayDuration: const Duration(seconds: 5),
      frequencyCap: const StartupAdFrequencyCap(
        maxImpressions: 1,
        window: Duration(days: 1),
      ),
      platforms: const {'android', 'ios'},
      channels: {startupAdChannel},
      media: movie == null
          ? image
          : StartupAdMedia(
              type: StartupAdMediaType.video,
              url: Uri.parse('https://starter-contract.invalid/video.mp4'),
              mimeType: 'video/mp4',
              byteLength: movie.length,
              width: 1280,
              height: 720,
              sha256: sha256.convert(movie).toString(),
              semanticLabel: 'Integration bundled video',
              duration: const Duration(seconds: 8),
            ),
      fallbackImage: movie == null ? null : image,
      action: const StartupAdAction.none(),
    );
    _directory = await (await getTemporaryDirectory()).createTemp(
      'starter-contract-',
    );
    final client = MockClient((request) async {
      expect(request.url.host, 'starter-contract.invalid');
      if (request.url.path == '/placement') return http.Response('', 204);
      final (Uint8List bytes, String mime) = switch (request.url.path) {
        '/photo.jpg' => (photo, 'image/jpeg'),
        '/video.mp4' when movie != null => (movie, 'video/mp4'),
        _ => throw StateError(
          'Unexpected integration fixture URL: ${request.url}',
        ),
      };
      return http.Response.bytes(bytes, 200, headers: {'content-type': mime});
    });
    _client = client;
    cache = StartupAdCache(
      client: client,
      allowedMediaHosts: const {'starter-contract.invalid'},
      cacheDirectory: () async => _directory!,
    );
    await cache.store(candidate);
    final validated = await cache.readValidated();
    expect(validated, isNotNull);
    campaign = validated!;
    expect(
      campaign.isEligible(
        now: now,
        platform: Platform.isIOS ? 'ios' : 'android',
        appVersion: startupAdAppVersion,
        channel: startupAdChannel,
        exposures: const [],
      ),
      isTrue,
    );
    repository = CachedStartupAdRepository(
      service: HttpStartupAdService(
        client: client,
        endpoint: Uri.parse('https://starter-contract.invalid/placement'),
        allowedApiHosts: const {'starter-contract.invalid'},
        platform: Platform.isIOS ? 'ios' : 'android',
        appVersion: startupAdAppVersion,
        channel: startupAdChannel,
      ),
      cache: cache,
      platform: Platform.isIOS ? 'ios' : 'android',
      appVersion: startupAdAppVersion,
      channel: startupAdChannel,
    );
  }

  Future<ProviderContainer> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('zh', 'CN')],
        fallbackLocale: const Locale('zh', 'CN'),
        startLocale: const Locale('zh', 'CN'),
        path: 'assets/translations',
        saveLocale: false,
        child: ProviderScope(
          overrides: [
            startupAdRepositoryProvider.overrideWithValue(repository),
            startupMetricsSinkProvider.overrideWithValue(metrics),
          ],
          child: const Admin9App(),
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Admin9App)),
    );
    container.listen(
      startupCoordinatorProvider,
      (_, state) => phases.add(state.phase),
      fireImmediately: true,
    );
    return container;
  }

  Future<void> waitForExposure(WidgetTester tester) async {
    await _until(
      tester,
      () async =>
          (await startup.load()).exposures[campaign.exposureKey]?.length == 1,
    );
    expect(find.byType(StartupAdPage), findsOneWidget);
    expect(_key('startup-ad-skip'), findsOneWidget);
  }

  Future<void> screenshot(WidgetTester tester, String name) async {
    if (Platform.isAndroid && !_surfaceConverted) {
      await binding.convertFlutterSurfaceToImage();
      _surfaceConverted = true;
    }
    await tester.pump();
    final bytes = await binding.takeScreenshot('starter_contract_$name');
    expect(bytes, isNotEmpty);
  }

  void expectFinished(String reason) => expect(
    metrics.events
        .where((event) => event.name == StartupMetricName.campaignFinished)
        .map((event) => event.fields['reason']),
    [reason],
  );

  Future<void> dispose() async {
    try {
      if (_authentication) {
        if (_originalSecureAccounts == null) {
          await secureStorage.delete(
            key: LocalAuthenticationGateway.accountsKey,
          );
        } else {
          await secureStorage.write(
            key: LocalAuthenticationGateway.accountsKey,
            value: _originalSecureAccounts!,
          );
        }
        if (_originalLegacyAccounts == null) {
          await preferences.remove(LocalAuthenticationGateway.accountsKey);
        } else {
          await preferences.setString(
            LocalAuthenticationGateway.accountsKey,
            _originalLegacyAccounts!,
          );
        }
      }
    } finally {
      for (final entry in _original.entries) {
        if (entry.value == null) {
          await preferences.remove(entry.key);
        } else {
          await preferences.setString(entry.key, entry.value!);
        }
      }
      _client?.close();
      final directory = _directory;
      if (directory != null && await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  }
}

final class _RecordedMetrics implements StartupMetricsSink {
  final events = <StartupMetric>[];

  @override
  Future<void> record(StartupMetric metric) async => events.add(metric);
}
