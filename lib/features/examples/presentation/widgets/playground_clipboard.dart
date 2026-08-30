import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

Future<bool> copyPlaygroundText(
  BuildContext context, {
  required String text,
  required String title,
  required String description,
}) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
  } on Object {
    if (context.mounted) {
      showFToast(
        context: context,
        alignment: .bottomCenter,
        variant: .destructive,
        icon: const Icon(FLucideIcons.copyX),
        title: Text('examples.playground.copy_failed_title'.tr()),
        description: Text('examples.playground.copy_failed_description'.tr()),
      );
    }
    return false;
  }

  if (!context.mounted) return true;

  showFToast(
    context: context,
    alignment: .bottomCenter,
    icon: const Icon(FLucideIcons.copyCheck),
    title: Text(title),
    description: Text(description),
  );
  return true;
}
