import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../shared/ui/responsive_page_body.dart';
import '../../data/services/media_audio_handler.dart';
import '../providers/media_audio_provider.dart';
import '../providers/media_scenario_provider.dart';

@RoutePage()
class AudioPage extends ConsumerStatefulWidget {
  const AudioPage({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  ConsumerState<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends ConsumerState<AudioPage> {
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final catalog = ref.read(mediaScenarioRepositoryProvider).load();
      await ref
          .read(mediaAudioHandlerProvider)
          .load(catalog.audio, initialId: widget.scenarioId);
    } on Object catch (error) {
      if (mounted) setState(() => _loadError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final handler = ref.watch(mediaAudioHandlerProvider);
    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(context.tr('media.audio.title')),
        prefixes: [FHeaderAction.back(onPress: context.maybePop)],
      ),
      child: ResponsivePageBody(
        children: [
          if (_loadError != null)
            Column(
              spacing: 12,
              children: [
                Text(context.tr('media.audio.load_failed')),
                FButton(
                  onPress: _load,
                  child: Text(context.tr('common.retry')),
                ),
              ],
            )
          else
            StreamBuilder<PlaybackState>(
              stream: handler.playbackState,
              initialData: handler.playbackState.value,
              builder: (context, playbackSnapshot) => StreamBuilder<MediaItem?>(
                stream: handler.mediaItem,
                initialData: handler.mediaItem.value,
                builder: (context, itemSnapshot) => _player(
                  context,
                  handler,
                  playbackSnapshot.data!,
                  itemSnapshot.data,
                ),
              ),
            ),
          Text(
            context.tr('media.audio.queue'),
            style: FTheme.of(context).typography.body.lg,
          ),
          StreamBuilder<List<MediaItem>>(
            stream: handler.queue,
            initialData: handler.queue.value,
            builder: (context, snapshot) => FItemGroup(
              divider: .indented,
              children: [
                for (var index = 0; index < snapshot.data!.length; index++)
                  FItem(
                    key: ValueKey('audio-queue-$index'),
                    prefix: Icon(
                      handler.isLive(snapshot.data![index])
                          ? FLucideIcons.radio
                          : FLucideIcons.music,
                    ),
                    title: Text(snapshot.data![index].title),
                    subtitle: Text(snapshot.data![index].artist ?? ''),
                    suffix:
                        handler.mediaItem.value?.id == snapshot.data![index].id
                        ? const Icon(FLucideIcons.volume2)
                        : const Icon(FLucideIcons.chevronRight),
                    onPress: () async {
                      await handler.skipToQueueItem(index);
                      await handler.play();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _player(
    BuildContext context,
    MediaAudioHandler handler,
    PlaybackState state,
    MediaItem? item,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: [
      Text(
        item?.title ?? '准备音频',
        style: FTheme.of(context).typography.display.sm,
      ),
      Text(item?.artist ?? '', style: FTheme.of(context).typography.body.sm),
      if (state.processingState == AudioProcessingState.loading ||
          state.processingState == AudioProcessingState.buffering)
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
      if (state.processingState == AudioProcessingState.error)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(state.errorMessage ?? '播放失败'),
            FButton(
              key: const ValueKey('audio-retry'),
              variant: .outline,
              mainAxisSize: MainAxisSize.min,
              onPress: _load,
              child: Text(context.tr('common.retry')),
            ),
          ],
        ),
      if (handler.isLive(item))
        Text(context.tr('media.live_no_seek'))
      else
        StreamBuilder<Duration>(
          stream: handler.positionStream,
          initialData: state.updatePosition,
          builder: (context, snapshot) {
            final duration = item?.duration ?? Duration.zero;
            final position = snapshot.data! > duration
                ? duration
                : snapshot.data!;
            final ratio = duration == Duration.zero
                ? 0.0
                : (position.inMilliseconds / duration.inMilliseconds).clamp(
                    0.0,
                    1.0,
                  );
            return FSlider(
              key: const ValueKey('audio-progress'),
              enabled: duration > Duration.zero,
              control: .liftedContinuous(
                value: FSliderValue(max: ratio),
                stepPercentage: 0.001,
                onChange: (next) => handler.seek(
                  Duration(
                    milliseconds: (duration.inMilliseconds * next.max).round(),
                  ),
                ),
              ),
            );
          },
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          FButton.icon(
            variant: .outline,
            semanticsLabel: context.tr('media.audio.previous'),
            onPress: handler.skipToPrevious,
            child: const Icon(FLucideIcons.skipBack),
          ),
          FButton.icon(
            key: const ValueKey('audio-play-pause'),
            semanticsLabel: state.playing ? '暂停音频' : '播放音频',
            onPress: state.playing ? handler.pause : handler.play,
            child: Icon(state.playing ? FLucideIcons.pause : FLucideIcons.play),
          ),
          FButton.icon(
            variant: .outline,
            semanticsLabel: context.tr('media.audio.next'),
            onPress: handler.skipToNext,
            child: const Icon(FLucideIcons.skipForward),
          ),
        ],
      ),
      if (!handler.isLive(item))
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final speed in [1.0, 1.5, 2.0])
              FButton(
                variant: state.speed == speed ? .primary : .outline,
                mainAxisSize: MainAxisSize.min,
                onPress: () => handler.setSpeed(speed),
                child: Text('${speed}x'),
              ),
          ],
        ),
    ],
  );
}
