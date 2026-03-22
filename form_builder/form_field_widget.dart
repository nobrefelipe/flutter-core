import 'package:flutter/material.dart';

import '../ui/_theme.dart';
import 'fn_form_field.dart';

class FormFieldInput extends StatefulWidget {
  final FNFormField field;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String value)? onChanged;

  const FormFieldInput({
    super.key,
    required this.field,
    this.enabled = true,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  State<FormFieldInput> createState() => _FormFieldInputState();
}

class _FormFieldInputState extends State<FormFieldInput> {
  late FocusNode focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Controller initialised with field value — do NOT also pass initialValue
    // to TextFormField as Flutter forbids using both simultaneously.
    _controller = TextEditingController(text: widget.field.value ?? '');
    focusNode = FocusNode()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = focusNode.hasFocus
        ? Theme.of(context).primaryColor
        : _controller.text.isEmpty
        ? Theme.of(context).onSurfaceColor
        : Colors.black45;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(100, 100, 100, 0.07),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: TextFormField(
        controller: _controller,
        focusNode: focusNode,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        enabled: widget.enabled,
        obscureText: widget.keyboardType == TextInputType.visiblePassword,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          widget.onChanged?.call(value);
          // Trigger label colour rebuild when text changes
          setState(() {});
        },
        onTapOutside: (_) => focusNode.unfocus(),
        validator: widget.field.required ? widget.field.validate : null,
        textInputAction: widget.textInputAction ?? TextInputAction.done,
        onEditingComplete: () => focusNode.nextFocus(),
        decoration: InputDecoration(
          suffixIcon: _suffixIcon(widget.field.suffix),
          filled: true,
          fillColor: Colors.white,
          hintText: widget.field.hint,
          hintStyle: const TextStyle(color: Colors.black26),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          labelText: widget.field.label,
          labelStyle: TextStyle(color: labelColor),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}

// Fixed: was missing `return null` so always returned the container even for empty suffix
Widget? _suffixIcon(String suffix) {
  if (suffix.isEmpty) return null;
  return Container(
    margin: const EdgeInsets.only(top: 13, right: 10),
    child: Text(suffix, textAlign: TextAlign.center),
  );
}
