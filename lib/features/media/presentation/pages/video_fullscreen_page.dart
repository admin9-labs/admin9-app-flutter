import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:video_player/video_player.dart';

import '../providers/media_audio_provider.dart';

@RoutePage()
class VideoFullscreenPage extends ConsumerStatefulWidget {
  const VideoFullscreenPage({
    super.key,
    required this.controller,
    required this.title,
  });

  final VideoPlayerController controller;
  final String title;

  @override
  ConsumerState<VideoFullscreenPage> createState() =>
      _VideoFullscreenPageState();
}

class _VideoFullscreenPageState extends ConsumerState<VideoFullscreenPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
    );
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xff000000),
    child: SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio <= 0
                  ? 16 / 9
                  : widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: FButton.icon(
              key: const ValueKey('video-fullscreen-close'),
              variant: .secondary,
              semanticsLabel: context.tr('media.video.exit_fullscreen'),
              onPress: context.maybePop,
              child: const Icon(FLucideIcons.minimize),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: FButton.icon(
              variant: .secondary,
              semanticsLabel: widget.controller.value.isPlaying
                  ? '暂停视频'
                  : '播放视频',
              onPress: widget.controller.value.isPlaying
                  ? widget.controller.pause
                  : () async {
                      await ref.read(mediaAudioHandlerProvider).pause();
                      await widget.controller.play();
                    },
              child: Icon(
                widget.controller.value.isPlaying
                    ? FLucideIcons.pause
                    : FLucideIcons.play,
              ),
            ),
          ),
          if (widget.controller.value.isBuffering)
            const Center(child: FCircularProgress()),
        ],
      ),
    ),
  );
}
