import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'splash_remote_content.dart';

class SplashCacheDirectory {
  const SplashCacheDirectory(this.path);

  final String path;

  Directory get _directory => Directory(path);
}

class SplashCacheFile {
  const SplashCacheFile(this.path);

  final String path;

  File get _file => File(path);

  Future<bool> exists() => _file.exists();

  Future<int> length() => _file.length();

  Future<void> writeAsBytes(Uint8List bytes, {bool flush = false}) {
    return _file.writeAsBytes(bytes, flush: flush);
  }
}

Future<SplashCacheDirectory> defaultSplashCacheDirectory() async {
  final supportDirectory = await getApplicationSupportDirectory();
  return SplashCacheDirectory('${supportDirectory.path}/admin9-splash-cache');
}

Future<void> createSplashCacheDirectory(SplashCacheDirectory directory) {
  return directory._directory.create(recursive: true);
}

SplashCacheFile splashCacheFile(String path) => SplashCacheFile(path);

String splashCacheFilePath(SplashCacheDirectory directory, String fileName) {
  return '${directory.path}/$fileName';
}

Future<SplashRemoteContent?> downloadSplashRemoteContent({
  required Uri uri,
  required Duration timeout,
  required int maxBytes,
  required bool Function(String? contentType) isImageContentType,
  required void Function(String message, [Object? error]) debugLog,
}) async {
  final client = HttpClient()..connectionTimeout = timeout;

  try {
    final request = await client.getUrl(uri).timeout(timeout);
    final response = await request.close().timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugLog('splash download failed with HTTP ${response.statusCode}');
      return null;
    }

    final contentType = response.headers.contentType?.mimeType;
    if (!isImageContentType(contentType)) {
      debugLog('splash download rejected content type $contentType');
      return null;
    }

    if (response.contentLength > maxBytes) {
      debugLog('splash download rejected oversized content');
      return null;
    }

    final bytes = await _readBytesBounded(
      response,
      maxBytes: maxBytes,
      debugLog: debugLog,
    );
    return bytes == null
        ? null
        : SplashRemoteContent(bytes: bytes, contentType: contentType);
  } finally {
    client.close(force: true);
  }
}

Future<Uint8List?> _readBytesBounded(
  HttpClientResponse response, {
  required int maxBytes,
  required void Function(String message, [Object? error]) debugLog,
}) async {
  final builder = BytesBuilder(copy: false);
  var totalBytes = 0;
  await for (final chunk in response) {
    totalBytes += chunk.length;
    if (totalBytes > maxBytes) {
      debugLog('splash download exceeded max bytes');
      return null;
    }
    builder.add(chunk);
  }
  return builder.takeBytes();
}
