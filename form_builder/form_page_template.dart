import 'package:flutter/material.dart';

import '../entity_adapter.dart';
import '../ui/_theme.dart';
import 'fn_form_field.dart';
import 'form_fields.dart';

// FormPageTemplate is a Scaffold wrapper around FormFieldsBuilderPage.
// All form state, DTO building, and validation lives in FormFieldsBuilderPage.
// Do not duplicate buildDto() or _formKey here.
class FormPageTemplate extends StatelessWidget {
  final Entity? entity;
  final List<FNFormField> formFields;
  final String? ctaLabel;
  final Widget? ctaIcon;
  final Function(Map<String, dynamic>) onSubmit;

  const FormPageTemplate({
    super.key,
    this.entity,
    this.ctaLabel,
    this.ctaIcon,
    required this.formFields,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entity != null ? 'Editing' : 'Register'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FormFieldsBuilderPage(
        entity: entity,
        formFields: formFields,
        ctaLabel: ctaLabel,
        ctaIcon: ctaIcon,
        onSubmit: onSubmit,
      ),
    );
  }
}
