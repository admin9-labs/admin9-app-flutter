import 'package:flutter/foundation.dart';

import 'splash_remote_content.dart';

class SplashCacheDirectory {
  const SplashCacheDirectory(this.path);

  final String path;
}

class SplashCacheFile {
  const SplashCacheFile(this.path);

  final String path;

  Future<bool> exists() async => false;

  Future<int> length() async => 0;

  Future<void> writeAsBytes(Uint8List bytes, {bool flush = false}) async {}
}

Future<SplashCacheDirectory> defaultSplashCacheDirectory() {
  throw UnsupportedError(
    'Splash file cache is not available on this platform.',
  );
}

Future<void> createSplashCacheDirectory(SplashCacheDirectory directory) async {}

SplashCacheFile splashCacheFile(String path) => SplashCacheFile(path);

String splashCacheFilePath(SplashCacheDirectory directory, String fileName) =>
    '${directory.path}/$fileName';

Future<SplashRemoteContent?> downloadSplashRemoteContent({
  required Uri uri,
  required Duration timeout,
  required int maxBytes,
  required bool Function(String? contentType) isImageContentType,
  required void Function(String message, [Object? error]) debugLog,
}) async {
  debugLog(
    'splash remote download unavailable on ${defaultTargetPlatform.name}',
  );
  return null;
}
