import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/routing/app_router.gr.dart';
import '../../../../shared/ui/error_state_view.dart';
import '../../../../shared/ui/responsive_page_body.dart';
import '../../data/models/media_scenario.dart';
import '../providers/media_scenario_provider.dart';
import '../providers/media_audio_provider.dart';
import '../providers/media_video_state.dart';

@RoutePage()
class VideoPage extends ConsumerStatefulWidget {
  const VideoPage({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  ConsumerState<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends ConsumerState<VideoPage>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  VideoScenario? _scenario;
  Object? _error;
  bool _loading = true;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_open(widget.scenarioId));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_controller?.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_refresh);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _open(String id) async {
    final catalog = ref.read(mediaScenarioRepositoryProvider).load();
    final scenario = catalog.videoById(id);
    if (scenario == null) {
      setState(() {
        _scenario = null;
        _error = StateError('Unknown video scenario: $id');
        _loading = false;
      });
      return;
    }
    final previous = _controller;
    previous?.removeListener(_refresh);
    await previous?.dispose();
    final controller = switch (scenario.kind) {
      VideoScenarioKind.local => VideoPlayerController.asset(scenario.location),
      VideoScenarioKind.networkMp4 => VideoPlayerController.networkUrl(
        Uri.parse(scenario.location),
      ),
      VideoScenarioKind.hlsVod ||
      VideoScenarioKind.hlsLive => VideoPlayerController.networkUrl(
        Uri.parse(scenario.location),
        formatHint: VideoFormat.hls,
      ),
    };
    controller.addListener(_refresh);
    setState(() {
      _scenario = scenario;
      _controller = controller;
      _error = null;
      _loading = true;
      _muted = false;
    });
    try {
      await controller.initialize();
      await controller.setLooping(false);
      if (!mounted || controller != _controller) return;
      setState(() => _loading = false);
    } on Object catch (error) {
      if (!mounted || controller != _controller) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scenario = _scenario;
    final catalog = ref.watch(mediaScenarioRepositoryProvider).load();
    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(scenario?.title ?? context.tr('media.video.title')),
        prefixes: [FHeaderAction.back(onPress: context.maybePop)],
      ),
      child: ResponsivePageBody(
        children: [
          if (_error != null)
            ErrorStateView(
              title: context.tr('media.video.load_failed_title'),
              message: context.tr('media.video.load_failed_message'),
              retryLabel: context.tr('common.retry'),
              onRetry: () => _open(scenario?.id ?? widget.scenarioId),
            )
          else if (_loading || _controller?.value.isInitialized != true)
            const SizedBox(
              height: 240,
              child: Center(child: FCircularProgress()),
            )
          else ...[
            _VideoSurface(controller: _controller!),
            _controls(context, scenario!),
          ],
          Text(
            scenario?.description ?? '',
            style: FTheme.of(context).typography.body.sm,
          ),
          Text(
            context.tr('media.video.scenarios'),
            style: FTheme.of(context).typography.body.lg,
          ),
          FItemGroup(
            divider: .indented,
            children: [
              for (final candidate in catalog.videos)
                FItem(
                  key: ValueKey('video-scenario-${candidate.id}'),
                  prefix: Icon(
                    candidate.isLive
                        ? FLucideIcons.radio
                        : FLucideIcons.circlePlay,
                  ),
                  title: Text(candidate.title),
                  subtitle: Text(candidate.description),
                  suffix: candidate.id == scenario?.id
                      ? const Icon(FLucideIcons.check)
                      : const Icon(FLucideIcons.chevronRight),
                  onPress: candidate.id == scenario?.id
                      ? null
                      : () => _open(candidate.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controls(BuildContext context, VideoScenario scenario) {
    final controller = _controller!;
    final value = controller.value;
    final playback = MediaVideoState.fromValue(value, isLive: scenario.isLive);
    final duration = value.duration;
    final position = value.position > duration ? duration : value.position;
    final ratio = duration == Duration.zero
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (!scenario.isLive)
          FSlider(
            key: const ValueKey('video-progress'),
            enabled: playback.canSeek,
            control: .liftedContinuous(
              value: FSliderValue(max: ratio),
              stepPercentage: 0.001,
              onChange: (next) => controller.seekTo(
                Duration(
                  milliseconds: (duration.inMilliseconds * next.max).round(),
                ),
              ),
            ),
            semanticFormatterCallback: (_) =>
                '${_duration(position)} / ${_duration(duration)}',
          )
        else
          Semantics(
            liveRegion: true,
            label: context.tr('media.video.live_playback'),
            child: Text(context.tr('media.live_no_seek')),
          ),
        Row(
          spacing: 8,
          children: [
            FButton.icon(
              key: const ValueKey('video-play-pause'),
              semanticsLabel: value.isPlaying ? '暂停视频' : '播放视频',
              onPress: value.isPlaying
                  ? controller.pause
                  : () async {
                      await ref.read(mediaAudioHandlerProvider).pause();
                      await controller.play();
                    },
              child: Icon(
                value.isPlaying ? FLucideIcons.pause : FLucideIcons.play,
              ),
            ),
            FButton.icon(
              key: const ValueKey('video-mute'),
              variant: .outline,
              semanticsLabel: _muted ? '开启视频声音' : '静音视频',
              onPress: () async {
                _muted = !_muted;
                await controller.setVolume(_muted ? 0 : 1);
                if (mounted) setState(() {});
              },
              child: Icon(_muted ? FLucideIcons.volumeX : FLucideIcons.volume2),
            ),
            const Spacer(),
            if (!scenario.isLive)
              Text(
                '${_duration(position)} / ${_duration(duration)}',
                style: FTheme.of(context).typography.body.sm,
              ),
            FButton.icon(
              key: const ValueKey('video-fullscreen'),
              variant: .outline,
              semanticsLabel: context.tr('media.video.fullscreen'),
              onPress: () => context.router.root.push(
                VideoFullscreenRoute(
                  controller: controller,
                  title: scenario.title,
                ),
              ),
              child: const Icon(FLucideIcons.maximize),
            ),
          ],
        ),
        if (playback.phase == MediaVideoPhase.buffering)
          Semantics(
            liveRegion: true,
            child: Row(
              spacing: 8,
              children: [
                FCircularProgress(size: .sm),
                Text(context.tr('media.buffering')),
              ],
            ),
          ),
      ],
    );
  }
}

class _VideoSurface extends StatelessWidget {
  const _VideoSurface({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final ratio = controller.value.aspectRatio;
    return ColoredBox(
      color: const Color(0xff000000),
      child: AspectRatio(
        aspectRatio: ratio <= 0 ? 16 / 9 : ratio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(controller),
            if (controller.value.isBuffering)
              const Center(child: FCircularProgress()),
          ],
        ),
      ),
    );
  }
}

String _duration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
