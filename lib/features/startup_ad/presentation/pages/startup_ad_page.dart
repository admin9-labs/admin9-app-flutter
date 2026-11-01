import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/startup_ad_campaign.dart';

class StartupAdPage extends StatefulWidget {
  const StartupAdPage({
    super.key,
    required this.campaign,
    required this.onVisible,
    required this.onSkip,
    required this.onCompleted,
    required this.onBackgrounded,
    required this.onAction,
    required this.onFailure,
  });

  final StartupAdCampaign campaign;
  final Future<void> Function() onVisible;
  final VoidCallback onSkip;
  final VoidCallback onCompleted;
  final VoidCallback onBackgrounded;
  final ValueChanged<StartupAdAction> onAction;
  final VoidCallback onFailure;

  @override
  State<StartupAdPage> createState() => _StartupAdPageState();
}

class _StartupAdPageState extends State<StartupAdPage>
    with WidgetsBindingObserver {
  Timer? _timer;
  Timer? _completionTimer;
  Timer? _mediaTimeout;
  bool _finished = false;
  bool _fallbackScheduled = false;
  VideoPlayerController? _videoController;
  late int _remainingSeconds;
  bool _visibleRecorded = false;
  bool _visibleScheduled = false;
  bool _muted = true;
  bool _usingFallback = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remainingSeconds = widget.campaign.displayDuration.inSeconds;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mediaTimeout ??= Timer(
      const Duration(milliseconds: 800),
      _useFallbackOrFail,
    );
    if (MediaQuery.disableAnimationsOf(context) && _videoController != null) {
      final video = _videoController;
      _videoController = null;
      video?.dispose();
    }
    _prepareMedia();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _finish(widget.onBackgrounded);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _completionTimer?.cancel();
    _mediaTimeout?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaign = widget.campaign;
    final media = _displayMedia(context);
    return ColoredBox(
      key: const ValueKey('startup-ad-page'),
      color: const Color(0xff000000),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            key: const ValueKey('startup-ad-action'),
            behavior: HitTestBehavior.opaque,
            onTap: campaign.action.type == StartupAdActionType.none
                ? null
                : () => _finish(() => widget.onAction(campaign.action)),
            child: _media(media),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xb3000000),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              child: Text(
                                context.tr('startup_ad.label'),
                                style: FTheme.of(context).typography.body.xs
                                    .copyWith(color: const Color(0xffffffff)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (media.type == StartupAdMediaType.video &&
                          _videoController != null)
                        FButton.icon(
                          key: const ValueKey('startup-ad-mute'),
                          variant: .secondary,
                          size: .lg,
                          semanticsLabel: context.tr(
                            _muted ? 'startup_ad.unmute' : 'startup_ad.mute',
                          ),
                          onPress: _toggleMuted,
                          child: Icon(
                            _muted
                                ? FLucideIcons.volumeX
                                : FLucideIcons.volume2,
                          ),
                        ),
                      const SizedBox(width: 8),
                      FButton(
                        key: const ValueKey('startup-ad-skip'),
                        variant: .secondary,
                        size: .lg,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => _finish(widget.onSkip),
                        child: Text(
                          context.tr(
                            'startup_ad.skip',
                            namedArgs: {'seconds': '$_remainingSeconds'},
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (campaign.action.type != StartupAdActionType.none)
                    FButton(
                      variant: .secondary,
                      onPress: () =>
                          _finish(() => widget.onAction(campaign.action)),
                      child: Text(context.tr('startup_ad.open')),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _media(StartupAdMedia media) {
    if (media.type == StartupAdMediaType.video &&
        _videoController?.value.isInitialized == true &&
        _videoController?.value.hasError == false &&
        !_fallbackScheduled) {
      if (_videoController!.value.isPlaying) _recordVisible(media);
      return Semantics(
        image: true,
        label: media.semanticLabel,
        child: ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment(
              (media.focalX * 2) - 1,
              (media.focalY * 2) - 1,
            ),
            child: SizedBox(
              width: media.width.toDouble(),
              height: media.height.toDouble(),
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
      );
    }
    if (media.type == StartupAdMediaType.video) {
      return const SizedBox.shrink();
    }
    if (media.localPath == null) {
      _useFallbackOrFail();
      return const SizedBox.shrink();
    }
    return Image.file(
      File(media.localPath!),
      fit: BoxFit.cover,
      alignment: Alignment((media.focalX * 2) - 1, (media.focalY * 2) - 1),
      semanticLabel: media.semanticLabel,
      frameBuilder: (context, child, frame, synchronous) {
        if (frame != null || synchronous) _recordVisible(media);
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        _useFallbackOrFail();
        return const SizedBox.shrink();
      },
    );
  }

  StartupAdMedia _displayMedia(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final primary = widget.campaign.media;
    if (_usingFallback ||
        (reduceMotion &&
            (primary.type == StartupAdMediaType.gif ||
                primary.type == StartupAdMediaType.video))) {
      return widget.campaign.fallbackImage ?? primary;
    }
    return primary;
  }

  void _prepareMedia() {
    if (_videoController != null || _failed || _finished) return;
    final media = _displayMedia(context);
    if (media.type != StartupAdMediaType.video) return;
    if (media.localPath == null) {
      _useFallbackOrFail();
      return;
    }
    final controller = VideoPlayerController.file(File(media.localPath!));
    _videoController = controller;
    controller.addListener(() {
      if (mounted &&
          !_finished &&
          _videoController == controller &&
          controller.value.hasError) {
        _useFallbackOrFail();
      }
    });
    controller
        .initialize()
        .timeout(const Duration(milliseconds: 800))
        .then((_) async {
          if (!mounted || _finished || _videoController != controller) return;
          final size = controller.value.size;
          final expectedDuration = media.duration;
          final dimensionsMatch =
              (size.width.round() == media.width &&
                  size.height.round() == media.height) ||
              (size.width.round() == media.height &&
                  size.height.round() == media.width);
          final durationMatches =
              expectedDuration == null ||
              (controller.value.duration - expectedDuration).abs() <=
                  const Duration(seconds: 1);
          if (!dimensionsMatch || !durationMatches) {
            _useFallbackOrFail();
            return;
          }
          await controller.setVolume(0);
          await controller.setLooping(true);
          if (!mounted || _finished || _videoController != controller) return;
          await controller.play();
          if (!mounted ||
              _finished ||
              _videoController != controller ||
              controller.value.hasError ||
              _fallbackScheduled) {
            return;
          }
          setState(() {});
        })
        .catchError((Object _) {
          if (mounted && !_finished && _videoController == controller) {
            _useFallbackOrFail();
          }
        });
  }

  void _recordVisible(StartupAdMedia media) {
    if (_failed || _finished || _fallbackScheduled) return;
    // Each successfully rendered medium cancels its own load deadline, even
    // when a previous medium already recorded this campaign's exposure.
    _mediaTimeout?.cancel();
    if (_visibleRecorded || _visibleScheduled) return;
    _visibleScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visibleScheduled = false;
      if (!mounted ||
          _finished ||
          _failed ||
          _fallbackScheduled ||
          !identical(_displayMedia(context), media)) {
        return;
      }
      if (media.type == StartupAdMediaType.video &&
          (_videoController == null ||
              _videoController!.value.hasError ||
              !_videoController!.value.isPlaying)) {
        return;
      }
      _visibleRecorded = true;
      widget.onVisible();
      _completionTimer = Timer(
        widget.campaign.displayDuration,
        () => _finish(widget.onCompleted),
      );
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _finished) return;
        setState(() => _remainingSeconds = (_remainingSeconds - 1).clamp(0, 5));
      });
    });
  }

  void _finish(VoidCallback callback) {
    if (_finished || !mounted) return;
    _finished = true;
    _timer?.cancel();
    _completionTimer?.cancel();
    _mediaTimeout?.cancel();
    _videoController?.pause();
    callback();
  }

  void _useFallbackOrFail() {
    if (_finished || _failed || _fallbackScheduled || !mounted) return;
    _mediaTimeout?.cancel();
    _fallbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fallbackScheduled = false;
      if (!mounted || _finished) return;
      if (_usingFallback ||
          widget.campaign.fallbackImage == null ||
          _displayMedia(context) == widget.campaign.fallbackImage) {
        _failed = true;
        _finish(widget.onFailure);
        return;
      }
      final video = _videoController;
      _videoController = null;
      video?.dispose();
      setState(() => _usingFallback = true);
      _mediaTimeout = Timer(
        const Duration(milliseconds: 800),
        _useFallbackOrFail,
      );
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _toggleMuted() async {
    final controller = _videoController;
    if (controller == null) return;
    _muted = !_muted;
    await controller.setVolume(_muted ? 0 : 1);
    if (mounted) setState(() {});
  }
}
