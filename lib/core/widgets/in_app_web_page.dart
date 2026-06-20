import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

class InAppWebPage extends StatefulWidget {
  const InAppWebPage({
    super.key,
    required this.title,
    required this.url,
    this.webViewBuilder,
  });

  final String title;
  final String url;
  final Widget Function(WebViewController controller)? webViewBuilder;

  @override
  State<InAppWebPage> createState() => _InAppWebPageState();
}

class _InAppWebPageState extends State<InAppWebPage> {
  late final WebViewController _controller;
  var _progress = 0;
  var _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _hasError = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) return;
            if (mounted) setState(() => _hasError = true);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('in-app-web-page'),
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          widget.webViewBuilder?.call(_controller) ??
              WebViewWidget(
                key: const Key('in-app-web-view'),
                controller: _controller,
              ),
          if (_progress < 100 && !_hasError)
            LinearProgressIndicator(
              key: const Key('in-app-web-progress'),
              value: _progress == 0 ? null : _progress / 100,
            ),
          if (_hasError)
            _WebLoadFallback(
              title: widget.title,
              url: widget.url,
              onRetry: () {
                setState(() => _hasError = false);
                _controller.reload();
              },
            ),
        ],
      ),
    );
  }
}

class _WebLoadFallback extends StatelessWidget {
  const _WebLoadFallback({
    required this.title,
    required this.url,
    required this.onRetry,
  });

  final String title;
  final String url;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('in-app-web-fallback'),
      color: context.tokens.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.typography.sectionTitle),
                const SizedBox(height: AppSpacing.sm),
                Text('页面加载失败，请稍后重试。', style: context.typography.feedSummary),
                const SizedBox(height: AppSpacing.md),
                SelectableText(
                  url,
                  key: const Key('in-app-web-url'),
                  style: context.typography.feedMeta,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  key: const Key('in-app-web-retry'),
                  onPressed: onRetry,
                  child: const Text('重新加载'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
