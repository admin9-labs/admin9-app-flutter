import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';

import 'package:admin9_app_flutter/core/theme/app_appearance.dart';
import 'package:admin9_app_flutter/core/theme/app_theme.dart';
import 'package:admin9_app_flutter/core/widgets/live_stream_player.dart';

void main() {
  tearDown(LiveStreamPlayer.resetControllerFactory);

  testWidgets('LiveStreamPlayer catches malformed URLs in error UI', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const LiveStreamPlayer(
          config: LiveStreamPlayerConfig(url: 'http://[', title: '坏地址'),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('直播加载失败'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '重试'), findsOneWidget);
  });

  testWidgets('LiveStreamPlayer catches controller construction errors', (
    tester,
  ) async {
    LiveStreamPlayer.controllerFactory = (_) {
      throw StateError('factory failed');
    };

    await tester.pumpWidget(
      _harness(
        const LiveStreamPlayer(
          config: LiveStreamPlayerConfig(
            url: 'https://example.com/live.m3u8',
            title: '构造失败',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('直播加载失败'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '重试'), findsOneWidget);
  });

  testWidgets(
    'LiveStreamPlayer ignores stale initialization after URL switch',
    (tester) async {
      final controllers = <_FakeLiveVideoController>[];
      LiveStreamPlayer.controllerFactory = (uri) {
        final controller = _FakeLiveVideoController(uri.toString());
        controllers.add(controller);
        return controller;
      };

      await tester.pumpWidget(
        _harness(
          const LiveStreamPlayer(
            config: LiveStreamPlayerConfig(
              url: 'https://example.com/first.m3u8',
              title: '第一路',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(controllers, hasLength(1));
      expect(controllers.single.disposeCount, 0);

      await tester.pumpWidget(
        _harness(
          const LiveStreamPlayer(
            config: LiveStreamPlayerConfig(
              url: 'https://example.com/second.m3u8',
              title: '第二路',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(controllers, hasLength(2));
      expect(controllers[0].disposeCount, 1);

      controllers[0].completeInitialize();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(controllers[0].playCount, 0);
      expect(
        find.byKey(const Key('fake-video-https://example.com/first.m3u8')),
        findsNothing,
      );

      controllers[1].completeInitialize();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(controllers[1].loopingValues, [true]);
      expect(controllers[1].volumeValues, [1]);
      expect(controllers[1].playCount, 1);
      expect(
        find.byKey(const Key('fake-video-https://example.com/second.m3u8')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'LiveStreamPlayer cancels pending owned controller on builder switch',
    (tester) async {
      final controllers = <_FakeLiveVideoController>[];
      LiveStreamPlayer.controllerFactory = (uri) {
        final controller = _FakeLiveVideoController(uri.toString());
        controllers.add(controller);
        return controller;
      };

      await tester.pumpWidget(
        _harness(
          const LiveStreamPlayer(
            config: LiveStreamPlayerConfig(
              url: 'https://example.com/pending.m3u8',
              title: '待取消',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(controllers, hasLength(1));

      await tester.pumpWidget(
        _harness(
          LiveStreamPlayer(
            config: const LiveStreamPlayerConfig(
              url: 'https://example.com/pending.m3u8',
              title: '待取消',
            ),
            builder: (context, config, muted, onMutedChanged) {
              return const ColoredBox(
                key: Key('external-live-player'),
                color: Colors.black,
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(controllers.single.disposeCount, 1);
      controllers.single.completeInitialize();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(controllers.single.playCount, 0);
      expect(find.byKey(const Key('external-live-player')), findsOneWidget);
    },
  );

  testWidgets(
    'LiveStreamPlayer disposal during init does not update stale state',
    (tester) async {
      final controllers = <_FakeLiveVideoController>[];
      LiveStreamPlayer.controllerFactory = (uri) {
        final controller = _FakeLiveVideoController(uri.toString());
        controllers.add(controller);
        return controller;
      };

      await tester.pumpWidget(
        _harness(
          const LiveStreamPlayer(
            config: LiveStreamPlayerConfig(
              url: 'https://example.com/dispose.m3u8',
              title: '待销毁',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(controllers, hasLength(1));

      await tester.pumpWidget(_harness(const SizedBox.shrink()));
      await tester.pump();
      expect(controllers.single.disposeCount, 1);

      controllers.single.completeInitialize();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(controllers.single.playCount, 0);
      expect(
        find.byKey(const Key('fake-video-https://example.com/dispose.m3u8')),
        findsNothing,
      );
    },
  );

  testWidgets('LiveStreamPlayer error path disposes failed controller', (
    tester,
  ) async {
    late _FakeLiveVideoController controller;
    LiveStreamPlayer.controllerFactory = (uri) {
      controller = _FakeLiveVideoController(uri.toString());
      return controller;
    };

    await tester.pumpWidget(
      _harness(
        const LiveStreamPlayer(
          config: LiveStreamPlayerConfig(
            url: 'https://example.com/fail.m3u8',
            title: '初始化失败',
          ),
        ),
      ),
    );
    await tester.pump();

    controller.failInitialize(StateError('init failed'));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(controller.disposeCount, 1);
    expect(find.text('直播加载失败'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '重试'), findsOneWidget);
  });
}

Widget _harness(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(
      brand: AppBrand.newsBlueBrand,
      fontLevel: AppFontLevel.standard,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

class _FakeLiveVideoController implements LiveVideoController {
  _FakeLiveVideoController(this.id);

  final String id;
  final _initializeCompleter = Completer<void>();
  var _disposed = false;
  var _initialized = false;
  var disposeCount = 0;
  var playCount = 0;
  final loopingValues = <bool>[];
  final volumeValues = <double>[];

  @override
  VideoPlayerValue get value => VideoPlayerValue(
    duration: const Duration(minutes: 1),
    size: const Size(160, 90),
    isInitialized: _initialized,
  );

  @override
  Future<void> initialize() async {
    await _initializeCompleter.future;
    _initialized = true;
  }

  void completeInitialize() {
    if (!_initializeCompleter.isCompleted) {
      _initializeCompleter.complete();
    }
  }

  void failInitialize(Object error) {
    if (!_initializeCompleter.isCompleted) {
      _initializeCompleter.completeError(error);
    }
  }

  @override
  Future<void> setLooping(bool looping) async {
    loopingValues.add(looping);
  }

  @override
  Future<void> setVolume(double volume) async {
    volumeValues.add(volume);
  }

  @override
  Future<void> play() async {
    playCount++;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    disposeCount++;
  }

  @override
  Widget buildView() {
    return ColoredBox(key: Key('fake-video-$id'), color: Colors.black);
  }
}
