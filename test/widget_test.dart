import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/core/assets/app_assets.dart';
import 'package:admin9_app_flutter/core/theme/app_appearance.dart';
import 'package:admin9_app_flutter/core/theme/app_spacing.dart';
import 'package:admin9_app_flutter/core/theme/app_theme.dart';
import 'package:admin9_app_flutter/core/widgets/app_card.dart';
import 'package:admin9_app_flutter/core/widgets/app_info_list_item.dart';
import 'package:admin9_app_flutter/core/widgets/app_search_entry.dart';
import 'package:admin9_app_flutter/core/widgets/app_section_header.dart';
import 'package:admin9_app_flutter/core/widgets/app_tab_bar.dart';
import 'package:admin9_app_flutter/core/widgets/article_visual.dart';
import 'package:admin9_app_flutter/core/widgets/content_tag_pill.dart';
import 'package:admin9_app_flutter/core/widgets/foundation_page.dart';
import 'package:admin9_app_flutter/core/widgets/live_stream_player.dart';
import 'package:admin9_app_flutter/core/widgets/media_badge.dart';
import 'package:admin9_app_flutter/core/widgets/message_card.dart';
import 'package:admin9_app_flutter/core/widgets/primary_pill_button.dart';
import 'package:admin9_app_flutter/core/widgets/quick_action_grid.dart';
import 'package:admin9_app_flutter/core/widgets/settings_group.dart';
import 'package:admin9_app_flutter/core/widgets/status_pill.dart';
import 'package:admin9_app_flutter/core/widgets/top_level_page_config.dart';
import 'package:admin9_app_flutter/core/widgets/top_level_page_scaffold.dart';
import 'package:admin9_app_flutter/data/repositories/channel_repository.dart';
import 'package:admin9_app_flutter/data/repositories/foundation_repository.dart';
import 'package:admin9_app_flutter/data/services/local_storage_service.dart';
import 'package:admin9_app_flutter/data/repositories/live_repository.dart';
import 'package:admin9_app_flutter/data/repositories/home_content_repository.dart';
import 'package:admin9_app_flutter/data/repositories/points_repository.dart';
import 'package:admin9_app_flutter/data/repositories/report_repository.dart';
import 'package:admin9_app_flutter/data/repositories/service_repository.dart';
import 'package:admin9_app_flutter/data/repositories/splash_repository.dart';
import 'package:admin9_app_flutter/data/repositories/splash_platform.dart';
import 'package:admin9_app_flutter/data/repositories/user_repository.dart';
import 'package:admin9_app_flutter/domain/models/article.dart';
import 'package:admin9_app_flutter/domain/models/home_block.dart';
import 'package:admin9_app_flutter/domain/models/media_channel.dart';
import 'package:admin9_app_flutter/domain/models/points.dart';
import 'package:admin9_app_flutter/domain/models/service_item.dart';
import 'package:admin9_app_flutter/domain/models/splash_content.dart';
import 'package:admin9_app_flutter/ui/features/foundation/views/about_page.dart';
import 'package:admin9_app_flutter/ui/features/home/views/article_detail_page.dart';
import 'package:admin9_app_flutter/ui/features/home/views/channel_content_blocks.dart';
import 'package:admin9_app_flutter/ui/features/home/view_models/channel_view_model.dart';
import 'package:admin9_app_flutter/ui/features/home/views/channel_content_tab.dart';
import 'package:admin9_app_flutter/ui/features/home/views/home_channel_visual_resolver.dart';
import 'package:admin9_app_flutter/ui/features/search/views/search_page.dart';
import 'package:admin9_app_flutter/ui/features/live/views/live_page.dart';
import 'package:admin9_app_flutter/ui/features/mine/view_models/session_view_model.dart';
import 'package:admin9_app_flutter/ui/features/mine/views/activity_list_page.dart';
import 'package:admin9_app_flutter/ui/features/mine/views/auth_page.dart';
import 'package:admin9_app_flutter/ui/features/mine/views/mine_page.dart';
import 'package:admin9_app_flutter/ui/features/mine/views/settings_page.dart';
import 'package:admin9_app_flutter/ui/features/report/views/report_form_page.dart';
import 'package:admin9_app_flutter/ui/features/report/views/report_page.dart';
import 'package:admin9_app_flutter/ui/features/services/views/services_page.dart';
import 'package:admin9_app_flutter/ui/features/splash/views/splash_page.dart';
import 'package:admin9_app_flutter/ui/shared/app_state_controller.dart';

Widget themedHarness({
  required Widget child,
  AppBrand brand = AppBrand.newsBlueBrand,
  AppFontLevel fontLevel = AppFontLevel.standard,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return MaterialApp(
    theme: AppTheme.light(brand: brand, fontLevel: fontLevel),
    darkTheme: AppTheme.dark(brand: brand, fontLevel: fontLevel),
    themeMode: themeMode,
    home: child,
  );
}

Future<Widget> interactiveHarness({required Widget child}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();

  return MultiProvider(
    providers: [
      Provider<HomeContentRepository>.value(
        value: const HomeContentRepository(),
      ),
      Provider<UserRepository>.value(value: const UserRepository()),
      Provider<LiveRepository>.value(value: const LiveRepository()),
      Provider<ReportRepository>.value(value: const ReportRepository()),
      Provider<ServiceRepository>.value(value: const ServiceRepository()),
      Provider<PointsRepository>.value(value: const PointsRepository()),
      Provider<FoundationRepository>.value(value: const FoundationRepository()),
      ChangeNotifierProvider(
        create: (context) =>
            SessionViewModel(repository: context.read<UserRepository>()),
      ),
      ChangeNotifierProxyProvider<SessionViewModel, AppStateController>(
        create: (_) => AppStateController(
          storage: LocalStorageService(preferences),
          pointsRepository: const PointsRepository(),
        ),
        update: (_, session, state) =>
            state!..setPointsUserKey(session.user?.phone),
      ),
    ],
    child: themedHarness(child: child),
  );
}

Future<void> pumpAdmin9App(
  WidgetTester tester, {
  Map<String, Object> initialPreferences = const {},
  bool autoSkipSplash = true,
}) async {
  SharedPreferences.setMockInitialValues({
    'privacy_guide_accepted': true,
    'onboarding_completed': true,
    ...initialPreferences,
  });
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(admin9AppForTest(preferences));
  await tester.pump();
  final splashSkip = find.byKey(const Key('splash-skip'));
  if (autoSkipSplash && splashSkip.evaluate().isNotEmpty) {
    await tester.tap(splashSkip);
  }
  await tester.pumpAndSettle();
}

Admin9App admin9AppForTest(SharedPreferences preferences) {
  return Admin9App(
    preferences: preferences,
    channelH5WebViewBuilder: fakeChannelH5WebViewBuilder,
    liveStreamPlayerBuilder: fakeLiveStreamPlayerBuilder,
  );
}

Widget fakeLiveStreamPlayerBuilder(
  BuildContext context,
  LiveStreamPlayerConfig config,
  bool muted,
  ValueChanged<bool> onMutedChanged,
) {
  return ColoredBox(
    key: Key('fake-live-stream-player-${config.title}'),
    color: Colors.black,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Text(
            config.url,
            key: const Key('fake-live-stream-url'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        if (config.showMuteButton)
          Positioned(
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: IconButton(
              key: const Key('fake-live-stream-mute'),
              onPressed: () => onMutedChanged(!muted),
              icon: Icon(
                muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: Colors.white,
              ),
            ),
          ),
      ],
    ),
  );
}

Widget fakeChannelH5WebViewBuilder(
  BuildContext context,
  Uri uri,
  String channelId,
  String channelLabel,
) {
  return ColoredBox(
    key: Key('fake-channel-h5-webview-$channelId'),
    color: Colors.transparent,
    child: SizedBox.expand(
      child: Text(uri.toString(), key: Key('fake-channel-h5-url-$channelId')),
    ),
  );
}

Future<void> simulateAppBackgroundResume(WidgetTester tester) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pump();
}

Future<void> simulateTransientInactiveResume(WidgetTester tester) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pump();
}

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 12 && finder.evaluate().isEmpty; i++) {
    await tester.drag(
      find.byKey(const Key('channel-content-list')),
      const Offset(0, -280),
    );
    await tester.pumpAndSettle();
  }
  if (finder.evaluate().isNotEmpty) {
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
  }
  expect(finder, findsWidgets);
}

Future<void> scrollToSafeArea(WidgetTester tester, Finder finder) async {
  await scrollTo(tester, finder);
  expect(finder, findsWidgets);
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await scrollToSafeArea(tester, finder);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

Future<void> tapTextTile(WidgetTester tester, String label) async {
  final text = find.text(label);
  if (text.evaluate().isEmpty) {
    await dragUntilVisible(tester, text);
  }
  var target = find.ancestor(of: text, matching: find.byType(InkWell));
  if (target.evaluate().isEmpty) {
    target = find.ancestor(of: text, matching: find.byType(AppCard));
  }
  if (target.evaluate().isEmpty) {
    target = find.ancestor(of: text, matching: find.byType(FilledButton));
  }
  if (target.evaluate().isEmpty) target = text;
  await tester.ensureVisible(target.last);
  await tester.pumpAndSettle();
  await tester.tap(target.last);
  await tester.pumpAndSettle();
}

Future<void> simulateStatusBarTapAndSettle(WidgetTester tester) async {
  tester.simulateStatusBarTap();
  await tester.pumpAndSettle();
}

Future<void> safePageBack(WidgetTester tester) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  await navigator.maybePop();
  await tester.pumpAndSettle();
}

String splashCacheMetadata({
  DateTime? cachedAt,
  String source = 'assets/images/top_level_jacaranda_header.png',
  String sourceType = 'asset',
  String mediaType = 'image',
  String id = 'xichang-splash-20250320',
  String? actionUrl,
  String? targetTitle,
}) {
  final time = cachedAt ?? DateTime.now();
  final action = actionUrl == null ? '' : ',"action_url":"$actionUrl"';
  final target = targetTitle == null ? '' : ',"target_title":"$targetTitle"';
  return '''
{"id":"$id","title":"城市更新进行时","subtitle":"关注身边变化，发现美好生活","media_type":"$mediaType","duration_seconds":5,"call_to_action":"立即查看","source_type":"$sourceType","source":"$source","cached_at":"${time.toIso8601String()}"$action$target}''';
}

Future<void> pumpScrollToTopUpdate(
  WidgetTester tester, {
  required Widget Function(int request) builder,
  required int request,
}) async {
  await tester.pumpWidget(await interactiveHarness(child: builder(request)));
  await tester.pumpAndSettle();
}

Future<void> dragUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Finder? scrollable,
  Offset step = const Offset(0, -260),
}) async {
  final targetScrollable =
      scrollable ??
      find.byWidgetPredicate((widget) {
        if (widget is! Scrollable) return false;
        final physics = widget.physics;
        return physics is! NeverScrollableScrollPhysics;
      }).last;
  for (final direction in [step, -step]) {
    for (var i = 0; i < 12 && finder.evaluate().isEmpty; i++) {
      await tester.drag(targetScrollable, direction);
      await tester.pumpAndSettle();
    }
    if (finder.evaluate().isNotEmpty) break;
  }
  expect(finder, findsWidgets);
}

Future<void> revealInVerticalScroll(WidgetTester tester, Finder finder) async {
  final scrollable = find
      .byWidgetPredicate(
        (widget) =>
            widget is Scrollable &&
            (widget.axisDirection == AxisDirection.down ||
                widget.axisDirection == AxisDirection.up),
      )
      .last;
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 220, scrollable: scrollable);
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}

Future<void> tapInVerticalScroll(WidgetTester tester, Finder finder) async {
  await revealInVerticalScroll(tester, finder);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

FilledButton filledButtonUnder(Finder parent) {
  return find
      .descendant(of: parent, matching: find.byType(FilledButton))
      .evaluate()
      .map((element) => element.widget)
      .cast<FilledButton>()
      .single;
}

double opacityOf(WidgetTester tester, Key key) {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
  return tester.widget<Opacity>(finder).opacity;
}

Future<void> dragUntilOpacityAbove(
  WidgetTester tester, {
  required Key scrollKey,
  required Key opacityKey,
  double threshold = 0.85,
  Offset step = const Offset(0, -260),
  int maxAttempts = 6,
}) async {
  for (var i = 0; i < maxAttempts; i++) {
    if (opacityOf(tester, opacityKey) >= threshold) return;
    await tester.drag(find.byKey(scrollKey), step);
    await tester.pumpAndSettle();
  }
  expect(opacityOf(tester, opacityKey), greaterThanOrEqualTo(threshold));
}

SystemUiOverlayStyle systemOverlayStyleOf(WidgetTester tester, Key key) {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
  return tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(finder).value;
}

LinearGradient linearGradientOf(WidgetTester tester, Key key) {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
  final decoratedBox = tester.widget<DecoratedBox>(finder);
  final decoration = decoratedBox.decoration as BoxDecoration;
  return decoration.gradient as LinearGradient;
}

double contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;

  return (lighter + 0.05) / (darker + 0.05);
}

Color alphaBlend(Color foreground, Color background) {
  return Color.alphaBlend(foreground, background);
}

void expectColorNear(Color actual, Color expected, {double epsilon = 0.001}) {
  expect(actual.a, moreOrLessEquals(expected.a, epsilon: epsilon));
  expect(actual.r, moreOrLessEquals(expected.r, epsilon: epsilon));
  expect(actual.g, moreOrLessEquals(expected.g, epsilon: epsilon));
  expect(actual.b, moreOrLessEquals(expected.b, epsilon: epsilon));
}

Iterable<Color> brandGradientSamples(AppBrand brand) {
  return [brand.gradientStart, brand.gradientMiddle, brand.gradientEnd];
}

void expectHitTestable(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  final center = tester.getCenter(finder);
  final result = HitTestResult();
  tester.binding.hitTestInView(result, center, tester.view.viewId);
  expect(
    result.path.map((entry) => entry.target),
    contains(tester.renderObject(finder)),
  );
}

Article articleFixture({
  required String id,
  required String title,
  String source = '测试来源',
  String time = '刚刚',
  ArticleContentTag? contentTag,
}) {
  return Article(
    id: id,
    title: title,
    source: source,
    time: time,
    summary: '字体规范测试摘要',
    visuals: const [
      ArticleVisualAsset(label: '主图', type: ArticleVisualType.city),
      ArticleVisualAsset(label: '配图一', type: ArticleVisualType.rural),
      ArticleVisualAsset(label: '配图二', type: ArticleVisualType.service),
    ],
    paragraphs: const ['测试正文'],
    contentTag: contentTag,
  );
}

ContentItem contentItemFixture({
  required String id,
  required String title,
  required ContentItemLayout layout,
  ContentKind kind = ContentKind.article,
  String source = '测试来源',
  String time = '刚刚',
  ArticleContentTag? contentTag,
  SurfaceStyle surface = SurfaceStyle.card,
}) {
  return ContentItem(
    id: id,
    title: title,
    contentKind: kind,
    layout: layout,
    surface: surface,
    article: articleFixture(
      id: id,
      title: title,
      source: source,
      time: time,
      contentTag: contentTag,
    ),
  );
}

ContentItem mediaFeatureItemFixture({
  required String id,
  required String title,
  required String subtitle,
  List<Article> articles = const [],
}) {
  return ContentItem(
    id: id,
    title: title,
    contentKind: ContentKind.special,
    layout: ContentItemLayout.mediaFeature,
    article: articleFixture(id: '$id-article', title: title),
    mediaFeature: MediaFeatureContent(
      title: title,
      subtitle: subtitle,
      articles: articles,
    ),
  );
}

TextStyle? textStyleOf(WidgetTester tester, String text) {
  return tester.widget<Text>(find.text(text).first).style;
}

void main() {
  testWidgets('design tokens expose foundation spacing and semantic colors', (
    tester,
  ) async {
    expect(AppSpacing.pageX, 16);
    expect(AppSpacing.sectionGap, 14);
    expect(AppSpacing.cardPadding, 16);
    expect(AppSpacing.cardRadius, 8);
    expect(AppSpacing.rowMinHeight, 56);
    expect(AppSpacing.minTouchTarget, 44);
    expect(AppSpacing.topLevelToolbarHeight, 56);
    expect(AppSpacing.topLevelBackdropCanvasHeight, 224);
    expect(AppSpacing.topLevelBackdropHeight, 224);
    expect(AppSpacing.topLevelPinnedChannelHeight, 48);
    expect(AppSpacing.topLevelSearchHeight, 56);
    expect(AppSpacing.topLevelPinnedHomeHeaderHeight, 104);
    expect(AppSpacing.homeSearchTopGap, 8);
    expect(AppSpacing.homeSearchBottomGap, 4);
    expect(AppSpacing.contentMaxWidth, 560);

    await tester.pumpWidget(
      themedHarness(
        child: Builder(
          builder: (context) {
            final tokens = context.tokens;
            return Scaffold(
              body: Column(
                children: [
                  ColoredBox(color: tokens.warning, child: const SizedBox()),
                  ColoredBox(color: tokens.success, child: const SizedBox()),
                  ColoredBox(color: tokens.info, child: const SizedBox()),
                  ColoredBox(color: tokens.pressed, child: const SizedBox()),
                  ColoredBox(color: tokens.selected, child: const SizedBox()),
                  ColoredBox(color: tokens.unread, child: const SizedBox()),
                ],
              ),
            );
          },
        ),
      ),
    );

    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    final tokens = theme.extension<AppThemeTokens>()!;
    expect(tokens.surface, tokens.cardBackground);
    expect(tokens.warning, isA<Color>());
    expect(tokens.success, isA<Color>());
    expect(tokens.info, isA<Color>());
    expect(tokens.pressed, isA<Color>());
    expect(tokens.selected, isA<Color>());
    expect(tokens.unread, tokens.danger);
  });

  test('typography exposes converged page, feed, and meta roles', () {
    final theme = AppTheme.light();
    final tokens = theme.extension<AppThemeTokens>()!;
    final typography = theme.extension<AppTypography>()!;

    expect(typography.pageTitle.fontSize, 26);
    expect(typography.pageTitle.fontWeight, FontWeight.w700);
    expect(typography.sectionTitle.fontSize, 20);
    expect(typography.sectionTitle.fontWeight, FontWeight.w500);
    expect(typography.cardSectionTitle.fontSize, 18);
    expect(typography.cardSectionTitle.fontWeight, FontWeight.w600);
    expect(typography.cardSectionTitle.height, 1.28);
    expect(typography.feedTitle.fontSize, 19);
    expect(typography.feedTitle.fontWeight, FontWeight.w400);
    expect(typography.feedTitle.height, 1.42);
    expect(typography.feedTitleCompact.fontSize, 17);
    expect(typography.feedTitleCompact.fontWeight, FontWeight.w400);
    expect(
      typography.feedMeta.fontSize,
      closeTo(14 * AppFontLevel.standard.scale, 0.001),
    );
    expect(typography.feedMeta.fontWeight, FontWeight.w400);
    expect(typography.tabLabel.fontSize, 17);
    expect(typography.tabLabel.fontWeight, FontWeight.w500);
    expect(typography.settingsTitle.fontSize, 17);
    expect(typography.settingsTitle.fontWeight, FontWeight.w500);
    expect(typography.settingsValue.fontSize, 17);
    expect(typography.settingsValue.fontWeight, FontWeight.w400);
    expect(typography.bodyText.fontSize, 17);
    expect(typography.bodyText.fontWeight, FontWeight.w400);
    expect(typography.bodyText.height, 1.65);
    expect(typography.actionLabel.fontSize, 15);
    expect(typography.actionLabel.fontWeight, FontWeight.w500);
    expect(typography.label.fontSize, 13);
    expect(typography.feedTitle.color, tokens.textPrimary);
    expect(typography.cardSectionTitle.color, tokens.textPrimary);
    expect(typography.feedMeta.color, tokens.textTertiary);
    expect(typography.tabLabel.color, tokens.textPrimary);
    expect(typography.settingsTitle.color, tokens.textPrimary);
    expect(typography.settingsValue.color, tokens.textSecondary);
    expect(typography.bodyText.color, tokens.textPrimary);
    expect(typography.actionLabel.color, tokens.textPrimary);

    final largeTypography = AppTheme.light(
      fontLevel: AppFontLevel.large,
    ).extension<AppTypography>()!;
    expect(
      largeTypography.feedTitle.fontSize,
      closeTo(19 * AppFontLevel.large.scale, 0.001),
    );
    expect(
      largeTypography.cardSectionTitle.fontSize,
      closeTo(18 * AppFontLevel.large.scale, 0.001),
    );
    expect(
      largeTypography.feedMeta.fontSize,
      closeTo(14 * AppFontLevel.large.scale, 0.001),
    );
    expect(
      largeTypography.tabLabel.fontSize,
      closeTo(17 * AppFontLevel.large.scale, 0.001),
    );
    expect(
      largeTypography.settingsTitle.fontSize,
      closeTo(17 * AppFontLevel.large.scale, 0.001),
    );
    expect(
      largeTypography.settingsValue.fontSize,
      closeTo(17 * AppFontLevel.large.scale, 0.001),
    );
    expect(
      largeTypography.bodyText.fontSize,
      closeTo(17 * AppFontLevel.large.scale, 0.001),
    );
    expect(
      largeTypography.actionLabel.fontSize,
      closeTo(15 * AppFontLevel.large.scale, 0.001),
    );
  });

  testWidgets('app section header owns title typography and stable actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageX),
            child: Column(
              children: [
                const AppSectionHeader(title: '便民服务'),
                AppSectionHeader(
                  title: '便民服务',
                  actionLabel: '更多',
                  onActionTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final typography = Theme.of(
      tester.element(find.text('便民服务').first),
    ).extension<AppTypography>()!;
    expect(textStyleOf(tester, '便民服务'), typography.sectionTitle);

    final headers = find.byKey(const Key('app-section-header'));
    expect(headers, findsNWidgets(2));
    expect(
      tester.getSize(headers.at(0)).height,
      moreOrLessEquals(tester.getSize(headers.at(1)).height, epsilon: 1),
    );
  });

  testWidgets('app info list item owns icon row layout and overflow', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      themedHarness(
        child: Material(
          child: SizedBox(
            width: 240,
            child: AppInfoListCard(
              icon: Icons.search,
              title: '很长很长很长的信息列表标题',
              subtitle: '很长很长很长的信息列表副标题',
              meta: '刚刚',
              unread: true,
              trailing: const Text('99'),
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text('很长很长很长的信息列表标题'));
    final detail = tester.widget<Text>(find.text('很长很长很长的信息列表副标题 · 刚刚'));
    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(detail.maxLines, 2);
    expect(detail.overflow, TextOverflow.ellipsis);
    expect(
      find.byKey(const Key('app-info-list-unread-marker')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

    await tester.tap(find.byType(AppInfoListCard));
    expect(taps, 1);
  });

  testWidgets(
    'article feed variants consume shared title and meta typography',
    (tester) async {
      final items = [
        contentItemFixture(
          id: 'feed-text-image',
          title: '图文信息流标题',
          source: '图文来源',
          time: '刚刚',
          layout: ContentItemLayout.sideImage,
        ),
        contentItemFixture(
          id: 'feed-large-image',
          title: '大图信息流标题',
          source: '大图来源',
          time: '10分钟前',
          layout: ContentItemLayout.largeImage,
        ),
        contentItemFixture(
          id: 'feed-multi-images',
          title: '三图信息流标题',
          source: '三图来源',
          time: '昨天',
          layout: ContentItemLayout.imageGrid,
        ),
      ];

      await tester.pumpWidget(
        themedHarness(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.pageX),
                child: ContentFeedBlock(headerTitle: '本地关注', items: items),
              ),
            ),
          ),
        ),
      );

      final typography = Theme.of(
        tester.element(find.text('本地关注')),
      ).extension<AppTypography>()!;
      expect(textStyleOf(tester, '本地关注'), typography.sectionTitle);
      for (final item in items) {
        final article = item.article;
        expect(textStyleOf(tester, article.title), typography.feedTitle);
        expect(textStyleOf(tester, article.time), typography.feedMeta);
      }
      expect(find.text('测试'), findsNothing);
      expect(find.text('推荐'), findsNothing);
    },
  );

  test('typed article content tags expose taxonomy labels only', () {
    expect(ArticleContentTag.politics.label, '时政');
    expect(ArticleContentTag.live.label, '直播');
    expect(ArticleContentTag.video.label, '视频');
    expect(ArticleContentTag.cultureTourism.label, '文旅');
    expect(ArticleContentTag.sports.label, '体育');
    expect(ArticleContentTag.politicalVoice.label, '政声');

    final blocks = [
      ...const HomeContentRepository().blocksForChannel('recommend'),
      ...const HomeContentRepository().blocksForChannel('politics'),
    ];
    final tags = [
      for (final block in blocks) ...[
        for (final item in block.items) ...[
          item.article.contentTag,
          if (item.mediaFeature != null)
            for (final article in item.mediaFeature!.articles)
              article.contentTag,
        ],
      ],
    ].whereType<ArticleContentTag>();

    expect(tags, isNot(contains(null)));
    expect(tags.map((tag) => tag.label), isNot(contains('推荐')));
    expect(tags.map((tag) => tag.label), isNot(contains('热门')));
    expect(tags.map((tag) => tag.label), isNot(contains('置顶')));
  });

  testWidgets('content kind stays independent from item layout', (
    tester,
  ) async {
    final items = [
      contentItemFixture(
        id: 'gallery-large',
        title: '图集也可以大图展示',
        kind: ContentKind.gallery,
        layout: ContentItemLayout.largeImage,
      ),
      contentItemFixture(
        id: 'gallery-multi',
        title: '图集也可以多图展示',
        kind: ContentKind.gallery,
        layout: ContentItemLayout.imageGrid,
      ),
    ];

    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(body: ContentFeedBlock(items: items)),
      ),
    );

    expect(find.byKey(const Key('content-item-gallery-large')), findsOneWidget);
    expect(
      find.byKey(const Key('content-item-gallery-multi-multi-images')),
      findsOneWidget,
    );
  });

  testWidgets('text content layout renders without article visual', (
    tester,
  ) async {
    await tester.pumpWidget(
      await interactiveHarness(
        child: Scaffold(
          body: ContentFeedBlock(
            items: [
              contentItemFixture(
                id: 'text-only-feed',
                title: '纯文字信息流标题',
                layout: ContentItemLayout.text,
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('content-item-text-only-feed')),
      findsOneWidget,
    );
    expect(find.text('纯文字信息流标题'), findsOneWidget);
    expect(find.byType(ArticleVisual), findsNothing);
  });

  test('article feed headers reject generic distribution words', () {
    final repository = const HomeContentRepository();
    final feedBlocks = [
      ...repository.blocksForChannel('recommend'),
      ...repository.blocksForChannel('politics'),
    ].where((block) => block.type == PageBlockType.contentFeed);
    const genericDistributionWords = {'推荐', '热门', '置顶'};

    expect(feedBlocks, isNotEmpty);
    for (final block in feedBlocks) {
      if (block.id == 'content-feed-main') {
        expect(block.displayTitle, isNull);
      }
      expect(
        genericDistributionWords,
        isNot(contains(block.displayTitle?.trim())),
      );
    }
  });

  testWidgets('article detail uses content tag pill and hides null tags', (
    tester,
  ) async {
    final taggedArticle = articleFixture(
      id: 'detail-tagged',
      title: '详情页真实分类标题',
      contentTag: ArticleContentTag.politics,
    );
    final untaggedArticle = articleFixture(
      id: 'detail-untagged',
      title: '详情页无标签标题',
    );

    await tester.pumpWidget(
      await interactiveHarness(
        child: ArticleDetailPage(article: taggedArticle),
      ),
    );
    expect(find.text('时政'), findsOneWidget);
    expect(find.text('测试来源 · 刚刚'), findsOneWidget);
    expect(find.byType(ContentTagPill), findsOneWidget);
    expect(find.byType(StatusPill), findsNothing);

    await tester.pumpWidget(
      await interactiveHarness(
        child: ArticleDetailPage(article: untaggedArticle),
      ),
    );
    expect(find.text('时政'), findsNothing);
    expect(find.text('测试来源 · 刚刚'), findsOneWidget);
    expect(find.byType(ContentTagPill), findsNothing);
    expect(find.byType(StatusPill), findsNothing);
  });

  testWidgets('article visual media duration uses media badge semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const Scaffold(
          body: ArticleVisual(
            label: '视频封面',
            type: ArticleVisualType.live,
            height: 180,
            showPlay: true,
            duration: '06:55',
          ),
        ),
      ),
    );

    expect(find.text('06:55'), findsOneWidget);
    expect(find.byType(MediaBadge), findsOneWidget);
    expect(find.byType(StatusPill), findsNothing);
  });

  testWidgets('home channel content boundary golden keeps card title quiet', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pageX),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TileGridBlock(
                    title: '便民服务',
                    tiles: const [
                      TileGridItem(
                        id: 'weather',
                        title: '天气',
                        visual: ArticleVisualAsset(
                          label: '天气',
                          type: ArticleVisualType.service,
                        ),
                      ),
                      TileGridItem(
                        id: 'traffic',
                        title: '交通',
                        visual: ArticleVisualAsset(
                          label: '交通',
                          type: ArticleVisualType.city,
                        ),
                      ),
                      TileGridItem(
                        id: 'policy',
                        title: '政策',
                        visual: ArticleVisualAsset(
                          label: '政策',
                          type: ArticleVisualType.politics,
                        ),
                        badge: '新',
                      ),
                      TileGridItem(
                        id: 'help',
                        title: '帮办',
                        visual: ArticleVisualAsset(
                          label: '帮办',
                          type: ArticleVisualType.service,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  ContentFeedBlock(
                    items: [
                      contentItemFixture(
                        id: 'golden-large',
                        title: '信息流标题应该保持统一表现',
                        source: '规范测试',
                        time: '刚刚',
                        layout: ContentItemLayout.largeImage,
                        contentTag: ArticleContentTag.politics,
                      ),
                      contentItemFixture(
                        id: 'golden-text',
                        title: '图文卡标题不能因为布局变化而漂移',
                        source: '规范测试',
                        time: '10分钟前',
                        layout: ContentItemLayout.sideImage,
                        contentTag: ArticleContentTag.video,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home_channel_content_semantics.png'),
    );
  });

  test('notice bar block renderability follows notice item payload', () {
    const emptyNoticeBlock = PageBlock(
      id: 'empty-notice',
      type: PageBlockType.noticeBar,
      adminName: '空公告',
      sort: 1,
    );
    const filledNoticeBlock = PageBlock(
      id: 'filled-notice',
      type: PageBlockType.noticeBar,
      adminName: '有公告',
      sort: 2,
      noticeItems: [NoticeItem(id: 'notice-one', title: '有公告内容')],
    );

    expect(emptyNoticeBlock.hasRenderablePayload, isFalse);
    expect(filledNoticeBlock.hasRenderablePayload, isTrue);
  });

  testWidgets('notice bar block renders one-line ticker and advances notices', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const Scaffold(
          body: NoticeBarBlock(
            blockId: 'ticker-test',
            config: NoticeBarConfig(intervalMs: 120),
            items: [
              NoticeItem(id: 'late', title: '后展示公告', sort: 20),
              NoticeItem(id: 'early', title: '先展示公告', sort: 10),
            ],
          ),
        ),
      ),
    );

    final block = find.byKey(const Key('notice-bar-block-ticker-test'));
    expect(block, findsOneWidget);
    expect(tester.getSize(block).height, 30);
    expect(find.byKey(const Key('notice-item-early')), findsOneWidget);
    expect(find.byKey(const Key('notice-item-late')), findsNothing);

    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('notice-item-early')), findsNothing);
    expect(find.byKey(const Key('notice-item-late')), findsOneWidget);
  });

  testWidgets('single notice bar item stays static without ticker loop', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const Scaffold(
          body: NoticeBarBlock(
            blockId: 'single-test',
            config: NoticeBarConfig(intervalMs: 80),
            items: [NoticeItem(id: 'single', title: '单条公告静态展示')],
          ),
        ),
      ),
    );

    expect(find.text('单条公告静态展示'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 240));
    await tester.pumpAndSettle();
    expect(find.text('单条公告静态展示'), findsOneWidget);
  });

  test(
    'home content repository exposes three recommend notice bar fixtures',
    () {
      final noticeBlocks = const HomeContentRepository()
          .blocksForChannel('recommend')
          .where((block) => block.type == PageBlockType.noticeBar)
          .toList();

      expect(noticeBlocks.map((block) => block.id), [
        'notice-bar-headlines',
        'notice-bar-local',
        'notice-bar-live',
      ]);
      expect(
        noticeBlocks.every((block) => block.noticeItems.isNotEmpty),
        isTrue,
      );
      expect(
        noticeBlocks.every((block) => block.noticeItems.length > 1),
        isTrue,
      );
      expect(noticeBlocks.map((block) => block.sort), [10, 11, 12]);
      expect(
        noticeBlocks.every((block) => block.channelId == 'recommend'),
        isTrue,
      );
    },
  );

  test('home content repository keeps prototype more-target metadata', () {
    final blocks = const HomeContentRepository().blocksForChannel('recommend');
    final feedBlock = blocks.singleWhere(
      (block) => block.id == 'content-feed-main',
    );
    final serviceBlock = blocks.singleWhere(
      (block) => block.id == 'home-top-service-navigation',
    );

    expect(feedBlock.channelId, 'recommend');
    expect(feedBlock.moreLabel, '查看更多');
    expect(feedBlock.moreTarget, 'app://prototype/channel/recommend/feed');
    expect(serviceBlock.type, PageBlockType.serviceNavigation);
    expect(serviceBlock.sort, 35);
  });

  testWidgets('home top service navigation block renders configured sections', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      themedHarness(
        child: MultiProvider(
          providers: [
            Provider<ServiceRepository>.value(
              value: const _CompactServiceRepository(),
            ),
            ChangeNotifierProvider(
              create: (_) =>
                  AppStateController(storage: LocalStorageService(preferences)),
            ),
          ],
          child: const Scaffold(
            body: SingleChildScrollView(child: HomeServiceNavigationBlock()),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('home-service-navigation')), findsOneWidget);
    final serviceCard = tester.widget<AppCard>(
      find.descendant(
        of: find.byKey(const Key('service-section-government')),
        matching: find.byType(AppCard),
      ),
    );
    expect(serviceCard.padding, const EdgeInsets.fromLTRB(14, 12, 14, 14));
    expect(serviceCard.radius, AppRadius.input);
    expect(serviceCard.showBorder, isFalse);
    expect(find.text('政务服务'), findsOneWidget);
    expect(find.text('智慧医疗'), findsOneWidget);
    expect(find.text('最近使用'), findsNothing);
  });

  testWidgets('home service navigation adapts grid columns to compact width', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    Future<void> pumpAtWidth(double width) async {
      await tester.binding.setSurfaceSize(Size(width, 760));
      await tester.pumpWidget(
        themedHarness(
          child: MultiProvider(
            providers: [
              Provider<ServiceRepository>.value(
                value: const _DenseServiceRepository(),
              ),
              ChangeNotifierProvider(
                create: (_) => AppStateController(
                  storage: LocalStorageService(preferences),
                ),
              ),
            ],
            child: const Scaffold(
              body: SingleChildScrollView(child: HomeServiceNavigationBlock()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpAtWidth(320);
    var gridDelegate =
        tester
                .widget<GridView>(
                  find.byKey(const Key('quick-action-grid-service-government')),
                )
                .gridDelegate
            as SliverGridDelegateWithFixedCrossAxisCount;
    expect(gridDelegate.crossAxisCount, 3);

    await pumpAtWidth(390);
    gridDelegate =
        tester
                .widget<GridView>(
                  find.byKey(const Key('quick-action-grid-service-government')),
                )
                .gridDelegate
            as SliverGridDelegateWithFixedCrossAxisCount;
    expect(gridDelegate.crossAxisCount, 4);
  });

  testWidgets('article feed can render without an in-stream title', (
    tester,
  ) async {
    await tester.pumpWidget(
      await interactiveHarness(
        child: Scaffold(
          body: ContentFeedBlock(
            items: [
              contentItemFixture(
                id: 'untitled-feed',
                title: '无标题信息流第一条',
                layout: ContentItemLayout.sideImage,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('content-feed-block')), findsOneWidget);
    expect(find.text('无标题信息流第一条'), findsOneWidget);
    expect(find.text('推荐'), findsNothing);
  });

  testWidgets('article feed can render a meaningful header title', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(
          body: ContentFeedBlock(
            headerTitle: '本地关注',
            items: [
              contentItemFixture(
                id: 'named-feed',
                title: '命名信息流第一条',
                layout: ContentItemLayout.sideImage,
              ),
            ],
          ),
        ),
      ),
    );

    final typography = Theme.of(
      tester.element(find.text('本地关注')),
    ).extension<AppTypography>()!;
    expect(find.byKey(const Key('content-feed-block')), findsOneWidget);
    expect(find.text('本地关注'), findsOneWidget);
    expect(textStyleOf(tester, '本地关注'), typography.sectionTitle);
    expect(find.text('命名信息流第一条'), findsOneWidget);
    expect(find.text('推荐'), findsNothing);
  });

  testWidgets('channel content tab applies block-level content list surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(
          body: ChannelContentTab(
            blocks: [
              PageBlock(
                id: 'card-surface-list',
                type: PageBlockType.contentFeed,
                adminName: '测试内容流',
                sort: 10,
                surface: SurfaceStyle.card,
                items: [
                  contentItemFixture(
                    id: 'plain-item',
                    title: '区块卡片外壳测试',
                    layout: ContentItemLayout.sideImage,
                    surface: SurfaceStyle.plain,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('区块卡片外壳测试'), findsOneWidget);
    expect(find.byType(AppCard), findsNWidgets(2));
  });

  testWidgets(
    'page block list filters hidden blocks and sorts renderable blocks',
    (tester) async {
      await tester.pumpWidget(
        themedHarness(
          child: Scaffold(
            body: ChannelContentTab(
              blocks: [
                PageBlock(
                  id: 'visible-late',
                  type: PageBlockType.noticeBar,
                  adminName: '后置公告',
                  sort: 20,
                  noticeItems: const [NoticeItem(id: 'late', title: '后展示公告')],
                ),
                PageBlock(
                  id: 'disabled',
                  type: PageBlockType.noticeBar,
                  adminName: '禁用公告',
                  sort: 1,
                  enabled: false,
                  noticeItems: const [
                    NoticeItem(id: 'disabled', title: '不应展示'),
                  ],
                ),
                PageBlock(
                  id: 'visible-early',
                  type: PageBlockType.noticeBar,
                  adminName: '前置公告',
                  sort: 10,
                  noticeItems: const [NoticeItem(id: 'early', title: '先展示公告')],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('不应展示'), findsNothing);
      expect(find.textContaining('先展示公告'), findsOneWidget);
      expect(find.textContaining('后展示公告'), findsOneWidget);
      expect(
        tester.getTopLeft(find.textContaining('先展示公告')).dy,
        lessThan(tester.getTopLeft(find.textContaining('后展示公告')).dy),
      );
    },
  );

  testWidgets('channel content tab filters inactive prototype time windows', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(
          body: ChannelContentTab(
            now: DateTime.parse('2026-06-07T12:00:00'),
            blocks: const [
              PageBlock(
                id: 'expired-notice',
                type: PageBlockType.noticeBar,
                adminName: '过期公告',
                sort: 1,
                endAt: '2026-06-07T11:59:59',
                noticeItems: [NoticeItem(id: 'expired', title: '不应展示过期公告')],
              ),
              PageBlock(
                id: 'future-notice',
                type: PageBlockType.noticeBar,
                adminName: '未开始公告',
                sort: 2,
                startAt: '2026-06-07T12:00:01',
                noticeItems: [NoticeItem(id: 'future', title: '不应展示未开始公告')],
              ),
              PageBlock(
                id: 'active-notice',
                type: PageBlockType.noticeBar,
                adminName: '有效公告',
                sort: 3,
                startAt: '2026-06-07T11:00:00',
                endAt: '2026-06-07T13:00:00',
                noticeItems: [NoticeItem(id: 'active', title: '应展示有效公告')],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('不应展示过期公告'), findsNothing);
    expect(find.text('不应展示未开始公告'), findsNothing);
    expect(find.text('应展示有效公告'), findsOneWidget);
  });

  testWidgets(
    'channel content tab shows empty state after filtering all blocks',
    (tester) async {
      await tester.pumpWidget(
        themedHarness(
          child: Scaffold(
            body: ChannelContentTab(
              now: DateTime.parse('2026-06-07T12:00:00'),
              emptyTitle: '政声 暂无内容',
              emptyMessage: '当前频道内容暂不可展示。',
              blocks: const [
                PageBlock(
                  id: 'future-only-notice',
                  type: PageBlockType.noticeBar,
                  adminName: '未开始公告',
                  sort: 1,
                  startAt: '2026-06-07T12:00:01',
                  noticeItems: [NoticeItem(id: 'future', title: '不应展示未开始公告')],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('channel-content-empty')), findsOneWidget);
      expect(find.text('政声 暂无内容'), findsOneWidget);
      expect(find.text('当前频道内容暂不可展示。'), findsOneWidget);
      expect(find.text('不应展示未开始公告'), findsNothing);
    },
  );

  testWidgets('special entry renders as image-only vertical carousel', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SpecialEntryBlock(
                  entries: const [
                    SpecialEntryItem(
                      id: 'entry',
                      specialId: 'special-one',
                      title: '专题入口标题',
                      visual: ArticleVisualAsset(
                        label: '专题入口',
                        type: ArticleVisualType.politics,
                        imageUrl: 'https://example.com/entry.png',
                      ),
                      badge: '专题',
                    ),
                    SpecialEntryItem(
                      id: 'entry-two',
                      specialId: 'special-two',
                      title: '第二个专题入口',
                      visual: ArticleVisualAsset(
                        label: '第二专题入口',
                        type: ArticleVisualType.politics,
                        imageUrl: 'https://example.com/entry-two.png',
                      ),
                      badge: '专题',
                    ),
                  ],
                ),
                SpecialContentGroupBlock(
                  headerTitle: '专题内容组标题',
                  items: [
                    contentItemFixture(
                      id: 'special-content',
                      title: '专题内容文章',
                      layout: ContentItemLayout.sideImage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('special-entry-block')), findsOneWidget);
    expect(find.byKey(const Key('special-entry-carousel')), findsOneWidget);
    expect(
      find.byKey(const Key('special-entry-animated-switcher')),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const Key('special-entry-carousel'))).height,
      72,
    );
    expect(find.byKey(const Key('network-image-专题入口')), findsOneWidget);
    expect(find.text('专题入口标题'), findsNothing);
    expect(find.text('专题'), findsNothing);

    await tester.fling(
      find.byKey(const Key('special-entry-carousel')),
      const Offset(0, -80),
      700,
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('network-image-第二专题入口')), findsOneWidget);

    expect(find.text('专题内容组标题'), findsOneWidget);
    expect(find.text('专题内容文章'), findsOneWidget);
  });

  testWidgets('special entry opens the configured in-app web URL', (
    tester,
  ) async {
    const targetUrl =
        'https://wx.wifixc.com/h5/ymapp_subject/#/32/subject?id=45';

    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(
          body: SpecialEntryBlock(
            webPageBuilder: (title, url) => Scaffold(
              key: const Key('special-entry-test-web-page'),
              body: Column(
                children: [
                  Text(title, key: const Key('special-entry-test-web-title')),
                  Text(url, key: const Key('special-entry-test-web-url')),
                ],
              ),
            ),
            entries: const [
              SpecialEntryItem(
                id: '2026633285145427970',
                specialId: '2026633285145427970',
                title: '树立和践行正确政绩观学习教育',
                visual: ArticleVisualAsset(
                  label: '树立和践行正确政绩观学习教育',
                  type: ArticleVisualType.politics,
                  imageUrl:
                      'https://kscgc.scgchc.com/layout/image/2026/02/25/1772024861566_zJ3HYcm3.jpg',
                ),
                targetUrl: targetUrl,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('special-entry-carousel')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('special-entry-test-web-page')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('special-entry-test-web-title')),
      findsOneWidget,
    );
    expect(find.text(targetUrl), findsOneWidget);
  });

  testWidgets(
    'media showcase and feature rows keep media semantics without block-title noise',
    (tester) async {
      final politicsArticle = articleFixture(
        id: 'politics-row',
        title: '政声新闻紧凑标题',
        source: '政声来源',
        time: '昨天 18:48',
      );

      await tester.pumpWidget(
        themedHarness(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.pageX),
                child: Column(
                  children: [
                    MediaShowcaseBlock(
                      items: const [
                        MediaShowcaseItem(
                          id: 'live-row',
                          kind: MediaKind.live,
                          title: '直播条紧凑标题',
                          visual: ArticleVisualAsset(
                            label: '直播来源',
                            type: ArticleVisualType.live,
                          ),
                          durationText: 'LIVE',
                          badge: '直播中',
                        ),
                        MediaShowcaseItem(
                          id: 'video-row',
                          kind: MediaKind.video,
                          title: '视频缩略标题',
                          visual: ArticleVisualAsset(
                            label: '视频来源',
                            type: ArticleVisualType.live,
                          ),
                          durationText: '06:55',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ContentFeedItemRenderer(
                      item: mediaFeatureItemFixture(
                        id: 'mediaFeature-compact',
                        title: '测试人物',
                        subtitle: '测试职务',
                        articles: [politicsArticle],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final typography = Theme.of(
        tester.element(find.text('直播条紧凑标题')),
      ).extension<AppTypography>()!;
      expect(
        textStyleOf(tester, '直播条紧凑标题'),
        typography.feedTitle.copyWith(fontSize: 18),
      );
      expect(find.text('直播中'), findsOneWidget);
      expect(find.text('视频'), findsOneWidget);
      expect(find.text('06:55'), findsOneWidget);
      expect(textStyleOf(tester, '政声新闻紧凑标题'), typography.feedTitleCompact);
      expect(textStyleOf(tester, '昨天 18:48'), typography.feedMeta);
      expect(find.text('正在关注'), findsNothing);
      expect(find.text('推荐'), findsNothing);
    },
  );

  testWidgets('media showcase block ignores empty item lists safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const Scaffold(body: MediaShowcaseBlock(items: [])),
      ),
    );

    expect(find.byKey(const Key('media-showcase-empty')), findsOneWidget);
    expect(find.byKey(const Key('media-showcase-block')), findsNothing);
  });

  testWidgets('live page pins tabs at the top without a duplicate title', (
    tester,
  ) async {
    await tester.pumpWidget(
      await interactiveHarness(
        child: LivePage(streamPlayerBuilder: fakeLiveStreamPlayerBuilder),
      ),
    );

    final typography = Theme.of(
      tester.element(find.text('热门节目')),
    ).extension<AppTypography>()!;
    expect(textStyleOf(tester, '热门节目'), typography.sectionTitle);
    expect(
      find.ancestor(
        of: find.text('热门节目'),
        matching: find.byType(AppSectionHeader),
      ),
      findsOneWidget,
    );

    expect(
      find.byKey(const Key('top-level-scroll-edge-backdrop-直播')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('top-level-toolbar-直播')), findsNothing);
    expect(find.byKey(const Key('top-level-toolbar-title-直播')), findsNothing);
    expect(find.byKey(const Key('live-search-entry')), findsNothing);
    expect(find.byKey(const Key('live-tabs-sliver')), findsOneWidget);
    expect(find.byKey(const Key('live-pinned-tab-bar')), findsOneWidget);
    expect(find.byKey(const Key('live-tab-view')), findsOneWidget);
    expect(find.text('电视直播'), findsOneWidget);
    expect(find.text('广播直播'), findsOneWidget);
    expect(find.text('互动直播'), findsOneWidget);
    expect(find.byKey(const Key('tv-live-channel-selector')), findsNothing);
    expect(find.byKey(const Key('top-level-toolbar-blur-直播')), findsNothing);
    expect(find.byKey(const Key('top-level-toolbar-tint-直播')), findsNothing);
    expect(find.byKey(const Key('top-level-toolbar-divider-直播')), findsNothing);
    expect(
      find.byKey(const Key('top-level-toolbar-background-opacity-直播')),
      findsNothing,
    );
    expect(find.byKey(const Key('top-level-chrome-backdrop-直播')), findsNothing);
    await tester.drag(
      find.byKey(const Key('top-level-scroll-直播')),
      const Offset(0, -520),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('top-level-toolbar-title-直播')), findsNothing);
    expect(find.byKey(const Key('live-search-entry')), findsNothing);
  });

  testWidgets('live page switches new live tabs without search', (
    tester,
  ) async {
    await tester.pumpWidget(
      await interactiveHarness(
        child: LivePage(streamPlayerBuilder: fakeLiveStreamPlayerBuilder),
      ),
    );

    expect(find.byKey(const Key('live-search-entry')), findsNothing);
    expect(find.byKey(const Key('tv-live-login-gate')), findsOneWidget);
    expect(find.text('四川新闻联播'), findsOneWidget);
    expect(find.byKey(const Key('tv-live-channel-selector')), findsNothing);

    await tester.tap(find.text('广播直播'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('radio-live-player-card')), findsOneWidget);
    expect(
      find.byKey(const Key('fake-live-stream-player-交通广播')),
      findsOneWidget,
    );
    expect(
      find.text('http://xcfb.screx.com.cn:18085/hlsnew1/channel1.m3u8'),
      findsOneWidget,
    );
    expect(find.textContaining('暂用电视直播流验证播放链路'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('radio-live-channel-news-radio')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('radio-live-channel-news-radio')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('fake-live-stream-player-新闻广播')),
      findsOneWidget,
    );

    await tester.tap(find.text('互动直播'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('interactive-live-grid')), findsOneWidget);
    expect(find.text('回看'), findsWidgets);
  });

  testWidgets('live active tab content scrolls to top on repeated request', (
    tester,
  ) async {
    var request = 0;
    await pumpScrollToTopUpdate(
      tester,
      request: request,
      builder: (request) => LivePage(
        scrollToTopRequest: request,
        streamPlayerBuilder: fakeLiveStreamPlayerBuilder,
      ),
    );

    await tester.tap(find.text('互动直播'));
    await tester.pumpAndSettle();

    final interactiveList = find.byKey(const Key('live-互动直播-list'));
    final interactiveController = tester
        .widget<CustomScrollView>(interactiveList)
        .controller!;
    await tester.drag(interactiveList, const Offset(0, -520));
    await tester.pumpAndSettle();
    expect(interactiveController.offset, greaterThan(0));

    await pumpScrollToTopUpdate(
      tester,
      request: ++request,
      builder: (request) => LivePage(
        scrollToTopRequest: request,
        streamPlayerBuilder: fakeLiveStreamPlayerBuilder,
      ),
    );

    expect(interactiveController.offset, moreOrLessEquals(0, epsilon: 0.1));
    expect(find.byKey(const Key('interactive-live-grid')), findsOneWidget);
  });

  testWidgets('live page gates TV preview before login and opens login', (
    tester,
  ) async {
    await tester.pumpWidget(
      await interactiveHarness(
        child: LivePage(streamPlayerBuilder: fakeLiveStreamPlayerBuilder),
      ),
    );

    expect(find.byKey(const Key('tv-live-login-gate')), findsOneWidget);
    expect(find.text('登录后观看精彩节目'), findsNothing);
    expect(find.text('点击进入详情'), findsOneWidget);
    expect(find.byKey(const Key('tv-live-preview-poster')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('tv-live-preview-card')),
        matching: find.text('四川卫视'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('tv-live-preview-card')),
        matching: find.text('西昌市广播电视台频道实时直播流'),
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('tv-live-login-button')));
    await tester.pumpAndSettle();
    expect(find.byType(AuthPage), findsOneWidget);
  });

  testWidgets('logged in live page opens TV detail with chat only', (
    tester,
  ) async {
    await pumpAdmin9App(tester);
    await _login(tester);

    await tester.tap(find.text('直播').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tv-live-login-gate')), findsNothing);
    expect(find.byKey(const Key('tv-live-open-detail')), findsOneWidget);
    expect(
      find.byKey(const Key('fake-live-stream-player-四川卫视')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('fake-live-stream-mute')), findsNothing);
    expect(find.byKey(const Key('tv-live-channel-selector')), findsNothing);

    await tester.tap(find.byKey(const Key('tv-live-open-detail')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tv-live-detail-page')), findsOneWidget);
    expect(find.text('聊天室'), findsOneWidget);
    expect(find.text('换台'), findsNothing);
    expect(find.byKey(const Key('tv-live-chat-input')), findsOneWidget);
  });

  testWidgets('live featured program opens schedule detail', (tester) async {
    await tester.pumpWidget(
      await interactiveHarness(
        child: LivePage(streamPlayerBuilder: fakeLiveStreamPlayerBuilder),
      ),
    );

    await tester.ensureVisible(
      find.byKey(const Key('featured-program-sichuan-news')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('featured-program-sichuan-news')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('live-program-detail-page')), findsOneWidget);
    expect(find.byKey(const Key('program-detail-date-strip')), findsOneWidget);
    await tester.ensureVisible(find.text('四川新闻联播（2026.06.15）'));
    await tester.pumpAndSettle();
    expect(find.text('四川新闻联播（2026.06.15）'), findsOneWidget);
    expect(
      find.byKey(const Key('program-detail-comment-input')),
      findsOneWidget,
    );
  });

  testWidgets('live featured programs use compact two-column 4:3 cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      await interactiveHarness(
        child: LivePage(streamPlayerBuilder: fakeLiveStreamPlayerBuilder),
      ),
    );

    final grid = tester.widget<GridView>(
      find.byKey(const Key('tv-featured-program-grid')),
    );
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
    expect(delegate.childAspectRatio, moreOrLessEquals(1.04));

    final imageBox = tester.getSize(
      find
          .descendant(
            of: find.byKey(const Key('featured-program-sichuan-news')),
            matching: find.byType(AspectRatio),
          )
          .first,
    );
    expect(imageBox.width / imageBox.height, moreOrLessEquals(4 / 3));
  });

  testWidgets('interactive live card opens lightweight detail', (tester) async {
    await tester.pumpWidget(
      await interactiveHarness(
        child: LivePage(streamPlayerBuilder: fakeLiveStreamPlayerBuilder),
      ),
    );

    await tester.tap(find.text('互动直播'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('interactive-live-football-replay')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('interactive-live-detail-page')),
      findsOneWidget,
    );
    await dragUntilVisible(
      tester,
      find.byKey(const Key('interactive-live-summary-card')),
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('互动摘要'), findsOneWidget);
  });

  testWidgets('about page shows Xichang Publish brand icon', (tester) async {
    await tester.pumpWidget(
      themedHarness(
        brand: AppBrand.byId(AppBrandId.cityGold),
        child: Provider<FoundationRepository>.value(
          value: const FoundationRepository(),
          child: const AboutPage(),
        ),
      ),
    );

    final clip = tester.widget<ClipRRect>(
      find.byKey(const Key('about-brand-icon')),
    );
    expect(clip.borderRadius, BorderRadius.circular(AppSpacing.largeRadius));

    final image = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const Key('about-brand-icon')),
        matching: find.byType(Image),
      ),
    );
    expect(image.width, 92);
    expect(image.height, 92);
    expect(image.fit, BoxFit.cover);
    expect(find.text('权威发布，服务西昌'), findsOneWidget);
    expect(find.text('互联网新闻信息服务许可证号：\n51120200128'), findsOneWidget);
  });

  testWidgets('top level scaffold keeps plain pages at status safe area', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      themedHarness(
        child: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: 24)),
          child: TopLevelPageScaffold(
            title: '测试页',
            controller: controller,
            slivers: [
              SliverList.builder(
                itemCount: 32,
                itemBuilder: (context, index) =>
                    SizedBox(height: 72, child: Text('列表项 $index')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('top-level-toolbar-测试页')), findsNothing);
    expect(
      find.byKey(const Key('top-level-safe-area-spacer-测试页')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('top-level-chrome-backdrop-测试页')),
      findsNothing,
    );
    final firstItemTop = tester.getTopLeft(find.text('列表项 0')).dy;
    expect(firstItemTop, 24);

    await tester.drag(
      find.byKey(const Key('top-level-scroll-测试页')),
      const Offset(0, -520),
    );
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
  });

  testWidgets('report page is a single entry guide and opens form', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      themedHarness(
        child: ChangeNotifierProvider(
          create: (_) =>
              AppStateController(storage: LocalStorageService(preferences)),
          child: const ReportPage(),
        ),
      ),
    );

    expect(find.byKey(const Key('report-entry-page')), findsOneWidget);
    expect(find.byKey(const Key('report-notice-card')), findsOneWidget);
    expect(find.byKey(const Key('report-create-card')), findsOneWidget);
    expect(find.byType(AppSectionHeader), findsWidgets);
    expect(find.byType(AppInfoListItem), findsNWidgets(3));
    expect(find.text('有线索，来爆料'), findsOneWidget);
    expect(find.text('爆料须知'), findsOneWidget);
    expect(find.text('热门线索'), findsNothing);
    expect(find.byKey(const Key('report-pinned-tab-bar')), findsNothing);
    expect(find.byKey(const Key('report-tab-view')), findsNothing);
    expect(find.byKey(const Key('report-hot-tab-list')), findsNothing);
    expect(find.text('小区门口路灯连续三晚不亮'), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('report-create-card')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-create-card')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, '填写线索'), findsOneWidget);
    expect(find.byKey(const Key('report-title-field')), findsOneWidget);
    expect(find.byKey(const Key('report-content-field')), findsOneWidget);
    expect(find.text('具体情况'), findsOneWidget);
    expect(find.text('补充时间、经过、现场情况或希望我们关注的重点'), findsOneWidget);
    expect(find.byKey(const Key('report-attachment-field')), findsOneWidget);
    expect(find.byKey(const Key('add-report-image')), findsOneWidget);
    expect(find.byKey(const Key('add-report-video')), findsOneWidget);
  });

  testWidgets('report form limits and restores image and video attachments', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      themedHarness(
        child: ChangeNotifierProvider(
          create: (_) =>
              AppStateController(storage: LocalStorageService(preferences)),
          child: const ReportFormPage(),
        ),
      ),
    );

    expect(find.text('照片 0/9，视频 0/1'), findsOneWidget);
    expect(find.byKey(const Key('add-report-image')), findsOneWidget);
    expect(find.byKey(const Key('add-report-video')), findsOneWidget);

    Future<void> tapControl(Finder finder) async {
      await tapInVerticalScroll(tester, finder);
    }

    for (var i = 0; i < 9; i += 1) {
      await tapControl(find.byKey(const Key('add-report-image')));
    }
    expect(find.text('照片 9/9，视频 0/1'), findsOneWidget);
    expect(find.byKey(const Key('add-report-image')), findsNothing);

    await tapControl(find.byKey(const Key('add-report-video')));
    expect(find.text('照片 9/9，视频 1/1'), findsOneWidget);
    expect(find.byKey(const Key('add-report-video')), findsNothing);
    expect(find.text('现场视频'), findsOneWidget);

    final removeButtons = find.byTooltip('删除附件');
    await tapControl(removeButtons.first);
    expect(find.text('照片 8/9，视频 1/1'), findsOneWidget);
    expect(find.byKey(const Key('add-report-image')), findsOneWidget);

    await tapControl(removeButtons.last);
    expect(find.text('照片 8/9，视频 0/1'), findsOneWidget);
    expect(find.byKey(const Key('add-report-video')), findsOneWidget);
  });

  testWidgets('report guide content scrolls to top on repeated request', (
    tester,
  ) async {
    var request = 0;
    await pumpScrollToTopUpdate(
      tester,
      request: request,
      builder: (request) => ReportPage(scrollToTopRequest: request),
    );

    final reportScroll = find.byKey(const Key('top-level-scroll-爆料'));
    final controller = tester
        .widget<CustomScrollView>(reportScroll)
        .controller!;
    await tester.drag(reportScroll, const Offset(0, -420));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));

    await pumpScrollToTopUpdate(
      tester,
      request: ++request,
      builder: (request) => ReportPage(scrollToTopRequest: request),
    );

    expect(controller.offset, moreOrLessEquals(0, epsilon: 0.1));
    expect(find.byKey(const Key('report-entry-page')), findsOneWidget);
  });

  testWidgets('report guide keeps readable hero in dark mode', (tester) async {
    await tester.pumpWidget(
      themedHarness(themeMode: ThemeMode.dark, child: const ReportPage()),
    );

    expect(find.byKey(const Key('report-entry-header')), findsOneWidget);
    expect(find.text('有线索，来爆料'), findsOneWidget);
    expect(find.textContaining('让有价值的信息被看见'), findsOneWidget);
    expect(find.byKey(const Key('report-notice-card')), findsOneWidget);
  });

  testWidgets('services page renders configurable navigation sections', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(720, 900);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 59);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      themedHarness(
        child: MultiProvider(
          providers: [
            Provider<ServiceRepository>.value(
              value: const _CompactServiceRepository(),
            ),
            ChangeNotifierProvider(
              create: (_) =>
                  AppStateController(storage: LocalStorageService(preferences)),
            ),
          ],
          child: const Scaffold(body: ServicesPage()),
        ),
      ),
    );

    expect(find.byKey(const Key('service-channel-sections')), findsOneWidget);
    expect(find.text('最近使用'), findsOneWidget);
    expect(find.text('政务服务'), findsOneWidget);
    expect(find.text('智慧医疗'), findsOneWidget);
    expect(find.text('服务一'), findsOneWidget);
    expect(find.text('服务二'), findsOneWidget);
    expect(find.text('服务三'), findsOneWidget);

    final recentTitleGap = _verticalGapBetween(
      tester,
      lowerEdge: find.text('最近使用'),
      upperEdge: _firstIconIn(find.byKey(const Key('service-section-recent'))),
    );
    final governmentTitleGap = _verticalGapBetween(
      tester,
      lowerEdge: find.text('政务服务'),
      upperEdge: _firstIconIn(
        find.byKey(const Key('service-section-government')),
      ),
    );
    expect(recentTitleGap, moreOrLessEquals(governmentTitleGap, epsilon: 1));
    expect(governmentTitleGap, lessThanOrEqualTo(24));
    expect(
      tester.getTopLeft(find.text('服务一')).dy,
      greaterThan(
        tester
            .getBottomLeft(
              _firstIconIn(find.byKey(const Key('service-section-government'))),
            )
            .dy,
      ),
    );
  });

  testWidgets('service target types dispatch with local feedback and pages', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      themedHarness(
        child: MultiProvider(
          providers: [
            Provider<ServiceRepository>.value(
              value: const _CompactServiceRepository(),
            ),
            ChangeNotifierProvider(
              create: (_) =>
                  AppStateController(storage: LocalStorageService(preferences)),
            ),
          ],
          child: const Scaffold(body: ServicesPage()),
        ),
      ),
    );

    expect(find.text('政务服务'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('service-entry-one')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('service-entry-one')));
    await tester.pumpAndSettle();
    expect(find.text('服务一'), findsWidgets);
    expect(find.text('https://example.com/one'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('service-section-recent')),
        matching: find.text('服务一'),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const Key('service-entry-two')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('service-entry-two')));
    await tester.pump();
    expect(find.text('电话入口暂不可用'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('service-entry-three')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('service-entry-three')));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const Key('service-section-recent')),
        matching: find.text('服务三'),
      ),
      findsOneWidget,
    );
  });

  test('service repository uses the imported service page dataset', () {
    final repository = const ServiceRepository();

    expect(repository.sections.map((section) => section.title), [
      '政务服务',
      '生活服务',
      '教育考试',
      '医疗健康',
      '旅游出行',
      '交通出行',
      '新闻服务',
    ]);
    expect(repository.services, hasLength(61));

    final miniProgram = repository.findById('liangshan-12345')!;
    expect(miniProgram.title, '凉山12345');
    expect(miniProgram.target.type, ServiceTargetType.miniProgram);
    expect(miniProgram.target.appId, 'wxfa6f8eb6804a12ef');
    expect(miniProgram.target.userName, 'gh_380f3a579483');
    expect(
      miniProgram.iconUrl,
      'https://alifile.i0834.cn/nmip/2024-09-20/66689509/2C9BB2332C32F3653AC3895DAA7466B4.png',
    );

    final h5 = repository.findById('liangshan-human-resources')!;
    expect(h5.target.type, ServiceTargetType.h5);
    expect(h5.target.value, 'https://lszrs.com.cn/lswx/index.html');

    final tax = repository.findById('social-security-payment')!;
    expect(tax.target.type, ServiceTargetType.h5);
    expect(tax.target.value, 'https://sichuan.chinatax.gov.cn/sbjf/');
    expect(tax.target.value, isNot(contains('__csSessionId__')));

    final page = repository.findById('read-newspaper')!;
    expect(page.target.type, ServiceTargetType.page);
    expect(page.target.pageId, 84572);

    expect(repository.findById('railway-12306')!.title, '铁路12306');
    expect(repository.findById('medical-insurance-certificate')!.title, '医保凭证');
    expect(repository.services.where((item) => item.iconUrl.isEmpty), isEmpty);
    expect(
      repository.defaultRecentItems.where((item) => item.iconUrl.isEmpty),
      isEmpty,
    );
  });

  test('non-web service feedback stays truthful for the static prototype', () {
    final repository = const ServiceRepository();
    final sideEffectTargets = repository.services.where((item) {
      return switch (item.target.type) {
        ServiceTargetType.phone ||
        ServiceTargetType.email ||
        ServiceTargetType.externalApp ||
        ServiceTargetType.miniProgram ||
        ServiceTargetType.page => true,
        _ => false,
      };
    });

    expect(sideEffectTargets, isNotEmpty);
    for (final item in sideEffectTargets) {
      expect(item.target.feedback, isNot(contains('已打开')));
      expect(item.target.feedback, isNot(contains('已唤起')));
      expect(item.target.feedback, isNot(contains('已准备拨打')));
      expect(
        item.target.feedback,
        anyOf(contains('暂不可用'), contains('暂未接入'), contains('待接入')),
      );
    }
  });

  test('AppBrandId.parse handles old enum names and defaults', () {
    expect(AppBrandId.parse('mediaBlue'), AppBrandId.newsBlue);
    expect(AppBrandId.parse('civicRed'), AppBrandId.mainstreamRed);
    expect(AppBrandId.parse('serviceGreen'), AppBrandId.livelihoodGreen);
    expect(AppBrandId.parse(null), AppBrandId.jacarandaBlue);
    expect(AppBrandId.parse(''), AppBrandId.jacarandaBlue);
    expect(AppBrandId.parse('garbage'), AppBrandId.jacarandaBlue);
  });

  test('AppThemeMode.parse defaults to light mode', () {
    expect(AppThemeMode.parse(null), AppThemeMode.light);
    expect(AppThemeMode.parse(''), AppThemeMode.light);
    expect(AppThemeMode.parse('garbage'), AppThemeMode.light);
    for (final mode in AppThemeMode.values) {
      expect(AppThemeMode.parse(mode.name), mode);
    }
  });

  test('AppBrandId.parse round-trips all 6 values', () {
    expect(AppBrandId.values, hasLength(6));
    for (final id in AppBrandId.values) {
      expect(AppBrandId.parse(id.name), id);
    }
  });

  test('all brand themes inject semantic brand colors', () {
    expect(AppBrand.all, hasLength(6));
    for (final brand in AppBrand.all) {
      final theme = AppTheme.light(brand: brand);
      final tokens = theme.extension<AppThemeTokens>()!;
      expect(theme.colorScheme.primary, brand.primary);
      expect(tokens.brand, brand);
      expect(tokens.brand.gradientStart, brand.gradientStart);
      expect(tokens.brand.gradientMiddle, brand.gradientMiddle);
      expect(tokens.brand.gradientEnd, brand.gradientEnd);
      expect(tokens.accent, Color.lerp(tokens.warning, tokens.info, 0.5));
      expect(tokens.pressed, brand.primary.withValues(alpha: 0.1));
      expect(tokens.selected, brand.primary.withValues(alpha: 0.14));
    }
  });

  test('all 6 brand primary colors keep white buttons AA normal', () {
    for (final brand in AppBrand.all) {
      final theme = AppTheme.light(brand: brand);
      final tokens = theme.extension<AppThemeTokens>()!;
      expect(tokens.buttonForeground, Colors.white);
      expect(
        contrastRatio(tokens.buttonForeground, tokens.buttonBackground),
        greaterThanOrEqualTo(4.5),
        reason: '${brand.id.name} white button text must meet WCAG AA Normal',
      );
    }
  });

  test('brand gradient text-bearing scrims keep white text AA normal', () {
    final scrimStops = [
      Colors.black.withValues(alpha: 0.68),
      Colors.black.withValues(alpha: 0.72),
    ];

    for (final brand in AppBrand.all) {
      for (final gradientColor in brandGradientSamples(brand)) {
        for (final scrim in scrimStops) {
          final protectedBackground = alphaBlend(scrim, gradientColor);
          expect(
            contrastRatio(Colors.white, protectedBackground),
            greaterThanOrEqualTo(4.5),
            reason:
                '${brand.id.name} white title text must stay readable over protected gradients',
          );
          expect(
            contrastRatio(
              alphaBlend(Colors.white70, protectedBackground),
              protectedBackground,
            ),
            greaterThanOrEqualTo(4.5),
            reason:
                '${brand.id.name} white70 meta text must stay readable over protected gradients',
          );
        }
      }
    }
  });

  test('AppThemeTokens.lerp works across brands', () {
    final red = AppTheme.light(
      brand: AppBrand.byId(AppBrandId.mainstreamRed),
    ).extension<AppThemeTokens>()!;
    final blue = AppTheme.light(
      brand: AppBrand.byId(AppBrandId.newsBlue),
    ).extension<AppThemeTokens>()!;

    final mixed = red.lerp(blue, 0.5);

    expect(mixed.brand, AppBrand.byId(AppBrandId.newsBlue));
    expect(
      mixed.pageBackground,
      Color.lerp(red.pageBackground, blue.pageBackground, 0.5),
    );
    expect(
      mixed.buttonBackground,
      Color.lerp(red.buttonBackground, blue.buttonBackground, 0.5),
    );
    expect(mixed.fontScale, 1);
  });

  test('AppThemeTokens.copyWith preserves unchanged fields', () {
    final tokens = AppTheme.light().extension<AppThemeTokens>()!;
    final next = tokens.copyWith(
      brand: AppBrand.byId(AppBrandId.cityGold),
      buttonBackground: AppBrand.byId(AppBrandId.cityGold).primary,
    );

    expect(next.brand.id, AppBrandId.cityGold);
    expect(next.buttonBackground, AppBrand.byId(AppBrandId.cityGold).primary);
    expect(next.textPrimary, tokens.textPrimary);
    expect(next.pageBackground, tokens.pageBackground);
    expect(next.fontScale, tokens.fontScale);
  });

  test('all 6 brands build valid ThemeData in light and dark', () {
    for (final brand in AppBrand.all) {
      final light = AppTheme.light(brand: brand);
      final dark = AppTheme.dark(brand: brand);
      expect(light.extension<AppThemeTokens>()!.brand, brand);
      expect(dark.extension<AppThemeTokens>()!.brand, brand);
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
    }
  });

  test('font scaling is independent of brand', () {
    final expectedSize = 26 * AppFontLevel.large.scale;
    for (final brand in AppBrand.all) {
      final theme = AppTheme.light(brand: brand, fontLevel: AppFontLevel.large);
      expect(theme.textTheme.headlineMedium?.fontSize, expectedSize);
      expect(
        theme.extension<AppThemeTokens>()!.fontScale,
        AppFontLevel.large.scale,
      );
    }
  });

  test(
    'Switch theme uses neutral semantic colors instead of brand primary',
    () {
      for (final brand in AppBrand.all) {
        final theme = AppTheme.light(brand: brand);
        final tokens = theme.extension<AppThemeTokens>()!;
        final thumb = theme.switchTheme.thumbColor?.resolve({
          WidgetState.selected,
        });
        final track = theme.switchTheme.trackColor?.resolve({
          WidgetState.selected,
        });
        expect(thumb, tokens.info);
        expect(thumb, isNot(brand.primary));
        expect(track, isNot(brand.primary));
      }
    },
  );

  testWidgets('QuickActionGrid icons use neutral color in light mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        brand: AppBrand.byId(AppBrandId.hotOrange),
        child: Material(
          child: QuickActionGrid(
            gridKey: const Key('quick-action-grid-neutral-test'),
            items: [
              QuickActionItem(icon: Icons.settings, label: '设置', onTap: () {}),
            ],
          ),
        ),
      ),
    );

    final tokens = Theme.of(
      tester.element(find.byType(QuickActionGrid)),
    ).extension<AppThemeTokens>()!;
    final icon = tester.widget<Icon>(find.byIcon(Icons.settings));
    expect(icon.color, tokens.textPrimary);
    expect(icon.color, isNot(tokens.brand.primary));
  });

  testWidgets('QuickActionGrid renders network images when provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Material(
          child: QuickActionGrid(
            gridKey: const Key('quick-action-grid-image-test'),
            items: [
              QuickActionItem(
                icon: Icons.settings,
                label: '设置',
                imageUrl: 'https://example.com/icon.png',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final imageFinder = find.byKey(const Key('quick-action-image-设置'));
    expect(imageFinder, findsOneWidget);
    final image = tester.widget<Image>(imageFinder);
    expect(image.fit, BoxFit.cover);
    expect(image.image, isA<ResizeImage>());
    final resized = image.image as ResizeImage;
    expect(
      resized.imageProvider,
      isA<NetworkImage>().having(
        (image) => image.url,
        'url',
        'https://example.com/icon.png',
      ),
    );
  });

  testWidgets('QuickActionGrid labels stay single-line with ellipsis', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Material(
          child: SizedBox(
            width: 360,
            child: QuickActionGrid(
              gridKey: const Key('quick-action-grid-label-test'),
              items: [
                QuickActionItem(
                  icon: Icons.local_hospital_outlined,
                  label: '市妇幼保健院',
                  onTap: () {},
                ),
                QuickActionItem(
                  icon: Icons.local_hospital_outlined,
                  label: '市人民医院',
                  onTap: () {},
                ),
                QuickActionItem(
                  icon: Icons.local_hospital_outlined,
                  label: '市中医医院',
                  onTap: () {},
                ),
                QuickActionItem(
                  icon: Icons.local_pharmacy_outlined,
                  label: '医疗药店',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final longLabel = tester.widget<Text>(find.text('市妇幼保健院'));
    expect(longLabel.maxLines, 1);
    expect(longLabel.overflow, TextOverflow.ellipsis);
  });

  testWidgets('QuickActionSection keeps header rhythm independent of actions', (
    tester,
  ) async {
    Widget section({required bool withAction}) {
      return QuickActionSection(
        title: withAction ? '政务服务' : '最近使用',
        actionLabel: withAction ? '更多' : null,
        onActionTap: withAction ? () {} : null,
        gridKey: Key('quick-action-section-grid-$withAction'),
        items: [
          QuickActionItem(
            icon: Icons.menu_book_outlined,
            label: withAction ? '学习强国' : '油价查询',
            onTap: () {},
          ),
        ],
      );
    }

    await tester.pumpWidget(
      themedHarness(
        child: Material(
          child: Column(
            children: [
              section(withAction: false),
              const SizedBox(height: AppSpacing.cardGap),
              section(withAction: true),
            ],
          ),
        ),
      ),
    );

    final headers = find.byKey(const Key('quick-action-section-header'));
    expect(headers, findsNWidgets(2));
    final firstHeader = headers.at(0);
    final secondHeader = headers.at(1);
    expect(
      tester.getSize(firstHeader).height,
      moreOrLessEquals(tester.getSize(secondHeader).height, epsilon: 1),
    );

    final firstGap = _verticalGapBetween(
      tester,
      lowerEdge: find.text('最近使用'),
      upperEdge: _firstIconIn(
        find.byKey(const Key('quick-action-section-grid-false')),
      ),
    );
    final secondGap = _verticalGapBetween(
      tester,
      lowerEdge: find.text('政务服务'),
      upperEdge: _firstIconIn(
        find.byKey(const Key('quick-action-section-grid-true')),
      ),
    );
    expect(firstGap, moreOrLessEquals(secondGap, epsilon: 1));
  });

  testWidgets('QuickActionSection can render untitled inline actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Material(
          child: QuickActionSection(
            title: null,
            surface: QuickActionSectionSurface.inline,
            gridKey: const Key('quick-action-section-inline-grid'),
            items: [
              QuickActionItem(
                icon: Icons.work_outline,
                label: '工作指示',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppCard), findsNothing);
    expect(find.byKey(const Key('quick-action-section-header')), findsNothing);
    expect(
      find.byKey(const Key('quick-action-section-inline-grid')),
      findsOneWidget,
    );
    expect(find.text('工作指示'), findsOneWidget);
  });

  test('dark theme selection states use luminance contrast', () {
    final theme = AppTheme.dark(brand: AppBrand.byId(AppBrandId.mainstreamRed));
    final tokens = theme.extension<AppThemeTokens>()!;

    expect(tokens.pressed, tokens.textPrimary.withValues(alpha: 0.1));
    expect(tokens.selected, tokens.textPrimary.withValues(alpha: 0.16));

    final navigationIconTheme = theme.navigationBarTheme.iconTheme!;
    expect(
      navigationIconTheme.resolve({WidgetState.selected})?.color,
      tokens.textPrimary,
    );
    expect(
      navigationIconTheme.resolve(<WidgetState>{})?.color,
      tokens.textSecondary,
    );

    final navigationLabelStyle = theme.navigationBarTheme.labelTextStyle!;
    expect(
      navigationLabelStyle.resolve({WidgetState.selected})?.color,
      tokens.textPrimary,
    );
    expect(
      navigationLabelStyle.resolve(<WidgetState>{})?.color,
      tokens.textSecondary,
    );
    expect(navigationLabelStyle.resolve({WidgetState.selected})?.fontSize, 11);

    final outlinedStyle = theme.outlinedButtonTheme.style!;
    expect(
      outlinedStyle.foregroundColor?.resolve(<WidgetState>{}),
      tokens.textPrimary,
    );
    expect(
      outlinedStyle.side?.resolve(<WidgetState>{})?.color,
      tokens.textPrimary,
    );
  });

  testWidgets('foundation components keep tokenized default structure', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: FoundationPage(
          title: '组件规范',
          children: [
            const SectionHeader(title: '设置分组'),
            SettingsGroup(
              children: [
                const SettingsRow(title: '账号与安全', value: '未登录'),
                SettingsRow(
                  title: '外观主题',
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
              ],
            ),
            const SectionGap(),
            AppCard(
              child: QuickActionGrid(
                gridKey: const Key('quick-action-grid-foundation-demo'),
                shrinkToItemCount: true,
                items: [
                  QuickActionItem(
                    icon: Icons.notifications_none,
                    label: '消息通知',
                    badge: '新',
                    onTap: () {},
                  ),
                  QuickActionItem(
                    icon: Icons.settings_outlined,
                    label: '系统设置',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SectionGap(),
            const MessageCard(title: '系统消息', time: '2026-06-06', unread: true),
            const SectionGap(),
            PrimaryPillButton(label: '提交', onPressed: () {}),
          ],
        ),
      ),
    );

    expect(find.text('组件规范'), findsOneWidget);
    expect(find.text('设置分组'), findsOneWidget);
    expect(find.text('账号与安全'), findsOneWidget);
    expect(find.text('消息通知'), findsOneWidget);
    expect(find.text('系统消息'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '提交'), findsOneWidget);

    final headerStyle = tester.widget<Text>(find.text('设置分组')).style;
    final rowTitleStyle = tester.widget<Text>(find.text('账号与安全')).style;
    expect(headerStyle?.fontSize, lessThan(rowTitleStyle?.fontSize ?? 0));
    expect(headerStyle?.fontWeight, FontWeight.w600);

    final settingsRowBox = tester.renderObject<RenderBox>(
      find.ancestor(of: find.text('账号与安全'), matching: find.byType(SettingsRow)),
    );
    expect(
      settingsRowBox.size.height,
      greaterThanOrEqualTo(AppSpacing.rowMinHeight),
    );

    final cardTheme = Theme.of(
      tester.element(find.byType(Card).first),
    ).cardTheme;
    final shape = cardTheme.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(AppSpacing.cardRadius));

    final typography = Theme.of(
      tester.element(find.text('账号与安全')),
    ).extension<AppTypography>()!;
    final tokens = Theme.of(
      tester.element(find.text('账号与安全')),
    ).extension<AppThemeTokens>()!;
    final settingsTitle = tester.widget<Text>(find.text('账号与安全'));
    final settingsValue = tester.widget<Text>(find.text('未登录'));
    expect(settingsTitle.style?.fontSize, typography.settingsTitle.fontSize);
    expect(
      settingsTitle.style?.fontWeight,
      typography.settingsTitle.fontWeight,
    );
    expect(settingsTitle.style?.color, tokens.textPrimary);
    expect(settingsValue.style?.fontSize, typography.settingsValue.fontSize);
    expect(
      settingsValue.style?.fontWeight,
      typography.settingsValue.fontWeight,
    );
    expect(settingsValue.style?.color, tokens.textSecondary);
  });

  testWidgets('settings rows keep trailing chevrons right aligned', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(984, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      themedHarness(
        fontLevel: AppFontLevel.large,
        themeMode: ThemeMode.dark,
        child: FoundationPage(
          title: '设置',
          children: [
            SettingsGroup(
              children: [
                SettingsRow(title: '字体大小', value: '标准字体', onTap: () {}),
                SettingsRow(title: '意见反馈', onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );

    final chevrons = find.byIcon(Icons.chevron_right);
    expect(chevrons, findsNWidgets(2));

    final valueChevronRight = tester.getTopRight(chevrons.at(0)).dx;
    final plainChevronRight = tester.getTopRight(chevrons.at(1)).dx;
    expect(valueChevronRight, closeTo(plainChevronRight, 0.1));
  });

  testWidgets('interaction components keep design-system behavior', (
    tester,
  ) async {
    var enabledTaps = 0;
    var disabledTaps = 0;
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);

    await tester.pumpWidget(
      themedHarness(
        child: DefaultTabController(
          length: 2,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    AppTabBar(
                      controller: DefaultTabController.of(context),
                      tabs: const [
                        Tab(text: '推荐'),
                        Tab(text: '政声'),
                      ],
                    ),
                    AppCard(
                      onTap: () => enabledTaps++,
                      child: const Text('可点击卡片'),
                    ),
                    AppCard(
                      enabled: false,
                      onTap: () => disabledTaps++,
                      child: const Text('禁用卡片'),
                    ),
                    const SizedBox(
                      width: 48,
                      child: StatusPill(
                        label: '很长的状态标签',
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    AppSearchTextField(
                      controller: searchController,
                      onSubmitted: (_) {},
                      onClear: searchController.clear,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.dividerColor, Colors.transparent);
    expect(tabBar.dividerHeight, 0);
    expect(tabBar.indicatorWeight, 2);
    expect(tabBar.indicatorPadding, EdgeInsets.zero);
    expect(
      tabBar.overlayColor?.resolve({WidgetState.pressed}),
      tester.element(find.byType(TabBar)).tokens.pressed,
    );
    expect(
      tabBar.labelPadding,
      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    );

    expect(find.widgetWithText(InkWell, '可点击卡片'), findsOneWidget);
    expect(find.widgetWithText(InkWell, '禁用卡片'), findsNothing);
    await tester.tap(find.text('可点击卡片'));
    await tester.tap(find.text('禁用卡片'), warnIfMissed: false);
    expect(enabledTaps, 1);
    expect(disabledTaps, 0);

    final pillBox = tester.renderObject<RenderBox>(find.byType(StatusPill));
    expect(pillBox.size.width, lessThanOrEqualTo(48));

    expect(find.byTooltip('清空'), findsNothing);
    await tester.enterText(find.byKey(const Key('search-input')), '城市更新');
    await tester.pump();
    expect(find.byTooltip('清空'), findsOneWidget);
    await tester.tap(find.byTooltip('清空'));
    await tester.pump();
    expect(searchController.text, isEmpty);
    expect(find.byTooltip('清空'), findsNothing);
  });

  testWidgets('dark interaction components keep grayscale-safe contrast', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        themeMode: ThemeMode.dark,
        child: DefaultTabController(
          length: 2,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    AppTabBar(
                      controller: DefaultTabController.of(context),
                      tabs: const [
                        Tab(text: '推荐'),
                        Tab(text: '政声'),
                      ],
                    ),
                    QuickActionGrid(
                      gridKey: const Key('quick-action-grid-dark-test'),
                      shrinkToItemCount: true,
                      items: [
                        QuickActionItem(
                          icon: Icons.notifications_none,
                          label: '消息通知',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    final tokens = Theme.of(
      tester.element(find.byType(TabBar)),
    ).extension<AppThemeTokens>()!;
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.labelColor, tokens.textPrimary);
    expect(tabBar.indicatorColor, tokens.textPrimary);
    expect(tabBar.unselectedLabelColor, tokens.textSecondary);
    final tabTypography = Theme.of(
      tester.element(find.byType(TabBar)),
    ).extension<AppTypography>()!;
    expect(tabBar.labelStyle?.fontSize, tabTypography.tabLabel.fontSize);
    expect(tabBar.labelStyle?.fontWeight, FontWeight.w700);
    expect(
      tabBar.unselectedLabelStyle?.fontSize,
      tabTypography.tabLabel.fontSize,
    );
    expect(
      tabBar.unselectedLabelStyle?.fontWeight,
      tabTypography.tabLabel.fontWeight,
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.notifications_none));
    expect(icon.color, tokens.textPrimary);

    final label = tester.widget<Text>(find.text('消息通知'));
    expect(label.style?.color, tokens.textPrimary);
    final typography = Theme.of(
      tester.element(find.text('消息通知')),
    ).extension<AppTypography>()!;
    expect(label.style?.fontSize, typography.actionLabel.fontSize);
    expect(label.style?.fontWeight, typography.actionLabel.fontWeight);
  });

  testWidgets('foundation component golden stays visually stable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      themedHarness(
        child: FoundationPage(
          title: '设置',
          children: [
            const SectionHeader(title: '账号'),
            SettingsGroup(
              children: [
                const SettingsRow(title: '账号与安全', value: '未登录'),
                SettingsRow(
                  title: '接收推送',
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
              ],
            ),
            const SectionGap(),
            const MessageCard(
              title: '账号安全和外观设置已支持本地保存。',
              time: '2026-06-06 13:00:34',
              unread: true,
            ),
            const SectionGap(),
            AppCard(
              child: QuickActionGrid(
                gridKey: const Key('quick-action-grid-foundation-golden'),
                items: [
                  QuickActionItem(
                    icon: Icons.favorite_border,
                    label: '我的关注',
                    onTap: () {},
                  ),
                  QuickActionItem(
                    icon: Icons.notifications_none,
                    label: '消息通知',
                    badge: '新',
                    onTap: () {},
                  ),
                  QuickActionItem(
                    icon: Icons.feedback_outlined,
                    label: '意见反馈',
                    onTap: () {},
                  ),
                  QuickActionItem(
                    icon: Icons.verified_user_outlined,
                    label: '账号安全',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/foundation_components.png'),
    );
  });

  testWidgets('foundation component golden supports dark large font', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      themedHarness(
        fontLevel: AppFontLevel.large,
        themeMode: ThemeMode.dark,
        child: FoundationPage(
          title: '外观主题',
          children: [
            const SectionHeader(title: '显示模式'),
            SettingsGroup(
              children: [
                SettingsRow(
                  title: '深色模式',
                  trailing: Icon(
                    Icons.check,
                    color: AppBrand.newsBlueBrand.primary,
                  ),
                ),
                SettingsRow(
                  title: '一键全局灰',
                  value: '节日/纪念日使用',
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
              ],
            ),
            const SectionGap(),
            PrimaryPillButton(label: '保存设置', onPressed: () {}),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/foundation_dark_large.png'),
    );
  });

  testWidgets('appearance settings drive theme font size and grayscale', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'appearance_brand': AppBrandId.mainstreamRed.name,
      'appearance_theme_mode': AppThemeMode.dark.name,
      'appearance_font_level': AppFontLevel.large.name,
      'appearance_grayscale': true,
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(admin9AppForTest(preferences));
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    expect(
      materialApp.theme?.colorScheme.primary,
      AppBrand.byId(AppBrandId.mainstreamRed).primary,
    );
    expect(
      materialApp.theme?.textTheme.headlineMedium?.fontSize,
      26 * AppFontLevel.large.scale,
    );
    expect(
      materialApp.theme?.navigationBarTheme.labelTextStyle?.resolve({
        WidgetState.selected,
      })?.fontSize,
      11 * AppFontLevel.large.scale,
    );
    expect(find.byKey(const Key('global-grayscale-filter')), findsOneWidget);
    final filter = tester.widget<ColorFiltered>(
      find.byKey(const Key('global-grayscale-filter')),
    );
    expect(
      filter.colorFilter,
      const ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
    );
  });

  testWidgets('home dark grayscale smoke keeps dense content readable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpAdmin9App(
      tester,
      initialPreferences: {
        'appearance_theme_mode': AppThemeMode.dark.name,
        'appearance_grayscale': true,
      },
    );

    expect(find.byKey(const Key('global-grayscale-filter')), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    final tokens = Theme.of(
      tester.element(find.byType(NavigationBar)),
    ).extension<AppThemeTokens>()!;
    final navigationTheme = Theme.of(
      tester.element(find.byType(NavigationBar)),
    ).navigationBarTheme;
    expect(
      navigationTheme.iconTheme?.resolve({WidgetState.selected})?.color,
      tokens.textPrimary,
    );
    expect(
      navigationTheme.labelTextStyle?.resolve({WidgetState.selected})?.color,
      tokens.textPrimary,
    );

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.labelColor, Colors.white);
    expect(tabBar.indicatorColor, Colors.white);
    expect(tabBar.unselectedLabelColor, Colors.white.withValues(alpha: 0.72));

    final brief = tester.widget<Text>(
      find.textContaining('习近平同老挝人民革命党中央总书记').first,
    );
    expect(brief.style?.color, tokens.textPrimary);
    expect(brief.style?.fontWeight, FontWeight.w400);

    await scrollTo(tester, find.byType(IconNavigationBlock));

    final quickActionText = tester.widget<Text>(
      find
          .descendant(
            of: find.byType(IconNavigationBlock),
            matching: find.text('政声'),
          )
          .first,
    );
    expect(quickActionText.style?.color, tokens.textPrimary);
    final typography = Theme.of(
      tester.element(find.byType(IconNavigationBlock)),
    ).extension<AppTypography>()!;
    expect(quickActionText.style?.fontSize, typography.actionLabel.fontSize);
    expect(
      quickActionText.style?.fontWeight,
      typography.actionLabel.fontWeight,
    );

    final quickActionIcon = tester.widget<Icon>(
      find
          .descendant(
            of: find.byType(IconNavigationBlock),
            matching: find.byIcon(Icons.account_balance_outlined),
          )
          .first,
    );
    expect(quickActionIcon.color, tokens.textPrimary);

    expect(
      find.descendant(
        of: find.byType(TileGridBlock),
        matching: find.text('天气'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(TileGridBlock), matching: find.text('新')),
      findsOneWidget,
    );
  });

  testWidgets('admin9 shell caps content width on desktop preview', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpAdmin9App(
      tester,
      initialPreferences: {
        'appearance_theme_mode': AppThemeMode.dark.name,
        'appearance_grayscale': true,
      },
    );

    final contentBox = tester.renderObject<RenderBox>(
      find.byKey(const Key('admin9-shell-content')),
    );
    final navigationBox = tester.renderObject<RenderBox>(
      find.byKey(const Key('admin9-shell-navigation')),
    );

    expect(contentBox.size.width, AppSpacing.contentMaxWidth);
    expect(navigationBox.size.width, AppSpacing.contentMaxWidth);
  });

  testWidgets('message center caps content width on desktop preview', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mine-top-message-action')));
    await tester.pumpAndSettle();

    final contentBox = tester.renderObject<RenderBox>(
      find.byKey(const Key('message-center-content')),
    );

    expect(contentBox.size.width, AppSpacing.contentMaxWidth);
  });

  testWidgets('message center tabs keep the plain app bar title rhythm', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mine-top-message-action')));
    await tester.pumpAndSettle();

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.indicatorPadding, EdgeInsets.zero);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.byType(Tab)),
      findsNWidgets(3),
    );
    expect(find.text('评论'), findsOneWidget);
    expect(find.text('获赞'), findsOneWidget);
    expect(find.text('粉丝'), findsNothing);
    expect(find.text('系统消息'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(AppTabBar),
      ),
      findsOneWidget,
    );
  });

  testWidgets('message cards fill list width and keep unread marker inside', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mine-top-message-action')));
    await tester.pumpAndSettle();

    final contentRect = tester.getRect(
      find.byKey(const Key('message-center-content')),
    );
    final messageCards = find.byType(MessageCard);
    expect(messageCards, findsNWidgets(2));

    final firstCardRect = tester.getRect(messageCards.at(0));
    final secondCardRect = tester.getRect(messageCards.at(1));
    expect(firstCardRect.width, moreOrLessEquals(secondCardRect.width));
    expect(
      firstCardRect.left,
      moreOrLessEquals(contentRect.left + AppSpacing.pageX),
    );
    expect(
      firstCardRect.right,
      moreOrLessEquals(contentRect.right - AppSpacing.pageX),
    );

    final unreadMarkerRect = tester.getRect(
      find.byKey(const Key('message-card-unread-marker')).first,
    );
    expect(unreadMarkerRect.left, greaterThan(firstCardRect.left));
    expect(unreadMarkerRect.right, lessThan(firstCardRect.right));
  });

  testWidgets('channel management keeps dark grayscale chip contrast', (
    tester,
  ) async {
    await pumpAdmin9App(
      tester,
      initialPreferences: {
        'appearance_theme_mode': AppThemeMode.dark.name,
        'appearance_grayscale': true,
      },
    );

    await tester.tap(find.byKey(const Key('channel-manage-button')));
    await tester.pumpAndSettle();

    final tokens = Theme.of(
      tester.element(find.text('频道管理')),
    ).extension<AppThemeTokens>()!;
    final scaffold = tester.widget<Scaffold>(
      find.ancestor(of: find.text('频道管理'), matching: find.byType(Scaffold)),
    );
    expect(scaffold.backgroundColor, tokens.pageBackground);

    final selectedChipMaterial = tester.widget<Material>(
      find
          .ancestor(
            of: find.byKey(const Key('my-channel-recommend')),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(selectedChipMaterial.color, tokens.textPrimary);

    final selectedText = tester.widget<Text>(
      find
          .descendant(
            of: find.byKey(const Key('my-channel-recommend')),
            matching: find.text('推荐'),
          )
          .first,
    );
    expect(selectedText.style?.color, tokens.pageBackground);

    final addChannelChip = tester.widget<ActionChip>(
      find.byKey(const Key('add-channel-discover')),
    );
    expect(addChannelChip.backgroundColor, tokens.softFill);
    expect(addChannelChip.side?.color, tokens.divider);
  });

  testWidgets(
    'appearance settings fall back to jacaranda brand and light mode',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(admin9AppForTest(preferences));
      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.light);
      expect(
        materialApp.theme?.colorScheme.primary,
        AppBrand.defaultBrand.primary,
      );
      expect(find.byKey(const Key('global-grayscale-filter')), findsNothing);
    },
  );

  testWidgets('saved appearance settings are not overwritten by defaults', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'appearance_brand': AppBrandId.newsBlue.name,
      'appearance_theme_mode': AppThemeMode.system.name,
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(admin9AppForTest(preferences));
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.system);
    expect(
      materialApp.theme?.colorScheme.primary,
      AppBrand.byId(AppBrandId.newsBlue).primary,
    );
    expect(preferences.getString('appearance_brand'), AppBrandId.newsBlue.name);
    expect(
      preferences.getString('appearance_theme_mode'),
      AppThemeMode.system.name,
    );
  });

  test('splash repository reads valid non-empty cached file', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = LocalStorageService(preferences);
    final cacheDirectory = await Directory.systemTemp.createTemp(
      'admin9-splash-test-',
    );
    addTearDown(() => cacheDirectory.delete(recursive: true));
    final file = File('${cacheDirectory.path}/cached.jpg');
    await file.writeAsBytes([1, 2, 3]);
    await storage.saveSplashCacheMetadata(
      splashCacheMetadata(sourceType: 'file', source: file.path),
    );

    final repository = SplashRepository(
      storage,
      cacheDirectory: SplashCacheDirectory(cacheDirectory.path),
    );

    final content = await repository.loadCachedContent();

    expect(content, isNotNull);
    expect(content?.sourceType, SplashSourceType.file);
    expect(content?.source, file.path);
    expect(storage.loadSplashCacheMetadata(), isNotNull);
  });

  test('splash repository drops missing cached file metadata', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = LocalStorageService(preferences);
    await storage.saveSplashCacheMetadata(
      splashCacheMetadata(sourceType: 'file', source: '/missing/splash.jpg'),
    );

    final repository = SplashRepository(storage);

    final content = await repository.loadCachedContent();

    expect(content, isNull);
    expect(storage.loadSplashCacheMetadata(), isNull);
  });

  test('splash repository drops empty cached file metadata', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = LocalStorageService(preferences);
    final cacheDirectory = await Directory.systemTemp.createTemp(
      'admin9-splash-test-',
    );
    addTearDown(() => cacheDirectory.delete(recursive: true));
    final file = File('${cacheDirectory.path}/empty.jpg');
    await file.writeAsBytes([]);
    await storage.saveSplashCacheMetadata(
      splashCacheMetadata(sourceType: 'file', source: file.path),
    );

    final repository = SplashRepository(
      storage,
      cacheDirectory: SplashCacheDirectory(cacheDirectory.path),
    );

    final content = await repository.loadCachedContent();

    expect(content, isNull);
    expect(storage.loadSplashCacheMetadata(), isNull);
  });

  test('splash repository drops invalid cached metadata shapes', () async {
    for (final payload in [
      'not json',
      splashCacheMetadata(
        cachedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      splashCacheMetadata(id: 'old-campaign'),
      splashCacheMetadata(mediaType: 'video'),
      splashCacheMetadata(source: 'assets/images/missing_splash.png'),
    ]) {
      SharedPreferences.setMockInitialValues({
        'splash_cache_metadata': payload,
      });
      final preferences = await SharedPreferences.getInstance();
      final storage = LocalStorageService(preferences);
      final repository = SplashRepository(storage);

      final content = await repository.loadCachedContent();

      expect(content, isNull);
      expect(storage.loadSplashCacheMetadata(), isNull);
    }
  });

  test(
    'splash repository preloads image into injected cache directory',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final storage = LocalStorageService(preferences);
      final cacheDirectory = await Directory.systemTemp.createTemp(
        'admin9-splash-test-',
      );
      addTearDown(() => cacheDirectory.delete(recursive: true));

      final repository = SplashRepository(
        storage,
        cacheDirectory: SplashCacheDirectory(cacheDirectory.path),
        previewImageUrl: 'https://xcfb.screx.com.cn/cached.jpg',
        loadRemoteContent: (_) async => SplashRemoteContent(
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'image/jpeg',
        ),
      );

      await repository.preloadNextContent();
      final metadata = storage.loadSplashCacheMetadata();
      final content = await repository.loadCachedContent();

      expect(metadata, isNotNull);
      expect(content, isNotNull);
      expect(content?.sourceType, SplashSourceType.file);
      expect(content?.source.startsWith(cacheDirectory.path), isTrue);
      expect(await File(content!.source).length(), 3);
    },
  );

  test('splash repository ignores preload failures without throwing', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = LocalStorageService(preferences);
    final cacheDirectory = await Directory.systemTemp.createTemp(
      'admin9-splash-test-',
    );
    addTearDown(() => cacheDirectory.delete(recursive: true));

    final repository = SplashRepository(
      storage,
      cacheDirectory: SplashCacheDirectory(cacheDirectory.path),
      previewImageUrl: 'https://xcfb.screx.com.cn/missing.jpg',
      loadRemoteContent: (_) async => null,
    );

    await repository.preloadNextContent();

    expect(storage.loadSplashCacheMetadata(), isNull);
  });

  test('splash repository rejects unsafe preload payloads', () async {
    Future<void> expectRejected({
      required String previewImageUrl,
      required SplashRemoteContent? content,
    }) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final storage = LocalStorageService(preferences);
      final cacheDirectory = await Directory.systemTemp.createTemp(
        'admin9-splash-test-',
      );
      addTearDown(() => cacheDirectory.delete(recursive: true));

      final repository = SplashRepository(
        storage,
        cacheDirectory: SplashCacheDirectory(cacheDirectory.path),
        previewImageUrl: previewImageUrl,
        loadRemoteContent: (_) async => content,
      );

      await repository.preloadNextContent();

      expect(storage.loadSplashCacheMetadata(), isNull);
      expect(await cacheDirectory.list().isEmpty, isTrue);
    }

    await expectRejected(
      previewImageUrl: 'https://example.test/cached.jpg',
      content: SplashRemoteContent(
        bytes: Uint8List.fromList([1, 2, 3]),
        contentType: 'image/jpeg',
      ),
    );
    await expectRejected(
      previewImageUrl: 'http://xcfb.screx.com.cn/cached.jpg',
      content: SplashRemoteContent(
        bytes: Uint8List.fromList([1, 2, 3]),
        contentType: 'image/jpeg',
      ),
    );
    await expectRejected(
      previewImageUrl: 'https://xcfb.screx.com.cn/cached.jpg',
      content: SplashRemoteContent(
        bytes: Uint8List.fromList([1, 2, 3]),
        contentType: 'text/html',
      ),
    );
    await expectRejected(
      previewImageUrl: 'https://xcfb.screx.com.cn/cached.jpg',
      content: SplashRemoteContent(
        bytes: Uint8List(3 * 1024 * 1024 + 1),
        contentType: 'image/jpeg',
      ),
    );
  });

  testWidgets('first launch shows privacy guide before onboarding', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(admin9AppForTest(preferences));
    await tester.pump();

    expect(find.byKey(const Key('privacy-guide-page')), findsOneWidget);
    expect(find.text('个人隐私保护指引'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-page')), findsNothing);
    expect(find.byKey(const Key('splash-skip')), findsNothing);

    await tester.tap(find.byKey(const Key('privacy-decline')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('privacy-declined-page')), findsOneWidget);
    expect(find.text('需同意后使用'), findsOneWidget);
    expect(find.textContaining('不会写入同意状态'), findsOneWidget);
    expect(find.byKey(const Key('privacy-guide-page')), findsNothing);
    expect(find.byKey(const Key('onboarding-page')), findsNothing);
    expect(find.byKey(const Key('splash-skip')), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(preferences.getBool('privacy_guide_accepted'), isNot(true));
    expect(preferences.getString('splash_cache_metadata'), isNull);

    await tester.tap(find.byKey(const Key('privacy-review-again')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('privacy-guide-page')), findsOneWidget);
    expect(preferences.getBool('privacy_guide_accepted'), isNot(true));
  });

  testWidgets('privacy agreement links open complete non-placeholder pages', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(admin9AppForTest(preferences));
    await tester.pump();

    await tester.tap(find.text('《隐私政策》'));
    await tester.pumpAndSettle();

    expect(find.text('隐私政策'), findsWidgets);
    expect(find.textContaining('信息收集范围'), findsOneWidget);
    expect(find.textContaining('不会把这些原型数据上传至后台生产服务'), findsOneWidget);
    expect(find.textContaining('以正式发布版本为准'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('《用户协议》'));
    await tester.pumpAndSettle();

    expect(find.text('用户协议'), findsWidgets);
    expect(find.textContaining('当前 Flutter 仓库为静态数据原型'), findsOneWidget);
    expect(find.textContaining('停止使用与反馈'), findsOneWidget);
    expect(find.textContaining('以正式发布版本为准'), findsNothing);
  });

  testWidgets('accepting privacy enters onboarding then home without splash', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(admin9AppForTest(preferences));
    await tester.pump();

    await tester.tap(find.byKey(const Key('privacy-accept')));
    await tester.pumpAndSettle();

    expect(preferences.getBool('privacy_guide_accepted'), isTrue);
    expect(find.byKey(const Key('onboarding-page')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-image')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-start')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-page-view')), findsNothing);
    expect(find.byKey(const Key('onboarding-dots')), findsNothing);
    expect(find.byKey(const Key('splash-skip')), findsNothing);
    expect(find.byKey(const Key('onboarding-skip')), findsNothing);
    expect(find.text('跳过'), findsNothing);

    await tester.tap(find.byKey(const Key('onboarding-start')));
    await tester.pumpAndSettle();

    expect(preferences.getBool('onboarding_completed'), isTrue);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('首页'), findsWidgets);
    expect(find.byKey(const Key('splash-skip')), findsNothing);
  });

  testWidgets('later launch skips splash when no cached content exists', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'privacy_guide_accepted': true,
      'onboarding_completed': true,
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(admin9AppForTest(preferences));
    await tester.pump();

    expect(find.byKey(const Key('splash-loading-blocker')), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('splash-skip')), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('later launch shows cached splash and enters app after skip', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'privacy_guide_accepted': true,
      'onboarding_completed': true,
      'splash_cache_metadata': splashCacheMetadata(),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(admin9AppForTest(preferences));
    await tester.pump();

    expect(find.byKey(const Key('splash-asset-image')), findsOneWidget);
    expect(find.byKey(const Key('splash-fallback-background')), findsOneWidget);
    expect(find.text('跳过 5'), findsOneWidget);
    expect(find.text('城市更新进行时'), findsNothing);
    expect(find.text('关注身边变化，发现美好生活'), findsNothing);
    expect(find.text('立即查看'), findsNothing);
    expect(find.byKey(const Key('splash-action')), findsNothing);

    await tester.tap(find.byKey(const Key('splash-skip')));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('推荐'), findsWidgets);
  });

  testWidgets('cached splash enters app when countdown finishes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'privacy_guide_accepted': true,
      'onboarding_completed': true,
      'splash_cache_metadata': splashCacheMetadata(),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(admin9AppForTest(preferences));
    await tester.pump();

    expect(find.text('跳过 5'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('首页'), findsWidgets);
  });

  testWidgets('cached splash action opens internal preview before home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'privacy_guide_accepted': true,
      'onboarding_completed': true,
      'splash_cache_metadata': splashCacheMetadata(
        actionUrl: 'https://xichang.example/city',
        targetTitle: '城市更新专题',
      ),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(admin9AppForTest(preferences));
    await tester.pump();

    expect(find.byKey(const Key('splash-asset-image')), findsOneWidget);
    expect(find.byKey(const Key('splash-action')), findsOneWidget);
    expect(find.text('立即查看'), findsOneWidget);

    await tester.tap(find.byKey(const Key('splash-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('splash-action-preview')), findsOneWidget);
    expect(find.text('城市更新专题'), findsOneWidget);
    expect(find.text('https://xichang.example/city'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.byKey(const Key('splash-action-continue')));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('推荐'), findsWidgets);
  });

  testWidgets('resume from background shows cached splash over current page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'privacy_guide_accepted': true,
      'onboarding_completed': true,
      'splash_cache_metadata': splashCacheMetadata(),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pump();
    await tester.tap(find.byKey(const Key('splash-skip')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mine-top-settings-action')));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('设置'), findsWidgets);

    await simulateAppBackgroundResume(tester);

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.byKey(const Key('splash-skip')), findsOneWidget);
    expect(find.text('跳过 5'), findsOneWidget);

    await tester.tap(find.byKey(const Key('splash-skip')));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('设置'), findsWidgets);
    expect(find.byKey(const Key('splash-skip')), findsNothing);
  });

  testWidgets(
    'resume from background without cached splash keeps current page',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'privacy_guide_accepted': true,
        'onboarding_completed': true,
      });
      final preferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(Admin9App(preferences: preferences));
      await tester.pumpAndSettle();

      await tester.tap(find.text('我的').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('mine-top-settings-action')));
      await tester.pumpAndSettle();

      await simulateAppBackgroundResume(tester);

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byKey(const Key('splash-skip')), findsNothing);
    },
  );

  testWidgets('resume from background waits for privacy and onboarding', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'splash_cache_metadata': splashCacheMetadata(),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pump();

    expect(find.byKey(const Key('privacy-guide-page')), findsOneWidget);

    await simulateAppBackgroundResume(tester);

    expect(find.byKey(const Key('privacy-guide-page')), findsOneWidget);
    expect(find.byKey(const Key('splash-skip')), findsNothing);
  });

  testWidgets('inactive resume does not show splash', (tester) async {
    SharedPreferences.setMockInitialValues({
      'privacy_guide_accepted': true,
      'onboarding_completed': true,
      'splash_cache_metadata': splashCacheMetadata(),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pump();
    await tester.tap(find.byKey(const Key('splash-skip')));
    await tester.pumpAndSettle();

    await simulateTransientInactiveResume(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(const Key('splash-skip')), findsNothing);
  });

  testWidgets('resume does not stack a second splash while one is visible', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'privacy_guide_accepted': true,
      'onboarding_completed': true,
      'splash_cache_metadata': splashCacheMetadata(),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pump();
    await tester.tap(find.byKey(const Key('splash-skip')));
    await tester.pumpAndSettle();

    await simulateAppBackgroundResume(tester);
    expect(find.byKey(const Key('splash-skip')), findsOneWidget);

    await simulateAppBackgroundResume(tester);
    expect(find.byKey(const Key('splash-skip')), findsOneWidget);

    await tester.tap(find.byKey(const Key('splash-skip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('splash-skip')), findsNothing);
  });

  testWidgets(
    'expired cached splash is skipped and refreshed for next launch',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'privacy_guide_accepted': true,
        'onboarding_completed': true,
        'splash_cache_metadata': splashCacheMetadata(
          cachedAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
      });
      final preferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(admin9AppForTest(preferences));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('splash-skip')), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets('splash falls back when no real image is configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: SplashPage(
          content: const SplashContent(
            id: 'fallback',
            title: '无图开屏',
            subtitle: '图片为空时使用兜底背景',
            mediaType: SplashMediaType.image,
            duration: Duration(seconds: 5),
            callToAction: '进入',
            sourceType: SplashSourceType.file,
            source: '/missing/splash.jpg',
          ),
          remainingSeconds: 5,
          onSkip: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('splash-asset-image')), findsNothing);
    expect(find.byKey(const Key('splash-file-image')), findsOneWidget);
    expect(find.byKey(const Key('splash-fallback-background')), findsOneWidget);
    expect(find.text('无图开屏'), findsNothing);
    expect(find.byKey(const Key('splash-action')), findsNothing);
  });

  testWidgets('shows bottom navigation and channel content feed', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('首页'), findsWidgets);
    expect(find.text('直播'), findsWidgets);
    expect(find.text('爆料'), findsWidgets);
    expect(find.text('服务'), findsWidgets);
    expect(find.text('我的'), findsWidgets);

    expect(find.text('推荐'), findsWidgets);
    expect(find.text('政声'), findsWidgets);
    expect(find.text('视频'), findsWidgets);
    expect(find.text('本地'), findsWidgets);
    expect(find.text('文旅'), findsWidgets);
    expect(find.text('专题'), findsWidgets);
    expect(find.text('火把节'), findsWidgets);
    expect(find.text('城市更新进行时：看见身边的民生变化'), findsWidgets);
    expect(find.byKey(const Key('special-entry-block')), findsOneWidget);
    expect(find.byKey(const Key('special-entry-carousel')), findsOneWidget);
    expect(find.text('政声'), findsWidgets);
  });

  testWidgets('home keeps search and channels pinned after scroll', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    expect(find.byKey(const Key('home-search-entry')), findsOneWidget);
    expect(find.text('搜索新闻、服务'), findsOneWidget);
    expect(find.byKey(const Key('top-level-scroll-首页')), findsOneWidget);
    expect(find.byKey(const Key('top-level-toolbar-首页')), findsOneWidget);
    expect(find.byKey(const Key('home-pinned-channel-bar')), findsOneWidget);
    expect(find.byKey(const Key('channel-manage-button')), findsOneWidget);
    expect(find.byType(NestedScrollView), findsNothing);
    expect(
      tester.widget<TabBar>(find.byType(TabBar)).indicatorPadding,
      const EdgeInsets.only(bottom: AppSpacing.sm),
    );
    final homeTabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(
      homeTabBar.overlayColor?.resolve({WidgetState.hovered}),
      Colors.transparent,
      reason: 'Home channel tabs opt into no-fill selection chrome explicitly.',
    );
    expect(
      homeTabBar.overlayColor?.resolve({WidgetState.pressed}),
      Colors.transparent,
    );
    expect(
      tester
          .widget<Padding>(
            find.byKey(const Key('home-channel-tab-rhythm-padding')),
          )
          .padding,
      const EdgeInsets.only(bottom: AppSpacing.xxs),
    );

    await tester.drag(
      find.byKey(const Key('channel-content-list')),
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-search-entry')), findsOneWidget);
    expect(find.text('搜索新闻、服务'), findsOneWidget);
    expect(find.byKey(const Key('home-pinned-channel-bar')), findsOneWidget);
    expect(find.byKey(const Key('channel-manage-button')), findsOneWidget);
    expectHitTestable(tester, find.byKey(const Key('home-search-entry')));
  });

  testWidgets('home channel switches keep content below pinned tabs', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    final outerController = tester
        .widget<CustomScrollView>(find.byKey(const Key('top-level-scroll-首页')))
        .controller!;
    expect(
      outerController.position.maxScrollExtent,
      moreOrLessEquals(0, epsilon: 0.1),
    );
    expect(find.byKey(const Key('channel-content-list')), findsOneWidget);
    expect(
      find.byKey(const Key('home-channel-content-recommend')),
      findsOneWidget,
    );

    await tester.drag(
      find.byKey(const Key('channel-content-list')),
      const Offset(0, -520),
    );
    await tester.pumpAndSettle();
    expect(outerController.offset, moreOrLessEquals(0, epsilon: 0.1));

    await tester.drag(
      find.byKey(const Key('channel-content-list')),
      const Offset(0, 900),
    );
    await tester.pumpAndSettle();
    expect(outerController.offset, moreOrLessEquals(0, epsilon: 0.1));

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('政声')),
    );
    await tester.pumpAndSettle();
    expect(outerController.offset, moreOrLessEquals(0, epsilon: 0.1));
    expect(
      find.byKey(const Key('home-channel-content-politics')),
      findsOneWidget,
    );

    await tester.drag(
      find.byKey(const Key('channel-content-list')),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('channel-content-list')),
      const Offset(0, 900),
    );
    await tester.pumpAndSettle();
    expect(outerController.offset, moreOrLessEquals(0, epsilon: 0.1));

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('直播')),
    );
    await tester.pumpAndSettle();

    final tabsBottom = tester
        .getBottomLeft(find.byKey(const Key('home-pinned-channel-bar')))
        .dy;
    final listTop = tester
        .getTopLeft(find.byKey(const Key('channel-content-list')))
        .dy;
    final firstCardTop = tester
        .getTopLeft(find.byKey(const Key('media-showcase-block')))
        .dy;

    expect(outerController.offset, moreOrLessEquals(0, epsilon: 0.1));
    expect(find.byKey(const Key('home-channel-content-live')), findsOneWidget);
    expect(listTop, moreOrLessEquals(tabsBottom, epsilon: 0.1));
    expect(firstCardTop, greaterThan(tabsBottom));
  });

  testWidgets(
    'iOS status bar tap scrolls current home channel to top',
    (tester) async {
      await pumpAdmin9App(tester);

      final contentList = find.byKey(const Key('channel-content-list')).first;
      final contentController = tester
          .widget<CustomScrollView>(contentList)
          .controller!;

      await tester.drag(contentList, const Offset(0, -520));
      await tester.pumpAndSettle();
      expect(contentController.offset, greaterThan(0));

      await simulateStatusBarTapAndSettle(tester);

      expect(contentController.offset, 0);
      expectHitTestable(tester, find.byKey(const Key('home-search-entry')));
      expectHitTestable(tester, find.byKey(const Key('channel-manage-button')));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'iOS status bar tap targets the active home channel only',
    (tester) async {
      await pumpAdmin9App(tester);

      final recommendList = find.byKey(const Key('channel-content-list')).first;
      final recommendController = tester
          .widget<CustomScrollView>(recommendList)
          .controller!;
      await tester.drag(recommendList, const Offset(0, -520));
      await tester.pumpAndSettle();
      expect(recommendController.offset, greaterThan(0));

      await tester.tap(
        find.descendant(of: find.byType(TabBar), matching: find.text('政声')),
      );
      await tester.pumpAndSettle();

      final politicsList = find.byKey(const Key('channel-content-list')).first;
      final politicsController = tester
          .widget<CustomScrollView>(politicsList)
          .controller!;
      await tester.drag(politicsList, const Offset(0, -320));
      await tester.pumpAndSettle();
      expect(politicsController.offset, greaterThan(0));

      await simulateStatusBarTapAndSettle(tester);

      expect(politicsController.offset, 0);
      expectHitTestable(tester, find.byKey(const Key('home-search-entry')));
      expectHitTestable(tester, find.byKey(const Key('channel-manage-button')));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'iOS status bar tap does not reset home while detail route is current',
    (tester) async {
      await pumpAdmin9App(tester);

      final contentList = find.byKey(const Key('channel-content-list')).first;
      final contentController = tester
          .widget<CustomScrollView>(contentList)
          .controller!;

      await tester.drag(contentList, const Offset(0, -520));
      await tester.pumpAndSettle();
      expect(contentController.offset, greaterThan(0));

      await tapVisible(
        tester,
        find.byKey(const Key('content-item-laos-meeting')),
      );
      expect(find.text('文章详情'), findsOneWidget);

      await simulateStatusBarTapAndSettle(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(contentController.offset, greaterThan(0));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'iOS status bar tap scrolls non-home top page to top',
    (tester) async {
      await pumpAdmin9App(tester);

      await tester.tap(find.text('我的').last);
      await tester.pumpAndSettle();

      final scrollView = find.byKey(const Key('top-level-scroll-我的'));
      final controller = tester
          .widget<CustomScrollView>(scrollView)
          .controller!;

      await tester.drag(scrollView, const Offset(0, -520));
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(0));

      await simulateStatusBarTapAndSettle(tester);

      expect(controller.offset, 0);
      expectHitTestable(
        tester,
        find.byKey(const Key('mine-top-message-action')),
      );
      expectHitTestable(
        tester,
        find.byKey(const Key('mine-top-settings-action')),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('reselecting current bottom tab scrolls report guide to top', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('爆料').last);
    await tester.pumpAndSettle();

    final reportScroll = find.byKey(const Key('top-level-scroll-爆料'));
    final controller = tester
        .widget<CustomScrollView>(reportScroll)
        .controller!;
    await tester.drag(reportScroll, const Offset(0, -420));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));

    await tester.tap(find.text('爆料').last);
    await tester.pumpAndSettle();

    expect(controller.offset, moreOrLessEquals(0, epsilon: 0.1));
    expect(find.byKey(const Key('report-entry-page')), findsOneWidget);
  });

  testWidgets('home toolbar keeps backdrop visible without a frosted layer', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    expect(find.byKey(const Key('top-level-toolbar-首页')), findsOneWidget);
    expect(find.byKey(const Key('top-level-toolbar-blur-首页')), findsNothing);
    expect(find.byKey(const Key('top-level-toolbar-tint-首页')), findsNothing);
    expect(find.byKey(const Key('top-level-toolbar-divider-首页')), findsNothing);
    expect(
      find.byKey(const Key('top-level-toolbar-background-opacity-首页')),
      findsNothing,
    );
    expect(
      find.byKey(
        const Key(
          'top-level-scroll-edge-backdrop-首页-page-backdrop-image-asset',
        ),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('home-page-backdrop')), findsNothing);
    expect(find.byKey(const Key('home-top-chrome-background')), findsNothing);
    expect(find.byKey(const Key('top-level-chrome-backdrop-首页')), findsNothing);

    await tester.drag(
      find.byKey(const Key('channel-content-list')),
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('top-level-toolbar-首页')), findsOneWidget);
    expect(find.byKey(const Key('top-level-toolbar-blur-首页')), findsNothing);
    expect(find.byKey(const Key('top-level-toolbar-tint-首页')), findsNothing);
    expect(find.byKey(const Key('top-level-toolbar-divider-首页')), findsNothing);
    expect(
      find.byKey(const Key('top-level-toolbar-background-opacity-首页')),
      findsNothing,
    );
    expect(
      find.byKey(
        const Key(
          'top-level-scroll-edge-backdrop-首页-page-backdrop-image-asset',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('home channels fall back to the shared top surface image', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('政声').first);
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(
      find.byKey(
        const Key(
          'top-level-scroll-edge-backdrop-首页-page-backdrop-image-asset',
        ),
      ),
    );
    expect(image.image, isA<AssetImage>());
    expect(
      (image.image as AssetImage).assetName,
      AppAssets.topLevelHeaderImage(AppBrand.defaultBrand.id),
    );
    expect(image.fit, BoxFit.cover);
    expect(image.alignment, Alignment.bottomCenter);
  });

  testWidgets('home dark top chrome keeps search and channels usable', (
    tester,
  ) async {
    await pumpAdmin9App(
      tester,
      initialPreferences: {'appearance_theme_mode': AppThemeMode.dark.name},
    );

    expect(find.byKey(const Key('home-search-entry')), findsOneWidget);
    expect(find.byKey(const Key('home-pinned-channel-bar')), findsOneWidget);
    expect(find.byKey(const Key('channel-manage-button')), findsOneWidget);
    expect(find.byKey(const Key('home-page-backdrop')), findsNothing);
    expect(find.byKey(const Key('top-level-toolbar-blur-首页')), findsNothing);
    expect(
      find.byKey(
        const Key('top-level-scroll-edge-backdrop-首页-page-backdrop-empty'),
      ),
      findsWidgets,
    );
    expect(
      find.byKey(
        const Key(
          'top-level-scroll-edge-backdrop-首页-page-backdrop-image-asset',
        ),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('home-search-entry')),
        matching: find.byKey(const Key('app-search-entry-blur')),
      ),
      findsNothing,
    );
    final darkSearchMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byKey(const Key('home-search-entry')),
        matching: find.byType(Material),
      ),
    );
    expectColorNear(
      darkSearchMaterial.color!,
      Colors.white.withValues(alpha: 0.10),
    );
    final darkSearchShape = darkSearchMaterial.shape as RoundedRectangleBorder;
    expectColorNear(
      darkSearchShape.side.color,
      Colors.white.withValues(alpha: 0.14),
    );

    await tester.drag(
      find.byKey(const Key('channel-content-list')),
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();

    expectHitTestable(tester, find.byKey(const Key('home-search-entry')));
    expectHitTestable(tester, find.byKey(const Key('channel-manage-button')));
  });

  testWidgets('top chrome foreground follows dark channel surface', (
    tester,
  ) async {
    const surfaceColor = Color(0xffb00020);

    await tester.pumpWidget(
      themedHarness(
        child: const _TopSurfaceForegroundHost(
          title: '深色频道',
          surfaceColor: surfaceColor,
        ),
      ),
    );

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.labelColor, Colors.white);
    expect(tabBar.indicatorColor, Colors.white);
    expect(tabBar.unselectedLabelColor, Colors.white.withValues(alpha: 0.72));

    final manageIconTheme = IconTheme.of(
      tester.element(find.byKey(const Key('surface-manage-button'))),
    );
    expect(manageIconTheme.color, Colors.white);

    expect(
      find.descendant(
        of: find.byKey(const Key('surface-search-entry')),
        matching: find.byKey(const Key('app-search-entry-blur')),
      ),
      findsNothing,
    );
    final searchMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byKey(const Key('surface-search-entry')),
        matching: find.byType(Material),
      ),
    );
    expectColorNear(
      searchMaterial.color!,
      Colors.white.withValues(alpha: 0.10),
    );
    final searchShape = searchMaterial.shape as RoundedRectangleBorder;
    expectColorNear(
      searchShape.side.color,
      Colors.white.withValues(alpha: 0.14),
    );

    final searchIcon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const Key('surface-search-entry')),
        matching: find.byIcon(Icons.search_rounded),
      ),
    );
    expect(searchIcon.color, Colors.white.withValues(alpha: 0.82));
    final searchText = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('surface-search-entry')),
        matching: find.text('搜索'),
      ),
    );
    expect(searchText.style?.color, Colors.white.withValues(alpha: 0.82));
  });

  testWidgets('top chrome foreground keeps brand colors on light surface', (
    tester,
  ) async {
    late AppThemeTokens tokens;

    await tester.pumpWidget(
      themedHarness(
        child: Builder(
          builder: (context) {
            tokens = context.tokens;
            return const _TopSurfaceForegroundHost(
              title: '浅色频道',
              surfaceColor: Color(0xffffe4d8),
            );
          },
        ),
      ),
    );

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.labelColor, tokens.brand.primary);
    expect(tabBar.indicatorColor, tokens.brand.primary);
    expect(tabBar.unselectedLabelColor, tokens.textSecondary);

    final searchMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byKey(const Key('surface-search-entry')),
        matching: find.byType(Material),
      ),
    );
    expect(searchMaterial.color, Colors.white.withValues(alpha: 0.50));
    final searchIcon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const Key('surface-search-entry')),
        matching: find.byIcon(Icons.search_rounded),
      ),
    );
    expect(searchIcon.color, tokens.textTertiary);
  });

  testWidgets('immersive home channel hides light backdrop in dark mode', (
    tester,
  ) async {
    await pumpAdmin9App(
      tester,
      initialPreferences: {'appearance_theme_mode': AppThemeMode.dark.name},
    );

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('专题')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('home-immersive-channel-backdrop')),
      findsNothing,
    );
    expect(
      find.byKey(
        const Key('home-immersive-channel-backdrop-page-backdrop-image-asset'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const Key('top-level-scroll-edge-backdrop-首页-page-backdrop-empty'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key(
          'top-level-scroll-edge-backdrop-首页-page-backdrop-image-asset',
        ),
      ),
      findsNothing,
    );

    expect(find.byKey(const Key('home-channel-h5-topic')), findsOneWidget);
    expect(find.text(ChannelRepository.topicH5Url), findsOneWidget);
    expectHitTestable(tester, find.byKey(const Key('home-search-entry')));
    expectHitTestable(tester, find.byKey(const Key('channel-manage-button')));
  });

  testWidgets('home toolbar includes status safe area and 44px search', (
    tester,
  ) async {
    const topPadding = 24.0;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = FakeViewPadding(top: topPadding);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await pumpAdmin9App(tester);

    expect(
      tester.getRect(find.byKey(const Key('top-level-toolbar-首页'))).height,
      topPadding + AppSpacing.topLevelToolbarHeight,
    );
    final homeBackdropSurface = find.byKey(
      const Key('top-level-scroll-edge-backdrop-首页-page-backdrop-surface'),
    );
    expect(tester.getRect(homeBackdropSurface).width, 390);
    expect(
      tester.getRect(homeBackdropSurface).height,
      topLevelBackdropChromeHeight(
        topPadding: topPadding,
        includePinnedChannels: true,
      ),
    );
    expect(
      find.byKey(
        const Key(
          'top-level-scroll-edge-backdrop-首页-page-backdrop-image-asset',
        ),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('home-page-backdrop')), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const Key('top-level-toolbar-首页'))).dy,
      0,
    );
    final searchRect = tester.getRect(
      find.byKey(const Key('home-search-entry')),
    );
    expect(searchRect.height, 40);
    final searchBlur = tester.widget<BackdropFilter>(
      find.descendant(
        of: find.byKey(const Key('home-search-entry')),
        matching: find.byKey(const Key('app-search-entry-blur')),
      ),
    );
    expect(searchBlur.filter, ImageFilter.blur(sigmaX: 8, sigmaY: 8));
    final searchMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byKey(const Key('home-search-entry')),
        matching: find.byType(Material),
      ),
    );
    expect(searchMaterial.color, Colors.white.withValues(alpha: 0.50));
    final searchShape = searchMaterial.shape as RoundedRectangleBorder;
    expect(searchShape.side.color, Colors.white.withValues(alpha: 0.30));
    expect(
      searchRect.top,
      topPadding + (AppSpacing.topLevelToolbarHeight - 40) / 2,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('home-pinned-channel-bar'))).dy,
      topPadding + AppSpacing.topLevelToolbarHeight,
    );
    expect(
      find.byKey(const Key('top-level-tabs-backdrop-首页-page-backdrop-slice')),
      findsNothing,
    );
    expect(
      tester
          .getRect(
            find.byKey(
              const Key(
                'top-level-scroll-edge-backdrop-首页-page-backdrop-surface',
              ),
            ),
          )
          .height,
      topLevelBackdropChromeHeight(
        topPadding: topPadding,
        includePinnedChannels: true,
      ),
    );
  });

  testWidgets('top-level backdrop slots follow runtime chrome config', (
    tester,
  ) async {
    const cases = [
      _ChromeSlotCase(
        name: 'search and tabs reserve slot by default',
        topPadding: 24,
        search: true,
        tabs: true,
        expectSlot: true,
        expectControls: true,
        expectedContentTop: 80,
      ),
      _ChromeSlotCase(
        name: 'tabs without search still show title slot by default',
        topPadding: 24,
        search: false,
        tabs: true,
        expectSlot: true,
        expectControls: true,
        expectedContentTop: 80,
      ),
      _ChromeSlotCase(
        name: 'plain content keeps scroll-edge title slot by default',
        topPadding: 24,
        search: false,
        tabs: false,
        expectSlot: true,
        expectControls: true,
        expectedContentTop: 80,
      ),
      _ChromeSlotCase(
        name: 'explicit false keeps visible title controls when enabled',
        topPadding: 24,
        search: false,
        tabs: true,
        reserveToolbarSlot: false,
        expectSlot: true,
        expectControls: true,
        expectedContentTop: 80,
      ),
      _ChromeSlotCase(
        name:
            'explicit false with disabled title bar keeps tab below safe area',
        topPadding: 24,
        titleBarEnabled: false,
        search: false,
        tabs: true,
        reserveToolbarSlot: false,
        expectSlot: false,
        expectControls: false,
        expectedContentTop: 24,
      ),
      _ChromeSlotCase(
        name: 'disabled title bar with tabs reserves backdrop slot only',
        topPadding: 24,
        titleBarEnabled: false,
        search: false,
        tabs: true,
        expectSlot: true,
        expectControls: false,
        expectedContentTop: 80,
      ),
      _ChromeSlotCase(
        name: 'disabled title bar plain content keeps safe-area spacer',
        topPadding: 24,
        titleBarEnabled: false,
        search: false,
        tabs: false,
        expectSlot: false,
        expectControls: false,
        expectedContentTop: 24,
      ),
      _ChromeSlotCase(
        name: 'actions reserve visible toolbar controls',
        topPadding: 24,
        search: false,
        tabs: false,
        actions: true,
        expectSlot: true,
        expectControls: true,
        expectedContentTop: 80,
      ),
      _ChromeSlotCase(
        name: 'explicit true can reserve slot without title-bar controls',
        topPadding: 24,
        titleBarEnabled: false,
        search: false,
        tabs: false,
        reserveToolbarSlot: true,
        expectSlot: true,
        expectControls: false,
        expectedContentTop: 80,
      ),
      _ChromeSlotCase(
        name: 'zero safe-area keeps reserved slot at toolbar height',
        topPadding: 0,
        search: true,
        tabs: true,
        expectSlot: true,
        expectControls: true,
        expectedContentTop: 56,
      ),
      _ChromeSlotCase(
        name: 'zero safe-area without slot starts at top',
        topPadding: 0,
        titleBarEnabled: false,
        search: false,
        tabs: false,
        expectSlot: false,
        expectControls: false,
        expectedContentTop: 0,
      ),
    ];

    for (final entry in cases) {
      await tester.pumpWidget(
        themedHarness(
          child: MediaQuery(
            data: MediaQueryData(
              padding: EdgeInsets.only(top: entry.topPadding),
            ),
            child: _ChromeSlotHost(
              search: entry.search,
              tabs: entry.tabs,
              actions: entry.actions,
              titleBarEnabled: entry.titleBarEnabled,
              reserveToolbarSlot: entry.reserveToolbarSlot,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final reason = entry.name;
      final slotFinder = find.byKey(const Key('top-level-toolbar-slot-配置页'));
      final controlsFinder = find.byKey(const Key('top-level-toolbar-配置页'));
      final titleFinder = find.byKey(const Key('top-level-toolbar-title-配置页'));
      final actionFinder = find.byKey(const Key('config-toolbar-action'));
      final scrollEdgeBackdropSurfaceFinder = find.byKey(
        const Key('top-level-scroll-edge-backdrop-配置页-page-backdrop-surface'),
      );
      final contentFinder = entry.tabs
          ? find.byKey(const Key('config-pinned-tab-bar'))
          : find.text('配置列表 0');

      expect(
        slotFinder,
        entry.expectSlot ? findsOneWidget : findsNothing,
        reason: reason,
      );
      expect(
        controlsFinder,
        entry.expectControls ? findsOneWidget : findsNothing,
        reason: reason,
      );
      expect(
        find.byKey(const Key('config-search-entry')),
        entry.search ? findsOneWidget : findsNothing,
        reason: reason,
      );
      expect(
        titleFinder,
        entry.expectTitle ? findsOneWidget : findsNothing,
        reason: reason,
      );
      expect(
        actionFinder,
        entry.actions && entry.expectControls ? findsOneWidget : findsNothing,
        reason: reason,
      );
      expect(
        find.byKey(const Key('config-pinned-tab-bar')),
        entry.tabs ? findsOneWidget : findsNothing,
        reason: reason,
      );
      expect(
        tester.getTopLeft(contentFinder).dy,
        entry.expectedContentTop,
        reason: reason,
      );

      if (entry.expectSlot) {
        expect(
          tester.getRect(slotFinder).height,
          entry.topPadding + AppSpacing.topLevelToolbarHeight,
          reason: reason,
        );
        expect(
          tester.getRect(scrollEdgeBackdropSurfaceFinder).height,
          topLevelBackdropChromeHeight(
            topPadding: entry.topPadding,
            includePinnedChannels: entry.tabs,
          ),
          reason: reason,
        );
      }

      final expectedScrollEdgeCanvasHeight = topLevelBackdropChromeHeight(
        topPadding: entry.topPadding,
        reserveToolbarSlot: entry.expectSlot,
        includePinnedChannels: entry.tabs,
      );
      if (!entry.expectSlot && expectedScrollEdgeCanvasHeight > 0) {
        expect(
          tester.getRect(scrollEdgeBackdropSurfaceFinder).height,
          expectedScrollEdgeCanvasHeight,
          reason: reason,
        );
      }

      if (entry.tabs) {
        expect(
          tester
              .getRect(
                find.byKey(
                  const Key(
                    'top-level-scroll-edge-backdrop-配置页-page-backdrop-surface',
                  ),
                ),
              )
              .height,
          topLevelBackdropChromeHeight(
            topPadding: entry.topPadding,
            reserveToolbarSlot: entry.expectSlot,
            includePinnedChannels: true,
          ),
          reason: reason,
        );
      }
    }
  });

  testWidgets('home content starts below channels with standard top gap', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    final contentPadding = tester.widget<SliverPadding>(
      find.byKey(const Key('channel-content-padding')),
    );
    expect(
      contentPadding.padding.resolve(TextDirection.ltr).top,
      AppSpacing.homeChannelContentTopGap,
    );
    expect(find.byKey(const Key('home-page-backdrop')), findsNothing);
  });

  testWidgets('topic channel uses brand backdrop without immersive skin', (
    tester,
  ) async {
    expect(
      const MediaChannelStyle().surfaceMode,
      MediaChannelSurfaceMode.normal,
    );
    final topicChannel = ChannelRepository.defaultChannels.firstWhere(
      (channel) => channel.label == '专题',
    );
    expect(topicChannel.style.surfaceMode, MediaChannelSurfaceMode.normal);
    expect(topicChannel.style.topSurfaceMode, MediaChannelTopSurfaceMode.brand);
    expect(topicChannel.style.backgroundColor, isNull);

    await pumpAdmin9App(tester);
    final tokens = Theme.of(
      tester.element(find.byKey(const Key('admin9-shell-content'))),
    ).extension<AppThemeTokens>()!;

    expect(
      find.byKey(const Key('home-immersive-channel-backdrop')),
      findsNothing,
    );

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('专题')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-page-backdrop')), findsNothing);
    expect(
      find.byKey(const Key('home-immersive-channel-backdrop')),
      findsNothing,
    );
    expect(
      find.byKey(
        const Key(
          'top-level-scroll-edge-backdrop-首页-page-backdrop-image-asset',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('top-level-scroll-edge-backdrop-首页-page-backdrop-empty'),
      ),
      findsNothing,
    );

    final topChromeImage = tester.widget<Image>(
      find.byKey(
        const Key(
          'top-level-scroll-edge-backdrop-首页-page-backdrop-image-asset',
        ),
      ),
    );
    expect(topChromeImage.image, isA<AssetImage>());
    expect(
      (topChromeImage.image as AssetImage).assetName,
      AppAssets.topLevelHeaderImage(AppBrand.defaultBrand.id),
    );

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.labelColor, tokens.brand.primary);
    expect(tabBar.indicatorColor, tokens.brand.primary);
    expect(tabBar.unselectedLabelColor, tokens.textSecondary);

    final manageIconTheme = IconTheme.of(
      tester.element(find.byKey(const Key('channel-manage-button'))),
    );
    expect(manageIconTheme.color, tokens.brand.primary);

    final searchIcon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const Key('home-search-entry')),
        matching: find.byIcon(Icons.search_rounded),
      ),
    );
    expect(searchIcon.color, tokens.textTertiary);

    expect(find.byKey(const Key('home-channel-h5-topic')), findsOneWidget);
    expect(
      find.byKey(const Key('fake-channel-h5-webview-topic')),
      findsOneWidget,
    );
    expect(find.text(ChannelRepository.topicH5Url), findsOneWidget);
    expect(find.byKey(const Key('channel-content-list')), findsNothing);
  });

  testWidgets('plain home channels do not render immersive backdrop', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('政声')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('home-immersive-channel-backdrop')),
      findsNothing,
    );

    final contentPadding = tester.widget<SliverPadding>(
      find.byKey(const Key('channel-content-padding')),
    );
    expect(
      contentPadding.padding.resolve(TextDirection.ltr).top,
      AppSpacing.homeChannelContentTopGap,
    );
  });

  testWidgets('home uses custom page toolbar and content channel tabs', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    expect(find.byKey(const Key('home-search-entry')), findsOneWidget);
    expect(find.byKey(const Key('top-level-scroll-首页')), findsOneWidget);
    expect(find.byKey(const Key('top-level-toolbar-首页')), findsOneWidget);
    expect(find.byKey(const Key('top-level-toolbar-blur-首页')), findsNothing);
    expect(find.byKey(const Key('top-level-toolbar-title-首页')), findsNothing);
    expect(
      find.byKey(const Key('top-level-scroll-edge-backdrop-首页')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('top-level-chrome-backdrop-首页')), findsNothing);
    expect(find.byKey(const Key('home-channel-tabs-sliver')), findsOneWidget);
    expect(find.byType(NestedScrollView), findsNothing);
  });

  testWidgets(
    'configured top-level page disposes internal controller ownership',
    (tester) async {
      final hostKey = GlobalKey<_ControllerOwnershipHostState>();

      await tester.pumpWidget(
        themedHarness(child: _ControllerOwnershipHost(key: hostKey)),
      );
      await tester.pumpAndSettle();

      expect(find.text('内部一'), findsOneWidget);
      hostKey.currentState!.useExternalController();
      await tester.pumpAndSettle();
      expect(find.text('外部二'), findsOneWidget);

      hostKey.currentState!.useInternalController();
      await tester.pumpAndSettle();
      expect(find.text('内部二'), findsOneWidget);
    },
  );

  testWidgets('top-level pages render through shared page configuration', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    for (final label in ['首页', '直播', '爆料', '服务', '我的']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();

      expect(find.byType(ConfiguredTopLevelPage), findsWidgets);
      expect(find.byKey(Key('top-level-scroll-$label')), findsOneWidget);
    }
  });

  test('live and report repositories expose enough preview rows', () {
    expect(const LiveRepository().programs.length, greaterThanOrEqualTo(8));
    expect(const ReportRepository().reports.length, greaterThanOrEqualTo(9));
  });

  testWidgets('non-home top pages keep their scroll-edge title behaviors', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    const titleBehavior = {
      '爆料': (Alignment.center, 1.0),
      '服务': (Alignment.center, 1.0),
      '我的': (Alignment.centerLeft, 0.0),
    };

    for (final entry in titleBehavior.entries) {
      final label = entry.key;
      final (expectedAlignment, initialTitleOpacity) = entry.value;
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();

      expect(find.byKey(Key('top-level-scroll-$label')), findsOneWidget);
      expect(find.byKey(Key('top-level-toolbar-$label')), findsOneWidget);
      expect(find.byKey(Key('top-level-toolbar-blur-$label')), findsNothing);
      expect(find.byKey(Key('top-level-toolbar-tint-$label')), findsNothing);
      expect(find.byKey(Key('top-level-toolbar-divider-$label')), findsNothing);
      expect(find.byKey(Key('top-level-toolbar-title-$label')), findsOneWidget);
      expect(
        opacityOf(tester, Key('top-level-title-opacity-$label')),
        initialTitleOpacity,
      );
      expect(
        find.byKey(Key('top-level-toolbar-background-opacity-$label')),
        findsNothing,
      );
      expect(
        find.byKey(Key('top-level-scroll-edge-backdrop-$label')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          Key(
            'top-level-scroll-edge-backdrop-$label-page-backdrop-image-asset',
          ),
        ),
        findsOneWidget,
      );
      expect(find.byKey(Key('top-level-chrome-backdrop-$label')), findsNothing);
      expect(
        find.byKey(Key('top-level-scroll-edge-spacer-$label')),
        findsNothing,
      );

      final image = tester.widget<Image>(
        find.byKey(
          Key(
            'top-level-scroll-edge-backdrop-$label-page-backdrop-image-asset',
          ),
        ),
      );
      expect(
        (image.image as AssetImage).assetName,
        AppAssets.topLevelHeaderImage(AppBrand.defaultBrand.id),
      );
      expect(image.alignment, Alignment.topCenter);
      final titleAlign = tester.widget<Align>(
        find.byKey(Key('top-level-title-alignment-$label')),
      );
      expect(titleAlign.alignment, expectedAlignment);
      final titleText = tester.widget<Text>(
        find.byKey(Key('top-level-scroll-edge-title-$label')),
      );
      expect(
        titleText.style?.fontSize,
        AppTheme.light().extension<AppTypography>()!.sectionTitle.fontSize,
      );
      expect(titleText.style?.fontWeight, FontWeight.w700);
      if (initialTitleOpacity == 0) {
        await dragUntilOpacityAbove(
          tester,
          scrollKey: Key('top-level-scroll-$label'),
          opacityKey: Key('top-level-title-opacity-$label'),
        );
      } else {
        await tester.drag(
          find.byKey(Key('top-level-scroll-$label')),
          const Offset(0, -260),
        );
        await tester.pumpAndSettle();
      }
      expect(
        find.byKey(Key('top-level-toolbar-background-opacity-$label')),
        findsNothing,
      );
      if (label == '爆料') {
        expect(find.byKey(const Key('report-pinned-tab-bar')), findsNothing);
        expect(find.byKey(const Key('report-entry-page')), findsOneWidget);
      }
    }
  });

  testWidgets('default page toolbar can center its title', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      themedHarness(
        child: TopLevelPageScaffold(
          title: '可配置标题',
          mode: TopLevelPageScaffoldMode.scrollEdgeTitle,
          scrollEdgeTitleBehavior:
              TopLevelScrollEdgeTitleBehavior.visibleAtEdge,
          scrollEdgeTitleAlignment: TopLevelScrollEdgeTitleAlignment.center,
          controller: controller,
          slivers: [
            SliverList.builder(
              itemCount: 16,
              itemBuilder: (context, index) =>
                  SizedBox(height: 72, child: Text('标题配置列表 $index')),
            ),
          ],
        ),
      ),
    );

    expect(
      find.byKey(const Key('top-level-toolbar-title-可配置标题')),
      findsOneWidget,
    );
    final titleAlign = tester.widget<Align>(
      find.byKey(const Key('top-level-title-alignment-可配置标题')),
    );
    expect(titleAlign.alignment, Alignment.center);

    await tester.drag(
      find.byKey(const Key('top-level-scroll-可配置标题')),
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('top-level-toolbar-title-可配置标题')),
      findsOneWidget,
    );
  });

  testWidgets('page toolbar can be disabled for plain safe-area content', (
    tester,
  ) async {
    const topPadding = 24.0;

    await tester.pumpWidget(
      themedHarness(
        child: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: topPadding)),
          child: TopLevelPageScaffold(
            title: '无标题栏',
            mode: TopLevelPageScaffoldMode.scrollEdgeTitle,
            scrollEdgeTitleBarEnabled: false,
            slivers: [
              SliverList.builder(
                itemCount: 16,
                itemBuilder: (context, index) =>
                    SizedBox(height: 72, child: Text('无标题栏列表 $index')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('top-level-toolbar-无标题栏')), findsNothing);
    expect(
      find.byKey(const Key('top-level-scroll-edge-backdrop-无标题栏')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('top-level-safe-area-spacer-无标题栏')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('top-level-toolbar-title-无标题栏')), findsNothing);
    expect(tester.getTopLeft(find.text('无标题栏列表 0')).dy, topPadding);

    await tester.pumpWidget(
      themedHarness(
        child: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: topPadding)),
          child: TopLevelPageScaffold(
            title: '有标题栏',
            mode: TopLevelPageScaffoldMode.scrollEdgeTitle,
            slivers: [
              SliverList.builder(
                itemCount: 16,
                itemBuilder: (context, index) =>
                    SizedBox(height: 72, child: Text('有标题栏列表 $index')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('有标题栏列表 0')).dy,
      topPadding + AppSpacing.topLevelToolbarHeight,
    );
    expect(find.byKey(const Key('top-level-toolbar-有标题栏')), findsOneWidget);
    expect(
      find.byKey(const Key('top-level-toolbar-title-有标题栏')),
      findsOneWidget,
    );
  });

  testWidgets('mine exposes fixed top actions and keeps grid entries', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();

    expect(find.byTooltip('设置'), findsOneWidget);
    expect(find.byTooltip('消息通知'), findsOneWidget);
    expect(find.byKey(const Key('mine-top-message-action')), findsOneWidget);
    await dragUntilVisible(tester, find.text('设置'));
    expect(find.text('设置'), findsOneWidget);

    final settingsBefore = tester.getTopLeft(
      find.byKey(const Key('mine-top-settings-action')),
    );
    final messageBefore = tester.getTopLeft(
      find.byKey(const Key('mine-top-message-action')),
    );
    await tester.drag(
      find.byKey(const Key('top-level-scroll-我的')),
      const Offset(0, -520),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byKey(const Key('mine-top-settings-action'))),
      settingsBefore,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('mine-top-message-action'))),
      messageBefore,
    );

    await tester.tap(find.byKey(const Key('mine-top-settings-action')));
    await tester.pumpAndSettle();
    expect(find.text('清理缓存'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mine-top-message-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('message-center-content')), findsOneWidget);
  });

  testWidgets('mine dark surface hides light scroll edge image', (
    tester,
  ) async {
    await pumpAdmin9App(
      tester,
      initialPreferences: {'appearance_theme_mode': AppThemeMode.dark.name},
    );

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('top-level-scroll-edge-backdrop-我的')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key(
          'top-level-scroll-edge-backdrop-我的-page-backdrop-image-asset',
        ),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const Key('top-level-scroll-edge-backdrop-我的-page-backdrop-empty'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('top-level-toolbar-我的')), findsOneWidget);
    expect(find.byKey(const Key('top-level-toolbar-blur-我的')), findsNothing);
    expect(find.byKey(const Key('top-level-toolbar-title-我的')), findsOneWidget);
    expect(find.byKey(const Key('top-level-toolbar-divider-我的')), findsNothing);

    await tester.drag(
      find.byKey(const Key('top-level-scroll-我的')),
      const Offset(0, -520),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('top-level-toolbar-title-我的')), findsOneWidget);
  });

  testWidgets('top level scaffold keeps plain mode at status safe area', (
    tester,
  ) async {
    const topPadding = 24.0;

    await tester.pumpWidget(
      themedHarness(
        child: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: topPadding)),
          child: TopLevelPageScaffold(
            title: '安全区',
            slivers: [
              SliverList.builder(
                itemCount: 16,
                itemBuilder: (context, index) =>
                    SizedBox(height: 72, child: Text('安全区列表 $index')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('top-level-toolbar-安全区')), findsNothing);
    expect(
      find.byKey(const Key('top-level-safe-area-spacer-安全区')),
      findsOneWidget,
    );
    expect(tester.getTopLeft(find.text('安全区列表 0')).dy, topPadding);
  });

  testWidgets('search entry defaults to solid soft fill without blur', (
    tester,
  ) async {
    late AppThemeTokens tokens;

    await tester.pumpWidget(
      themedHarness(
        child: Builder(
          builder: (context) {
            tokens = context.tokens;
            return Center(
              child: AppSearchEntry(
                key: const Key('default-search-entry'),
                placeholder: '搜索',
                onTap: () {},
              ),
            );
          },
        ),
      ),
    );

    final material = tester.widget<Material>(
      find.descendant(
        of: find.byKey(const Key('default-search-entry')),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, tokens.softFill);
    expect(
      find.descendant(
        of: find.byKey(const Key('default-search-entry')),
        matching: find.byType(BackdropFilter),
      ),
      findsNothing,
    );
  });

  testWidgets('page backdrop uses soft brand preset and configured height', (
    tester,
  ) async {
    const configuredHeight = 208.0;
    late ResolvedPageSurface resolved;
    late AppThemeTokens tokens;

    await tester.pumpWidget(
      themedHarness(
        child: Builder(
          builder: (context) {
            tokens = context.tokens;
            resolved = PageSurface(
              backdrop: PageBackdrop.brand(
                tokens: tokens,
                endColor: tokens.pageBackground,
                height: configuredHeight,
                strength: 0.62,
              ),
            ).resolve(context);

            return PageBackdropView(surface: resolved);
          },
        ),
      ),
    );

    expect(resolved.backdrop.preset, PageBackdropPreset.softBrand);
    expect(resolved.backdrop.height, configuredHeight);
    expect(resolved.backdrop.strength, 0.62);
    expect(resolved.backdrop.colors, [
      tokens.brand.gradientStart,
      tokens.brand.gradientMiddle,
      tokens.pageBackground,
    ]);
    expect(resolved.backdrop.stops, const [0, 0.35, 1]);
    expect(
      tester.getRect(find.byKey(const Key('page-backdrop-gradient'))).height,
      configuredHeight,
    );
    final maskGradient = linearGradientOf(
      tester,
      const Key('page-backdrop-blend-mask'),
    );
    expect(maskGradient.begin, Alignment.topCenter);
    expect(maskGradient.end, Alignment.bottomCenter);
    expect(maskGradient.colors, [
      tokens.pageBackground.withValues(alpha: 0),
      tokens.pageBackground,
    ]);
    expect(maskGradient.stops, const [0, 1]);
  });

  testWidgets('dark page backdrop brand resolves to empty background', (
    tester,
  ) async {
    const configuredHeight = 208.0;
    late ResolvedPageSurface resolved;

    await tester.pumpWidget(
      themedHarness(
        themeMode: ThemeMode.dark,
        child: Builder(
          builder: (context) {
            resolved = PageSurface(
              backdrop: PageBackdrop.brand(
                tokens: context.tokens,
                endColor: context.tokens.pageBackground,
                height: configuredHeight,
              ),
            ).resolve(context);

            return PageBackdropView(
              surface: resolved,
              height: configuredHeight,
            );
          },
        ),
      ),
    );

    expect(resolved.backdrop.enabled, isFalse);
    expect(resolved.backdrop.startColor, resolved.backgroundColor);
    expect(resolved.backdrop.middleColor, resolved.backgroundColor);
    expect(resolved.backdrop.endColor, resolved.backgroundColor);
    expect(find.byKey(const Key('page-backdrop-empty')), findsOneWidget);
    expect(
      tester.getRect(find.byKey(const Key('page-backdrop-surface'))).height,
      configuredHeight,
    );
    expect(
      tester.getRect(find.byKey(const Key('page-backdrop-empty'))).height,
      configuredHeight,
    );
    expect(find.byKey(const Key('page-backdrop-gradient')), findsNothing);
    expect(find.byKey(const Key('page-backdrop-blend-mask')), findsNothing);
  });

  testWidgets(
    'page backdrop image uses cover bottom-center crop with blend mask',
    (tester) async {
      const configuredHeight = AppSpacing.topLevelBackdropHeight;
      late Color pageBackground;
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        themedHarness(
          child: Builder(
            builder: (context) {
              pageBackground = context.tokens.pageBackground;
              final surface = PageSurface(
                backdrop: PageBackdrop.image(
                  tokens: context.tokens,
                  endColor: context.tokens.pageBackground,
                  assetName: AppAssets.topLevelHeaderImage(
                    AppBrand.newsBlueBrand.id,
                  ),
                ),
              ).resolve(context);

              return PageBackdropView(surface: surface);
            },
          ),
        ),
      );

      final surfaceFinder = find.byKey(const Key('page-backdrop-surface'));
      expect(tester.getRect(surfaceFinder).width, 393);
      expect(tester.getRect(surfaceFinder).height, configuredHeight);

      final image = tester.widget<Image>(
        find.byKey(const Key('page-backdrop-image-asset')),
      );
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        AppAssets.topLevelHeaderImage(AppBrand.newsBlueBrand.id),
      );
      expect(image.fit, BoxFit.cover);
      expect(image.alignment, Alignment.bottomCenter);
      expect(image.width, double.infinity);
      expect(image.height, double.infinity);
      expect(find.byKey(const Key('page-backdrop-image-fade')), findsNothing);
      final maskGradient = linearGradientOf(
        tester,
        const Key('page-backdrop-blend-mask'),
      );
      expect(maskGradient.begin, Alignment.topCenter);
      expect(maskGradient.end, Alignment.bottomCenter);
      expect(maskGradient.colors, [
        pageBackground.withValues(alpha: 0),
        pageBackground,
      ]);
      expect(maskGradient.stops, const [0, 1]);
    },
  );

  testWidgets('page backdrop fadeToColor uses configured blend color', (
    tester,
  ) async {
    const surfaceColor = Color(0xfff2f7f3);
    const blendColor = Color(0xffdcefe2);

    await tester.pumpWidget(
      themedHarness(
        child: Builder(
          builder: (context) {
            final surface = const PageSurface(
              backgroundColor: surfaceColor,
              backdrop: PageBackdrop(
                startColor: Color(0xffd8efdd),
                middleColor: Color(0xffb9dfc3),
                endColor: blendColor,
                blendMode: PageBackdropBlendMode.fadeToColor,
                blendColor: blendColor,
              ),
            ).resolve(context);

            return PageBackdropView(surface: surface);
          },
        ),
      ),
    );

    final maskGradient = linearGradientOf(
      tester,
      const Key('page-backdrop-blend-mask'),
    );
    expect(maskGradient.colors, [blendColor.withValues(alpha: 0), blendColor]);
  });

  testWidgets('page backdrop none blend mode omits blend mask', (tester) async {
    await tester.pumpWidget(
      themedHarness(
        child: Builder(
          builder: (context) {
            final surface = const PageSurface(
              backdrop: PageBackdrop(
                startColor: Color(0xfffff8f1),
                middleColor: Color(0xffffddbd),
                endColor: Color(0xffff8a2a),
                blendMode: PageBackdropBlendMode.none,
              ),
            ).resolve(context);

            return PageBackdropView(surface: surface);
          },
        ),
      ),
    );

    expect(find.byKey(const Key('page-backdrop-gradient')), findsOneWidget);
    expect(find.byKey(const Key('page-backdrop-blend-mask')), findsNothing);
  });

  testWidgets('page backdrop image supports top-center crop configuration', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Builder(
          builder: (context) {
            final surface = PageSurface(
              backdrop: PageBackdrop.image(
                tokens: context.tokens,
                endColor: context.tokens.pageBackground,
                assetName: AppAssets.homeImmersiveChannelDemo,
                imageAlignment: Alignment.topCenter,
              ),
            ).resolve(context);

            return PageBackdropView(surface: surface);
          },
        ),
      ),
    );

    final image = tester.widget<Image>(
      find.byKey(const Key('page-backdrop-image-asset')),
    );
    expect(image.fit, BoxFit.cover);
    expect(image.alignment, Alignment.topCenter);
  });

  testWidgets('page backdrop image supports explicit opacity', (tester) async {
    await tester.pumpWidget(
      themedHarness(
        child: Builder(
          builder: (context) {
            final surface = PageSurface(
              backdrop: PageBackdrop.image(
                tokens: context.tokens,
                endColor: context.tokens.pageBackground,
                assetName: AppAssets.topLevelHeaderImage(
                  AppBrand.newsBlueBrand.id,
                ),
                imageOpacity: 0.42,
              ),
            ).resolve(context);

            return PageBackdropView(surface: surface);
          },
        ),
      ),
    );

    final opacity = tester.widget<Opacity>(
      find.byKey(const Key('page-backdrop-image-opacity')),
    );
    expect(opacity.opacity, 0.42);
    expect(
      find.descendant(
        of: find.byKey(const Key('page-backdrop-image-opacity')),
        matching: find.byKey(const Key('page-backdrop-image-asset')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('page backdrop image enabled override survives dark end color', (
    tester,
  ) async {
    const transientDarkSurface = Color(0xffa32635);

    await tester.pumpWidget(
      themedHarness(
        child: Builder(
          builder: (context) {
            final surface = PageSurface(
              backgroundColor: transientDarkSurface,
              backdrop: PageBackdrop.image(
                tokens: context.tokens,
                endColor: transientDarkSurface,
                assetName: AppAssets.topLevelHeaderImage(
                  AppBrand.newsBlueBrand.id,
                ),
                enabled: true,
              ),
            ).resolve(context);

            return PageBackdropView(surface: surface);
          },
        ),
      ),
    );

    final image = tester.widget<Image>(
      find.byKey(const Key('page-backdrop-image-asset')),
    );
    expect(
      (image.image as AssetImage).assetName,
      AppAssets.topLevelHeaderImage(AppBrand.newsBlueBrand.id),
    );
    expect(find.byKey(const Key('page-backdrop-empty')), findsNothing);
    expect(find.byKey(const Key('page-backdrop-blend-mask')), findsOneWidget);
  });

  testWidgets('dark page backdrop image ignores configured dark asset', (
    tester,
  ) async {
    late ResolvedPageSurface resolved;

    await tester.pumpWidget(
      themedHarness(
        themeMode: ThemeMode.dark,
        child: Builder(
          builder: (context) {
            resolved = PageSurface(
              backdrop: PageBackdrop.image(
                tokens: context.tokens,
                endColor: context.tokens.pageBackground,
                assetName: 'assets/images/light-top-surface.png',
                darkAssetName: AppAssets.topLevelHeaderImage(
                  AppBrand.newsBlueBrand.id,
                ),
              ),
            ).resolve(context);

            return PageBackdropView(surface: resolved);
          },
        ),
      ),
    );

    expect(resolved.backdrop.enabled, isFalse);
    expect(find.byKey(const Key('page-backdrop-empty')), findsOneWidget);
    expect(find.byKey(const Key('page-backdrop-image-asset')), findsNothing);
    expect(find.byKey(const Key('page-backdrop-gradient')), findsNothing);
    expect(find.byKey(const Key('page-backdrop-blend-mask')), findsNothing);
    expect(find.byKey(const Key('page-backdrop-dark-treatment')), findsNothing);
  });

  testWidgets('dark backdrop hides shared light image without dark asset', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        themeMode: ThemeMode.dark,
        child: Builder(
          builder: (context) {
            final surface = PageSurface(
              backdrop: PageBackdrop.image(
                tokens: context.tokens,
                endColor: context.tokens.pageBackground,
                assetName: AppAssets.topLevelHeaderImage(
                  AppBrand.newsBlueBrand.id,
                ),
              ),
            ).resolve(context);

            return PageBackdropView(surface: surface);
          },
        ),
      ),
    );

    expect(find.byKey(const Key('page-backdrop-empty')), findsOneWidget);
    expect(find.byKey(const Key('page-backdrop-image-asset')), findsNothing);
    expect(find.byKey(const Key('page-backdrop-image-fade')), findsNothing);
    expect(find.byKey(const Key('page-backdrop-gradient')), findsNothing);
    expect(find.byKey(const Key('page-backdrop-blend-mask')), findsNothing);
  });

  testWidgets(
    'page backdrop image falls back to soft brand gradient on error',
    (tester) async {
      await tester.pumpWidget(
        themedHarness(
          child: Builder(
            builder: (context) {
              final surface = PageSurface(
                backdrop: PageBackdrop.image(
                  tokens: context.tokens,
                  endColor: context.tokens.pageBackground,
                  assetName: 'assets/images/not-found-top-surface.png',
                ),
              ).resolve(context);

              return PageBackdropView(surface: surface);
            },
          ),
        ),
      );

      await tester.pump();

      expect(
        find.byKey(const Key('page-backdrop-image-asset')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('page-backdrop-gradient')), findsOneWidget);
      expect(find.byKey(const Key('page-backdrop-blend-mask')), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const Key('page-backdrop-gradient'))).height,
        AppSpacing.topLevelBackdropHeight,
      );
    },
  );

  testWidgets(
    'dark page backdrop image error falls back to empty dark surface',
    (tester) async {
      await tester.pumpWidget(
        themedHarness(
          themeMode: ThemeMode.dark,
          child: Builder(
            builder: (context) {
              final surface = PageSurface(
                backdrop: PageBackdrop.image(
                  tokens: context.tokens,
                  endColor: context.tokens.pageBackground,
                  darkAssetName: 'assets/images/not-found-top-surface.png',
                ),
              ).resolve(context);

              return PageBackdropView(surface: surface);
            },
          ),
        ),
      );

      await tester.pump();

      expect(find.byKey(const Key('page-backdrop-empty')), findsOneWidget);
      expect(find.byKey(const Key('page-backdrop-gradient')), findsNothing);
      expect(find.byKey(const Key('page-backdrop-blend-mask')), findsNothing);
    },
  );

  testWidgets('top level tab overlay is explicit configuration', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const _ConfiguredTabOverlayHost(
          title: '默认 Tab',
          newsStyle: true,
        ),
      ),
    );

    final defaultTabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(
      defaultTabBar.overlayColor?.resolve({WidgetState.pressed}),
      tester.element(find.byType(TabBar)).tokens.pressed,
      reason: 'newsStyle adjusts rhythm, not pressed/selected fill behavior.',
    );

    await tester.pumpWidget(
      themedHarness(
        child: const _ConfiguredTabOverlayHost(
          title: '透明 Tab',
          newsStyle: true,
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    );

    final configuredTabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(
      configuredTabBar.overlayColor?.resolve({WidgetState.pressed}),
      Colors.transparent,
    );
    expect(
      configuredTabBar.overlayColor?.resolve({WidgetState.hovered}),
      Colors.transparent,
    );
  });

  testWidgets('top level surface exposes theme aware status bar style', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const TopLevelPageScaffold(
          title: '浅色状态栏',
          slivers: [SliverToBoxAdapter(child: SizedBox(height: 80))],
        ),
      ),
    );

    final lightStyle = systemOverlayStyleOf(
      tester,
      const Key('top-level-system-overlay-浅色状态栏'),
    );
    expect(lightStyle.statusBarColor, Colors.transparent);
    expect(lightStyle.statusBarIconBrightness, Brightness.dark);
    expect(lightStyle.statusBarBrightness, Brightness.light);

    await tester.pumpWidget(
      themedHarness(
        child: const TopLevelPageScaffold(
          title: '深色状态栏',
          surface: PageSurface(backgroundColor: Color(0xff11161b)),
          slivers: [SliverToBoxAdapter(child: SizedBox(height: 80))],
        ),
      ),
    );

    final darkStyle = systemOverlayStyleOf(
      tester,
      const Key('top-level-system-overlay-深色状态栏'),
    );
    expect(darkStyle.statusBarColor, Colors.transparent);
    expect(darkStyle.statusBarIconBrightness, Brightness.light);
    expect(darkStyle.statusBarBrightness, Brightness.dark);
  });

  testWidgets('default channels expose renderable home content', (
    tester,
  ) async {
    final repository = const HomeContentRepository();
    final cultureItems = repository
        .blocksForChannel('culture')
        .expand((block) => block.items)
        .toList(growable: false);
    final torchFestivalItems = repository
        .blocksForChannel('torch_festival')
        .expand((block) => block.items)
        .toList(growable: false);
    expect(cultureItems.length, greaterThanOrEqualTo(5));
    expect(torchFestivalItems.length, greaterThanOrEqualTo(4));
    expect(
      repository.blocksForChannel('torch_festival').length,
      greaterThanOrEqualTo(3),
    );
    final cultureChannel = ChannelRepository.defaultChannels.firstWhere(
      (channel) => channel.id == 'culture',
    );
    final torchFestivalChannel = ChannelRepository.defaultChannels.firstWhere(
      (channel) => channel.id == 'torch_festival',
    );
    final videoChannel = ChannelRepository.defaultChannels.firstWhere(
      (channel) => channel.id == 'video',
    );
    expect(
      cultureChannel.style.visualProfile,
      MediaChannelVisualProfile.standard,
    );
    expect(
      cultureChannel.style.topBackground.mode,
      MediaChannelTopBackgroundMode.color,
    );
    expect(cultureChannel.style.backgroundColor, const Color(0xff2fbf71));
    expect(cultureChannel.style.accentColor, const Color(0xff0f5132));
    expect(cultureChannel.style.cardSurfaceColor, isNull);
    expect(
      torchFestivalChannel.style.visualProfile,
      MediaChannelVisualProfile.campaignImmersive,
    );
    expect(torchFestivalChannel.style.accentColor, const Color(0xffb71f2d));
    expect(torchFestivalChannel.style.immersiveBackdropHeight, 232);
    expect(torchFestivalChannel.style.immersiveContentTopInset, 10);
    expect(videoChannel.style.accentColor, isNull);
    expect(videoChannel.style.cardSurfaceColor, isNull);

    for (final channel in ChannelRepository.defaultChannels) {
      if (channel.content.type == MediaChannelContentType.h5) {
        expect(channel.content.h5Url, ChannelRepository.topicH5Url);
        continue;
      }
      expect(
        repository.blocksForChannel(channel.id),
        isNotEmpty,
        reason: '${channel.label} should have local MVP content',
      );
    }

    await pumpAdmin9App(tester);

    for (final label in ['视频', '本地', '文旅', '火把节', '直播']) {
      await tester.tap(
        find.descendant(of: find.byType(TabBar), matching: find.text(label)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('channel-content-empty')), findsNothing);
      expect(find.byKey(const Key('channel-content-list')), findsOneWidget);
    }

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('专题')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-channel-h5-topic')), findsOneWidget);
    expect(find.text(ChannelRepository.topicH5Url), findsOneWidget);
    expect(find.byKey(const Key('channel-content-list')), findsNothing);
  });

  testWidgets('home channel visual resolver is driven by style tokens', (
    tester,
  ) async {
    const resolver = HomeChannelVisualResolver();
    const relayStyle = MediaChannelStyle(
      visualProfile: MediaChannelVisualProfile.gradientRelay,
      topSurfaceMode: MediaChannelTopSurfaceMode.customImage,
      backdropAssetName: AppAssets.topLevelMainstreamRedHeader,
      topBackground: MediaChannelTopBackground(
        mode: MediaChannelTopBackgroundMode.color,
        endColor: Color(0xff2fbf71),
        height: 260,
      ),
      backdropBlendMode: MediaChannelBackdropBlendMode.none,
      backgroundColor: Color(0xff2fbf71),
      accentColor: Color(0xff0f5132),
    );

    expect(
      resolver.effectiveTopBackgroundMode(relayStyle),
      MediaChannelTopBackgroundMode.color,
      reason: 'New topBackground config wins over legacy topSurfaceMode.',
    );

    await tester.pumpWidget(
      themedHarness(
        child: Builder(
          builder: (context) {
            final topChrome = resolver.topChromeBackdropFor(
              context,
              relayStyle,
            )!;
            final visualTheme = resolver.visualThemeFor(relayStyle);
            final pageSurface = resolver.surfaceFor(
              context: context,
              style: relayStyle,
              backgroundColor: resolver.backgroundFor(
                context,
                relayStyle,
                Theme.of(context).scaffoldBackgroundColor,
              ),
            );

            return Column(
              children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: PageBackdropView(
                          surface: pageSurface.resolve(context),
                          height: 180,
                          debugKeyPrefix: 'synthetic-relay',
                        ),
                      ),
                      Positioned.fill(
                        child: PageBackdropView(
                          surface: pageSurface.resolve(context),
                          height: 180,
                          debugKeyPrefix: 'synthetic-relay-frame-host',
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  topChrome.solidColor != null
                      ? 'synthetic-solid'
                      : topChrome.gradient
                      ? 'synthetic-gradient'
                      : 'synthetic-image',
                ),
                Text(topChrome.assetName ?? 'no-image'),
                Text(
                  visualTheme.accentColor == const Color(0xff0f5132)
                      ? 'synthetic-accent-green'
                      : 'synthetic-accent-other',
                ),
              ],
            );
          },
        ),
      ),
    );

    expect(find.text('synthetic-solid'), findsOneWidget);
    expect(find.text('no-image'), findsOneWidget);
    expect(find.text('synthetic-accent-green'), findsOneWidget);
    expect(
      find.byKey(const Key('synthetic-relay-page-backdrop-solid')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('synthetic-relay-page-backdrop-gradient')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('synthetic-relay-page-backdrop-image-asset')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('synthetic-relay-page-backdrop-blend-mask')),
      findsNothing,
    );
    final frameBackground = resolver.frameBackgroundFor(
      tester.element(find.text('synthetic-solid')),
      relayStyle,
    );
    expect(frameBackground, isNull);
  });

  testWidgets('channel style background follows selected home channel', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    final defaultBackground = Theme.of(
      tester.element(find.byKey(const Key('admin9-shell-content'))),
    ).scaffoldBackgroundColor;
    Color homeBackground() {
      return tester
          .widget<ColoredBox>(find.byKey(const Key('top-level-background-首页')))
          .color;
    }

    expectColorNear(homeBackground(), defaultBackground);

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('专题')),
    );
    await tester.pumpAndSettle();

    expectColorNear(homeBackground(), defaultBackground);
    expect(
      find.byKey(const Key('home-immersive-channel-backdrop')),
      findsNothing,
    );

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('推荐')),
    );
    await tester.pump();

    await tester.pumpAndSettle();

    expectColorNear(homeBackground(), defaultBackground);
  });

  testWidgets('culture channel renders solid skin without immersive backdrop', (
    tester,
  ) async {
    const scrollEdgeImageKey = Key(
      'top-level-scroll-edge-backdrop-首页-page-backdrop-image-asset',
    );
    const scrollEdgeGradientKey = Key(
      'top-level-scroll-edge-backdrop-首页-page-backdrop-gradient',
    );
    const scrollEdgeSolidKey = Key(
      'top-level-scroll-edge-backdrop-首页-page-backdrop-solid',
    );
    const scrollEdgeMaskKey = Key(
      'top-level-scroll-edge-backdrop-首页-page-backdrop-blend-mask',
    );

    await pumpAdmin9App(tester);

    final defaultBackground = Theme.of(
      tester.element(find.byKey(const Key('admin9-shell-content'))),
    ).scaffoldBackgroundColor;
    Color homeBackground() {
      return tester
          .widget<ColoredBox>(find.byKey(const Key('top-level-background-首页')))
          .color;
    }

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('专题')),
    );
    await tester.pumpAndSettle();

    expectColorNear(homeBackground(), defaultBackground);
    expect(find.byKey(scrollEdgeImageKey), findsOneWidget);
    expect(find.byKey(scrollEdgeGradientKey), findsNothing);

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('文旅')),
    );
    await tester.pumpAndSettle();

    expect(homeBackground(), const Color(0xff2fbf71));
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.labelColor, const Color(0xff0f5132));
    expect(tabBar.indicatorColor, const Color(0xff0f5132));
    expect(tabBar.indicator, isNull);
    final cultureManageIconTheme = IconTheme.of(
      tester.element(find.byKey(const Key('channel-manage-button'))),
    );
    expect(cultureManageIconTheme.color, const Color(0xff0f5132));
    expect(find.byKey(scrollEdgeImageKey), findsNothing);
    expect(find.byKey(scrollEdgeGradientKey), findsNothing);
    expect(find.byKey(scrollEdgeSolidKey), findsOneWidget);
    expect(find.byKey(scrollEdgeMaskKey), findsNothing);
    expect(find.byKey(const Key('page-frame-gradient-relay')), findsNothing);
    expect(
      find.byKey(const Key('channel-content-gradient-relay')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('home-immersive-channel-backdrop')),
      findsNothing,
    );
    final cultureFeedCard = tester.widget<AppCard>(
      find.descendant(
        of: find.byKey(const Key('content-item-rural-gallery-culture')),
        matching: find.byType(AppCard),
      ),
    );
    expect(cultureFeedCard.backgroundColor, isNull);
    expect(
      tester
          .widgetList<ContentTagPill>(find.byType(ContentTagPill))
          .where((pill) => pill.tag == ArticleContentTag.cultureTourism)
          .map((pill) => pill.accentColor)
          .toSet(),
      contains(const Color(0xff0f5132)),
    );
    await scrollTo(
      tester,
      find.byKey(const Key('content-item-culture-mountain-stay')),
    );
    expect(find.text('高山民宿预约升温，避暑线路进入旺季'), findsOneWidget);
  });

  testWidgets('top backdrop stays global during horizontal topic switch', (
    tester,
  ) async {
    const scrollEdgeImageKey = Key(
      'top-level-scroll-edge-backdrop-首页-page-backdrop-image-asset',
    );
    const scrollEdgeGradientKey = Key(
      'top-level-scroll-edge-backdrop-首页-page-backdrop-gradient',
    );
    const scrollEdgeSolidKey = Key(
      'top-level-scroll-edge-backdrop-首页-page-backdrop-solid',
    );

    await pumpAdmin9App(
      tester,
      initialPreferences: const {
        'home_channel_ids': ['recommend', 'culture', 'topic', 'live'],
      },
    );
    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('文旅')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(scrollEdgeImageKey), findsNothing);
    expect(find.byKey(scrollEdgeGradientKey), findsNothing);
    expect(find.byKey(scrollEdgeSolidKey), findsOneWidget);

    Rect tabViewRect() =>
        tester.getRect(find.byKey(const Key('home-channel-tab-view')));
    Color homeBackground() {
      return tester
          .widget<ColoredBox>(find.byKey(const Key('top-level-background-首页')))
          .color;
    }

    final defaultBackground = Theme.of(
      tester.element(find.byKey(const Key('admin9-shell-content'))),
    ).scaffoldBackgroundColor;

    await tester.dragFrom(
      Offset(tabViewRect().center.dx, tabViewRect().bottom - AppSpacing.xl),
      const Offset(-420, 0),
    );
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key == scrollEdgeImageKey ||
            widget.key == scrollEdgeGradientKey ||
            widget.key == scrollEdgeSolidKey,
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('top-level-tabs-backdrop-首页-page-backdrop-image-asset'),
      ),
      findsNothing,
    );
    expect(homeBackground(), isNot(equals(const Color(0xff0c459b))));

    await tester.pumpAndSettle();

    expectColorNear(homeBackground(), defaultBackground);
    expect(find.byKey(scrollEdgeImageKey), findsOneWidget);
    expect(find.byKey(scrollEdgeGradientKey), findsNothing);
    expect(find.byKey(const Key('home-channel-h5-topic')), findsOneWidget);
  });

  testWidgets('fire festival renders campaign immersive native content', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    Color homeBackground() {
      return tester
          .widget<ColoredBox>(find.byKey(const Key('top-level-background-首页')))
          .color;
    }

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('火把节')),
    );
    await tester.pumpAndSettle();

    expect(homeBackground(), const Color(0xffb71f2d));
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.labelColor, const Color(0xffb71f2d));
    expect(tabBar.indicatorColor, const Color(0xffb71f2d));
    final torchManageIconTheme = IconTheme.of(
      tester.element(find.byKey(const Key('channel-manage-button'))),
    );
    expect(torchManageIconTheme.color, const Color(0xffb71f2d));
    expect(
      find.byKey(const Key('home-channel-content-torch_festival')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('channel-content-list')), findsOneWidget);
    expect(
      find.byKey(const Key('home-immersive-channel-backdrop')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('home-immersive-channel-backdrop-page-backdrop-image-asset'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('top-level-scroll-edge-backdrop-首页-page-backdrop-blend-mask'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('home-immersive-channel-backdrop-page-backdrop-blend-mask'),
      ),
      findsOneWidget,
    );
    final topMaskGradient = linearGradientOf(
      tester,
      const Key('top-level-scroll-edge-backdrop-首页-page-backdrop-blend-mask'),
    );
    expect(topMaskGradient.colors, [
      const Color(0xffb71f2d).withValues(alpha: 0),
      const Color(0xffb71f2d),
    ]);
    expect(
      find.byKey(const Key('channel-content-gradient-relay')),
      findsNothing,
    );
    expect(find.byKey(const Key('home-channel-h5-topic')), findsNothing);
    expect(find.byKey(const Key('special-entry-carousel')), findsOneWidget);
    final torchMediaBadge = tester
        .widgetList<MediaBadge>(
          find.descendant(
            of: find.byKey(const Key('media-showcase-block')),
            matching: find.byType(MediaBadge),
          ),
        )
        .firstWhere((badge) => badge.label == '直播中');
    expect(torchMediaBadge.color, const Color(0xffb71f2d));
    await scrollTo(
      tester,
      find.byKey(const Key('content-item-torch-volunteer-story')),
    );
    expect(find.text('志愿者上岗：多语导览和便民服务点准备就绪'), findsOneWidget);
    expect(
      tester
          .widgetList<ContentTagPill>(find.byType(ContentTagPill))
          .where((pill) => pill.tag == ArticleContentTag.cultureTourism)
          .map((pill) => pill.accentColor)
          .toSet(),
      contains(const Color(0xffb71f2d)),
    );
  });

  testWidgets(
    'fire festival toolbar background fades from transparent to solid',
    (tester) async {
      await pumpAdmin9App(tester);

      await tester.tap(
        find.descendant(of: find.byType(TabBar), matching: find.text('火把节')),
      );
      await tester.pumpAndSettle();

      const backgroundKey = Key('top-level-toolbar-background-首页');
      expect(find.byKey(backgroundKey), findsNothing);

      await tester.drag(
        find.byKey(const Key('channel-content-list')),
        const Offset(0, -260),
      );
      await tester.pumpAndSettle();

      final background = tester.widget<ColoredBox>(find.byKey(backgroundKey));
      expectColorNear(background.color, const Color(0xffb71f2d));
    },
  );

  testWidgets('channel style background follows horizontal page switch', (
    tester,
  ) async {
    await pumpAdmin9App(
      tester,
      initialPreferences: const {
        'home_channel_ids': ['recommend', 'topic'],
      },
    );

    final defaultBackground = Theme.of(
      tester.element(find.byKey(const Key('admin9-shell-content'))),
    ).scaffoldBackgroundColor;
    Color homeBackground() {
      return tester
          .widget<ColoredBox>(find.byKey(const Key('top-level-background-首页')))
          .color;
    }

    expectColorNear(homeBackground(), defaultBackground);

    final tabViewRect = tester.getRect(
      find.byKey(const Key('home-channel-tab-view')),
    );
    await tester.dragFrom(
      Offset(tabViewRect.center.dx, tabViewRect.bottom - AppSpacing.xl),
      const Offset(-420, 0),
    );
    await tester.pumpAndSettle();

    expectColorNear(homeBackground(), defaultBackground);
    expect(
      find.byKey(const Key('home-immersive-channel-backdrop')),
      findsNothing,
    );
    expect(find.byKey(const Key('home-channel-h5-topic')), findsOneWidget);
    expect(find.text(ChannelRepository.topicH5Url), findsOneWidget);
    expect(find.byKey(const Key('channel-content-list')), findsNothing);
  });

  testWidgets('plain channel transitions keep default home background', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    final defaultBackground = Theme.of(
      tester.element(find.byKey(const Key('admin9-shell-content'))),
    ).scaffoldBackgroundColor;
    Color homeBackground() {
      return tester
          .widget<ColoredBox>(find.byKey(const Key('top-level-background-首页')))
          .color;
    }

    Future<void> expectDefaultTransition(String channelLabel) async {
      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text(channelLabel),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expectColorNear(homeBackground(), defaultBackground);
    }

    expectColorNear(homeBackground(), defaultBackground);

    await expectDefaultTransition('视频');
    await expectDefaultTransition('本地');
    await expectDefaultTransition('本地');
    await expectDefaultTransition('视频');
  });

  testWidgets('channel content renders block based home layout', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    expect(find.byKey(const Key('carousel-block')), findsOneWidget);
    expect(find.text('城市更新进行时：看见身边的民生变化'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    expect(find.byKey(const Key('special-entry-block')), findsOneWidget);
    expect(find.text('政声'), findsWidgets);
    expect(find.text('公告'), findsNothing);

    await scrollTo(tester, find.text('便民服务'));
    expect(find.text('便民服务'), findsOneWidget);
    expect(find.byType(AppSectionHeader), findsWidgets);
    final typography = Theme.of(
      tester.element(find.text('便民服务')),
    ).extension<AppTypography>()!;
    expect(textStyleOf(tester, '便民服务'), typography.cardSectionTitle);
    expect(textStyleOf(tester, '便民服务'), isNot(typography.sectionTitle));

    expect(find.byKey(const Key('tile-grid-fixed-template')), findsOneWidget);
    expect(find.text('天气'), findsOneWidget);

    await scrollTo(tester, find.byKey(const Key('media-showcase-block')));
    expect(find.byKey(const Key('media-showcase-block')), findsOneWidget);
    expect(find.text('新闻早班车直播：直击城市更新重点项目'), findsWidgets);
  });

  testWidgets('home shortcut and tile grids choose adaptive columns', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpAdmin9App(tester);

    await scrollTo(tester, find.byType(IconNavigationBlock));
    final shortcutCard = tester.widget<AppCard>(
      find.descendant(
        of: find.byType(IconNavigationBlock),
        matching: find.byType(AppCard),
      ),
    );
    expect(shortcutCard.padding, const EdgeInsets.fromLTRB(14, 12, 14, 14));
    expect(shortcutCard.radius, AppRadius.input);
    expect(shortcutCard.showBorder, isFalse);
    final shortcutGridDelegate =
        tester
                .widget<GridView>(
                  find.byKey(const Key('quick-action-grid-icon-navigation')),
                )
                .gridDelegate
            as SliverGridDelegateWithFixedCrossAxisCount;
    expect(shortcutGridDelegate.crossAxisCount, 4);

    await scrollTo(tester, find.byKey(const Key('tile-grid-fixed-template')));
    final tileGridDelegate =
        tester
                .widget<GridView>(
                  find.byKey(const Key('tile-grid-fixed-template')),
                )
                .gridDelegate
            as SliverGridDelegateWithFixedCrossAxisCount;
    expect(tileGridDelegate.crossAxisCount, 3);
  });

  testWidgets('carousel swipes and updates number indicator', (tester) async {
    await pumpAdmin9App(tester);

    expect(find.byKey(const Key('carousel-block')), findsOneWidget);
    expect(find.byKey(const Key('network-image-城市更新')), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    await tester.fling(
      find.byKey(const Key('carousel-page-view')),
      const Offset(-420, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('一线调研行：乡村产业迎来新活力'), findsOneWidget);
  });

  testWidgets('article visual uses network image and fallback placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ArticleVisual(
                    label: '真实图',
                    type: ArticleVisualType.city,
                    height: 100,
                    imageUrl: 'https://example.com/news.jpg',
                  ),
                  SizedBox(height: 12),
                  ArticleVisual(
                    label: '无图',
                    type: ArticleVisualType.rural,
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('network-image-真实图')), findsOneWidget);
    expect(find.byKey(const Key('visual-fallback-无图')), findsOneWidget);
  });

  testWidgets(
    'article feed supports text image large image three images and video badges',
    (tester) async {
      await pumpAdmin9App(tester);

      await scrollTo(tester, find.byKey(const Key('content-feed-block')));
      expect(find.byKey(const Key('content-feed-block')), findsOneWidget);

      await scrollTo(
        tester,
        find.byKey(const Key('content-item-service-industry')),
      );
      expect(
        find.byKey(const Key('content-item-service-industry')),
        findsOneWidget,
      );
      expect(find.text('06:55'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);

      await scrollTo(tester, find.byKey(const Key('content-item-daily-video')));
      expect(find.text('24:00'), findsOneWidget);

      await scrollTo(
        tester,
        find.byKey(const Key('content-item-rural-gallery-multi-images')),
      );
      expect(find.byKey(const Key('network-image-小院')), findsOneWidget);
      expect(find.byKey(const Key('network-image-田野')), findsOneWidget);
      expect(find.byKey(const Key('network-image-产业')), findsOneWidget);
    },
  );

  testWidgets(
    'politics channel renders configurable media feature content items',
    (tester) async {
      await pumpAdmin9App(tester);

      await tester.tap(
        find.descendant(of: find.byType(TabBar), matching: find.text('政声')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const Key('content-mediaFeature-politics-media-feature-main'),
        ),
        findsOneWidget,
      );
      expect(find.text('王晓晖'), findsOneWidget);
      expect(find.text('四川省委书记'), findsOneWidget);
      expect(find.byKey(const Key('network-image-王晓晖')), findsOneWidget);
      expect(
        find.byKey(const Key('quick-action-grid-media-feature')),
        findsOneWidget,
      );
      expect(find.text('工作指示'), findsOneWidget);
      expect(find.text('重要活动'), findsOneWidget);
      expect(find.text('署名文章'), findsOneWidget);
      expect(find.text('会见座谈'), findsOneWidget);
      expect(find.text('重要会议'), findsOneWidget);
      expect(find.text('调研考察'), findsOneWidget);
      expect(find.textContaining('王晓晖在全省服务业大会上强调'), findsOneWidget);
      expect(
        find.byKey(const Key('content-mediaFeature-more')),
        findsOneWidget,
      );
    },
  );

  testWidgets('media feature content item hides empty optional sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(
          body: const Padding(
            padding: EdgeInsets.all(16),
            child: ContentFeedItemRenderer(
              item: ContentItem(
                id: 'mediaFeature-empty',
                title: '测试人物',
                contentKind: ContentKind.special,
                layout: ContentItemLayout.mediaFeature,
                article: Article(
                  id: 'mediaFeature-empty-article',
                  title: '测试人物',
                  source: '测试来源',
                  time: '刚刚',
                  summary: '测试摘要',
                  visuals: [
                    ArticleVisualAsset(
                      label: '主图',
                      type: ArticleVisualType.city,
                    ),
                  ],
                  paragraphs: ['测试正文'],
                ),
                mediaFeature: MediaFeatureContent(
                  title: '测试人物',
                  subtitle: '测试职务',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('测试人物'), findsOneWidget);
    expect(find.text('测试职务'), findsOneWidget);
    expect(
      find.byKey(const Key('quick-action-grid-media-feature')),
      findsNothing,
    );
    expect(find.byKey(const Key('content-mediaFeature-more')), findsNothing);
    expect(find.byKey(const Key('mediaFeature-article-test')), findsNothing);
  });

  testWidgets('media feature content item ignores missing payload safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(
          body: ContentFeedItemRenderer(
            item: ContentItem(
              id: 'invalid-mediaFeature',
              title: '缺少mediaFeature 数据',
              contentKind: ContentKind.special,
              layout: ContentItemLayout.mediaFeature,
              article: articleFixture(
                id: 'invalid-mediaFeature',
                title: '缺少mediaFeature 数据',
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const Key('content-mediaFeature-missing-invalid-mediaFeature'),
      ),
      findsOneWidget,
    );
    expect(find.text('缺少mediaFeature 数据'), findsNothing);
  });

  testWidgets('separated content feed keeps divider and article navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      await interactiveHarness(
        child: Scaffold(
          body: ContentFeedBlock(
            items: [
              contentItemFixture(
                id: 'separated-feed',
                title: '分隔线信息流标题',
                layout: ContentItemLayout.text,
                surface: SurfaceStyle.separated,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('分隔线信息流标题'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);

    await tester.tap(find.byKey(const Key('content-item-separated-feed')));
    await tester.pumpAndSettle();

    expect(find.byType(ArticleDetailPage), findsOneWidget);
    expect(find.text('分隔线信息流标题'), findsWidgets);
  });

  testWidgets('content feed hides unrenderable media feature items', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(
          body: ContentFeedBlock(
            headerTitle: '可渲染过滤',
            items: [
              ContentItem(
                id: 'invalid-mediaFeature',
                title: '缺少mediaFeature 数据',
                contentKind: ContentKind.special,
                layout: ContentItemLayout.mediaFeature,
                article: articleFixture(
                  id: 'invalid-mediaFeature',
                  title: '缺少mediaFeature 数据',
                ),
              ),
              contentItemFixture(
                id: 'valid-feed',
                title: '有效信息流标题',
                layout: ContentItemLayout.sideImage,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('content-feed-block')), findsOneWidget);
    expect(
      find.byKey(
        const Key('content-mediaFeature-missing-invalid-mediaFeature'),
      ),
      findsNothing,
    );
    expect(find.text('缺少mediaFeature 数据'), findsNothing);
    expect(find.text('有效信息流标题'), findsOneWidget);
  });

  testWidgets('channel content tab hides blocks with only unrenderable items', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHarness(
        child: Scaffold(
          body: ChannelContentTab(
            blocks: [
              PageBlock(
                id: 'invalid-feed',
                type: PageBlockType.contentFeed,
                adminName: '无效信息流',
                sort: 1,
                displayTitle: '不应展示区块',
                showHeader: true,
                items: [
                  ContentItem(
                    id: 'invalid-mediaFeature',
                    title: '缺少mediaFeature 数据',
                    contentKind: ContentKind.special,
                    layout: ContentItemLayout.mediaFeature,
                    article: articleFixture(
                      id: 'invalid-mediaFeature',
                      title: '缺少mediaFeature 数据',
                    ),
                  ),
                ],
              ),
              PageBlock(
                id: 'valid-feed',
                type: PageBlockType.contentFeed,
                adminName: '有效信息流',
                sort: 2,
                items: [
                  contentItemFixture(
                    id: 'valid-feed',
                    title: '有效区块标题',
                    layout: ContentItemLayout.sideImage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('不应展示区块'), findsNothing);
    expect(find.text('缺少mediaFeature 数据'), findsNothing);
    expect(find.text('有效区块标题'), findsOneWidget);
  });

  testWidgets('opens channel management and adds channel', (tester) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.byKey(const Key('channel-manage-button')));
    await tester.pumpAndSettle();

    expect(find.text('频道管理'), findsOneWidget);
    expect(find.text('我的频道'), findsOneWidget);
    expect(find.text('选择频道'), findsOneWidget);
    expect(find.text('恢复默认'), findsOneWidget);
    expect(find.byType(AppSectionHeader), findsWidgets);

    await tester.tap(find.byKey(const Key('add-channel-discover')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('my-channel-discover')), findsOneWidget);
    expect(find.byKey(const Key('add-channel-discover')), findsNothing);

    await tester.tap(find.byKey(const Key('close-channel-management')));
    await tester.pumpAndSettle();

    expect(find.text('发现'), findsWidgets);
  });

  testWidgets(
    'edit mode removes non-fixed channel but keeps fixed recommend channel',
    (tester) async {
      await pumpAdmin9App(tester);

      await tester.tap(find.byKey(const Key('channel-manage-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('app-section-header-action-编辑')));
      await tester.pumpAndSettle();

      expect(find.text('长按排序'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byKey(const Key('remove-channel-recommend')), findsNothing);
      expect(find.byKey(const Key('remove-channel-politics')), findsOneWidget);

      await tester.tap(find.byKey(const Key('remove-channel-politics')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('my-channel-politics')), findsNothing);
      expect(find.byKey(const Key('my-channel-recommend')), findsOneWidget);
    },
  );

  testWidgets('reset channels shows confirmation and restores default', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.byKey(const Key('channel-manage-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('app-section-header-action-编辑')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('remove-channel-politics')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('my-channel-politics')), findsNothing);

    await tester.tap(find.byKey(const Key('reset-channels-button')));
    await tester.pumpAndSettle();
    expect(find.text('恢复默认频道和排序？'), findsOneWidget);
    expect(find.text('将恢复系统默认频道列表，“推荐”会保持在首位。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-reset-channels')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('my-channel-politics')), findsOneWidget);
    expect(find.byKey(const Key('app-section-header-action-完成')), findsNothing);
    expect(
      find.byKey(const Key('app-section-header-action-编辑')),
      findsOneWidget,
    );
  });

  testWidgets('channel management highlights the current selected channel', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('专题')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('channel-manage-button')));
    await tester.pumpAndSettle();

    final tokens = Theme.of(
      tester.element(find.text('频道管理')),
    ).extension<AppThemeTokens>()!;
    final selectedChipMaterial = tester.widget<Material>(
      find
          .ancestor(
            of: find.byKey(const Key('my-channel-topic')),
            matching: find.byType(Material),
          )
          .first,
    );
    final recommendChipMaterial = tester.widget<Material>(
      find
          .ancestor(
            of: find.byKey(const Key('my-channel-recommend')),
            matching: find.byType(Material),
          )
          .first,
    );

    expect(selectedChipMaterial.color, tokens.brand.primary);
    expect(recommendChipMaterial.color, tokens.softFill);
  });

  testWidgets(
    'channel management uses adaptive chips and hides empty more section',
    (tester) async {
      await pumpAdmin9App(
        tester,
        initialPreferences: {
          'home_channel_ids': [
            for (final channel in ChannelRepository.allChannels) channel.id,
          ],
        },
      );

      await tester.tap(find.byKey(const Key('channel-manage-button')));
      await tester.pumpAndSettle();

      final recommendSize = tester.getSize(
        find.byKey(const Key('my-channel-recommend')),
      );
      final cityCircleSize = tester.getSize(
        find.byKey(const Key('my-channel-city_circle')),
      );

      expect(
        recommendSize.height,
        greaterThanOrEqualTo(AppSpacing.minTouchTarget),
      );
      expect(cityCircleSize.width, greaterThan(recommendSize.width));
      expect(cityCircleSize.width - recommendSize.width, greaterThan(8));
      expect(find.text('选择频道'), findsNothing);
      expect(find.byKey(const Key('all-channels-added-empty')), findsNothing);
    },
  );

  testWidgets('channel view model keeps recommend first when moving channels', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'home_channel_ids': ['recommend', 'politics', 'video', 'local'],
    });
    final preferences = await SharedPreferences.getInstance();
    final viewModel = ChannelViewModel(
      repository: ChannelRepository(storage: LocalStorageService(preferences)),
    );

    await viewModel.loadChannels();
    expect(viewModel.myChannels.map((channel) => channel.id), [
      'recommend',
      'politics',
      'video',
      'local',
      'torch_festival',
    ]);

    await viewModel.moveChannel(draggedId: 'local', targetId: 'politics');

    expect(viewModel.myChannels.map((channel) => channel.id), [
      'recommend',
      'local',
      'politics',
      'video',
      'torch_festival',
    ]);
    expect(preferences.getStringList('home_channel_ids'), [
      'recommend',
      'local',
      'politics',
      'video',
      'torch_festival',
    ]);

    await viewModel.moveChannel(draggedId: 'recommend', targetId: 'video');
    await viewModel.moveChannel(draggedId: 'video', targetId: 'recommend');

    expect(viewModel.myChannels.first.id, 'recommend');
    expect(preferences.getStringList('home_channel_ids')?.first, 'recommend');
  });

  testWidgets('removed migrated default channel stays removed after reload', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'home_channel_ids': ['recommend', 'politics', 'video', 'local'],
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = ChannelRepository(
      storage: LocalStorageService(preferences),
    );
    final viewModel = ChannelViewModel(repository: repository);

    await viewModel.loadChannels();
    final torchFestival = viewModel.myChannels.firstWhere(
      (channel) => channel.id == 'torch_festival',
    );
    await viewModel.removeChannel(torchFestival);

    expect(viewModel.myChannels.map((channel) => channel.id), [
      'recommend',
      'politics',
      'video',
      'local',
    ]);
    expect(preferences.getStringList('home_channel_ids'), [
      'recommend',
      'politics',
      'video',
      'local',
    ]);

    final reloadedViewModel = ChannelViewModel(repository: repository);
    await reloadedViewModel.loadChannels();

    expect(reloadedViewModel.myChannels.map((channel) => channel.id), [
      'recommend',
      'politics',
      'video',
      'local',
    ]);
    expect(
      reloadedViewModel.moreChannels.map((channel) => channel.id),
      contains('torch_festival'),
    );
  });

  testWidgets('opens article detail page from channel content feed', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tapVisible(
      tester,
      find.byKey(const Key('content-item-laos-meeting')),
    );

    expect(find.text('文章详情'), findsOneWidget);
    final articleParagraph = find.textContaining('双方围绕高质量共建命运共同体');
    expect(articleParagraph, findsWidgets);
    final typography = Theme.of(
      tester.element(articleParagraph.first),
    ).extension<AppTypography>()!;
    final paragraph = tester.widget<Text>(articleParagraph.first);
    expect(paragraph.style?.fontSize, typography.bodyText.fontSize);
    expect(paragraph.style?.fontWeight, typography.bodyText.fontWeight);
    expect(paragraph.style?.height, typography.bodyText.height);
    expect(paragraph.style?.color, typography.bodyText.color);
    expect(find.byKey(const Key('network-image-时政要闻')), findsOneWidget);
    expect(find.text('四川新闻联播 · 刚刚'), findsOneWidget);
  });

  testWidgets('search entry supports results and empty state', (tester) async {
    await pumpAdmin9App(tester);

    final searchSemantics = tester.widget<Semantics>(
      find
          .descendant(
            of: find.byKey(const Key('home-search-entry')),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(searchSemantics.properties.label, '搜索新闻、服务');
    expect(searchSemantics.properties.button, true);
    expect(searchSemantics.properties.onTap, isNotNull);

    await tester.tap(find.byType(AppSearchEntry));
    await tester.pumpAndSettle();
    expect(find.byType(SearchPage), findsOneWidget);
    expect(find.text('热门搜索'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('search-input')), '城市更新');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('search-result-city-update-local')),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('search-result-city-update-local')).first,
        matching: find.byType(AppInfoListItem),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('清空'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-input')), '凉山12345');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('search-result-liangshan-12345')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('清空'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-input')), '铁路12306');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('search-result-railway-12306')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('清空'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-input')), '医保凭证');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('search-result-medical-insurance-certificate')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('清空'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-input')), '不存在的内容');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search-empty-state')), findsOneWidget);
  });

  testWidgets('favorite history and comment records appear in mine', (
    tester,
  ) async {
    await pumpAdmin9App(tester);
    await _login(tester);

    await tester.tap(find.text('首页').last);
    await tester.pumpAndSettle();
    await tapVisible(
      tester,
      find.byKey(const Key('content-item-laos-meeting')),
    );
    await tester.tap(find.byTooltip('收藏'));
    await tester.pumpAndSettle();
    await dragUntilVisible(
      tester,
      find.byKey(const Key('comment-input')),
      scrollable: find.byType(Scrollable).last,
    );
    await tester.enterText(find.byKey(const Key('comment-input')), '这条新闻很有用');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tapTextTile(tester, '我的收藏');
    expect(find.byKey(const Key('favorite-laos-meeting')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('favorite-laos-meeting')),
        matching: find.byType(AppInfoListItem),
      ),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapTextTile(tester, '浏览历史');
    expect(find.byKey(const Key('history-laos-meeting')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapTextTile(tester, '我的评论');
    expect(find.text('这条新闻很有用'), findsOneWidget);
  });

  testWidgets('logged out interaction shows login guide', (tester) async {
    await pumpAdmin9App(tester);

    await tapVisible(
      tester,
      find.byKey(const Key('content-item-laos-meeting')),
    );
    await tester.tap(find.byTooltip('收藏'));
    await tester.pump();

    expect(find.text('请先登录'), findsOneWidget);
  });

  testWidgets('report submission appears in my reports', (tester) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('爆料').last);
    await tester.pumpAndSettle();
    await tapTextTile(tester, '我要爆料');
    await tester.enterText(
      find.byKey(const Key('report-title-field')),
      '路口信号灯异常',
    );
    await tester.enterText(
      find.byKey(const Key('report-location-field')),
      '青羊区',
    );
    await tester.enterText(
      find.byKey(const Key('report-content-field')),
      '晚高峰信号灯不亮',
    );
    await revealInVerticalScroll(
      tester,
      find.byKey(const Key('report-phone-field')),
    );
    await tester.enterText(
      find.byKey(const Key('report-phone-field')),
      '13800138000',
    );
    await revealInVerticalScroll(
      tester,
      find.byKey(const Key('submit-report')),
    );
    await tester.tap(find.byKey(const Key('submit-report')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tapTextTile(tester, '我的爆料');
    expect(find.text('路口信号灯异常'), findsOneWidget);
  });

  testWidgets('report submission keeps attachment summary in detail', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('爆料').last);
    await tester.pumpAndSettle();
    await tapTextTile(tester, '我要爆料');
    await tester.enterText(
      find.byKey(const Key('report-title-field')),
      '施工噪音扰民',
    );
    await tester.enterText(
      find.byKey(const Key('report-location-field')),
      '航天路',
    );
    await tester.enterText(
      find.byKey(const Key('report-content-field')),
      '夜间施工声音较大',
    );
    await tapInVerticalScroll(
      tester,
      find.byKey(const Key('add-report-image')),
    );
    await tapInVerticalScroll(
      tester,
      find.byKey(const Key('add-report-image')),
    );
    await tapInVerticalScroll(
      tester,
      find.byKey(const Key('add-report-video')),
    );
    expect(find.text('照片 2/9，视频 1/1'), findsOneWidget);
    await revealInVerticalScroll(
      tester,
      find.byKey(const Key('report-phone-field')),
    );
    await tester.enterText(
      find.byKey(const Key('report-phone-field')),
      '13800138000',
    );
    await revealInVerticalScroll(
      tester,
      find.byKey(const Key('submit-report')),
    );
    await tester.tap(find.byKey(const Key('submit-report')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tapTextTile(tester, '我的爆料');
    await tapTextTile(tester, '施工噪音扰民');
    expect(find.byKey(const Key('report-attachment-summary')), findsOneWidget);
    expect(find.text('已提交 2 张照片、1 个视频'), findsOneWidget);
  });

  testWidgets('live reservation appears in my reservations', (tester) async {
    await pumpAdmin9App(tester);
    await _login(tester);

    await tester.tap(find.text('首页').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-search-entry')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-input')), '全省服务业大会');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('search-result-city-service')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('reserve-live-button')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.byType(SearchPage))).push(
      MaterialPageRoute(
        builder: (_) =>
            const ActivityListPage(kind: ActivityListKind.reservations),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reservation-city-service')), findsOneWidget);
  });

  testWidgets('mini program service shortcut records recent placeholder use', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('服务').last);
    await tester.pumpAndSettle();
    final miniProgramEntry = find
        .byKey(const Key('service-entry-liangshan-12345'))
        .first;
    await tester.ensureVisible(miniProgramEntry);
    await tester.pumpAndSettle();
    await tester.tap(miniProgramEntry);
    await tester.pump();
    expect(find.text('微信小程序跳转待接入'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    expect(find.text('服务办理进度'), findsNothing);
    expect(find.text('待办理'), findsNothing);
    expect(find.text('我的办理'), findsNothing);

    await tester.tap(find.text('服务').last);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('service-section-recent')),
        matching: find.text('凉山12345'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('push setting persists through shared preferences', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mine-top-settings-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-push-switch')));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('settings_push_enabled'), isTrue);
  });

  testWidgets('mine major entries open clickable pages', (tester) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();

    final entries = {
      '我的收藏': '我的收藏',
      '浏览历史': '浏览历史',
      '我的评论': '我的评论',
      '我的关注': '我的关注',
      '我的预约': '我的预约',
      '我的爆料': '我的爆料',
      '反馈记录': '反馈记录',
      '账号安全': '账号与安全',
      '设置': '设置',
      '关于': '关于西昌发布',
    };
    for (final entry in entries.entries) {
      await tapTextTile(tester, entry.key);
      expect(find.text(entry.value), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('mine page groups status and service shortcuts', (tester) async {
    tester.view.padding = const FakeViewPadding(top: 59);
    addTearDown(tester.view.resetPadding);

    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();

    expect(find.text('立即登录'), findsOneWidget);
    expect(find.text('未登录'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
    expect(find.byKey(const Key('mine-profile-stats')), findsOneWidget);
    expect(find.byKey(const Key('mine-profile-stat-points')), findsOneWidget);
    expect(
      find.byKey(const Key('mine-profile-stat-favorites')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('mine-profile-stat-services')), findsNothing);
    expect(find.byKey(const Key('mine-profile-stat-orders')), findsOneWidget);
    expect(find.byKey(const Key('mine-points-card')), findsNothing);
    expect(find.text('查看积分商城权益核销进度'), findsNothing);
    expect(find.byKey(const Key('mine-status-summary')), findsNothing);
    expect(find.text('待办摘要'), findsNothing);
    expect(find.text('待办理'), findsNothing);
    await tester.tap(find.byKey(const Key('mine-profile-stat-points')));
    await tester.pumpAndSettle();
    expect(find.text('登录后查看积分'), findsOneWidget);
    expect(find.byType(AuthPage), findsOneWidget);
    await safePageBack(tester);

    await tester.tap(find.byKey(const Key('mine-top-message-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('message-center-content')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await dragUntilVisible(tester, find.text('常用记录'));
    expect(find.text('常用记录'), findsOneWidget);
    expect(find.text('我的关注'), findsOneWidget);
    expect(find.text('我的收藏'), findsOneWidget);
    expect(find.text('浏览历史'), findsOneWidget);
    expect(find.text('我的评论'), findsOneWidget);
    expect(
      _verticalGapBetween(
        tester,
        lowerEdge: find.text('收藏、历史和互动内容'),
        upperEdge: find.byIcon(Icons.favorite_border).last,
      ),
      lessThanOrEqualTo(24),
    );
    await dragUntilVisible(tester, find.text('服务互动'));
    expect(find.text('服务互动'), findsOneWidget);
    expect(find.text('我的预约'), findsOneWidget);
    expect(find.text('我的爆料'), findsOneWidget);
    expect(find.text('我的办理'), findsNothing);
    expect(find.text('反馈记录'), findsOneWidget);
    expect(
      _verticalGapBetween(
        tester,
        lowerEdge: find.text('预约、办理、爆料和反馈'),
        upperEdge: find.byIcon(Icons.access_time).last,
      ),
      lessThanOrEqualTo(24),
    );
    await dragUntilVisible(tester, find.text('设置支持'));
    expect(find.text('设置支持'), findsOneWidget);
    expect(find.text('账号安全'), findsOneWidget);
    expect(find.text('关于'), findsOneWidget);
    expect(
      _verticalGapBetween(
        tester,
        lowerEdge: find.text('账号、安全与应用信息'),
        upperEdge: find.byIcon(Icons.verified_user_outlined).last,
      ),
      lessThanOrEqualTo(24),
    );
    expect(find.text('系统消息'), findsNothing);
    expect(find.text('互动消息'), findsNothing);
    expect(find.text('隐私设置'), findsNothing);

    await _login(tester);
    expect(find.text('138****8000'), findsOneWidget);
    expect(find.text('黑铁'), findsOneWidget);
    expect(find.text('账号资料'), findsOneWidget);
    await tester.tap(find.text('账号资料'));
    await tester.pump();
    expect(find.text('账号资料暂不可用'), findsOneWidget);
  });

  testWidgets('mine layout tolerates compact dark large-font mode', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpAdmin9App(
      tester,
      initialPreferences: {
        'appearance_theme_mode': AppThemeMode.dark.name,
        'appearance_font_level': AppFontLevel.large.name,
      },
    );

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();

    expect(find.text('立即登录'), findsOneWidget);
    expect(find.text('未登录'), findsOneWidget);
    expect(find.text('待办摘要'), findsNothing);
    expect(find.text('待办理'), findsNothing);
    expect(find.text('我的办理'), findsNothing);
    await dragUntilVisible(tester, find.text('设置支持'));
    expect(find.text('常用记录'), findsOneWidget);
    expect(find.text('服务互动'), findsOneWidget);
    expect(find.text('设置支持'), findsOneWidget);

    final exception = tester.takeException();
    expect(exception, isNull);
  });

  testWidgets('top mine actions remain reachable after scroll', (tester) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('top-level-scroll-我的')),
      const Offset(0, -520),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mine-top-message-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('message-center-content')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mine-top-settings-action')));
    await tester.pumpAndSettle();
    expect(find.text('清理缓存'), findsOneWidget);
  });

  testWidgets('logged-in mine header shows account profile affordance', (
    tester,
  ) async {
    await pumpAdmin9App(tester);
    await _login(tester);

    expect(find.text('138****8000'), findsOneWidget);
    expect(find.text('黑铁'), findsOneWidget);
    expect(find.text('账号资料'), findsOneWidget);
    expect(find.text('个人主页'), findsNothing);
    await tester.tap(find.text('账号资料'));
    await tester.pump();
    expect(find.text('账号资料暂不可用'), findsOneWidget);
  });

  testWidgets('mine scroll-to-top request remains wired', (tester) async {
    await pumpScrollToTopUpdate(
      tester,
      builder: (request) => MinePage(scrollToTopRequest: request),
      request: 0,
    );

    await dragUntilVisible(tester, find.text('设置支持'));
    expect(find.text('设置支持'), findsOneWidget);

    await pumpScrollToTopUpdate(
      tester,
      builder: (request) => MinePage(scrollToTopRequest: request),
      request: 1,
    );
    expect(find.text('立即登录'), findsOneWidget);
    expect(find.text('未登录'), findsOneWidget);
  });

  testWidgets('service application keeps local record without mine entry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final appState = AppStateController(
      storage: LocalStorageService(preferences),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ServiceRepository>.value(
            value: const _ApplyServiceRepository(),
          ),
          ChangeNotifierProvider.value(value: appState),
        ],
        child: themedHarness(child: const Scaffold(body: ServicesPage())),
      ),
    );

    await tapTextTile(tester, '社区证明办理');
    expect(find.widgetWithText(AppBar, '社区证明办理办理'), findsOneWidget);
    expect(find.text('办理信息'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('service-applicant-field')),
      '张三',
    );
    await tester.enterText(
      find.byKey(const Key('service-phone-field')),
      '13900001111',
    );
    await tester.tap(find.byKey(const Key('submit-service-application')));
    await tester.pumpAndSettle();

    expect(appState.serviceRecords, hasLength(1));
    expect(appState.serviceRecords.single.service.title, '社区证明办理');
    expect(appState.serviceRecords.single.applicant, '张三');
    expect(appState.serviceRecords.single.phone, '13900001111');
    expect(find.text('办理已提交，本地生成进度记录'), findsOneWidget);
    expect(find.text('我的办理'), findsNothing);
    expect(find.text('待办理'), findsNothing);
  });

  testWidgets('mine removed message shortcuts stay inside message center', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    expect(find.text('系统消息'), findsNothing);
    expect(find.text('互动消息'), findsNothing);

    await tester.tap(find.byKey(const Key('mine-top-message-action')));
    await tester.pumpAndSettle();
    expect(find.text('系统消息'), findsOneWidget);
    expect(find.text('评论'), findsOneWidget);
    expect(find.text('获赞'), findsOneWidget);
    expect(find.text('粉丝'), findsNothing);
  });

  testWidgets('mine profile order stat is available after login', (
    tester,
  ) async {
    await pumpAdmin9App(tester);
    await _login(tester);

    await tester.tap(find.byKey(const Key('mine-profile-stat-orders')));
    await tester.pumpAndSettle();
    expect(find.text('兑换记录'), findsOneWidget);
  });

  testWidgets('live, report, service, mine pages expose core flows', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('直播').last);
    await tester.pumpAndSettle();
    expect(find.text('电视直播'), findsOneWidget);
    expect(find.text('四川新闻联播'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('featured-program-sichuan-news')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('featured-program-sichuan-news')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('live-program-detail-page')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('爆料').last);
    await tester.pumpAndSettle();
    expect(find.text('我要爆料'), findsWidgets);
    await tester.ensureVisible(find.byKey(const Key('report-create-card')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-create-card')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '填写线索'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('服务').last);
    await tester.pumpAndSettle();
    expect(find.text('最近使用'), findsOneWidget);
    expect(find.text('政务服务'), findsOneWidget);
    expect(find.text('生活服务'), findsOneWidget);
    expect(find.text('凉山人社'), findsWidgets);
    expect(find.text('凉山12345'), findsWidgets);
    expect(find.text('本地权益'), findsNothing);
    expect(find.byKey(const Key('service-section-local-rights')), findsNothing);
    expect(
      find.byKey(const Key('quick-action-grid-local-rights')),
      findsNothing,
    );
    expect(find.byIcon(Icons.payments_outlined), findsNothing);
    final h5Entry = find
        .byKey(const Key('service-entry-liangshan-human-resources'))
        .first;
    await tester.ensureVisible(h5Entry);
    await tester.pumpAndSettle();
    await tester.tap(h5Entry);
    await tester.pumpAndSettle();
    expect(find.text('凉山人社'), findsWidgets);
    expect(find.text('https://lszrs.com.cn/lswx/index.html'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    final miniProgramEntry = find
        .byKey(const Key('service-entry-liangshan-12345'))
        .first;
    await tester.ensureVisible(miniProgramEntry);
    await tester.pumpAndSettle();
    await tester.tap(miniProgramEntry);
    await tester.pump();
    expect(find.text('微信小程序跳转待接入'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.ensureVisible(serviceMoreButton('government'));
    await tester.pumpAndSettle();
    await tester.tap(serviceMoreButton('government'));
    await tester.pumpAndSettle();
    expect(find.text('医保凭证'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    expect(find.text('立即登录'), findsOneWidget);
    expect(find.text('未登录'), findsOneWidget);
    expect(find.byKey(const Key('mine-top-message-action')), findsOneWidget);
    expect(find.byKey(const Key('mine-profile-stats')), findsOneWidget);
    expect(find.byKey(const Key('mine-profile-stat-points')), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
    expect(find.byKey(const Key('mine-points-card')), findsNothing);
    expect(find.text('我的积分'), findsNothing);
    expect(find.text('登录后查看积分权益'), findsNothing);
    expect(find.text('1280'), findsNothing);
    expect(find.text('活跃用户 · 连续签到 3 天'), findsNothing);
    expect(find.text('积分商城'), findsNothing);
    await dragUntilVisible(tester, find.text('我的关注'));
    expect(find.text('我的关注'), findsOneWidget);
    expect(find.text('我的收藏'), findsOneWidget);
    await dragUntilVisible(tester, find.text('账号安全'));
    expect(find.text('账号安全'), findsOneWidget);
    expect(find.textContaining('观察豆'), findsNothing);
    expect(find.text('智媒工具'), findsNothing);
    expect(find.text('AI听会'), findsNothing);
    expect(find.text('AI写作'), findsNothing);
    expect(find.text('AI编曲'), findsNothing);
  });

  testWidgets('login, agreement validation, logout, and settings flows work', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();
    expect(find.text('西昌发布'), findsOneWidget);
    expect(find.byKey(const Key('auth-phone-field')), findsOneWidget);
    expect(find.byKey(const Key('auth-code-field')), findsOneWidget);
    expect(find.text('发送验证码'), findsOneWidget);
    expect(find.text('其他登录方式（原型本地模拟）'), findsOneWidget);
    expect(find.byKey(const Key('prototype-auth-notice')), findsOneWidget);
    expect(find.text('原型演示登录：SMS、一键登录和第三方入口均为本地模拟，不代表真实认证。'), findsOneWidget);
    expect(find.byKey(const Key('one-tap-login')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('auth-phone-field')),
      '13800138000',
    );
    await tester.enterText(find.byKey(const Key('auth-code-field')), '123456');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pump();
    expect(find.text('请先同意用户协议和隐私政策'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('同意登录协议'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('auth-phone-field')),
      '13800138000',
    );
    await tester.enterText(find.byKey(const Key('auth-code-field')), '123456');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    expect(find.text('138****8000'), findsOneWidget);
    expect(find.text('黑铁'), findsOneWidget);

    await tester.tap(find.byKey(const Key('mine-top-settings-action')));
    await tester.pumpAndSettle();
    expect(find.text('账号与安全'), findsOneWidget);
    expect(find.text('字体大小'), findsOneWidget);
    expect(find.text('外观主题'), findsOneWidget);
    expect(find.text('有害信息举报'), findsOneWidget);
    expect(find.text('意见反馈'), findsOneWidget);

    await tester.tap(find.text('账号与安全'));
    await tester.pumpAndSettle();
    expect(find.text('手机号'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 4));
    await tester.ensureVisible(find.text('关于'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('关于'));
    await tester.pumpAndSettle();
    expect(find.text('软件版本'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('退出登录'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('top-level-scroll-我的')),
      const Offset(0, 520),
    );
    await tester.pumpAndSettle();
    expect(find.text('立即登录'), findsOneWidget);
  });

  testWidgets('cellular auth page defaults to one tap login', (tester) async {
    await tester.pumpWidget(
      await interactiveHarness(child: const AuthPage(oneTapAvailable: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('158****1001'), findsOneWidget);
    expect(find.text('本地模拟认证'), findsOneWidget);
    expect(find.byKey(const Key('prototype-auth-notice')), findsOneWidget);
    expect(find.byKey(const Key('one-tap-login')), findsOneWidget);
    expect(find.byKey(const Key('other-phone-login')), findsOneWidget);
    expect(find.byKey(const Key('auth-phone-field')), findsNothing);
    expect(find.text('其他登录方式'), findsNothing);

    await tester.tap(find.byKey(const Key('one-tap-login')));
    await tester.pump();
    expect(find.text('请先同意用户协议和隐私政策'), findsOneWidget);
  });

  testWidgets('auth page validates phone code login', (tester) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-phone-field')), findsOneWidget);
    expect(find.byKey(const Key('auth-code-field')), findsOneWidget);
    expect(find.text('发送验证码'), findsOneWidget);
    expect(find.text('其他登录方式（原型本地模拟）'), findsOneWidget);
    expect(find.byKey(const Key('prototype-auth-notice')), findsOneWidget);
    expect(find.text('原型演示登录：SMS、一键登录和第三方入口均为本地模拟，不代表真实认证。'), findsOneWidget);
    expect(find.byKey(const Key('one-tap-login')), findsNothing);

    await tester.tap(find.bySemanticsLabel('同意登录协议'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('auth-phone-field')),
      '13800138000',
    );
    await tester.enterText(find.byKey(const Key('auth-code-field')), '000000');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pump();

    expect(find.text('原型演示验证码不正确，请输入本地模拟验证码'), findsOneWidget);
    expect(find.text('138****8000'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('auth-phone-field')),
      '13800138000',
    );
    await tester.enterText(find.byKey(const Key('auth-code-field')), '123456');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();
    expect(find.text('138****8000'), findsOneWidget);
  });

  testWidgets('auth prototype config disables local mock login fail closed', (
    tester,
  ) async {
    await tester.pumpWidget(
      await interactiveHarness(
        child: const AuthPage(
          prototypeAuthConfig: PrototypeAuthConfig(enabled: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('同意登录协议'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('auth-phone-field')),
      '13800138000',
    );
    await tester.enterText(find.byKey(const Key('auth-code-field')), '123456');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pump();

    expect(find.text('原型演示登录已关闭，无法使用本地模拟认证'), findsOneWidget);
    expect(find.byType(AuthPage), findsOneWidget);
    final authContext = tester.element(find.byType(AuthPage));
    expect(authContext.read<SessionViewModel>().isLoggedIn, isFalse);
  });

  testWidgets('account security shows logged out state without mock binding', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mine-top-settings-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('账号与安全'));
    await tester.pumpAndSettle();

    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('未登录'), findsOneWidget);
    expect(find.text('15881551001'), findsNothing);
    expect(find.byKey(const Key('account-security-login')), findsOneWidget);
  });

  testWidgets('auth page keeps third party methods behind phone login', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();

    expect(find.text('其他登录方式（原型本地模拟）'), findsOneWidget);
    expect(find.byKey(const Key('auth-third-party-wechat')), findsOneWidget);
    expect(find.byKey(const Key('auth-third-party-qq')), findsOneWidget);
    expect(find.byKey(const Key('auth-third-party-weibo')), findsOneWidget);
    expect(find.byKey(const Key('auth-third-party-apple')), findsOneWidget);
    expect(find.byKey(const Key('auth-third-party-account')), findsOneWidget);
  });

  testWidgets(
    'foundation settings navigate to appearance font report feedback',
    (tester) async {
      await pumpAdmin9App(tester);

      await tester.tap(find.text('我的').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('mine-top-settings-action')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('字体大小'));
      await tester.pumpAndSettle();
      expect(find.text('大号字体'), findsOneWidget);
      await tester.tap(find.text('大号字体'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('大号字体'), findsOneWidget);

      await tester.tap(find.text('外观主题'));
      await tester.pumpAndSettle();
      expect(find.text('主题样式'), findsOneWidget);
      expect(find.text('品牌色'), findsNothing);
      expect(find.text('已选'), findsNothing);
      for (final brand in AppBrand.all) {
        expect(find.byKey(Key('brand-${brand.id.name}')), findsOneWidget);
      }
      expect(find.byType(Image), findsWidgets);
      final themeImages = tester
          .widgetList<Image>(find.byType(Image))
          .whereType<Image>()
          .where((image) {
            final provider = image.image;
            return provider is AssetImage &&
                AppBrand.all.any(
                  (brand) =>
                      provider.assetName ==
                      AppAssets.topLevelHeaderImage(brand.id),
                );
          })
          .toList();
      expect(themeImages, hasLength(AppBrand.all.length));
      await tester.tap(find.byKey(const Key('brand-mainstreamRed')));
      await tester.pumpAndSettle();
      final darkModeText = find.text('深色模式');
      await dragUntilVisible(tester, darkModeText);
      final darkModeRow = find.ancestor(
        of: darkModeText,
        matching: find.byType(SettingsRow),
      );
      await tester.ensureVisible(darkModeRow);
      await tester.pumpAndSettle();
      await tester.tap(darkModeRow);
      await tester.pumpAndSettle();
      await dragUntilVisible(tester, find.text('一键全局灰'));
      final grayscaleSwitch = find.byType(Switch).last;
      await tester.ensureVisible(grayscaleSwitch);
      await tester.pumpAndSettle();
      await tester.tap(grayscaleSwitch);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('global-grayscale-filter')), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('主流红'), findsOneWidget);

      await tester.tap(find.text('有害信息举报'));
      await tester.pumpAndSettle();
      expect(find.text('举报电话'), findsWidgets);
      expect(find.text('中央网信办不良信息举报中心'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('意见反馈'));
      await tester.pumpAndSettle();
      expect(
        filledButtonUnder(find.byKey(const Key('submit-feedback'))).enabled,
        isFalse,
      );
      await tester.enterText(
        find.byKey(const Key('feedback-input')),
        '页面清晰，想增加本地服务入口',
      );
      await tester.pump();
      expect(find.textContaining('(14/140)'), findsOneWidget);
      expect(
        filledButtonUnder(find.byKey(const Key('submit-feedback'))).enabled,
        isTrue,
      );
    },
  );

  testWidgets('message center opens system messages from mine page', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mine-top-message-action')));
    await tester.pumpAndSettle();

    expect(find.text('粉丝'), findsNothing);
    expect(find.text('系统消息'), findsOneWidget);
    expect(find.text('账号安全和外观设置已支持本地保存。'), findsOneWidget);
  });

  testWidgets('message center remaining tabs switch to their message lists', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mine-top-message-action')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('评论'));
    await tester.pumpAndSettle();
    expect(find.text('你关注的线索有了新的编辑回复。'), findsOneWidget);

    await tester.tap(find.text('获赞'));
    await tester.pumpAndSettle();
    expect(find.text('你收藏的专题更新了 2 条新内容。'), findsOneWidget);

    await tester.tap(find.text('系统消息'));
    await tester.pumpAndSettle();
    expect(find.text('账号安全和外观设置已支持本地保存。'), findsOneWidget);
    expect(find.text('粉丝'), findsNothing);
  });

  testWidgets('points center mall exchange and order use flow works', (
    tester,
  ) async {
    await pumpAdmin9App(tester);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mine-profile-stat-points')));
    await tester.pumpAndSettle();
    expect(find.text('登录后查看积分'), findsOneWidget);
    expect(find.text('西昌发布'), findsOneWidget);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();

    await _login(tester);
    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mine-profile-stat-points')), findsOneWidget);
    expect(find.byKey(const Key('mine-points-card')), findsNothing);
    await tester.tap(find.byKey(const Key('mine-profile-stat-points')));
    await tester.pumpAndSettle();
    expect(find.text('我的积分'), findsWidgets);

    await tester.tap(find.byKey(const Key('points-checkin-button')));
    await tester.pump();
    expect(find.text('签到成功，积分 +10'), findsOneWidget);
    expect(find.text('今日已签到'), findsOneWidget);

    await tester.tap(find.text('赚积分'));
    await tester.pumpAndSettle();
    final readTask = find.byKey(const Key('point-task-read-news'));
    await tester.ensureVisible(readTask);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: readTask, matching: find.byType(AppInfoListItem)),
      findsOneWidget,
    );
    await tester.tap(find.descendant(of: readTask, matching: find.text('去完成')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: readTask, matching: find.text('领取')),
      findsOneWidget,
    );
    await tester.tap(find.descendant(of: readTask, matching: find.text('领取')));
    await tester.pump();
    expect(find.textContaining('积分 +'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('积分明细').first);
    await tester.pumpAndSettle();
    expect(find.text('每日签到'), findsWidgets);
    expect(find.text('积分过期'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('积分商城').first);
    await tester.pumpAndSettle();
    expect(find.text('本地咖啡满减券'), findsOneWidget);
    await tester.tap(find.byKey(const Key('point-product-coffee-coupon')));
    await tester.pumpAndSettle();
    expect(find.text('商品详情'), findsOneWidget);
    await tester.tap(find.byKey(const Key('point-product-exchange')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('confirm-point-exchange')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-point-exchange')));
    await tester.pumpAndSettle();
    expect(find.text('兑换成功'), findsWidgets);
    await tester.tap(find.text('查看兑换记录'));
    await tester.pumpAndSettle();
    expect(find.text('待使用'), findsWidgets);
    await tester.tap(find.text('本地咖啡满减券').first);
    await tester.pumpAndSettle();
    expect(find.text('兑换详情'), findsOneWidget);
    await tester.tap(find.byKey(const Key('simulate-point-order-use')));
    await tester.pump();
    expect(find.text('已使用'), findsOneWidget);
    expect(find.text('已核销'), findsOneWidget);
  });

  test('points check-in resets by local date', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const repository = PointsRepository();
    var currentTime = DateTime(2026, 6, 8, 9);

    final dayOneState = AppStateController(
      storage: LocalStorageService(preferences),
      pointsRepository: repository,
      now: () => currentTime,
    );
    expect(dayOneState.checkedInToday, isFalse);
    expect(dayOneState.checkInForPoints(), isTrue);
    expect(dayOneState.checkedInToday, isTrue);
    currentTime = DateTime(2026, 6, 9, 8);
    expect(dayOneState.checkedInToday, isFalse);
    expect(dayOneState.checkInForPoints(), isTrue);

    final sameDayState = AppStateController(
      storage: LocalStorageService(preferences),
      pointsRepository: repository,
      now: () => DateTime(2026, 6, 9, 18),
    );
    expect(sameDayState.checkedInToday, isTrue);
    expect(sameDayState.checkInForPoints(), isFalse);

    final nextDayState = AppStateController(
      storage: LocalStorageService(preferences),
      pointsRepository: repository,
      now: () => DateTime(2026, 6, 10, 8),
    );
    expect(nextDayState.checkedInToday, isFalse);
    expect(nextDayState.checkInForPoints(), isTrue);
  });

  test(
    'points ledger and used orders persist across controller restarts',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      const repository = PointsRepository();
      final coffee = repository.productById('coffee-coupon')!;

      final state = AppStateController(
        storage: LocalStorageService(preferences),
        pointsRepository: repository,
        now: () => DateTime(2026, 6, 8, 9),
      );
      expect(state.checkInForPoints(), isTrue);
      final order = state.exchangeProduct(coffee);
      expect(order, isNotNull);
      state.markPointOrderUsed(order!.id);

      final restarted = AppStateController(
        storage: LocalStorageService(preferences),
        pointsRepository: repository,
        now: () => DateTime(2026, 6, 8, 10),
      );
      expect(restarted.pointsBalance, state.pointsBalance);
      expect(
        restarted.pointTransactions.any(
          (transaction) =>
              transaction.title == '每日签到' &&
              transaction.time == '刚刚' &&
              transaction.points == 10,
        ),
        isTrue,
      );
      expect(
        restarted.pointTransactions.any(
          (transaction) =>
              transaction.kind == PointTransactionKind.spend &&
              transaction.title == coffee.title &&
              transaction.points == -coffee.pointsPrice,
        ),
        isTrue,
      );
      expect(restarted.pointOrders, hasLength(1));
      expect(restarted.pointOrders.single.status, PointOrderStatus.used);
    },
  );

  test('points state is scoped by mock user key', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const repository = PointsRepository();
    final coffee = repository.productById('coffee-coupon')!;

    final userAState = AppStateController(
      storage: LocalStorageService(preferences),
      pointsRepository: repository,
      pointsUserKey: '13800138000',
      now: () => DateTime(2026, 6, 8, 9),
    );
    expect(userAState.checkInForPoints(), isTrue);
    expect(userAState.exchangeProduct(coffee), isNotNull);

    final userBState = AppStateController(
      storage: LocalStorageService(preferences),
      pointsRepository: repository,
      pointsUserKey: '15881551001',
      now: () => DateTime(2026, 6, 8, 10),
    );
    expect(userBState.pointsBalance, repository.initialBalance);
    expect(userBState.pointOrders, isEmpty);
    expect(userBState.checkedInToday, isFalse);
    expect(userBState.checkInForPoints(), isTrue);
    expect(userBState.pointsBalance, repository.initialBalance + 10);

    userBState.setPointsUserKey('13800138000');
    expect(
      userBState.pointsBalance,
      repository.initialBalance + 10 - coffee.pointsPrice,
    );
    expect(userBState.pointOrders, hasLength(1));
    expect(userBState.checkedInToday, isTrue);
  });

  test('points tasks cannot be claimed before they are ready', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const repository = PointsRepository();
    final readTask = repository.taskById('read-news')!;
    final state = AppStateController(
      storage: LocalStorageService(preferences),
      pointsRepository: repository,
      pointsUserKey: '13800138000',
      now: () => DateTime(2026, 6, 8, 9),
    );
    final initialBalance = state.pointsBalance;

    expect(state.claimPointTask(readTask), isFalse);
    expect(state.pointsBalance, initialBalance);
    expect(state.isPointTaskClaimed(readTask.id), isFalse);

    state.markPointTaskReady(readTask.id);
    expect(state.claimPointTask(readTask), isTrue);
    expect(state.pointsBalance, initialBalance + readTask.points);
    expect(state.claimPointTask(readTask), isFalse);
    expect(state.pointsBalance, initialBalance + readTask.points);
  });

  test(
    'points exchange blockers keep balance and prioritize redeem limits',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      const repository = PointsRepository();
      final state = AppStateController(
        storage: LocalStorageService(preferences),
        pointsRepository: repository,
        now: () => DateTime(2026, 6, 8, 9),
      );

      final soldOut = repository.productById('library-seat')!;
      final festival = repository.productById('festival-ticket')!;
      final bag = repository.productById('cultural-bag')!;
      final initialBalance = state.pointsBalance;

      expect(state.canExchangeProduct(soldOut), '已兑完');
      expect(state.exchangeProduct(soldOut), isNull);
      expect(state.pointsBalance, initialBalance);

      final order = state.exchangeProduct(festival);
      expect(order, isNotNull);
      expect(state.pointsBalance, initialBalance - festival.pointsPrice);
      expect(state.canExchangeProduct(festival), '该权益每人限兑 1 次');
      expect(state.exchangeProduct(festival), isNull);
      expect(state.pointsBalance, initialBalance - festival.pointsPrice);

      expect(state.canExchangeProduct(bag), '还差 360 积分');
      expect(state.exchangeProduct(bag), isNull);
      expect(state.pointsBalance, initialBalance - festival.pointsPrice);
    },
  );

  test('foundation deny-list terms stay out of runtime Flutter sources', () {
    const forbidden = [
      '观察豆',
      '智媒工具',
      'AI听会',
      'AI写作',
      'AI编曲',
      'pointsStart',
      'pointsEnd',
      '/api/frontend',
      '/api/events',
      'feed-pools',
      'data-sources',
      'placements',
    ];
    for (final term in forbidden) {
      expect(
        _runtimeSourceContains(term),
        isFalse,
        reason: '$term must not return to foundation runtime sources',
      );
    }
  });
}

Future<void> _login(WidgetTester tester) async {
  await tester.tap(find.text('我的').last);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(FilledButton, '登录'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, '登录'));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('auth-code-field')), findsOneWidget);
  await tester.tap(find.bySemanticsLabel('同意登录协议'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('auth-phone-field')),
    '13800138000',
  );
  await tester.enterText(find.byKey(const Key('auth-code-field')), '123456');
  await tester.ensureVisible(find.byKey(const Key('auth-submit')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('auth-submit')));
  await tester.pumpAndSettle();
}

double _verticalGapBetween(
  WidgetTester tester, {
  required Finder lowerEdge,
  required Finder upperEdge,
}) {
  return tester.getTopLeft(upperEdge).dy - tester.getBottomLeft(lowerEdge).dy;
}

Finder _firstIconIn(Finder ancestor) {
  final image = find.descendant(
    of: ancestor,
    matching: find.byWidgetPredicate((widget) {
      return widget is Image &&
          widget.key.toString().contains('quick-action-image-');
    }),
  );
  if (image.evaluate().isNotEmpty) return image.first;
  return find.descendant(of: ancestor, matching: find.byType(Icon)).first;
}

Finder serviceMoreButton(String sectionId) {
  return find.descendant(
    of: find.byKey(Key('service-section-$sectionId')),
    matching: find.widgetWithText(TextButton, '更多'),
  );
}

bool _runtimeSourceContains(String term) {
  return _runtimeSourceFiles().any(
    (file) => file.readAsStringSync().contains(term),
  );
}

Iterable<File> _runtimeSourceFiles() sync* {
  final root = Directory('lib').existsSync()
      ? Directory('lib')
      : Directory('lib');
  if (!root.existsSync()) return;

  yield* root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

class _ControllerOwnershipHost extends StatefulWidget {
  const _ControllerOwnershipHost({super.key});

  @override
  State<_ControllerOwnershipHost> createState() =>
      _ControllerOwnershipHostState();
}

class _ControllerOwnershipHostState extends State<_ControllerOwnershipHost>
    with TickerProviderStateMixin {
  TabController? _externalController;

  @override
  void dispose() {
    _externalController?.dispose();
    super.dispose();
  }

  void useExternalController() {
    setState(() {
      _externalController?.dispose();
      _externalController = TabController(
        length: 2,
        vsync: this,
        initialIndex: 1,
      );
    });
  }

  void useInternalController() {
    setState(() {
      _externalController?.dispose();
      _externalController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final external = _externalController;
    return ConfiguredTopLevelPage(
      tabController: external,
      config: TopLevelPageConfig(
        title: '控制器测试',
        surfaceBuilder: (_, _) => const PageSurface(),
        tabs: TopLevelTabConfig(
          headerKey: const Key('controller-test-tabs-sliver'),
          barKey: const Key('controller-test-pinned-tab-bar'),
          viewportSliverKey: const Key('controller-test-tab-viewport-sliver'),
          viewportKey: const Key('controller-test-tab-viewport'),
          viewKey: const Key('controller-test-tab-view'),
          tabs: [
            TopLevelTabItem(
              id: 'one',
              label: '一',
              builder: (_, _) =>
                  Center(child: Text(external == null ? '内部一' : '外部一')),
            ),
            TopLevelTabItem(
              id: 'two',
              label: '二',
              builder: (_, _) =>
                  Center(child: Text(external == null ? '内部二' : '外部二')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChromeSlotCase {
  const _ChromeSlotCase({
    required this.name,
    required this.topPadding,
    required this.search,
    required this.tabs,
    required this.expectSlot,
    required this.expectControls,
    required this.expectedContentTop,
    this.actions = false,
    this.titleBarEnabled = true,
    this.reserveToolbarSlot,
  });

  final String name;
  final double topPadding;
  final bool search;
  final bool tabs;
  final bool actions;
  final bool titleBarEnabled;
  final bool? reserveToolbarSlot;
  final bool expectSlot;
  final bool expectControls;
  final double expectedContentTop;

  bool get expectTitle => expectControls && !search;
}

class _TopSurfaceForegroundHost extends StatelessWidget {
  const _TopSurfaceForegroundHost({
    required this.title,
    required this.surfaceColor,
  });

  final String title;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    return ConfiguredTopLevelPage(
      config: TopLevelPageConfig(
        title: title,
        surfaceBuilder: (_, _) => PageSurface(
          backgroundColor: surfaceColor,
          backdrop: PageBackdrop(
            enabled: false,
            startColor: surfaceColor,
            middleColor: surfaceColor,
            endColor: surfaceColor,
          ),
        ),
        search: const TopLevelSearchConfig(
          key: Key('surface-search-entry'),
          placeholder: '搜索',
          onTap: _noop,
        ),
        tabs: TopLevelTabConfig(
          headerKey: const Key('surface-tabs-sliver'),
          barKey: const Key('surface-pinned-tab-bar'),
          viewportSliverKey: const Key('surface-tab-viewport-sliver'),
          viewportKey: const Key('surface-tab-viewport'),
          viewKey: const Key('surface-tab-view'),
          trailing: const IconButton(
            key: Key('surface-manage-button'),
            tooltip: '频道管理',
            onPressed: _noop,
            icon: Icon(Icons.grid_view_rounded),
          ),
          tabs: const [
            TopLevelTabItem(id: 'one', label: '一', builder: _buildSurfaceTab),
            TopLevelTabItem(id: 'two', label: '二', builder: _buildSurfaceTab),
          ],
        ),
      ),
    );
  }

  static Widget _buildSurfaceTab(
    BuildContext context,
    ScrollController? controller,
  ) {
    return CustomScrollView(
      controller: controller,
      slivers: const [
        SliverToBoxAdapter(child: SizedBox(height: 320, child: Text('内容'))),
      ],
    );
  }

  static void _noop() {}
}

class _ConfiguredTabOverlayHost extends StatelessWidget {
  const _ConfiguredTabOverlayHost({
    required this.title,
    required this.newsStyle,
    this.overlayColor,
  });

  final String title;
  final bool newsStyle;
  final WidgetStateProperty<Color?>? overlayColor;

  @override
  Widget build(BuildContext context) {
    return ConfiguredTopLevelPage(
      config: TopLevelPageConfig(
        title: title,
        surfaceBuilder: (_, _) => const PageSurface(),
        tabs: TopLevelTabConfig(
          headerKey: Key('$title-tabs-sliver'),
          barKey: Key('$title-pinned-tab-bar'),
          viewportSliverKey: Key('$title-tab-viewport-sliver'),
          viewportKey: Key('$title-tab-viewport'),
          viewKey: Key('$title-tab-view'),
          newsStyle: newsStyle,
          overlayColor: overlayColor,
          tabs: const [
            TopLevelTabItem(id: 'one', label: '一', builder: _buildTab),
            TopLevelTabItem(id: 'two', label: '二', builder: _buildTab),
          ],
        ),
      ),
    );
  }

  static Widget _buildTab(BuildContext context, ScrollController? controller) {
    return CustomScrollView(
      controller: controller,
      slivers: const [
        SliverToBoxAdapter(child: SizedBox(height: 240, child: Text('内容'))),
      ],
    );
  }
}

class _ChromeSlotHost extends StatelessWidget {
  const _ChromeSlotHost({
    required this.search,
    required this.tabs,
    required this.actions,
    required this.titleBarEnabled,
    this.reserveToolbarSlot,
  });

  final bool search;
  final bool tabs;
  final bool actions;
  final bool titleBarEnabled;
  final bool? reserveToolbarSlot;

  @override
  Widget build(BuildContext context) {
    final config = TopLevelPageConfig(
      title: '配置页',
      surfaceBuilder: (_, _) => PageSurface(
        backdrop: PageBackdrop.image(
          tokens: context.tokens,
          endColor: context.tokens.pageBackground,
          assetName: AppAssets.topLevelHeaderImage(AppBrand.newsBlueBrand.id),
          imageAlignment: Alignment.topCenter,
        ),
      ),
      scrollEdgeTitleBarEnabled: titleBarEnabled,
      reserveToolbarSlot: reserveToolbarSlot,
      actions: actions
          ? const [
              IconButton(
                key: Key('config-toolbar-action'),
                onPressed: _noop,
                icon: Icon(Icons.more_horiz),
              ),
            ]
          : const [],
      search: search
          ? TopLevelSearchConfig(
              key: const Key('config-search-entry'),
              placeholder: '配置搜索',
              onTap: _noop,
            )
          : null,
      tabs: tabs
          ? TopLevelTabConfig(
              headerKey: const Key('config-tabs-sliver'),
              barKey: const Key('config-pinned-tab-bar'),
              viewportSliverKey: const Key('config-tab-viewport-sliver'),
              viewportKey: const Key('config-tab-viewport'),
              viewKey: const Key('config-tab-view'),
              tabs: [
                TopLevelTabItem(
                  id: 'one',
                  label: '一',
                  builder: (_, _) => const Center(child: Text('配置 Tab 一')),
                ),
              ],
            )
          : null,
      plainSliversBuilder: tabs
          ? null
          : (_) => [
              SliverList.builder(
                itemCount: 3,
                itemBuilder: (context, index) =>
                    SizedBox(height: 56, child: Text('配置列表 $index')),
              ),
            ],
    );

    return ConfiguredTopLevelPage(config: config);
  }

  static void _noop() {}
}

class _CompactServiceRepository extends ServiceRepository {
  const _CompactServiceRepository();

  @override
  List<ServiceSection> get sections => const [
    ServiceSection(
      id: 'government',
      title: '政务服务',
      displayLimit: 3,
      items: [
        ServiceItem(
          id: 'one',
          title: '服务一',
          description: '第一项服务',
          iconKey: 'one',
          target: ServiceTarget(
            type: ServiceTargetType.h5,
            value: 'https://example.com/one',
          ),
        ),
        ServiceItem(
          id: 'two',
          title: '服务二',
          description: '第二项服务',
          iconKey: 'two',
          target: ServiceTarget(
            type: ServiceTargetType.phone,
            value: '12345',
            feedback: '电话入口暂不可用',
          ),
        ),
        ServiceItem(
          id: 'three',
          title: '服务三',
          description: '第三项服务',
          iconKey: 'three',
          target: ServiceTarget(
            type: ServiceTargetType.externalApp,
            value: 'demo://three',
            feedback: '外部 App 暂未接入',
          ),
        ),
      ],
    ),
    ServiceSection(
      id: 'medical',
      title: '智慧医疗',
      items: [
        ServiceItem(
          id: 'medical-one',
          title: '医疗一',
          description: '医疗服务',
          iconKey: 'hospital',
        ),
      ],
    ),
  ];
}

class _ApplyServiceRepository extends ServiceRepository {
  const _ApplyServiceRepository();

  @override
  List<ServiceSection> get sections => const [
    ServiceSection(
      id: 'apply',
      title: '便民办理',
      items: [
        ServiceItem(
          id: 'apply',
          title: '社区证明办理',
          description: '提交一次本地服务申请',
          iconKey: 'government',
          target: ServiceTarget(
            type: ServiceTargetType.internalPage,
            value: 'service-apply',
          ),
        ),
      ],
    ),
  ];

  @override
  List<ServiceItem> get defaultRecentItems => const [];
}

class _DenseServiceRepository extends ServiceRepository {
  const _DenseServiceRepository();

  @override
  List<ServiceSection> get sections => const [
    ServiceSection(
      id: 'government',
      title: '政务服务',
      displayLimit: 5,
      items: [
        ServiceItem(
          id: 'one',
          title: '服务一',
          description: '第一项服务',
          iconKey: 'government',
        ),
        ServiceItem(
          id: 'two',
          title: '服务二',
          description: '第二项服务',
          iconKey: 'mailbox',
        ),
        ServiceItem(
          id: 'three',
          title: '服务三',
          description: '第三项服务',
          iconKey: 'people',
        ),
        ServiceItem(
          id: 'four',
          title: '服务四',
          description: '第四项服务',
          iconKey: 'tax',
        ),
        ServiceItem(
          id: 'five',
          title: '服务五',
          description: '第五项服务',
          iconKey: 'phone',
        ),
      ],
    ),
  ];
}
