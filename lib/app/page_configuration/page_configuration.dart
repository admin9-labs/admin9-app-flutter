final class PageConfiguration {
  const PageConfiguration({
    required this.schemaVersion,
    required this.revision,
    required this.navigation,
    required this.pages,
  });

  final int schemaVersion;
  final int revision;
  final List<NavigationEntry> navigation;
  final Map<String, PageDefinition> pages;

  PageDefinition? page(String pageId) => pages[pageId];

  List<NavigationEntry> get visibleNavigation => _ordered(
    navigation.where((entry) => entry.visible).toList(),
    (entry) => entry.order,
  );

  static PageConfiguration? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final schemaVersion = value['schemaVersion'];
    final revision = value['revision'];
    final navigationValue = value['navigation'];
    final pagesValue = value['pages'];
    if (!_onlyKeys(value, {
          'schemaVersion',
          'revision',
          'navigation',
          'pages',
        }) ||
        schemaVersion is! int ||
        schemaVersion != 1 ||
        revision is! int ||
        navigationValue is! List<dynamic> ||
        pagesValue is! List<dynamic>) {
      return null;
    }
    final navigation = <NavigationEntry>[];
    final pageIds = <String>{};
    for (final item in navigationValue) {
      final entry = NavigationEntry.fromJson(item);
      if (entry == null || !pageIds.add(entry.pageId)) return null;
      navigation.add(entry);
    }
    if (navigation.isEmpty) return null;
    final pages = <String, PageDefinition>{};
    for (final item in pagesValue) {
      final page = PageDefinition.fromJson(item);
      if (page == null || pages.containsKey(page.pageId)) return null;
      pages[page.pageId] = page;
    }
    if (navigation.any((entry) => !pages.containsKey(entry.pageId))) {
      return null;
    }
    if (navigation.every((entry) => !entry.visible)) return null;
    if (navigation.any(
      (entry) => pages[entry.pageId]?.pageType != entry.pageType,
    )) {
      return null;
    }
    return PageConfiguration(
      schemaVersion: schemaVersion,
      revision: revision,
      navigation: List.unmodifiable(navigation),
      pages: Map.unmodifiable(pages),
    );
  }
}

final class NavigationEntry {
  const NavigationEntry({
    required this.pageId,
    required this.pageType,
    required this.label,
    required this.icon,
    this.visible = true,
    this.order = 0,
  });

  final String pageId;
  final String pageType;
  final String label;
  final String icon;
  final bool visible;
  final int order;

  static NavigationEntry? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final pageId = value['pageId'];
    final pageType = value['pageType'];
    final label = value['label'];
    final icon = value['icon'];
    final visible = value['visible'] ?? true;
    final order = value['order'] ?? 0;
    if (!_onlyKeys(value, {
          'pageId',
          'pageType',
          'label',
          'icon',
          'visible',
          'order',
        }) ||
        !_validId(pageId) ||
        pageType is! String ||
        pageType.isEmpty ||
        !_registeredPageTypes.contains(pageType) ||
        label is! String ||
        label.isEmpty ||
        icon is! String ||
        !_allowedIcons.contains(icon) ||
        visible is! bool ||
        order is! int) {
      return null;
    }
    return NavigationEntry(
      pageId: pageId as String,
      pageType: pageType,
      label: label,
      icon: icon,
      visible: visible,
      order: order,
    );
  }
}

final class PageDefinition {
  const PageDefinition({
    required this.pageId,
    required this.pageType,
    required this.title,
    this.actions = const [],
    this.tabs = const [],
    this.regions = const {},
    this.showTitle = true,
  });

  final String pageId;
  final String pageType;
  final String title;
  final List<String> actions;
  final List<PageTabDefinition> tabs;
  final Map<String, bool> regions;
  final bool showTitle;

  bool shows(String region) => regions[region] ?? true;

  PageDefinition forTab(PageTabDefinition tab) => PageDefinition(
    pageId: pageId,
    pageType: pageType,
    title: title,
    actions: actions,
    regions: {...regions, ...tab.regions},
    showTitle: showTitle,
  );

  static PageDefinition? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final pageId = value['pageId'];
    final pageType = value['pageType'];
    final title = value['title'];
    final actions = value['actions'] ?? const <dynamic>[];
    final tabsValue = value['tabs'] ?? const <dynamic>[];
    final regionsValue = value['regions'] ?? const <String, dynamic>{};
    final appearance = value['appearance'] ?? const <String, dynamic>{};
    if (!_onlyKeys(value, {
          'pageId',
          'pageType',
          'title',
          'actions',
          'tabs',
          'regions',
          'appearance',
        }) ||
        !_validId(pageId) ||
        pageType is! String ||
        pageType.isEmpty ||
        !_registeredPageTypes.contains(pageType) ||
        title is! String ||
        title.isEmpty ||
        actions is! List<dynamic> ||
        actions.any((value) => value != 'open_settings') ||
        tabsValue is! List<dynamic> ||
        regionsValue is! Map<String, dynamic> ||
        appearance is! Map<String, dynamic> ||
        !_onlyKeys(appearance, {'showTitle'}) ||
        (appearance['showTitle'] != null && appearance['showTitle'] is! bool)) {
      return null;
    }
    final tabs = <PageTabDefinition>[];
    final tabIds = <String>{};
    for (final value in tabsValue) {
      final tab = PageTabDefinition.fromJson(
        value,
        allowedRegions: _regionsFor(pageType),
      );
      if (tab == null || !tabIds.add(tab.id)) return null;
      tabs.add(tab);
    }
    final regions = <String, bool>{};
    for (final entry in regionsValue.entries) {
      if (entry.value is! bool || !_regionsFor(pageType).contains(entry.key)) {
        return null;
      }
      regions[entry.key] = entry.value as bool;
    }
    return PageDefinition(
      pageId: pageId as String,
      pageType: pageType,
      title: title,
      actions: List.unmodifiable(actions.cast<String>()),
      tabs: List.unmodifiable(_ordered(tabs, (tab) => tab.order)),
      regions: Map.unmodifiable(regions),
      showTitle: appearance['showTitle'] as bool? ?? true,
    );
  }
}

final class PageTabDefinition {
  const PageTabDefinition({
    required this.id,
    required this.label,
    this.order = 0,
    this.regions = const {},
  });
  final String id;
  final String label;
  final int order;
  final Map<String, bool> regions;

  static PageTabDefinition? fromJson(
    Object? value, {
    required Set<String> allowedRegions,
  }) {
    if (value is! Map<String, dynamic> ||
        !_onlyKeys(value, {'id', 'label', 'order', 'regions'})) {
      return null;
    }
    final id = value['id'];
    final label = value['label'];
    final order = value['order'] ?? 0;
    final regions = value['regions'] ?? const <String, dynamic>{};
    if (!_validId(id) ||
        label is! String ||
        label.trim().isEmpty ||
        order is! int ||
        regions is! Map<String, dynamic> ||
        regions.entries.any(
          (entry) =>
              !allowedRegions.contains(entry.key) || entry.value is! bool,
        )) {
      return null;
    }
    return PageTabDefinition(
      id: id as String,
      label: label,
      order: order,
      regions: Map.unmodifiable(regions.cast<String, bool>()),
    );
  }
}

bool _validId(Object? value) =>
    value is String && RegExp(r'^[a-z][a-z0-9_-]*$').hasMatch(value);
bool _onlyKeys(Map<String, dynamic> value, Set<String> keys) =>
    value.keys.every(keys.contains);
List<T> _ordered<T>(List<T> values, int Function(T) order) {
  final indexed = values.indexed.toList();
  indexed.sort((a, b) {
    final difference = order(a.$2).compareTo(order(b.$2));
    return difference == 0 ? a.$1.compareTo(b.$1) : difference;
  });
  return List.unmodifiable(indexed.map((item) => item.$2));
}

Set<String> _regionsFor(String type) => switch (type) {
  'home' => {
    'introduction', 'media', 'settings',
    // examples:begin
    'components',
    // examples:end
  },
  'settings' => {'account', 'appearance'},
  _ => {'content'},
};

const _allowedIcons = {
  'home',
  'blocks',
  'play',
  'settings',
  'sliders-horizontal',
};

const _registeredPageTypes = {
  'home',
  // examples:begin
  'components',
  // examples:end
  'media',
  'settings',
  'placeholder',
};
