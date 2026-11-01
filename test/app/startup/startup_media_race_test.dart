import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/features/startup_ad/data/models/startup_ad_campaign.dart';
import 'package:admin9_app_flutter/features/startup_ad/presentation/pages/startup_ad_page.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  late Map<String, dynamic> translations;
  late _ControlledVideoPlatform platform;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    translations = jsonDecode(
      File('assets/translations/zh-CN.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  });

  void installPlatform() {
    final original = VideoPlayerPlatform.instance;
    platform = _ControlledVideoPlatform();
    VideoPlayerPlatform.instance = platform;
    addTearDown(() => VideoPlayerPlatform.instance = original);
  }

  testWidgets(
    'successful fallback survives 800ms and records the campaign only once',
    (tester) async {
      installPlatform();
      final harness = await _mount(tester, translations);
      expect(platform.playStarted, isTrue);
      expect(harness.visible, 0);

      platform.playCompleted.complete();
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(find.byType(VideoPlayer), findsOneWidget);
      expect(find.byKey(const ValueKey('fake-video-surface')), findsOneWidget);
      expect(harness.visible, 1);

      await tester.pump(const Duration(milliseconds: 500));
      platform.failPlayback();
      tester.binding.scheduleFrame();
      await tester.pump();
      await tester.pump();
      _expectRenderedFallback(tester);

      await tester.pump(const Duration(milliseconds: 900));
      _expectRenderedFallback(tester);
      expect(harness.visible, 1);
      expect(harness.failed, 0);
      expect(harness.completed, 0);

      // The original five-second display period continues across the fallback.
      await tester.pump(const Duration(milliseconds: 3600));
      expect(harness.completed, 1);
      expect(harness.failed, 0);
      expect(harness.visible, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'error followed by play completion cannot count the blank transition frame',
    (tester) async {
      installPlatform();
      final harness = await _mount(tester, translations);
      expect(platform.playStarted, isTrue);
      expect(harness.visible, 0);
      expect(find.byType(VideoPlayer), findsNothing);

      // Deliver the platform error before the pending play acknowledgement,
      // without a frame between them. Fallback is selected at this frame's end.
      platform.failPlayback();
      platform.playCompleted.complete();
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(find.byType(VideoPlayer), findsNothing);
      expect(find.byType(RawImage), findsNothing);
      expect(harness.visible, 0);
      expect(harness.failed, 0);

      await tester.pump();
      _expectRenderedFallback(tester);
      expect(harness.visible, 1);
      await tester.pump(const Duration(milliseconds: 900));
      expect(harness.visible, 1);
      expect(harness.failed, 0);
      expect(harness.completed, 0);
      expect(tester.takeException(), isNull);
    },
  );
}

void _expectRenderedFallback(WidgetTester tester) {
  expect(find.byType(StartupAdPage), findsOneWidget);
  expect(find.byType(VideoPlayer), findsNothing);
  expect(
    tester.widget<Image>(find.byType(Image)).semanticLabel,
    'Static fallback',
  );
  expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
}

Future<_Callbacks> _mount(
  WidgetTester tester,
  Map<String, dynamic> translations,
) async {
  final child = ValueNotifier<Widget>(const SizedBox.expand());
  final callbacks = _Callbacks();
  final fallbackFile = File('assets/images/onboarding/read.jpg').absolute;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    child.dispose();
  });
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      assetLoader: _Translations(translations),
      saveLocale: false,
      child: _App(child: child),
    ),
  );
  await tester.pumpAndSettle();
  // Decode the real fallback before the race so filesystem timing cannot hide
  // which Flutter frame first paints it. The ad itself still uses Image.file.
  await tester.runAsync(
    () => precacheImage(
      FileImage(fallbackFile),
      tester.element(find.byKey(const ValueKey('media-race-host'))),
    ),
  );
  await tester.pump();
  child.value = StartupAdPage(
    campaign: _campaign(fallbackFile.path),
    onVisible: () async => callbacks.visible++,
    onFailure: () => callbacks.failed++,
    onCompleted: () => callbacks.completed++,
    onSkip: () => fail('Unexpected skip.'),
    onBackgrounded: () => fail('Unexpected background transition.'),
    onAction: (_) => fail('Unexpected ad action.'),
  );
  await tester.pump();
  await tester.pump();
  return callbacks;
}

final class _Callbacks {
  int visible = 0;
  int failed = 0;
  int completed = 0;
}

class _App extends StatelessWidget {
  const _App({required this.child});

  final ValueNotifier<Widget> child;

  @override
  Widget build(BuildContext context) => material.MaterialApp(
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: [
      ...context.localizationDelegates,
      ...material.GlobalMaterialLocalizations.delegates,
      FLocalizations.delegate,
    ],
    builder: (context, child) => FTheme(data: lightTheme, child: child!),
    home: MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: ValueListenableBuilder<Widget>(
        key: const ValueKey('media-race-host'),
        valueListenable: child,
        builder: (_, child, _) => child,
      ),
    ),
  );
}

class _Translations extends AssetLoader {
  const _Translations(this.values);

  final Map<String, dynamic> values;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => values;
}

final class _ControlledVideoPlatform extends VideoPlayerPlatform {
  final events = StreamController<VideoEvent>();
  final playCompleted = Completer<void>();
  bool playStarted = false;

  void failPlayback() => events.addError(
    PlatformException(
      code: 'VideoError',
      message: 'Controlled playback failure.',
    ),
  );

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    events.add(
      VideoEvent(
        eventType: VideoEventType.initialized,
        size: const Size(1080, 1920),
        duration: const Duration(seconds: 5),
      ),
    );
    return 1;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => events.stream;

  @override
  Future<void> play(int playerId) {
    playStarted = true;
    return playCompleted.future;
  }

  @override
  Future<void> dispose(int playerId) async {
    await events.close();
  }

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Widget buildViewWithOptions(VideoViewOptions options) => const ColoredBox(
    key: ValueKey('fake-video-surface'),
    color: Color(0xff336699),
  );
}

StartupAdCampaign _campaign(String fallbackPath) {
  final now = DateTime.utc(2026, 11, 1);
  return StartupAdCampaign(
    schemaVersion: 1,
    placementId: StartupAdCampaign.placement,
    campaignId: 'race-campaign',
    creativeId: 'race-creative',
    active: true,
    priority: 1,
    startsAt: now,
    endsAt: now.add(const Duration(days: 1)),
    serverTime: now,
    updatedAt: now,
    freshUntil: now.add(const Duration(hours: 1)),
    displayDuration: const Duration(seconds: 5),
    frequencyCap: const StartupAdFrequencyCap(
      maxImpressions: 1,
      window: Duration(days: 1),
    ),
    platforms: const {'android', 'ios'},
    channels: const {'official'},
    media: StartupAdMedia(
      type: StartupAdMediaType.video,
      url: Uri.parse('https://cdn.example.com/video.mp4'),
      mimeType: 'video/mp4',
      byteLength: 1,
      width: 1080,
      height: 1920,
      sha256: 'a' * 64,
      semanticLabel: 'Video creative',
      duration: const Duration(seconds: 5),
      localPath: '/cached/race-video.mp4',
    ),
    fallbackImage: StartupAdMedia(
      type: StartupAdMediaType.image,
      url: Uri.parse('https://cdn.example.com/fallback.jpg'),
      mimeType: 'image/jpeg',
      byteLength: 1,
      width: 1080,
      height: 1920,
      sha256: 'b' * 64,
      semanticLabel: 'Static fallback',
      localPath: fallbackPath,
    ),
    action: const StartupAdAction.none(),
  );
}
