import 'package:flutter/material.dart';
import '../extensions.dart';

import 'fn_form_field.dart';

class RadioInputField extends FormField<String> {
  final FNFormField field;
  final void Function(String value) onDone;

  RadioInputField({
    required this.field,
    required this.onDone,
  }) : super(
         validator: field.required ? field.validate : null,
         builder: (FormFieldState<String> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text("${field.label}${field.required ? '*' : ''}"),
               const SizedBox(height: 5),
               Wrap(
                 children: [
                   ...field.values.map((option) {
                     return Row(
                       children: [
                         Expanded(
                           child: RadioListTile<String>(
                             title: Text(option.label),
                             groupValue: field.value,
                             value: option.value,
                             activeColor: Colors.pink,
                             contentPadding: EdgeInsets.zero,
                             onChanged: (String? value) {
                               if (value == null) return;
                               field.value = value;
                               onDone(value);
                               state.setValue(value);
                               state.validate();
                             },
                           ),
                         ),
                       ],
                     );
                   }),
                 ],
               ),
               if (state.hasError && state.errorText != null)
                 Padding(
                   padding: const EdgeInsets.only(top: 6),
                   child: Text(
                     state.errorText!,
                     textAlign: TextAlign.left,
                   ),
                 ),
             ],
           ).marginOnly(bottom: 30);
         },
       );
}
