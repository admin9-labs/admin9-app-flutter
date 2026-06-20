import 'dart:typed_data';

class SplashRemoteContent {
  const SplashRemoteContent({required this.bytes, required this.contentType});

  final Uint8List bytes;
  final String? contentType;
}
