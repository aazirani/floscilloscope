import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int? decimalRange;

  DecimalTextInputFormatter({this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final newText = newValue.text;

    // Allow only numbers and one decimal point
    if (newText == '.') {
      return oldValue;
    }

    // If decimalRange is not set (null), allow any number of decimals
    if (decimalRange == null) {
      final RegExp regex = RegExp(r'^\d*\.?\d*$');
      if (!regex.hasMatch(newText)) {
        return oldValue;
      }
    } else {
      // Limit the number of decimal places based on decimalRange
      final RegExp regex = RegExp(r'^\d*\.?\d{0,' + decimalRange.toString() + r'}$');
      if (!regex.hasMatch(newText)) {
        return oldValue;
      }
    }

    return newValue;
  }
}