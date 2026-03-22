import 'package:flutter/material.dart';

import 'fn_form_field.dart';
import 'form_field_widget.dart';
import 'radio_input_field.dart';
import 'remove_focus_on_tap.dart';
import 'select_value_widget.dart';

class FnFormBuilder extends StatefulWidget {
  final List<FNFormField> fields;
  final Map<String, dynamic> dto;

  const FnFormBuilder({
    super.key,
    required this.fields,
    required this.dto,
  });

  @override
  State<FnFormBuilder> createState() => _FnFormBuilderState();
}

class _FnFormBuilderState extends State<FnFormBuilder> {
  @override
  Widget build(BuildContext context) {
    return RemoveFocusOnTap(
      child: Column(
        spacing: 20,
        children: [
          ...widget.fields.map((field) => _wrap(field, _buildField(field))),
        ],
      ),
    );
  }

  Widget _buildField(FNFormField field) {
    return switch (field.type) {
      FieldType.text => FormFieldInput(
        field: field,
        keyboardType: TextInputType.text,
        textInputAction: field.textInputAction,
        onChanged: (value) => widget.dto[field.attribute] = value,
      ),
      FieldType.password => FormFieldInput(
        field: field,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: field.textInputAction,
        onChanged: (value) => widget.dto[field.attribute] = value,
      ),
      FieldType.email => FormFieldInput(
        field: field,
        keyboardType: TextInputType.emailAddress,
        textInputAction: field.textInputAction,
        onChanged: (value) => widget.dto[field.attribute] = value,
      ),
      FieldType.number => FormFieldInput(
        field: field,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        textInputAction: field.textInputAction,
        onChanged: (value) => widget.dto[field.attribute] = value,
      ),
      FieldType.select => SelectValue(
        field: field,
        onDone: (selected) {
          widget.dto[field.attribute] = selected.value;
          setState(() {});
        },
      ),
      FieldType.radio => RadioInputField(
        field: field,
        onDone: (value) {
          widget.dto[field.attribute] = value;
          setState(() {});
        },
      ),
      FieldType.addressLookup => const SizedBox(), // placeholder — implement when needed
      FieldType.picture => const SizedBox(), // placeholder — implement when needed
    };
  }

  /// Conditionally show/hide a field based on the value of another field.
  /// [field.conditionedBy] — attribute name of the controlling field.
  /// [field.conditionValue] — value that makes this field visible.
  /// If conditionedBy is null, the field is always visible.
  Widget _wrap(FNFormField field, Widget child) {
    if (field.conditionedBy == null) return child;

    final isVisible = widget.dto[field.conditionedBy] == field.conditionValue;

    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeIn,
      child: Visibility(
        visible: isVisible,
        child: child,
      ),
    );
  }
}
