import 'package:admin9_app_flutter/app/page_configuration/page_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses navigation and registered pages', () {
    final configuration = PageConfiguration.fromJson({
      'schemaVersion': 1,
      'revision': 2,
      'navigation': [
        {'pageId': 'home', 'pageType': 'home', 'label': '首页', 'icon': 'home'},
      ],
      'pages': [
        {'pageId': 'home', 'pageType': 'home', 'title': '首页'},
      ],
    });

    expect(configuration?.navigation.single.pageId, 'home');
    expect(configuration?.page('home')?.title, '首页');
  });

  test('rejects unsupported schema, executable fields and incomplete tabs', () {
    final page = {'pageId': 'home', 'pageType': 'home', 'title': '首页'};
    final json = {
      'schemaVersion': 1,
      'revision': 1,
      'navigation': [
        {'pageId': 'home', 'pageType': 'home', 'label': '首页', 'icon': 'home'},
      ],
      'pages': [page],
    };
    expect(PageConfiguration.fromJson({...json, 'schemaVersion': 2}), isNull);
    expect(PageConfiguration.fromJson({...json, 'schemaVersion': 1.0}), isNull);
    for (final badPage in [
      {...page, 'url': 'https://example.com'},
      {
        ...page,
        'actions': ['arbitraryRoute'],
      },
      {
        ...page,
        'regions': {'unknown': true},
      },
      {
        ...page,
        'appearance': {'showTitle': 'yes'},
      },
      {
        ...page,
        'tabs': [
          {'id': 'news'},
        ],
      },
      {
        ...page,
        'tabs': [
          {'id': 'news', 'label': '新闻'},
          {'id': 'news', 'label': '重复'},
        ],
      },
    ]) {
      expect(
        PageConfiguration.fromJson({
          ...json,
          'pages': [badPage],
        }),
        isNull,
      );
    }
  });

  test('rejects duplicate IDs, unknown icons, and missing pages', () {
    final pages = [
      {'pageId': 'home', 'pageType': 'home', 'title': '首页'},
    ];
    final base = {
      'schemaVersion': 1,
      'revision': 1,
      'navigation': [
        {'pageId': 'home', 'pageType': 'home', 'label': '首页', 'icon': 'home'},
      ],
      'pages': pages,
    };
    expect(
      PageConfiguration.fromJson({
        ...base,
        'pages': [...pages, ...pages],
      }),
      isNull,
    );
    expect(
      PageConfiguration.fromJson({
        ...base,
        'navigation': [
          {
            'pageId': 'home',
            'pageType': 'home',
            'label': '首页',
            'icon': 'unknown',
          },
        ],
      }),
      isNull,
    );
    expect(
      PageConfiguration.fromJson({
        ...base,
        'navigation': [
          {
            'pageId': 'missing',
            'pageType': 'home',
            'label': '缺失',
            'icon': 'home',
          },
        ],
      }),
      isNull,
    );
  });

  test(
    'rejects unknown types, navigation conflicts, and hidden navigation',
    () {
      final base = {
        'schemaVersion': 1,
        'revision': 1,
        'navigation': [
          {'pageId': 'home', 'pageType': 'home', 'label': '首页', 'icon': 'home'},
        ],
        'pages': [
          {'pageId': 'home', 'pageType': 'home', 'title': '首页'},
        ],
      };

      expect(
        PageConfiguration.fromJson({
          ...base,
          'navigation': [
            {
              'pageId': 'home',
              'pageType': 'unknown',
              'label': '未知',
              'icon': 'home',
            },
          ],
        }),
        isNull,
      );
      expect(
        PageConfiguration.fromJson({
          ...base,
          'navigation': [
            {
              'pageId': 'home',
              'pageType': 'settings',
              'label': '设置',
              'icon': 'settings',
            },
          ],
        }),
        isNull,
      );
      expect(
        PageConfiguration.fromJson({
          ...base,
          'navigation': [
            {
              'pageId': 'home',
              'pageType': 'home',
              'label': '首页',
              'icon': 'home',
              'visible': false,
            },
          ],
        }),
        isNull,
      );
    },
  );
}
