// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';

import 'form_validators.dart';

enum FieldType {
  text,
  email,
  number,
  password,
  select,
  radio,
  picture,
  addressLookup,
}

class FNFormField with FormValidators {
  final String attribute;
  final String label;
  final FieldType type;
  final String hint;
  final String? conditionedBy;
  final String? conditionValue;
  final String suffix;
  final bool required;
  final List<FieldSelectValues> values;
  final TextInputAction? textInputAction;
  String? value;

  FNFormField({
    required this.attribute,
    required this.label,
    required this.type,
    required this.hint,
    required this.required,
    required this.suffix,
    this.conditionedBy,
    this.conditionValue,
    this.values = const [],
    this.textInputAction,
    this.value,
  });

  String? validate(String? value) {
    return switch (type) {
      FieldType.text => textValidate(value ?? ''),
      FieldType.email => emailValidate(value ?? ''),
      FieldType.select => selectValidate(value ?? ''),
      FieldType.number => numberValidate(value ?? ''),
      FieldType.picture => pictureValidate(value ?? ''),
      FieldType.radio => radioValidate(value ?? ''),
      FieldType.addressLookup => addressValidate(value ?? ''),
      FieldType.password => textValidate(value ?? ''),
    };
  }

  @override
  String toString() =>
      "FNFormField(attribute: $attribute, label: $label, type: $type, required: $required, value: $value, hint: $hint, conditionedBy: $conditionedBy, conditionValue: $conditionValue, values: $values)";
}

class FieldSelectValues {
  final String label;
  final String image;
  final String value;

  FieldSelectValues({
    required this.label,
    required this.image,
    required this.value,
  });

  @override
  String toString() =>
      "FieldSelectValues(label: $label, image: $image, value: $value)";
}
