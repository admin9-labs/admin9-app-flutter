import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../models/media_scenario.dart';
import 'media_audio_policy.dart';

final class MediaAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  MediaAudioHandler() : _player = AudioPlayer(handleInterruptions: false) {
    _subscriptions.add(
      _player.playbackEventStream.listen(
        (event) => playbackState.add(_transform(event)),
        onError: (Object error, StackTrace stackTrace) {
          playbackState.add(
            playbackState.value.copyWith(
              processingState: AudioProcessingState.error,
              errorMessage: error.toString(),
            ),
          );
        },
      ),
    );
    _subscriptions.add(
      _player.currentIndexStream.listen((index) {
        final items = queue.value;
        if (index != null && index >= 0 && index < items.length) {
          mediaItem.add(items[index].copyWith(duration: _player.duration));
        }
      }),
    );
    unawaited(_configureAudioSession());
  }

  final AudioPlayer _player;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final MediaAudioPolicy _policy = MediaAudioPolicy();
  String? _loadedSignature;

  Stream<Duration> get positionStream => _player.positionStream;

  Future<void> load(
    List<AudioScenario> scenarios, {
    required String initialId,
  }) async {
    final signature = scenarios.map((item) => item.id).join('|');
    final initialIndex = scenarios.indexWhere((item) => item.id == initialId);
    if (_loadedSignature == signature) {
      if (initialIndex >= 0 && initialIndex != _player.currentIndex) {
        await skipToQueueItem(initialIndex);
      }
      return;
    }
    final items = [
      for (final scenario in scenarios)
        MediaItem(
          id: scenario.id,
          title: scenario.title,
          artist: scenario.artist,
          album: 'Admin9 媒体中心',
          extras: {'location': scenario.location, 'isLive': scenario.isLive},
        ),
    ];
    final sources = [
      for (final scenario in scenarios)
        if (scenario.location.startsWith('assets/'))
          AudioSource.asset(scenario.location)
        else
          AudioSource.uri(Uri.parse(scenario.location)),
    ];
    queue.add(items);
    await _player.setAudioSources(
      sources,
      initialIndex: initialIndex < 0 ? 0 : initialIndex,
    );
    _loadedSignature = signature;
    final index = _player.currentIndex ?? 0;
    mediaItem.add(items[index].copyWith(duration: _player.duration));
  }

  bool isLive(MediaItem? item) => item?.extras?['isLive'] == true;

  @override
  Future<void> play() async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero, index: _player.currentIndex);
    }
    await _player.play();
  }

  @override
  Future<void> pause() async {
    _policy.userPauseOrNoisy();
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    await _player.seek(Duration.zero, index: index);
    mediaItem.add(queue.value[index].copyWith(duration: _player.duration));
  }

  @override
  Future<void> skipToNext() async {
    final index = _policy.nextIndex(
      current: _player.currentIndex,
      length: queue.value.length,
    );
    if (index != null) await skipToQueueItem(index);
  }

  @override
  Future<void> skipToPrevious() async {
    final index = _policy.previousIndex(
      current: _player.currentIndex,
      length: queue.value.length,
    );
    if (index != null) await skipToQueueItem(index);
  }

  @override
  Future<void> stop() async {
    _policy.userPauseOrNoisy();
    await _player.stop();
    await super.stop();
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _subscriptions.add(
      session.interruptionEventStream.listen((event) async {
        final kind = switch (event.type) {
          AudioInterruptionType.duck => MediaAudioInterruptionKind.duck,
          AudioInterruptionType.pause => MediaAudioInterruptionKind.pause,
          AudioInterruptionType.unknown => MediaAudioInterruptionKind.unknown,
        };
        final action = event.begin
            ? _policy.begin(kind, playing: _player.playing)
            : _policy.end(kind);
        await _applyPolicyAction(action);
      }),
    );
    _subscriptions.add(
      session.becomingNoisyEventStream.listen((_) async {
        await _applyPolicyAction(_policy.userPauseOrNoisy());
      }),
    );
  }

  Future<void> _applyPolicyAction(MediaAudioPolicyAction action) async {
    switch (action) {
      case MediaAudioPolicyAction.none:
        return;
      case MediaAudioPolicyAction.duck:
        await _player.setVolume(0.35);
      case MediaAudioPolicyAction.pause:
        await _player.pause();
      case MediaAudioPolicyAction.restoreVolume:
        await _player.setVolume(1);
      case MediaAudioPolicyAction.resume:
        await _player.play();
    }
  }

  PlaybackState _transform(PlaybackEvent event) => PlaybackState(
    controls: [
      MediaControl.skipToPrevious,
      if (_player.playing) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
    ],
    systemActions: isLive(mediaItem.value)
        ? const {}
        : const {MediaAction.seek},
    androidCompactActionIndices: const [0, 1, 2],
    processingState: switch (_player.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    },
    playing:
        _player.playing && _player.processingState != ProcessingState.completed,
    updatePosition: _player.position,
    bufferedPosition: _player.bufferedPosition,
    speed: _player.speed,
    queueIndex: event.currentIndex,
  );
}
