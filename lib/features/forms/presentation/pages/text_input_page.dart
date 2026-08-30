import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class TextInputPage extends StatefulWidget {
  const TextInputPage({super.key});

  @override
  State<TextInputPage> createState() => _TextInputPageState();
}

class _TextInputPageState extends State<TextInputPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('forms.text_input.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'forms.text_input.text_field'.tr(),
          child: FTextField(
            label: Text('forms.text_input.name_label'.tr()),
            hint: 'forms.text_input.name_hint'.tr(),
            description: Text('forms.text_input.name_description'.tr()),
            clearable: (value) => value.text.isNotEmpty,
            textInputAction: TextInputAction.next,
          ),
        ),
        ComponentExampleSection(
          title: 'forms.text_input.form_field'.tr(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                FTextFormField(
                  label: Text('forms.text_input.required_label'.tr()),
                  hint: 'forms.text_input.required_hint'.tr(),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'forms.text_input.required_error'.tr()
                      : null,
                ),
                FButton(
                  onPress: () => _formKey.currentState?.validate(),
                  child: Text('forms.text_input.validate'.tr()),
                ),
              ],
            ),
          ),
        ),
        ComponentExampleSection(
          title: 'forms.text_input.autocomplete'.tr(),
          child: FAutocomplete.text(
            label: Text('forms.text_input.city_label'.tr()),
            hint: 'forms.text_input.city_hint'.tr(),
            items: [
              'forms.text_input.city_chengdu'.tr(),
              'forms.text_input.city_shanghai'.tr(),
              'forms.text_input.city_shenzhen'.tr(),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'forms.text_input.otp'.tr(),
          child: FOtpField(
            label: Text('forms.text_input.otp_label'.tr()),
            description: Text('forms.text_input.otp_description'.tr()),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    ),
  );
}
