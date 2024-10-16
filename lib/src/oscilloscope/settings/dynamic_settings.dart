import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputType { text, number }

class DynamicSetting {
  String label;
  String? unit;
  dynamic value;
  Function(dynamic) onSave;
  InputType inputType;
  int? decimalPlaces;
  List<TextInputFormatter>? inputFormatters;
  String? Function(String)? validator;
  Widget Function(BuildContext context, TextEditingController controller, FocusNode focusNode, Function(String) onSubmitted)? widgetBuilder;
  bool allowNegativeNumbers;

  DynamicSetting({
    required this.label,
    this.unit,
    required this.value,
    required this.onSave,
    this.inputType = InputType.number,
    this.decimalPlaces,
    this.inputFormatters,
    this.validator,
    this.widgetBuilder,
    this.allowNegativeNumbers = false,
  });
}
