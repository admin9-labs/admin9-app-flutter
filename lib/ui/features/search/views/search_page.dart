import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_info_list_item.dart';
import '../../../../core/widgets/app_search_entry.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/repositories/home_content_repository.dart';
import '../../../../data/repositories/live_repository.dart';
import '../../../../data/repositories/service_repository.dart';
import '../../../../domain/models/home_block.dart';
import '../../../../domain/models/live_program.dart';
import '../../../../domain/models/service_item.dart';
import '../../../shared/app_state_controller.dart';
import '../../live/views/live_detail_page.dart';
import '../../services/views/services_page.dart';
import '../../home/views/channel_content_blocks.dart';

enum SearchCategory { all, article, video, special, service, live }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialKeyword});

  final String? initialKeyword;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialKeyword ?? '',
  );
  SearchCategory _category = SearchCategory.all;
  var _keyword = '';
  var _searched = false;

  static const _hotSearches = ['城市更新', '直播', '政务办理', '乡村', '服务业', '文旅'];

  @override
  void initState() {
    super.initState();
    final keyword = widget.initialKeyword?.trim();
    if (keyword != null && keyword.isNotEmpty) {
      _keyword = keyword;
      _searched = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateController>();
    final homeRepository = context.read<HomeContentRepository>();
    final serviceRepository = context.read<ServiceRepository>();
    final liveRepository = context.read<LiveRepository>();
    final results = _results(homeRepository, serviceRepository, liveRepository);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.xs,
        title: AppSearchTextField(
          controller: _controller,
          autofocus: true,
          placeholder: '搜索新闻、服务',
          height: AppSpacing.minTouchTarget,
          fillColor: tokens.softFill,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          contentPadding: EdgeInsets.zero,
          onSubmitted: _submit,
          onClear: () {
            setState(() {
              _controller.clear();
              _keyword = '';
              _searched = false;
            });
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: TextButton(
              onPressed: () => _submit(_controller.text),
              child: Text(
                '搜索',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: AppInsets.page,
          children: [
            if (!_searched) ...[
              _KeywordSection(
                title: '搜索历史',
                keywords: appState.searchHistory,
                emptyText: '暂无搜索',
                onTap: _useKeyword,
                trailing: appState.searchHistory.isEmpty
                    ? null
                    : TextButton(
                        key: const Key('clear-search-history'),
                        onPressed: appState.clearSearchHistory,
                        child: const Text('清空'),
                      ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              _KeywordSection(
                title: '热门搜索',
                keywords: _hotSearches,
                onTap: _useKeyword,
              ),
            ] else ...[
              _SearchTabs(
                selected: _category,
                onChanged: (category) => setState(() => _category = category),
              ),
              const SizedBox(height: AppSpacing.md),
              if (results.isEmpty)
                const EmptyState(
                  key: Key('search-empty-state'),
                  title: '暂无结果',
                  icon: Icons.search_off_outlined,
                )
              else
                for (final result in results) ...[
                  AppInfoListCard(
                    key: Key('search-result-${result.id}'),
                    icon: result.icon,
                    iconColor: context.tokens.tagForeground,
                    title: result.title,
                    subtitle: result.subtitle,
                    onTap: () => result.open(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
            ],
          ],
        ),
      ),
    );
  }

  List<_SearchResult> _results(
    HomeContentRepository homeRepository,
    ServiceRepository serviceRepository,
    LiveRepository liveRepository,
  ) {
    if (!_searched) return const [];
    final articleResults = [
      for (final item in homeRepository.search(_keyword))
        _SearchResult.content(item),
    ];
    final serviceResults = [
      for (final service in serviceRepository.services)
        if (service.searchableText.toLowerCase().contains(
          _keyword.toLowerCase(),
        ))
          _SearchResult.service(service),
    ];
    final liveResults = [
      for (final program in liveRepository.programs)
        if (_matches(program.title, program.summary))
          _SearchResult.live(program),
    ];

    final all = [...articleResults, ...serviceResults, ...liveResults];
    return all
        .where((result) {
          return switch (_category) {
            SearchCategory.all => true,
            SearchCategory.article => result.kind == SearchCategory.article,
            SearchCategory.video => result.kind == SearchCategory.video,
            SearchCategory.special => result.kind == SearchCategory.special,
            SearchCategory.service => result.kind == SearchCategory.service,
            SearchCategory.live => result.kind == SearchCategory.live,
          };
        })
        .toList(growable: false);
  }

  bool _matches(String title, String summary) {
    final normalized = _keyword.toLowerCase();
    return '$title $summary'.toLowerCase().contains(normalized);
  }

  void _useKeyword(String keyword) {
    _controller.text = keyword;
    _submit(keyword);
  }

  void _submit(String rawKeyword) {
    final keyword = rawKeyword.trim();
    if (keyword.isEmpty) {
      setState(() {
        _keyword = '';
        _searched = false;
      });
      return;
    }
    context.read<AppStateController>().addSearchQuery(keyword);
    setState(() {
      _keyword = keyword;
      _searched = true;
    });
  }
}

class _KeywordSection extends StatelessWidget {
  const _KeywordSection({
    required this.title,
    required this.keywords,
    required this.onTap,
    this.emptyText,
    this.trailing,
  });

  final String title;
  final List<String> keywords;
  final ValueChanged<String> onTap;
  final String? emptyText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: title, trailing: trailing),
          const SizedBox(height: AppSpacing.md),
          if (keywords.isEmpty)
            Text(emptyText ?? '暂无内容', style: context.typography.feedMeta)
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final keyword in keywords)
                  ActionChip(
                    label: Text(keyword),
                    onPressed: () => onTap(keyword),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SearchTabs extends StatelessWidget {
  const _SearchTabs({required this.selected, required this.onChanged});

  final SearchCategory selected;
  final ValueChanged<SearchCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<SearchCategory>(
        segments: const [
          ButtonSegment(value: SearchCategory.all, label: Text('全部')),
          ButtonSegment(value: SearchCategory.article, label: Text('文章')),
          ButtonSegment(value: SearchCategory.video, label: Text('视频')),
          ButtonSegment(value: SearchCategory.special, label: Text('专题')),
          ButtonSegment(value: SearchCategory.service, label: Text('服务')),
          ButtonSegment(value: SearchCategory.live, label: Text('直播')),
        ],
        selected: {selected},
        onSelectionChanged: (values) => onChanged(values.single),
      ),
    );
  }
}

class _SearchResult {
  const _SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.icon,
    required this.open,
  });

  factory _SearchResult.content(ContentItem item) {
    final kind = switch (item.contentKind) {
      ContentKind.video => SearchCategory.video,
      ContentKind.special || ContentKind.gallery => SearchCategory.special,
      ContentKind.live || ContentKind.replay => SearchCategory.live,
      ContentKind.service => SearchCategory.service,
      _ => SearchCategory.article,
    };
    return _SearchResult(
      id: item.id,
      title: item.article.title,
      subtitle: '${item.article.source} · ${item.article.summary}',
      kind: kind,
      icon: switch (kind) {
        SearchCategory.video => Icons.play_circle_outline,
        SearchCategory.special => Icons.topic_outlined,
        SearchCategory.live => Icons.live_tv_outlined,
        SearchCategory.service => Icons.apps_outlined,
        _ => Icons.article_outlined,
      },
      open: (context) => openArticle(context, item.article),
    );
  }

  factory _SearchResult.service(ServiceItem service) {
    return _SearchResult(
      id: service.id,
      title: service.title,
      subtitle: service.description,
      kind: SearchCategory.service,
      icon: Icons.apps_outlined,
      open: (context) => openServiceEntry(context, service),
    );
  }

  factory _SearchResult.live(LiveProgram program) {
    return _SearchResult(
      id: program.id,
      title: program.title,
      subtitle: '${program.source} · ${program.summary}',
      kind: SearchCategory.live,
      icon: Icons.live_tv_outlined,
      open: (context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LiveDetailPage(program: program)),
      ),
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final SearchCategory kind;
  final IconData icon;
  final void Function(BuildContext context) open;
}
