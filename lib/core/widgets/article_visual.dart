import 'package:flutter/material.dart';

import '../../domain/models/article.dart';
import '../theme/app_spacing.dart';
import 'media_cover.dart';

class ArticleVisual extends StatelessWidget {
  const ArticleVisual({
    super.key,
    required this.label,
    required this.type,
    required this.height,
    this.width,
    this.compact = false,
    this.duration,
    this.showPlay = false,
    this.imageUrl,
    this.showLabel = true,
  });

  final String label;
  final ArticleVisualType type;
  final double height;
  final double? width;
  final bool compact;
  final String? duration;
  final bool showPlay;
  final String? imageUrl;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return MediaCover(
      label: label,
      type: type,
      width: width,
      height: height,
      compact: compact,
      duration: duration,
      showPlay: showPlay,
      imageUrl: imageUrl,
      showLabel: showLabel,
      borderRadius: compact ? AppRadius.media : AppRadius.input,
    );
  }
}
