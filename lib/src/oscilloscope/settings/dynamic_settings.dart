import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputType { text, number }

class DynamicSetting {
  String label;
  String unit;
  dynamic value;
  Function(dynamic) onSave;
  InputType inputType; // Whether it's a text or number input
  int? decimalPlaces;  // Number of decimal places allowed for number input
  List<TextInputFormatter>? inputFormatters;
  String? Function(String)? validator;
  Widget Function(BuildContext context, TextEditingController controller, FocusNode focusNode, Function(String) onSubmitted)? widgetBuilder;

  DynamicSetting({
    required this.label,
    required this.unit,
    required this.value,
    required this.onSave,
    this.inputType = InputType.number,  // Default to number input
    this.decimalPlaces,                 // Optional: control decimal places for number input
    this.inputFormatters,
    this.validator,
    this.widgetBuilder,
  });
}
