import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';

IconData resolveAppIcon(AppIconRole role, TargetPlatform platform) {
  final ios = platform == TargetPlatform.iOS;
  return switch (role) {
    AppIconRole.back => ios ? CupertinoIcons.back : Icons.arrow_back,
    AppIconRole.close => ios ? CupertinoIcons.clear : Icons.close,
    AppIconRole.chevronForward =>
      ios ? CupertinoIcons.chevron_forward : Icons.chevron_right,
    AppIconRole.home => ios ? CupertinoIcons.house : Icons.home_outlined,
    AppIconRole.homeSelected => ios ? CupertinoIcons.house_fill : Icons.home,
    AppIconRole.account => ios ? CupertinoIcons.person : Icons.person_outline,
    AppIconRole.accountSelected =>
      ios ? CupertinoIcons.person_fill : Icons.person,
    AppIconRole.settings => ios ? CupertinoIcons.gear : Icons.settings_outlined,
    AppIconRole.search => ios ? CupertinoIcons.search : Icons.search,
    AppIconRole.info => ios ? CupertinoIcons.info : Icons.info_outline,
    AppIconRole.warning =>
      ios
          ? CupertinoIcons.exclamationmark_triangle
          : Icons.warning_amber_outlined,
    AppIconRole.success =>
      ios ? CupertinoIcons.check_mark_circled : Icons.check_circle_outline,
    AppIconRole.error =>
      ios ? CupertinoIcons.exclamationmark_circle : Icons.error_outline,
    AppIconRole.visibility => ios ? CupertinoIcons.eye : Icons.visibility,
    AppIconRole.visibilityOff =>
      ios ? CupertinoIcons.eye_slash : Icons.visibility_off,
    AppIconRole.more => ios ? CupertinoIcons.ellipsis : Icons.more_horiz,
  };
}
