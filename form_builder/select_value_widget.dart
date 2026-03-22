import 'package:flutter/material.dart';
import '../extensions.dart';

import '../ui/hero_dialog/popup_card_tile.dart';
import 'fn_form_field.dart';

class SelectValue extends FormField<String> {
  final FNFormField field;
  final void Function(FieldSelectValues value) onDone;

  SelectValue({
    required this.field,
    required this.onDone,
  }) : super(
         validator: field.required ? field.validate : null,
         builder: (FormFieldState<String> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Container(
                 width: double.infinity,
                 decoration: BoxDecoration(
                   border: Border.all(
                     color: (state.hasError && state.errorText != null) ? Colors.red : Colors.transparent,
                   ),
                   borderRadius: BorderRadius.circular(13),
                 ),
                 child: PopupCardTile(
                   id: field.label.replaceAll(' ', ''),
                   cardTitle: "${field.label}${field.required ? '*' : ''}",
                   cardSubtitle: field.hint,
                   child: SizedBox(
                     height: 300,
                     child: ListView.separated(
                       physics: const ClampingScrollPhysics(),
                       padding: EdgeInsets.zero,
                       itemCount: field.values.length,
                       itemBuilder: (BuildContext context, int index) {
                         return Container(
                           height: 65,
                           alignment: Alignment.centerLeft,
                           child: Row(
                             children: [
                               if (field.values[index].image.isNotEmpty)
                                 FadeInImage.assetNetwork(
                                   image: field.values[index].image,
                                   placeholder: 'resources/images/placeholder.png',
                                   fit: BoxFit.cover,
                                   placeholderFit: BoxFit.contain,
                                   imageErrorBuilder: (_, __, ___) {
                                     return Image.asset(
                                       'resources/images/placeholder.png',
                                       fit: BoxFit.cover,
                                     );
                                   },
                                 ),
                               const SizedBox(width: 10),
                               Text(field.values[index].label),
                             ],
                           ),
                         ).onTap(() {
                           final selected = field.values[index];
                           Navigator.of(context).pop(selected.label);
                           onDone(selected);
                           state.setValue(selected.label);
                           state.validate();
                         });
                       },
                       separatorBuilder: (_, __) => Container(
                         height: 1,
                         color: Colors.black26,
                       ),
                     ),
                   ),
                 ),
               ),
               if (state.hasError && state.errorText != null)
                 Padding(
                   padding: const EdgeInsets.only(top: 6, left: 20),
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
