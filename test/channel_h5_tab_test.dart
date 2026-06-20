import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'package:admin9_app_flutter/core/theme/app_appearance.dart';
import 'package:admin9_app_flutter/core/theme/app_theme.dart';
import 'package:admin9_app_flutter/data/repositories/channel_repository.dart';
import 'package:admin9_app_flutter/ui/features/home/views/channel_h5_tab.dart';

Widget themedHarness({required Widget child}) {
  return MaterialApp(
    theme: AppTheme.light(
      brand: AppBrand.newsBlueBrand,
      fontLevel: AppFontLevel.standard,
    ),
    home: child,
  );
}

void main() {
  late _RecordingWebViewPlatform platform;

  setUp(() {
    platform = _RecordingWebViewPlatform();
    WebViewPlatform.instance = platform;
  });

  testWidgets('default H5 WebView loads once across parent rebuilds', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const ChannelH5Tab(
          channelId: 'topic',
          channelLabel: '专题',
          url: ChannelRepository.topicH5Url,
        ),
      ),
    );
    await tester.pump();

    expect(platform.controllerCreations, 1);
    expect(platform.loadedUris, [Uri.parse(ChannelRepository.topicH5Url)]);

    await tester.pumpWidget(
      themedHarness(
        child: const ChannelH5Tab(
          channelId: 'topic',
          channelLabel: '专题',
          url: ChannelRepository.topicH5Url,
        ),
      ),
    );
    await tester.pump();

    expect(platform.controllerCreations, 1);
    expect(platform.loadedUris, [Uri.parse(ChannelRepository.topicH5Url)]);

    final updatedUri = Uri.parse(
      'https://wx.wifixc.com/h5/ymapp_subject/#/33/home',
    );
    await tester.pumpWidget(
      themedHarness(
        child: ChannelH5Tab(
          channelId: 'topic',
          channelLabel: '专题',
          url: updatedUri.toString(),
        ),
      ),
    );
    await tester.pump();

    expect(platform.controllerCreations, 1);
    expect(platform.loadedUris, [
      Uri.parse(ChannelRepository.topicH5Url),
      updatedUri,
    ]);
    expect(platform.widgetParams, hasLength(3));
    expect(platform.widgetParams.last.gestureRecognizers, hasLength(1));
    expect(
      platform.widgetParams.last.gestureRecognizers.single.constructor(),
      isA<VerticalDragGestureRecognizer>(),
    );
  });

  testWidgets('default H5 WebView opens child links in a separate page', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const ChannelH5Tab(
          channelId: 'topic',
          channelLabel: '专题',
          url: ChannelRepository.topicH5Url,
        ),
      ),
    );
    await tester.pump();

    final embeddedController = platform.controllers.single;
    final delegate = platform.navigationDelegates.single;
    final documentRootUrl = Uri.parse(
      ChannelRepository.topicH5Url,
    ).replace(fragment: '').toString();

    expect(
      await delegate.request(ChannelRepository.topicH5Url),
      NavigationDecision.navigate,
    );
    expect(
      await delegate.request(documentRootUrl),
      NavigationDecision.navigate,
    );

    final detailUrl = Uri.parse(
      'https://wx.wifixc.com/h5/ymapp_subject/#/32/detail?id=1',
    ).toString();

    expect(await delegate.request(detailUrl), NavigationDecision.prevent);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const Key('in-app-web-page')), findsOneWidget);
    expect(find.text('专题'), findsOneWidget);
    expect(embeddedController.loadedUris, [
      Uri.parse(ChannelRepository.topicH5Url),
    ]);
    expect(platform.controllers, hasLength(2));
    expect(platform.controllers.last.loadedUris, [Uri.parse(detailUrl)]);
  });

  testWidgets('default H5 WebView blocks non-child web navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const ChannelH5Tab(
          channelId: 'topic',
          channelLabel: '专题',
          url: ChannelRepository.topicH5Url,
        ),
      ),
    );
    await tester.pump();

    final embeddedController = platform.controllers.single;
    final delegate = platform.navigationDelegates.single;
    const externalUrl = 'https://example.com/story/42';

    expect(await delegate.request(externalUrl), NavigationDecision.prevent);
    await tester.pump();

    expect(embeddedController.loadedUris, [
      Uri.parse(ChannelRepository.topicH5Url),
    ]);
    expect(platform.controllers, hasLength(1));
    expect(find.byKey(const Key('in-app-web-page')), findsNothing);

    const sameOriginPathUrl = 'https://wx.wifixc.com/h5/ymapp_subject/news/1';
    expect(
      await delegate.request(sameOriginPathUrl),
      NavigationDecision.prevent,
    );
    await tester.pump();

    expect(embeddedController.loadedUris, [
      Uri.parse(ChannelRepository.topicH5Url),
    ]);
    expect(platform.controllers, hasLength(1));
    expect(find.byKey(const Key('in-app-web-page')), findsNothing);
  });

  testWidgets(
    'default H5 WebView lets non-child anchors use default handling',
    (tester) async {
      await tester.pumpWidget(
        themedHarness(
          child: const ChannelH5Tab(
            channelId: 'topic',
            channelLabel: '专题',
            url: ChannelRepository.topicH5Url,
          ),
        ),
      );
      await tester.pump();

      final delegate = platform.navigationDelegates.single;
      final documentAnchorUrl = Uri.parse(
        ChannelRepository.topicH5Url,
      ).replace(fragment: 'section-title').toString();

      expect(
        await delegate.request(documentAnchorUrl),
        NavigationDecision.navigate,
      );
      expect(
        await delegate.request('mailto:editor@example.com'),
        NavigationDecision.navigate,
      );
      expect(find.byKey(const Key('in-app-web-page')), findsNothing);
    },
  );

  testWidgets('default H5 WebView restores root after SPA url change', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const ChannelH5Tab(
          channelId: 'topic',
          channelLabel: '专题',
          url: ChannelRepository.topicH5Url,
        ),
      ),
    );
    await tester.pump();

    final embeddedController = platform.controllers.single;
    final delegate = platform.navigationDelegates.single;
    final detailUrl = Uri.parse(
      'https://wx.wifixc.com/h5/ymapp_subject/#/32/detail?id=1',
    ).toString();

    delegate.changeUrl(detailUrl);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const Key('in-app-web-page')), findsOneWidget);
    expect(embeddedController.loadedUris, [
      Uri.parse(ChannelRepository.topicH5Url),
      Uri.parse(ChannelRepository.topicH5Url),
    ]);
    expect(platform.controllers.last.loadedUris, [Uri.parse(detailUrl)]);
  });

  testWidgets('default H5 WebView installs bridge for anchor clicks', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const ChannelH5Tab(
          channelId: 'topic',
          channelLabel: '专题',
          url: ChannelRepository.topicH5Url,
        ),
      ),
    );
    await tester.pump();

    final embeddedController = platform.controllers.single;
    expect(
      embeddedController.javaScriptChannels,
      contains('Admin9H5LinkBridge'),
    );

    platform.navigationDelegates.single.finishPage(
      ChannelRepository.topicH5Url,
    );
    expect(
      embeddedController.runJavaScripts.single,
      contains('addEventListener'),
    );

    const detailUrl = 'https://wx.wifixc.com/h5/ymapp_subject/#/32/detail?id=1';
    embeddedController.postJavaScriptMessage('Admin9H5LinkBridge', detailUrl);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const Key('in-app-web-page')), findsOneWidget);
    expect(embeddedController.loadedUris, [
      Uri.parse(ChannelRepository.topicH5Url),
    ]);
    expect(platform.controllers.last.loadedUris, [Uri.parse(detailUrl)]);
  });
}

class _RecordingWebViewPlatform extends WebViewPlatform {
  final loadedUris = <Uri>[];
  final widgetParams = <PlatformWebViewWidgetCreationParams>[];
  final controllers = <_RecordingWebViewController>[];
  final navigationDelegates = <_RecordingNavigationDelegate>[];
  var controllerCreations = 0;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    controllerCreations += 1;
    final controller = _RecordingWebViewController(params, this);
    controllers.add(controller);
    return controller;
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    widgetParams.add(params);
    return _RecordingWebViewWidget(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    final delegate = _RecordingNavigationDelegate(params);
    navigationDelegates.add(delegate);
    return delegate;
  }
}

class _RecordingWebViewController extends PlatformWebViewController {
  _RecordingWebViewController(super.params, this.platform)
    : super.implementation();

  final _RecordingWebViewPlatform platform;
  final loadedUris = <Uri>[];
  final runJavaScripts = <String>[];
  final javaScriptChannels = <String, JavaScriptChannelParams>{};
  PlatformNavigationDelegate? navigationDelegate;

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    platform.loadedUris.add(params.uri);
    loadedUris.add(params.uri);
  }

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {
    javaScriptChannels[javaScriptChannelParams.name] = javaScriptChannelParams;
  }

  @override
  Future<void> runJavaScript(String javaScript) async {
    runJavaScripts.add(javaScript);
  }

  void postJavaScriptMessage(String channelName, String message) {
    javaScriptChannels[channelName]?.onMessageReceived(
      JavaScriptMessage(message: message),
    );
  }

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {
    navigationDelegate = handler;
  }
}

class _RecordingNavigationDelegate extends PlatformNavigationDelegate {
  _RecordingNavigationDelegate(super.params) : super.implementation();

  NavigationRequestCallback? onNavigationRequest;
  PageEventCallback? onPageStarted;
  PageEventCallback? onPageFinished;
  ProgressCallback? onProgress;
  WebResourceErrorCallback? onWebResourceError;
  UrlChangeCallback? onUrlChange;

  Future<NavigationDecision> request(
    String url, {
    bool isMainFrame = true,
  }) async {
    final callback = onNavigationRequest;
    if (callback == null) return NavigationDecision.navigate;

    return callback(NavigationRequest(url: url, isMainFrame: isMainFrame));
  }

  void finishPage(String url) {
    onPageFinished?.call(url);
  }

  void startPage(String url) {
    onPageStarted?.call(url);
  }

  void reportProgress(int progress) {
    onProgress?.call(progress);
  }

  void reportWebResourceError(WebResourceError error) {
    onWebResourceError?.call(error);
  }

  void changeUrl(String url) {
    onUrlChange?.call(UrlChange(url: url));
  }

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {
    this.onNavigationRequest = onNavigationRequest;
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {
    this.onPageFinished = onPageFinished;
  }

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {
    this.onPageStarted = onPageStarted;
  }

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {
    this.onProgress = onProgress;
  }

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {
    this.onWebResourceError = onWebResourceError;
  }

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {
    this.onUrlChange = onUrlChange;
  }

  @override
  Future<void> setOnHttpAuthRequest(
    HttpAuthRequestCallback onHttpAuthRequest,
  ) async {}

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) async {}

  @override
  Future<void> setOnSSlAuthError(SslAuthErrorCallback onSslAuthError) async {}
}

class _RecordingWebViewWidget extends PlatformWebViewWidget {
  _RecordingWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(key: Key('recording-webview-widget'));
  }
}
