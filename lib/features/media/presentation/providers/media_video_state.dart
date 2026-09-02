import 'package:video_player/video_player.dart';

enum MediaVideoPhase { loading, ready, buffering, playing, completed, error }

final class MediaVideoState {
  const MediaVideoState({
    required this.phase,
    required this.position,
    required this.duration,
    required this.canSeek,
    this.errorDescription,
  });

  factory MediaVideoState.fromValue(
    VideoPlayerValue value, {
    required bool isLive,
  }) {
    final phase = value.hasError
        ? MediaVideoPhase.error
        : !value.isInitialized
        ? MediaVideoPhase.loading
        : value.isBuffering
        ? MediaVideoPhase.buffering
        : value.isCompleted
        ? MediaVideoPhase.completed
        : value.isPlaying
        ? MediaVideoPhase.playing
        : MediaVideoPhase.ready;
    return MediaVideoState(
      phase: phase,
      position: value.position,
      duration: value.duration,
      canSeek: !isLive && value.isInitialized && value.duration > Duration.zero,
      errorDescription: value.errorDescription,
    );
  }

  final MediaVideoPhase phase;
  final Duration position;
  final Duration duration;
  final bool canSeek;
  final String? errorDescription;
}
