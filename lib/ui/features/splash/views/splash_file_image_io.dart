import 'dart:io';

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
    return Image.file(File(source), fit: fit, errorBuilder: errorBuilder);
  }
}
