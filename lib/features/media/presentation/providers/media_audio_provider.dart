import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/media_audio_handler.dart';

final mediaAudioHandlerProvider = Provider<MediaAudioHandler>(
  (ref) => MediaAudioHandler(),
);
