import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputType { text, number }

class DynamicSetting {
  String? label;
  String? unit;
  dynamic value;
  Function(dynamic)? onSave;
  InputType inputType;
  int? decimalPlaces;
  List<TextInputFormatter>? inputFormatters;
  String? Function(String)? validator;
  Widget Function(BuildContext context, TextEditingController controller, FocusNode focusNode, Function(dynamic) onSubmitted)? widgetBuilder;
  bool allowNegativeNumbers;
  int order;

  DynamicSetting({
    this.label,
    this.unit,
    this.value,
    this.onSave,
    this.inputType = InputType.number,
    this.decimalPlaces,
    this.inputFormatters,
    this.validator,
    this.widgetBuilder,
    this.allowNegativeNumbers = false,
    this.order = 0
  })  : assert(widgetBuilder != null || (label != null && value != null && onSave != null),
  'If widgetBuilder is not provided, label, value, and onSave must not be null');
}

