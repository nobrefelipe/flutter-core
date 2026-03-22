// ignore_for_file: type_annotate_public_apis, avoid_dynamic_calls

import 'package:flutter/material.dart';
import '../entity_adapter.dart';
import '../extensions.dart';

import '../helpers.dart';
import 'fn_form_field.dart';

class FormFieldAdapter with EntityAdapter<FNFormField> {
  @override
  FNFormField fromJson(json) {
    return FNFormField(
      attribute: Helper.getString(json["attribute"]),
      label: Helper.getString(json["label"]),
      required: Helper.getBool(json["required"]),
      hint: Helper.getString(json["hint"]),
      type: _parseType(json["type"]),
      suffix: Helper.getString(json["suffix"]),
      value: Helper.getString(json["value"]),
      conditionedBy: Helper.getStringOrNull(json["conditionedBy"]),
      conditionValue: Helper.getStringOrNull(json["conditionValue"]),
      textInputAction: TextInputAction.values.firstWhereOrNull(
        (e) => e.name == Helper.getString(json["textInputAction"]),
      ),
      values: _parseValues(json['values']),
    );
  }

  /// Parses a string into a FieldType enum.
  /// Handles snake_case → camelCase for address_lookup → addressLookup.
  /// Falls back to FieldType.text so unknown types are always visible.
  static FieldType _parseType(dynamic value) {
    final raw = Helper.getString(value);

    // Handle snake_case variants
    final normalised = switch (raw) {
      'address_lookup' => 'addressLookup',
      _ => raw,
    };

    return FieldType.values.firstWhereOrNull(
          (e) => e.name == normalised,
        ) ??
        FieldType.text; // fallback — unknown types render as plain text input
    // To debug: if a field looks wrong, check its 'type' string matches a FieldType name
  }

  @override
  List<FNFormField> fromJsonToList(json) {
    if (json == null || json is! List) return [];
    return json.map((item) => fromJson(item)).toList();
  }

  List<FieldSelectValues> _parseValues(json) {
    if (json == null || json is! List) return [];
    return json
        .map(
          (item) => FieldSelectValues(
            image: Helper.getString(item['image']),
            label: Helper.getString(item['label']),
            value: Helper.getString(item['value']),
          ),
        )
        .toList();
  }

  @override
  Map<String, dynamic> toMap(FNFormField value) => {};
}
