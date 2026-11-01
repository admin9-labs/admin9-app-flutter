import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/startup_ad_campaign.dart';

/// One deadline covers headers, all redirects, and the entire response body.
Future<http.Response> startupAdResponse({
  required http.Client client,
  required Uri uri,
  required Set<String> allowedHosts,
  required Duration timeout,
  String? accept,
  String? expectedMime,
  int? expectedLength,
}) async {
  final abort = Completer<void>();
  StreamSubscription<List<int>>? subscription;
  var finished = false;

  Future<http.Response> read() async {
    var current = uri;
    for (var redirect = 0; redirect <= 3; redirect++) {
      if (finished) throw TimeoutException('Startup-ad request expired.');
      if (!startupAdHttpsUriValid(current) ||
          !allowedHosts.contains(current.host)) {
        throw const FormatException('Untrusted startup-ad URL.');
      }
      final request = http.AbortableRequest(
        'GET',
        current,
        abortTrigger: abort.future,
      )..followRedirects = false;
      if (accept != null) request.headers['accept'] = accept;
      final response = await client.send(request);
      if (finished) {
        unawaited(response.stream.listen(null).cancel());
        throw TimeoutException('Startup-ad request expired.');
      }
      if (const {301, 302, 303, 307, 308}.contains(response.statusCode)) {
        // Redirect bodies are irrelevant; cancel rather than draining them.
        unawaited(response.stream.listen(null).cancel());
        final location = response.headers['location'];
        if (location == null || redirect == 3) {
          throw const FormatException('Invalid startup-ad redirect.');
        }
        current = current.resolve(location);
        continue;
      }
      final mime = response.headers['content-type']?.split(';').first.trim();
      if (expectedMime != null &&
          response.statusCode == 200 &&
          (mime != expectedMime ||
              (response.contentLength != null &&
                  response.contentLength != expectedLength))) {
        unawaited(response.stream.listen(null).cancel());
        throw const FormatException(
          'Startup-ad media response does not match.',
        );
      }
      final body = Completer<Uint8List>();
      final bytes = BytesBuilder(copy: false);
      subscription = response.stream.listen(
        (chunk) {
          if (body.isCompleted) return;
          if (expectedLength != null &&
              bytes.length + chunk.length > expectedLength) {
            body.completeError(
              const FormatException('Startup-ad body is too large.'),
            );
          } else {
            bytes.add(chunk);
          }
        },
        onError: (Object error, StackTrace stack) {
          if (!body.isCompleted) body.completeError(error, stack);
        },
        onDone: () {
          if (!body.isCompleted) body.complete(bytes.takeBytes());
        },
      );
      return http.Response.bytes(
        await body.future,
        response.statusCode,
        headers: response.headers,
      );
    }
    throw const FormatException('Too many startup-ad redirects.');
  }

  try {
    return await read().timeout(timeout);
  } finally {
    finished = true;
    abort.complete();
    final active = subscription;
    if (active != null) unawaited(active.cancel());
  }
}
