import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';

IconData resolveAppIcon(AppIconRole role, TargetPlatform platform) {
  return switch (role) {
    AppIconRole.back => Icons.arrow_back,
    AppIconRole.close => Icons.close,
    AppIconRole.chevronForward => Icons.chevron_right,
    AppIconRole.home => Icons.home_outlined,
    AppIconRole.homeSelected => Icons.home,
    AppIconRole.account => Icons.person_outline,
    AppIconRole.accountSelected => Icons.person,
    AppIconRole.settings => Icons.settings_outlined,
    AppIconRole.search => Icons.search,
    AppIconRole.info => Icons.info_outline,
    AppIconRole.warning => Icons.warning_amber_outlined,
    AppIconRole.success => Icons.check_circle_outline,
    AppIconRole.error => Icons.error_outline,
    AppIconRole.visibility => Icons.visibility,
    AppIconRole.visibilityOff => Icons.visibility_off,
    AppIconRole.more => Icons.more_horiz,
  };
}
