import 'package:flutter/material.dart';

class SplashFileImage extends StatelessWidget {
  const SplashFileImage({
    super.key,
    required this.source,
    required this.fit,
    required this.errorBuilder,
  });

  final String source;
  final BoxFit fit;
  final ImageErrorWidgetBuilder errorBuilder;

  @override
  Widget build(BuildContext context) {
    return errorBuilder(
      context,
      UnsupportedError('File images are not available'),
      null,
    );
  }
}
