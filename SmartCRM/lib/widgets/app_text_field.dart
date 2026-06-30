import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool numeric;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType ??
          (isMultiline ? TextInputType.multiline : TextInputType.text),
      textInputAction:
          isMultiline ? TextInputAction.newline : TextInputAction.next,
      textCapitalization:
          numeric ? TextCapitalization.none : TextCapitalization.sentences,
      enableSuggestions: !numeric,
      autocorrect: !numeric,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null
          : null,
    );
  }
}
