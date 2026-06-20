import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/widgets/in_app_web_page.dart';

typedef ChannelH5WebViewBuilder =
    Widget Function(
      BuildContext context,
      Uri uri,
      String channelId,
      String channelLabel,
    );

class ChannelH5Tab extends StatefulWidget {
  const ChannelH5Tab({
    super.key,
    required this.channelId,
    required this.channelLabel,
    required this.url,
    this.webViewBuilder = defaultWebViewBuilder,
  });

  final String channelId;
  final String channelLabel;
  final String url;
  final ChannelH5WebViewBuilder webViewBuilder;

  static Widget defaultWebViewBuilder(
    BuildContext context,
    Uri uri,
    String channelId,
    String channelLabel,
  ) {
    return _ChannelH5WebView(
      key: Key('home-channel-h5-webview-$channelId'),
      uri: uri,
      pageTitle: channelLabel,
    );
  }

  @override
  State<ChannelH5Tab> createState() => _ChannelH5TabState();
}

class _ChannelH5TabState extends State<ChannelH5Tab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final uri = Uri.parse(widget.url);

    return ColoredBox(
      key: Key('home-channel-h5-${widget.channelId}'),
      color: context.tokens.pageBackground,
      child: SafeArea(
        top: false,
        bottom: false,
        child: widget.webViewBuilder(
          context,
          uri,
          widget.channelId,
          widget.channelLabel,
        ),
      ),
    );
  }
}

class _ChannelH5WebView extends StatefulWidget {
  const _ChannelH5WebView({
    super.key,
    required this.uri,
    required this.pageTitle,
  });

  final Uri uri;
  final String pageTitle;

  @override
  State<_ChannelH5WebView> createState() => _ChannelH5WebViewState();
}

class _ChannelH5WebViewState extends State<_ChannelH5WebView>
    with AutomaticKeepAliveClientMixin {
  static const _linkBridgeName = 'Admin9H5LinkBridge';
  String get _linkInterceptorScript {
    final rootUrl = _javaScriptString(widget.uri.toString());
    final rootDocumentUrl = _javaScriptString(
      widget.uri.replace(fragment: '').toString(),
    );

    return '''
(function() {
  if (window.__admin9H5LinkInterceptorInstalled) return;
  window.__admin9H5LinkInterceptorInstalled = true;
  var rootUrl = new URL($rootUrl);
  var rootDocumentUrl = new URL($rootDocumentUrl);

  function postUrl(url) {
    if (!url || !window.Admin9H5LinkBridge) return;
    window.Admin9H5LinkBridge.postMessage(String(url));
  }

  function isOpenableHref(url) {
    try {
      var targetUrl = new URL(String(url), window.location.href);
      return targetUrl.protocol === rootUrl.protocol &&
        targetUrl.hostname === rootUrl.hostname &&
        targetUrl.port === rootUrl.port &&
        targetUrl.pathname === rootDocumentUrl.pathname &&
        targetUrl.search === rootDocumentUrl.search &&
        targetUrl.hash &&
        targetUrl.hash.indexOf('#/') === 0 &&
        targetUrl.hash !== rootUrl.hash;
    } catch (_) {
      return false;
    }
  }

  document.addEventListener('click', function(event) {
    var node = event.target;
    while (node && node !== document && !(node.tagName === 'A' && node.href)) {
      node = node.parentNode;
    }
    if (!node || node === document || !node.href) return;
    if (!isOpenableHref(node.href)) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    postUrl(node.href);
  }, true);
})();
''';
  }

  late final WebViewController _controller;
  final _openExternalUrls = <String>{};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        _linkBridgeName,
        onMessageReceived: (message) => _openExternalUrl(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigationRequest,
          onPageFinished: (_) => _installLinkInterceptor(),
          onUrlChange: (change) => _handleUrlChange(change.url),
        ),
      );
    _controller.loadRequest(widget.uri);
  }

  @override
  void didUpdateWidget(covariant _ChannelH5WebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri != widget.uri) {
      _controller.loadRequest(widget.uri);
    }
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    if (!request.isMainFrame || _isRootRequest(request.url)) {
      return NavigationDecision.navigate;
    }

    final requestUri = Uri.tryParse(request.url);
    if (requestUri == null) return NavigationDecision.navigate;

    if (_isOpenableChildUri(requestUri)) {
      _openExternalUrl(request.url);
      return NavigationDecision.prevent;
    }

    if (_isSameDocumentAnchor(requestUri)) {
      return NavigationDecision.navigate;
    }

    return _isWebUri(requestUri)
        ? NavigationDecision.prevent
        : NavigationDecision.navigate;
  }

  void _handleUrlChange(String? url) {
    if (url == null || !_isOpenableChildRoute(url)) return;

    _openExternalUrl(url, restoreEmbeddedRoot: true);
  }

  void _openExternalUrl(String url, {bool restoreEmbeddedRoot = false}) {
    final targetUri = Uri.tryParse(url);
    if (!mounted || targetUri == null || !_isOpenableChildUri(targetUri)) {
      return;
    }

    final targetUrl = targetUri.toString();
    if (_isRootRequest(targetUrl) || _openExternalUrls.contains(targetUrl)) {
      return;
    }
    _openExternalUrls.add(targetUrl);

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) =>
                InAppWebPage(title: widget.pageTitle, url: targetUrl),
          ),
        )
        .whenComplete(() => _openExternalUrls.remove(targetUrl));

    if (restoreEmbeddedRoot) {
      _controller.loadRequest(widget.uri);
    }
  }

  void _installLinkInterceptor() {
    unawaited(_controller.runJavaScript(_linkInterceptorScript));
  }

  bool _isRootRequest(String url) {
    if (url == widget.uri.toString()) return true;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final rootDocumentUri = widget.uri.replace(fragment: '');
    return uri.fragment.isEmpty && uri == rootDocumentUri;
  }

  bool _isOpenableChildRoute(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && _isOpenableChildUri(uri);
  }

  bool _isWebUri(Uri uri) => uri.scheme == 'http' || uri.scheme == 'https';

  bool _isOpenableChildUri(Uri uri) {
    if (!_isWebUri(uri) || uri.fragment.isEmpty) return false;
    if (!uri.fragment.startsWith('/')) return false;

    final rootDocumentUri = widget.uri.replace(fragment: '');
    return uri.replace(fragment: '') == rootDocumentUri &&
        !_isRootRequest(uri.toString());
  }

  bool _isSameDocumentAnchor(Uri uri) {
    if (!_isWebUri(uri) || uri.fragment.isEmpty) return false;
    if (uri.fragment.startsWith('/')) return false;

    final rootDocumentUri = widget.uri.replace(fragment: '');
    return uri.replace(fragment: '') == rootDocumentUri;
  }

  String _javaScriptString(String value) {
    final escaped = value
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
    return "'$escaped'";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WebViewWidget(
      controller: _controller,
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(
          () => VerticalDragGestureRecognizer(),
        ),
      },
    );
  }
}
