enum MediaAudioInterruptionKind { duck, pause, unknown }

enum MediaAudioPolicyAction { none, duck, pause, restoreVolume, resume }

final class MediaAudioPolicy {
  bool _resumeAfterInterruption = false;

  MediaAudioPolicyAction begin(
    MediaAudioInterruptionKind kind, {
    required bool playing,
  }) => switch (kind) {
    MediaAudioInterruptionKind.duck => MediaAudioPolicyAction.duck,
    MediaAudioInterruptionKind.pause => _pauseForInterruption(playing),
    MediaAudioInterruptionKind.unknown => _cancelAndPause(),
  };

  MediaAudioPolicyAction end(MediaAudioInterruptionKind kind) => switch (kind) {
    MediaAudioInterruptionKind.duck => MediaAudioPolicyAction.restoreVolume,
    MediaAudioInterruptionKind.pause => _resumeIfAllowed(),
    MediaAudioInterruptionKind.unknown => _cancel(),
  };

  MediaAudioPolicyAction userPauseOrNoisy() => _cancelAndPause();

  int? nextIndex({required int? current, required int length}) {
    if (current == null || current + 1 >= length) return null;
    return current + 1;
  }

  int? previousIndex({required int? current, required int length}) {
    if (current == null || current <= 0 || length <= 0) return null;
    return current - 1;
  }

  MediaAudioPolicyAction _pauseForInterruption(bool playing) {
    _resumeAfterInterruption = playing;
    return MediaAudioPolicyAction.pause;
  }

  MediaAudioPolicyAction _cancelAndPause() {
    _resumeAfterInterruption = false;
    return MediaAudioPolicyAction.pause;
  }

  MediaAudioPolicyAction _resumeIfAllowed() {
    final resume = _resumeAfterInterruption;
    _resumeAfterInterruption = false;
    return resume ? MediaAudioPolicyAction.resume : MediaAudioPolicyAction.none;
  }

  MediaAudioPolicyAction _cancel() {
    _resumeAfterInterruption = false;
    return MediaAudioPolicyAction.none;
  }
}
