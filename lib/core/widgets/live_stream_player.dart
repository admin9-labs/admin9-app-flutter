import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';

typedef LiveStreamPlayerBuilder =
    Widget Function(
      BuildContext context,
      LiveStreamPlayerConfig config,
      bool muted,
      ValueChanged<bool> onMutedChanged,
    );

typedef LiveVideoControllerFactory = LiveVideoController Function(Uri url);

abstract class LiveVideoController {
  VideoPlayerValue get value;

  Future<void> initialize();

  Future<void> setLooping(bool looping);

  Future<void> setVolume(double volume);

  Future<void> play();

  Future<void> dispose();

  Widget buildView();
}

class LiveStreamPlayerConfig {
  const LiveStreamPlayerConfig({
    required this.url,
    required this.title,
    this.subtitle,
    this.autoplay = true,
    this.initialMuted = false,
    this.showMuteButton = true,
    this.showOverlayText = true,
    this.aspectRatio = 16 / 9,
  });

  final String url;
  final String title;
  final String? subtitle;
  final bool autoplay;
  final bool initialMuted;
  final bool showMuteButton;
  final bool showOverlayText;
  final double aspectRatio;
}

class LiveStreamPlayer extends StatefulWidget {
  const LiveStreamPlayer({super.key, required this.config, this.builder});

  @visibleForTesting
  static LiveVideoControllerFactory controllerFactory =
      _defaultControllerFactory;

  @visibleForTesting
  static void resetControllerFactory() {
    controllerFactory = _defaultControllerFactory;
  }

  final LiveStreamPlayerConfig config;
  final LiveStreamPlayerBuilder? builder;

  @override
  State<LiveStreamPlayer> createState() => _LiveStreamPlayerState();
}

class _LiveStreamPlayerState extends State<LiveStreamPlayer> {
  LiveVideoController? _controller;
  Object? _error;
  var _generation = 0;
  late bool _muted = widget.config.initialMuted;

  @override
  void initState() {
    super.initState();
    if (widget.builder == null) {
      _initialize();
    }
  }

  @override
  void didUpdateWidget(covariant LiveStreamPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final initialMutedChanged =
        oldWidget.config.initialMuted != widget.config.initialMuted;
    if (widget.builder != null) {
      _generation++;
      final controller = _controller;
      _controller = null;
      _error = null;
      if (initialMutedChanged) {
        _muted = widget.config.initialMuted;
      }
      if (controller != null) {
        unawaited(controller.dispose());
      }
      return;
    }

    if (oldWidget.builder != null ||
        oldWidget.config.url != widget.config.url) {
      if (initialMutedChanged) {
        _muted = widget.config.initialMuted;
      }
      _initialize();
    } else if (initialMutedChanged) {
      _setMuted(widget.config.initialMuted);
    }
  }

  @override
  void dispose() {
    _generation++;
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      unawaited(controller.dispose());
    }
    super.dispose();
  }

  Future<void> _initialize() async {
    final generation = ++_generation;
    final previous = _controller;
    setState(() {
      _controller = null;
      _error = null;
    });
    await previous?.dispose();

    if (!_isCurrentGeneration(generation)) return;

    late final LiveVideoController controller;
    try {
      controller = LiveStreamPlayer.controllerFactory(
        Uri.parse(widget.config.url),
      );
    } catch (error) {
      if (_isCurrentGeneration(generation)) {
        setState(() => _error = error);
      }
      return;
    }

    if (await _disposeIfStale(generation, controller)) return;
    _controller = controller;

    try {
      await controller.initialize();
      if (await _disposeIfStale(generation, controller)) return;
      await controller.setLooping(true);
      if (await _disposeIfStale(generation, controller)) return;
      await controller.setVolume(_muted ? 0 : 1);
      if (await _disposeIfStale(generation, controller)) return;
      if (widget.config.autoplay) {
        await controller.play();
      }
      if (await _disposeIfStale(generation, controller)) return;
      setState(() {});
    } catch (error) {
      await controller.dispose();
      if (_isCurrentGeneration(generation)) {
        setState(() {
          _controller = null;
          _error = error;
        });
      }
    }
  }

  Future<bool> _disposeIfStale(
    int generation,
    LiveVideoController controller,
  ) async {
    if (_isCurrentGeneration(generation)) return false;
    await controller.dispose();
    return true;
  }

  bool _isCurrentGeneration(int generation) {
    return mounted && generation == _generation && widget.builder == null;
  }

  Future<void> _setMuted(bool muted) async {
    setState(() => _muted = muted);
    await _controller?.setVolume(muted ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final builder = widget.builder;
    if (builder != null) {
      return AspectRatio(
        aspectRatio: widget.config.aspectRatio,
        child: builder(context, widget.config, _muted, _setMuted),
      );
    }

    return AspectRatio(
      aspectRatio: widget.config.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildPlayerBody(context),
              _PlayerScrim(config: widget.config),
              if (widget.config.showMuteButton)
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: _MuteButton(muted: _muted, onChanged: _setMuted),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerBody(BuildContext context) {
    final controller = _controller;
    if (_error != null) {
      return _PlayerFallback(
        icon: Icons.error_outline,
        title: '直播加载失败',
        actionLabel: '重试',
        onAction: _initialize,
      );
    }
    if (controller == null || !controller.value.isInitialized) {
      return const _PlayerFallback(
        icon: Icons.live_tv_outlined,
        title: '正在连接直播流',
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: controller.buildView(),
      ),
    );
  }
}

LiveVideoController _defaultControllerFactory(Uri url) {
  return _VideoPlayerControllerAdapter(VideoPlayerController.networkUrl(url));
}

class _VideoPlayerControllerAdapter implements LiveVideoController {
  const _VideoPlayerControllerAdapter(this._controller);

  final VideoPlayerController _controller;

  @override
  VideoPlayerValue get value => _controller.value;

  @override
  Future<void> initialize() => _controller.initialize();

  @override
  Future<void> setLooping(bool looping) => _controller.setLooping(looping);

  @override
  Future<void> setVolume(double volume) => _controller.setVolume(volume);

  @override
  Future<void> play() => _controller.play();

  @override
  Future<void> dispose() => _controller.dispose();

  @override
  Widget buildView() => VideoPlayer(_controller);
}

class _PlayerScrim extends StatelessWidget {
  const _PlayerScrim({required this.config});

  final LiveStreamPlayerConfig config;

  @override
  Widget build(BuildContext context) {
    final subtitle = config.subtitle?.trim();
    final hasText =
        config.showOverlayText &&
        (config.title.trim().isNotEmpty ||
            (subtitle != null && subtitle.isNotEmpty));

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.06),
            Colors.black.withValues(alpha: 0.58),
          ],
        ),
      ),
      child: Padding(
        padding: AppInsets.section,
        child: hasText
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.feedTitleCompact.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.feedMeta.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                ],
              )
            : const SizedBox.expand(),
      ),
    );
  }
}

class _MuteButton extends StatelessWidget {
  const _MuteButton({required this.muted, required this.onChanged});

  final bool muted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      key: const Key('live-stream-mute-button'),
      tooltip: muted ? '取消静音' : '静音',
      onPressed: () => onChanged(!muted),
      icon: Icon(muted ? Icons.volume_off_rounded : Icons.volume_up_rounded),
    );
  }
}

class _PlayerFallback extends StatelessWidget {
  const _PlayerFallback({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: AppIconSize.empty),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: context.typography.feedTitleCompact.copyWith(
              color: Colors.white,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
