import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class ButtonsLabelsPage extends StatefulWidget {
  const ButtonsLabelsPage({super.key});

  @override
  State<ButtonsLabelsPage> createState() => _ButtonsLabelsPageState();
}

class _ButtonsLabelsPageState extends State<ButtonsLabelsPage> {
  int _pressCount = 0;

  void _recordPress() => setState(() => _pressCount++);

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('forms.buttons_labels.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'forms.buttons_labels.variants'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FButton(
                    mainAxisSize: MainAxisSize.min,
                    onPress: _recordPress,
                    child: Text('forms.buttons_labels.primary'.tr()),
                  ),
                  FButton(
                    mainAxisSize: MainAxisSize.min,
                    variant: .secondary,
                    onPress: _recordPress,
                    child: Text('forms.buttons_labels.secondary'.tr()),
                  ),
                  FButton(
                    mainAxisSize: MainAxisSize.min,
                    variant: .outline,
                    onPress: _recordPress,
                    child: Text('forms.buttons_labels.outline'.tr()),
                  ),
                  FButton(
                    mainAxisSize: MainAxisSize.min,
                    variant: .ghost,
                    onPress: _recordPress,
                    child: Text('forms.buttons_labels.ghost'.tr()),
                  ),
                  FButton(
                    mainAxisSize: MainAxisSize.min,
                    variant: .destructive,
                    onPress: _recordPress,
                    child: Text('forms.buttons_labels.destructive'.tr()),
                  ),
                ],
              ),
              Text(
                'forms.buttons_labels.press_count'.tr(
                  namedArgs: {'count': '$_pressCount'},
                ),
              ),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'forms.buttons_labels.states'.tr(),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: FButton(
                  onPress: null,
                  child: Text('forms.buttons_labels.disabled'.tr()),
                ),
              ),
              FButton.icon(
                semanticsLabel: 'forms.buttons_labels.icon_button'.tr(),
                onPress: _recordPress,
                child: context.theme.icons.check(context),
              ),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'forms.buttons_labels.label'.tr(),
          child: FLabel(
            layout: .vertical,
            label: Text('forms.buttons_labels.label_title'.tr()),
            description: Text('forms.buttons_labels.label_description'.tr()),
            child: FButton(
              variant: .outline,
              onPress: _recordPress,
              child: Text('forms.buttons_labels.label_action'.tr()),
            ),
          ),
        ),
      ],
    ),
  );
}
