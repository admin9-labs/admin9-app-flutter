import 'dart:async';
import 'dart:io';

import 'package:admin9_app_flutter/features/startup_ad/data/services/startup_ad_http.dart';
import 'package:admin9_app_flutter/features/startup_ad/data/services/startup_ad_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  testWidgets(
    'configuration deadline includes redirects and body; aborts at 800ms',
    (tester) async {
      var calls = 0;
      var cancelled = false;
      var aborted = false;
      final body = StreamController<List<int>>(
        onCancel: () => cancelled = true,
      );
      final client = _Client((request) async {
        (request as http.Abortable).abortTrigger!.then((_) => aborted = true);
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return calls == 1
            ? http.StreamedResponse(
                const Stream.empty(),
                302,
                headers: {'location': '/final'},
              )
            : http.StreamedResponse(
                body.stream,
                200,
                headers: {'content-type': 'application/json'},
              );
      });
      final service = _service(client);
      final failure = expectLater(
        service.fetchCampaign(),
        throwsA(isA<TimeoutException>()),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      body.add([123]);
      await tester.pump(const Duration(milliseconds: 200));
      await failure;
      expect(calls, 2);
      expect(cancelled, isTrue);
      expect(aborted, isTrue);
      unawaited(body.close());
      await tester.pump();
    },
  );

  testWidgets(
    'media has a total eight-second limit even while body keeps arriving',
    (tester) async {
      var cancelled = false;
      final body = StreamController<List<int>>(
        onCancel: () => cancelled = true,
      );
      var calls = 0;
      final client = _Client((_) async {
        calls++;
        if (calls == 1) {
          await Future<void>.delayed(const Duration(seconds: 3));
          return http.StreamedResponse(
            const Stream.empty(),
            302,
            headers: {'location': '/final'},
          );
        }
        return http.StreamedResponse(
          body.stream,
          200,
          headers: {'content-type': 'image/jpeg'},
        );
      });
      final failure = expectLater(
        startupAdResponse(
          client: client,
          uri: Uri.parse('https://cdn.example.com/a'),
          allowedHosts: {'cdn.example.com'},
          timeout: const Duration(seconds: 8),
          expectedMime: 'image/jpeg',
          expectedLength: 100,
        ),
        throwsA(isA<TimeoutException>()),
      );
      await tester.pump(const Duration(seconds: 3));
      for (var second = 0; second < 5; second++) {
        body.add([1]);
        await tester.pump(const Duration(seconds: 1));
      }
      await failure;
      expect(cancelled, isTrue);
      unawaited(body.close());
      await tester.pump();
    },
  );

  testWidgets('late headers cannot start a redirect after timeout', (
    tester,
  ) async {
    var calls = 0;
    var cancelled = false;
    final body = StreamController<List<int>>(onCancel: () => cancelled = true);
    final client = _Client((_) async {
      calls++;
      await Future<void>.delayed(const Duration(seconds: 1));
      return http.StreamedResponse(
        body.stream,
        302,
        headers: {'location': '/late'},
      );
    });
    final failure = expectLater(
      _service(client).fetchCampaign(),
      throwsA(isA<TimeoutException>()),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await failure;
    await tester.pump(const Duration(milliseconds: 200));
    expect(calls, 1);
    expect(cancelled, isTrue);
    unawaited(body.close());
    await tester.pump();
  });

  for (final location in [
    'http://api.example.com/a',
    'https://user@api.example.com/a',
    'https://api.example.com:8443/a',
    'https://evil.example/a',
  ]) {
    test('rejects redirect before contacting $location', () async {
      var calls = 0;
      final client = _Client((_) async {
        calls++;
        return http.StreamedResponse(
          const Stream.empty(),
          302,
          headers: {'location': location},
        );
      });
      await expectLater(
        _service(client).fetchCampaign(),
        throwsFormatException,
      );
      expect(calls, 1);
    });
  }

  test('204 is a kill switch and malformed JSON is rejected', () async {
    final noCampaign = _Client(
      (_) async => http.StreamedResponse(const Stream.empty(), 204),
    );
    expect(await _service(noCampaign).fetchCampaign(), isNull);
    final malformed = _Client(
      (_) async => http.StreamedResponse(
        Stream.value([123]),
        200,
        headers: {'content-type': 'application/json'},
      ),
    );
    await expectLater(
      _service(malformed).fetchCampaign(),
      throwsFormatException,
    );
  });

  test(
    'endpoint query data is not sent with approved request metadata',
    () async {
      final fixture = File('test/fixtures/startup_ad/campaign.json')
          .readAsBytesSync();
      final client = _Client((request) async {
        expect(request.url.queryParameters.keys.toSet(), {
          'placement',
          'platform',
          'app_version',
          'channel',
          'locale',
        });
        expect(request.followRedirects, isFalse);
        expect(request.headers.keys, ['accept']);
        return http.StreamedResponse(
          Stream.value(fixture),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      expect(await _service(client).fetchCampaign(), isNotNull);
    },
  );
}

HttpStartupAdService _service(http.Client client) => HttpStartupAdService(
  client: client,
  endpoint: Uri.parse('https://api.example.com/startup?token=forbidden'),
  allowedApiHosts: {'api.example.com'},
  platform: 'ios',
  appVersion: '1.1.0',
  channel: 'official',
);

final class _Client extends http.BaseClient {
  _Client(this.handler);
  final Future<http.StreamedResponse> Function(http.BaseRequest) handler;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      handler(request);
}
