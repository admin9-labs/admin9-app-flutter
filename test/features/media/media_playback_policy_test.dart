import 'package:admin9_app_flutter/features/media/data/services/media_audio_policy.dart';
import 'package:admin9_app_flutter/features/media/presentation/providers/media_video_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';

void main() {
  test(
    'video state maps loading, buffering, playing, completion, and errors',
    () {
      expect(
        MediaVideoState.fromValue(
          const VideoPlayerValue.uninitialized(),
          isLive: false,
        ).phase,
        MediaVideoPhase.loading,
      );
      expect(
        MediaVideoState.fromValue(
          const VideoPlayerValue(
            duration: Duration(seconds: 10),
            isInitialized: true,
            isBuffering: true,
          ),
          isLive: false,
        ).phase,
        MediaVideoPhase.buffering,
      );
      final playing = MediaVideoState.fromValue(
        const VideoPlayerValue(
          duration: Duration(seconds: 10),
          position: Duration(seconds: 3),
          isInitialized: true,
          isPlaying: true,
        ),
        isLive: false,
      );
      expect(playing.phase, MediaVideoPhase.playing);
      expect(playing.canSeek, isTrue);
      expect(
        MediaVideoState.fromValue(
          const VideoPlayerValue(
            duration: Duration(seconds: 10),
            isInitialized: true,
            isCompleted: true,
          ),
          isLive: false,
        ).phase,
        MediaVideoPhase.completed,
      );
      expect(
        MediaVideoState.fromValue(
          const VideoPlayerValue.erroneous('decode failed'),
          isLive: false,
        ).phase,
        MediaVideoPhase.error,
      );
      expect(
        MediaVideoState.fromValue(
          const VideoPlayerValue(
            duration: Duration(seconds: 10),
            isInitialized: true,
          ),
          isLive: true,
        ).canSeek,
        isFalse,
      );
    },
  );

  test(
    'audio interruption resumes only prior playback and never after noisy',
    () {
      final policy = MediaAudioPolicy();

      expect(
        policy.begin(MediaAudioInterruptionKind.pause, playing: true),
        MediaAudioPolicyAction.pause,
      );
      expect(
        policy.end(MediaAudioInterruptionKind.pause),
        MediaAudioPolicyAction.resume,
      );
      expect(
        policy.begin(MediaAudioInterruptionKind.pause, playing: false),
        MediaAudioPolicyAction.pause,
      );
      expect(
        policy.end(MediaAudioInterruptionKind.pause),
        MediaAudioPolicyAction.none,
      );
      expect(policy.userPauseOrNoisy(), MediaAudioPolicyAction.pause);
      expect(
        policy.end(MediaAudioInterruptionKind.pause),
        MediaAudioPolicyAction.none,
      );
      expect(
        policy.begin(MediaAudioInterruptionKind.duck, playing: true),
        MediaAudioPolicyAction.duck,
      );
      expect(
        policy.end(MediaAudioInterruptionKind.duck),
        MediaAudioPolicyAction.restoreVolume,
      );
    },
  );

  test('audio queue boundaries do not wrap or invent an item', () {
    final policy = MediaAudioPolicy();

    expect(policy.nextIndex(current: 0, length: 2), 1);
    expect(policy.nextIndex(current: 1, length: 2), isNull);
    expect(policy.previousIndex(current: 1, length: 2), 0);
    expect(policy.previousIndex(current: 0, length: 2), isNull);
    expect(policy.nextIndex(current: null, length: 2), isNull);
  });
}
