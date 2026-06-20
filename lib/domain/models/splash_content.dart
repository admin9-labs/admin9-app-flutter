enum SplashMediaType { image, gif, video }

enum SplashSourceType { asset, file }

class SplashContent {
  const SplashContent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.mediaType,
    required this.duration,
    required this.callToAction,
    required this.sourceType,
    required this.source,
    this.targetTitle,
    this.actionUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final SplashMediaType mediaType;
  final Duration duration;
  final String callToAction;
  final SplashSourceType sourceType;
  final String source;
  final String? targetTitle;
  final String? actionUrl;

  bool get hasAction {
    return actionUrl != null && actionUrl!.trim().isNotEmpty;
  }

  bool get isImageLike {
    return mediaType == SplashMediaType.image ||
        mediaType == SplashMediaType.gif;
  }
}
