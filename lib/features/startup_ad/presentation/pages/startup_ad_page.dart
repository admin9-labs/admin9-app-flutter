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
    required this.onAction,
    required this.onFailure,
  });

  final StartupAdCampaign campaign;
  final Future<void> Function() onVisible;
  final VoidCallback onSkip;
  final ValueChanged<StartupAdAction> onAction;
  final VoidCallback onFailure;

  @override
  State<StartupAdPage> createState() => _StartupAdPageState();
}

class _StartupAdPageState extends State<StartupAdPage>
    with WidgetsBindingObserver {
  Timer? _timer;
  VideoPlayerController? _videoController;
  late int _remainingSeconds;
  bool _visibleRecorded = false;
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
    _prepareMedia();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      widget.onSkip();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
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
                : () => widget.onAction(campaign.action),
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
                      DecoratedBox(
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
                      const Spacer(),
                      if (media.type == StartupAdMediaType.video &&
                          _videoController != null)
                        FButton.icon(
                          key: const ValueKey('startup-ad-mute'),
                          variant: .secondary,
                          size: .sm,
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
                        size: .sm,
                        mainAxisSize: MainAxisSize.min,
                        onPress: widget.onSkip,
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
                    Semantics(
                      label: context.tr('startup_ad.open'),
                      button: true,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xb3000000),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Text(
                              context.tr('startup_ad.open'),
                              style: FTheme.of(context).typography.body.sm
                                  .copyWith(color: const Color(0xffffffff)),
                            ),
                          ),
                        ),
                      ),
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
        _videoController?.value.isInitialized == true) {
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
    return Image.file(
      File(media.localPath!),
      fit: BoxFit.cover,
      alignment: Alignment((media.focalX * 2) - 1, (media.focalY * 2) - 1),
      semanticLabel: media.semanticLabel,
      frameBuilder: (context, child, frame, synchronous) {
        if (frame != null || synchronous) _recordVisible();
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
    if (_videoController != null || _failed) return;
    final media = _displayMedia(context);
    if (media.type != StartupAdMediaType.video) return;
    final controller = VideoPlayerController.file(File(media.localPath!));
    _videoController = controller;
    controller
        .initialize()
        .timeout(const Duration(milliseconds: 800))
        .then((_) async {
          if (!mounted) return;
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
          await controller.play();
          if (!mounted) return;
          setState(() {});
          _recordVisible();
        })
        .catchError((Object _) {
          if (mounted) _useFallbackOrFail();
        });
  }

  void _recordVisible() {
    if (_visibleRecorded || _failed) return;
    _visibleRecorded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onVisible();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        widget.onSkip();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _useFallbackOrFail() {
    if (_usingFallback || widget.campaign.fallbackImage == null) {
      _failed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onFailure();
      });
      return;
    }
    _videoController?.dispose();
    _videoController = null;
    setState(() => _usingFallback = true);
  }

  Future<void> _toggleMuted() async {
    final controller = _videoController;
    if (controller == null) return;
    _muted = !_muted;
    await controller.setVolume(_muted ? 0 : 1);
    if (mounted) setState(() {});
  }
}
