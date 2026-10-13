import 'package:admin9_ui/admin9_ui.dart';
import 'package:forui/forui.dart';

FThemeData gridTheme(FThemeData base) => FThemeData(
  touch: true,
  colors: base.colors,
  typography: base.typography,
  icons: base.icons,
  style: base.style.copyWith(
    extensions: {
      ...base.style.extensions,
      AGridStyle.inherit(
        colors: base.colors,
        typography: base.typography,
        borderRadius: base.style.borderRadius,
        focusedOutlineStyle: base.style.focusedOutlineStyle,
      ),
    },
  ),
);
final lightTheme = gridTheme(FTheme.neutral.light.touch);
final darkTheme = gridTheme(FTheme.neutral.dark.touch);
