// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:admin9_app_flutter/app/routing/main_destination.dart' as _i41;
import 'package:admin9_app_flutter/app/routing/main_shell_page.dart' as _i23;
import 'package:admin9_app_flutter/app/routing/startup_gate_page.dart' as _i30;
import 'package:admin9_app_flutter/app/startup/startup_state.dart' as _i42;
import 'package:admin9_app_flutter/features/examples/presentation/pages/catalog/content_page.dart'
    as _i11;
import 'package:admin9_app_flutter/features/examples/presentation/pages/catalog/feedback_page.dart'
    as _i13;
import 'package:admin9_app_flutter/features/examples/presentation/pages/catalog/forms_page.dart'
    as _i14;
import 'package:admin9_app_flutter/features/examples/presentation/pages/catalog/foundation_page.dart'
    as _i15;
import 'package:admin9_app_flutter/features/examples/presentation/pages/components_page.dart'
    as _i8;
import 'package:admin9_app_flutter/features/examples/presentation/pages/concepts/themes/themes_page.dart'
    as _i32;
import 'package:admin9_app_flutter/features/examples/presentation/pages/content/carousel/carousel_page.dart'
    as _i7;
import 'package:admin9_app_flutter/features/examples/presentation/pages/content/feed/content_feed_page.dart'
    as _i10;
import 'package:admin9_app_flutter/features/examples/presentation/pages/data/playgrounds/calendar_playground_page.dart'
    as _i6;
import 'package:admin9_app_flutter/features/examples/presentation/pages/data/playgrounds/lists_playground_page.dart'
    as _i22;
import 'package:admin9_app_flutter/features/examples/presentation/pages/data/playgrounds/overview_playground_page.dart'
    as _i25;
import 'package:admin9_app_flutter/features/examples/presentation/pages/feedback/playgrounds/async_status_playground_page.dart'
    as _i3;
import 'package:admin9_app_flutter/features/examples/presentation/pages/feedback/playgrounds/confirmation_playground_page.dart'
    as _i9;
import 'package:admin9_app_flutter/features/examples/presentation/pages/feedback/playgrounds/contextual_feedback_playground_page.dart'
    as _i12;
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/buttons/buttons_playground_page.dart'
    as _i5;
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/scheduling/scheduling_playground_page.dart'
    as _i26;
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/selection_controls/selection_controls_playground_page.dart'
    as _i27;
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/selects/selects_playground_page.dart'
    as _i28;
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/text_input/text_input_playground_page.dart'
    as _i31;
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/value_controls/value_controls_playground_page.dart'
    as _i33;
import 'package:admin9_app_flutter/features/examples/presentation/pages/foundation/playgrounds/app_shell_playground_page.dart'
    as _i1;
import 'package:admin9_app_flutter/features/examples/presentation/pages/foundation/playgrounds/interaction_playground_page.dart'
    as _i20;
import 'package:admin9_app_flutter/features/examples/presentation/pages/layout/grid/grid_page.dart'
    as _i16;
import 'package:admin9_app_flutter/features/examples/presentation/pages/reference/icons/icons_page.dart'
    as _i18;
import 'package:admin9_app_flutter/features/home/presentation/pages/home_page.dart'
    as _i17;
import 'package:admin9_app_flutter/features/legal/domain/legal_document.dart'
    as _i40;
import 'package:admin9_app_flutter/features/legal/presentation/pages/legal_document_page.dart'
    as _i21;
import 'package:admin9_app_flutter/features/media/presentation/pages/article_page.dart'
    as _i2;
import 'package:admin9_app_flutter/features/media/presentation/pages/audio_page.dart'
    as _i4;
import 'package:admin9_app_flutter/features/media/presentation/pages/image_viewer_page.dart'
    as _i19;
import 'package:admin9_app_flutter/features/media/presentation/pages/media_page.dart'
    as _i24;
import 'package:admin9_app_flutter/features/media/presentation/pages/video_fullscreen_page.dart'
    as _i34;
import 'package:admin9_app_flutter/features/media/presentation/pages/video_page.dart'
    as _i35;
import 'package:admin9_app_flutter/features/settings/presentation/pages/settings_page.dart'
    as _i29;
import 'package:admin9_app_flutter/shared/ui/media/image_viewer/a_image_viewer_item.dart'
    as _i38;
import 'package:auto_route/auto_route.dart' as _i36;
import 'package:collection/collection.dart' as _i39;
import 'package:flutter/widgets.dart' as _i37;
import 'package:video_player/video_player.dart' as _i43;

/// generated route for
/// [_i1.AppShellPlaygroundPage]
class AppShellPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const AppShellPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(AppShellPlaygroundRoute.name, initialChildren: children);

  static const String name = 'AppShellPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i1.AppShellPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i2.ArticlePage]
class ArticleRoute extends _i36.PageRouteInfo<ArticleRouteArgs> {
  ArticleRoute({
    _i37.Key? key,
    required String scenarioId,
    List<_i36.PageRouteInfo>? children,
  }) : super(
         ArticleRoute.name,
         args: ArticleRouteArgs(key: key, scenarioId: scenarioId),
         initialChildren: children,
       );

  static const String name = 'ArticleRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArticleRouteArgs>();
      return _i2.ArticlePage(key: args.key, scenarioId: args.scenarioId);
    },
  );
}

class ArticleRouteArgs {
  const ArticleRouteArgs({this.key, required this.scenarioId});

  final _i37.Key? key;

  final String scenarioId;

  @override
  String toString() {
    return 'ArticleRouteArgs{key: $key, scenarioId: $scenarioId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArticleRouteArgs) return false;
    return key == other.key && scenarioId == other.scenarioId;
  }

  @override
  int get hashCode => key.hashCode ^ scenarioId.hashCode;
}

/// generated route for
/// [_i3.AsyncStatusPlaygroundPage]
class AsyncStatusPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const AsyncStatusPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(AsyncStatusPlaygroundRoute.name, initialChildren: children);

  static const String name = 'AsyncStatusPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i3.AsyncStatusPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i4.AudioPage]
class AudioRoute extends _i36.PageRouteInfo<AudioRouteArgs> {
  AudioRoute({
    _i37.Key? key,
    required String scenarioId,
    List<_i36.PageRouteInfo>? children,
  }) : super(
         AudioRoute.name,
         args: AudioRouteArgs(key: key, scenarioId: scenarioId),
         initialChildren: children,
       );

  static const String name = 'AudioRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AudioRouteArgs>();
      return _i4.AudioPage(key: args.key, scenarioId: args.scenarioId);
    },
  );
}

class AudioRouteArgs {
  const AudioRouteArgs({this.key, required this.scenarioId});

  final _i37.Key? key;

  final String scenarioId;

  @override
  String toString() {
    return 'AudioRouteArgs{key: $key, scenarioId: $scenarioId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AudioRouteArgs) return false;
    return key == other.key && scenarioId == other.scenarioId;
  }

  @override
  int get hashCode => key.hashCode ^ scenarioId.hashCode;
}

/// generated route for
/// [_i5.ButtonsPlaygroundPage]
class ButtonsPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const ButtonsPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(ButtonsPlaygroundRoute.name, initialChildren: children);

  static const String name = 'ButtonsPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i5.ButtonsPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i6.CalendarPlaygroundPage]
class CalendarPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const CalendarPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(CalendarPlaygroundRoute.name, initialChildren: children);

  static const String name = 'CalendarPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i6.CalendarPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i7.CarouselPage]
class CarouselRoute extends _i36.PageRouteInfo<void> {
  const CarouselRoute({List<_i36.PageRouteInfo>? children})
    : super(CarouselRoute.name, initialChildren: children);

  static const String name = 'CarouselRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i7.CarouselPage();
    },
  );
}

/// generated route for
/// [_i8.ComponentsPage]
class ComponentsRoute extends _i36.PageRouteInfo<void> {
  const ComponentsRoute({List<_i36.PageRouteInfo>? children})
    : super(ComponentsRoute.name, initialChildren: children);

  static const String name = 'ComponentsRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i8.ComponentsPage();
    },
  );
}

/// generated route for
/// [_i9.ConfirmationPlaygroundPage]
class ConfirmationPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const ConfirmationPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(ConfirmationPlaygroundRoute.name, initialChildren: children);

  static const String name = 'ConfirmationPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i9.ConfirmationPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i10.ContentFeedPage]
class ContentFeedRoute extends _i36.PageRouteInfo<void> {
  const ContentFeedRoute({List<_i36.PageRouteInfo>? children})
    : super(ContentFeedRoute.name, initialChildren: children);

  static const String name = 'ContentFeedRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i10.ContentFeedPage();
    },
  );
}

/// generated route for
/// [_i11.ContentPage]
class ContentRoute extends _i36.PageRouteInfo<void> {
  const ContentRoute({List<_i36.PageRouteInfo>? children})
    : super(ContentRoute.name, initialChildren: children);

  static const String name = 'ContentRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i11.ContentPage();
    },
  );
}

/// generated route for
/// [_i12.ContextualFeedbackPlaygroundPage]
class ContextualFeedbackPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const ContextualFeedbackPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(ContextualFeedbackPlaygroundRoute.name, initialChildren: children);

  static const String name = 'ContextualFeedbackPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i12.ContextualFeedbackPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i13.FeedbackPage]
class FeedbackRoute extends _i36.PageRouteInfo<void> {
  const FeedbackRoute({List<_i36.PageRouteInfo>? children})
    : super(FeedbackRoute.name, initialChildren: children);

  static const String name = 'FeedbackRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i13.FeedbackPage();
    },
  );
}

/// generated route for
/// [_i14.FormsPage]
class FormsRoute extends _i36.PageRouteInfo<void> {
  const FormsRoute({List<_i36.PageRouteInfo>? children})
    : super(FormsRoute.name, initialChildren: children);

  static const String name = 'FormsRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i14.FormsPage();
    },
  );
}

/// generated route for
/// [_i15.FoundationPage]
class FoundationRoute extends _i36.PageRouteInfo<void> {
  const FoundationRoute({List<_i36.PageRouteInfo>? children})
    : super(FoundationRoute.name, initialChildren: children);

  static const String name = 'FoundationRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i15.FoundationPage();
    },
  );
}

/// generated route for
/// [_i16.GridPage]
class GridRoute extends _i36.PageRouteInfo<void> {
  const GridRoute({List<_i36.PageRouteInfo>? children})
    : super(GridRoute.name, initialChildren: children);

  static const String name = 'GridRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i16.GridPage();
    },
  );
}

/// generated route for
/// [_i17.HomePage]
class HomeRoute extends _i36.PageRouteInfo<void> {
  const HomeRoute({List<_i36.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i17.HomePage();
    },
  );
}

/// generated route for
/// [_i18.IconsPage]
class IconsRoute extends _i36.PageRouteInfo<void> {
  const IconsRoute({List<_i36.PageRouteInfo>? children})
    : super(IconsRoute.name, initialChildren: children);

  static const String name = 'IconsRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i18.IconsPage();
    },
  );
}

/// generated route for
/// [_i19.ImageViewerPage]
class ImageViewerRoute extends _i36.PageRouteInfo<ImageViewerRouteArgs> {
  ImageViewerRoute({
    _i37.Key? key,
    required List<_i38.AImageViewerItem> items,
    required int initialIndex,
    List<_i36.PageRouteInfo>? children,
  }) : super(
         ImageViewerRoute.name,
         args: ImageViewerRouteArgs(
           key: key,
           items: items,
           initialIndex: initialIndex,
         ),
         initialChildren: children,
       );

  static const String name = 'ImageViewerRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ImageViewerRouteArgs>();
      return _i19.ImageViewerPage(
        key: args.key,
        items: args.items,
        initialIndex: args.initialIndex,
      );
    },
  );
}

class ImageViewerRouteArgs {
  const ImageViewerRouteArgs({
    this.key,
    required this.items,
    required this.initialIndex,
  });

  final _i37.Key? key;

  final List<_i38.AImageViewerItem> items;

  final int initialIndex;

  @override
  String toString() {
    return 'ImageViewerRouteArgs{key: $key, items: $items, initialIndex: $initialIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ImageViewerRouteArgs) return false;
    return key == other.key &&
        const _i39.ListEquality<_i38.AImageViewerItem>().equals(
          items,
          other.items,
        ) &&
        initialIndex == other.initialIndex;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i39.ListEquality<_i38.AImageViewerItem>().hash(items) ^
      initialIndex.hashCode;
}

/// generated route for
/// [_i20.InteractionPlaygroundPage]
class InteractionPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const InteractionPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(InteractionPlaygroundRoute.name, initialChildren: children);

  static const String name = 'InteractionPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i20.InteractionPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i21.LegalDocumentPage]
class LegalDocumentRoute extends _i36.PageRouteInfo<LegalDocumentRouteArgs> {
  LegalDocumentRoute({
    _i37.Key? key,
    required _i40.LegalDocument document,
    List<_i36.PageRouteInfo>? children,
  }) : super(
         LegalDocumentRoute.name,
         args: LegalDocumentRouteArgs(key: key, document: document),
         initialChildren: children,
       );

  static const String name = 'LegalDocumentRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LegalDocumentRouteArgs>();
      return _i21.LegalDocumentPage(key: args.key, document: args.document);
    },
  );
}

class LegalDocumentRouteArgs {
  const LegalDocumentRouteArgs({this.key, required this.document});

  final _i37.Key? key;

  final _i40.LegalDocument document;

  @override
  String toString() {
    return 'LegalDocumentRouteArgs{key: $key, document: $document}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LegalDocumentRouteArgs) return false;
    return key == other.key && document == other.document;
  }

  @override
  int get hashCode => key.hashCode ^ document.hashCode;
}

/// generated route for
/// [_i22.ListsPlaygroundPage]
class ListsPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const ListsPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(ListsPlaygroundRoute.name, initialChildren: children);

  static const String name = 'ListsPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i22.ListsPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i23.MainShellPage]
class MainShellRoute extends _i36.PageRouteInfo<MainShellRouteArgs> {
  MainShellRoute({
    _i37.Key? key,
    _i41.MainDestination initialDestination = _i41.MainDestination.home,
    List<_i36.PageRouteInfo>? children,
  }) : super(
         MainShellRoute.name,
         args: MainShellRouteArgs(
           key: key,
           initialDestination: initialDestination,
         ),
         initialChildren: children,
       );

  static const String name = 'MainShellRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MainShellRouteArgs>(
        orElse: () => const MainShellRouteArgs(),
      );
      return _i23.MainShellPage(
        key: args.key,
        initialDestination: args.initialDestination,
      );
    },
  );
}

class MainShellRouteArgs {
  const MainShellRouteArgs({
    this.key,
    this.initialDestination = _i41.MainDestination.home,
  });

  final _i37.Key? key;

  final _i41.MainDestination initialDestination;

  @override
  String toString() {
    return 'MainShellRouteArgs{key: $key, initialDestination: $initialDestination}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MainShellRouteArgs) return false;
    return key == other.key && initialDestination == other.initialDestination;
  }

  @override
  int get hashCode => key.hashCode ^ initialDestination.hashCode;
}

/// generated route for
/// [_i24.MediaPage]
class MediaRoute extends _i36.PageRouteInfo<void> {
  const MediaRoute({List<_i36.PageRouteInfo>? children})
    : super(MediaRoute.name, initialChildren: children);

  static const String name = 'MediaRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i24.MediaPage();
    },
  );
}

/// generated route for
/// [_i25.OverviewPlaygroundPage]
class OverviewPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const OverviewPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(OverviewPlaygroundRoute.name, initialChildren: children);

  static const String name = 'OverviewPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i25.OverviewPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i26.SchedulingPlaygroundPage]
class SchedulingPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const SchedulingPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(SchedulingPlaygroundRoute.name, initialChildren: children);

  static const String name = 'SchedulingPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i26.SchedulingPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i27.SelectionControlsPlaygroundPage]
class SelectionControlsPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const SelectionControlsPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(SelectionControlsPlaygroundRoute.name, initialChildren: children);

  static const String name = 'SelectionControlsPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i27.SelectionControlsPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i28.SelectsPlaygroundPage]
class SelectsPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const SelectsPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(SelectsPlaygroundRoute.name, initialChildren: children);

  static const String name = 'SelectsPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i28.SelectsPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i29.SettingsPage]
class SettingsRoute extends _i36.PageRouteInfo<void> {
  const SettingsRoute({List<_i36.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i29.SettingsPage();
    },
  );
}

/// generated route for
/// [_i30.StartupGatePage]
class StartupGateRoute extends _i36.PageRouteInfo<StartupGateRouteArgs> {
  StartupGateRoute({
    _i37.Key? key,
    _i42.LaunchReason launchReason = _i42.LaunchReason.icon,
    String? initialPath,
    bool reviewPrivacy = false,
    List<_i36.PageRouteInfo>? children,
  }) : super(
         StartupGateRoute.name,
         args: StartupGateRouteArgs(
           key: key,
           launchReason: launchReason,
           initialPath: initialPath,
           reviewPrivacy: reviewPrivacy,
         ),
         initialChildren: children,
       );

  static const String name = 'StartupGateRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StartupGateRouteArgs>(
        orElse: () => const StartupGateRouteArgs(),
      );
      return _i30.StartupGatePage(
        key: args.key,
        launchReason: args.launchReason,
        initialPath: args.initialPath,
        reviewPrivacy: args.reviewPrivacy,
      );
    },
  );
}

class StartupGateRouteArgs {
  const StartupGateRouteArgs({
    this.key,
    this.launchReason = _i42.LaunchReason.icon,
    this.initialPath,
    this.reviewPrivacy = false,
  });

  final _i37.Key? key;

  final _i42.LaunchReason launchReason;

  final String? initialPath;

  final bool reviewPrivacy;

  @override
  String toString() {
    return 'StartupGateRouteArgs{key: $key, launchReason: $launchReason, initialPath: $initialPath, reviewPrivacy: $reviewPrivacy}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StartupGateRouteArgs) return false;
    return key == other.key &&
        launchReason == other.launchReason &&
        initialPath == other.initialPath &&
        reviewPrivacy == other.reviewPrivacy;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      launchReason.hashCode ^
      initialPath.hashCode ^
      reviewPrivacy.hashCode;
}

/// generated route for
/// [_i31.TextInputPlaygroundPage]
class TextInputPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const TextInputPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(TextInputPlaygroundRoute.name, initialChildren: children);

  static const String name = 'TextInputPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i31.TextInputPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i32.ThemesPage]
class ThemesRoute extends _i36.PageRouteInfo<void> {
  const ThemesRoute({List<_i36.PageRouteInfo>? children})
    : super(ThemesRoute.name, initialChildren: children);

  static const String name = 'ThemesRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i32.ThemesPage();
    },
  );
}

/// generated route for
/// [_i33.ValueControlsPlaygroundPage]
class ValueControlsPlaygroundRoute extends _i36.PageRouteInfo<void> {
  const ValueControlsPlaygroundRoute({List<_i36.PageRouteInfo>? children})
    : super(ValueControlsPlaygroundRoute.name, initialChildren: children);

  static const String name = 'ValueControlsPlaygroundRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      return const _i33.ValueControlsPlaygroundPage();
    },
  );
}

/// generated route for
/// [_i34.VideoFullscreenPage]
class VideoFullscreenRoute
    extends _i36.PageRouteInfo<VideoFullscreenRouteArgs> {
  VideoFullscreenRoute({
    _i37.Key? key,
    required _i43.VideoPlayerController controller,
    required String title,
    List<_i36.PageRouteInfo>? children,
  }) : super(
         VideoFullscreenRoute.name,
         args: VideoFullscreenRouteArgs(
           key: key,
           controller: controller,
           title: title,
         ),
         initialChildren: children,
       );

  static const String name = 'VideoFullscreenRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VideoFullscreenRouteArgs>();
      return _i34.VideoFullscreenPage(
        key: args.key,
        controller: args.controller,
        title: args.title,
      );
    },
  );
}

class VideoFullscreenRouteArgs {
  const VideoFullscreenRouteArgs({
    this.key,
    required this.controller,
    required this.title,
  });

  final _i37.Key? key;

  final _i43.VideoPlayerController controller;

  final String title;

  @override
  String toString() {
    return 'VideoFullscreenRouteArgs{key: $key, controller: $controller, title: $title}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VideoFullscreenRouteArgs) return false;
    return key == other.key &&
        controller == other.controller &&
        title == other.title;
  }

  @override
  int get hashCode => key.hashCode ^ controller.hashCode ^ title.hashCode;
}

/// generated route for
/// [_i35.VideoPage]
class VideoRoute extends _i36.PageRouteInfo<VideoRouteArgs> {
  VideoRoute({
    _i37.Key? key,
    required String scenarioId,
    List<_i36.PageRouteInfo>? children,
  }) : super(
         VideoRoute.name,
         args: VideoRouteArgs(key: key, scenarioId: scenarioId),
         initialChildren: children,
       );

  static const String name = 'VideoRoute';

  static _i36.PageInfo page = _i36.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VideoRouteArgs>();
      return _i35.VideoPage(key: args.key, scenarioId: args.scenarioId);
    },
  );
}

class VideoRouteArgs {
  const VideoRouteArgs({this.key, required this.scenarioId});

  final _i37.Key? key;

  final String scenarioId;

  @override
  String toString() {
    return 'VideoRouteArgs{key: $key, scenarioId: $scenarioId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VideoRouteArgs) return false;
    return key == other.key && scenarioId == other.scenarioId;
  }

  @override
  int get hashCode => key.hashCode ^ scenarioId.hashCode;
}
