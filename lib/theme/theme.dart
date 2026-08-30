import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_style.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

part 'colors.dart';
part 'typography.dart';
part 'style.dart';
part 'icons.dart';

const smallAppBorderRadius = FBorderRadius(
  xs2: .all(.circular(3)),
  xs: .all(.circular(4)),
  sm: .all(.circular(6)),
  md: .all(.circular(7)),
  lg: .all(.circular(10)),
  xl: .all(.circular(13)),
  xl2: .all(.circular(16)),
  xl3: .all(.circular(19)),
);

const mediumAppBorderRadius = FBorderRadius();

const largeAppBorderRadius = FBorderRadius(
  xs2: .all(.circular(6)),
  xs: .all(.circular(8)),
  sm: .all(.circular(11)),
  md: .all(.circular(14)),
  lg: .all(.circular(20)),
  xl: .all(.circular(25)),
  xl2: .all(.circular(31)),
  xl3: .all(.circular(36)),
);

FThemeData buildForuiTheme({
  required FColors colors,
  required FBorderRadius borderRadius,
}) {
  const touch = true;
  final typography = _typography(colors: colors, touch: touch);
  final icons = _icons();
  final style = _style(
    colors: colors,
    typography: typography,
    touch: touch,
    borderRadius: borderRadius,
  );
  return FThemeData(
    colors: colors,
    typography: typography,
    icons: icons,
    style: style,
    touch: touch,
  );
}

final lightTheme = buildForuiTheme(
  colors: neutralLightColors,
  borderRadius: mediumAppBorderRadius,
);

final darkTheme = buildForuiTheme(
  colors: neutralDarkColors,
  borderRadius: mediumAppBorderRadius,
);
