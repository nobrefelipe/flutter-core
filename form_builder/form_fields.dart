import 'package:flutter/material.dart';

import '../entity_adapter.dart';
import '../extensions.dart';
import '../ui/buttons/ui_kit_button.dart';
import '../ui/notifications/snackbar/snackbar.dart';
import 'fn_form_field.dart';
import 'fn_form_builder.dart';

class FormFieldsBuilderPage extends StatefulWidget {
  final Entity? entity;
  final List<FNFormField> formFields;
  final Function(Map<String, dynamic>) onSubmit;
  final String? ctaLabel;
  final Widget? ctaIcon;

  const FormFieldsBuilderPage({
    super.key,
    this.entity,
    this.ctaLabel,
    this.ctaIcon,
    required this.formFields,
    required this.onSubmit,
  });

  @override
  State<FormFieldsBuilderPage> createState() => _FormFieldsBuilderPageState();
}

class _FormFieldsBuilderPageState extends State<FormFieldsBuilderPage> {
  final _formKey = GlobalKey<FormState>();
  final dto = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _buildDto();
  }

  void _buildDto() {
    for (final field in widget.formFields) {
      String? value = widget.entity?.getAttribute(field.attribute);
      value = value != null && value.isNotEmpty ? value : field.value;
      dto.putIfAbsent(field.attribute, () => value ?? '');
      field.value = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: FnFormBuilder(
            fields: widget.formFields,
            dto: dto,
          ),
        ),
        const SizedBox(height: 40),
        UIKButton.primary(
          label: widget.ctaLabel ?? 'Submit',
          rightIcon: widget.ctaIcon,
          onTap: () async {
            if (!_formKey.currentState!.validate()) {
              UIKShowSnackBar(
                context,
                message: 'Please fill all required fields',
                type: UIKSnackBarType.error,
              );
              return;
            }
            await widget.onSubmit(dto);
          },
        ),
      ],
    ).paddingOnly(top: 20, bottom: 0);
  }
}
