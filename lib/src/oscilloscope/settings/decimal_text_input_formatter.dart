import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int? decimalRange;
  final bool allowNegativeNumbers;

  DecimalTextInputFormatter({this.decimalRange, this.allowNegativeNumbers = true});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final newText = newValue.text;

    // Build the regular expression based on whether negative numbers are allowed
    String regexPattern;
    if (allowNegativeNumbers) {
      regexPattern = r'^-?\d*\.?'; // Allows negative numbers
    } else {
      regexPattern = r'^\d*\.?'; // Only allows positive numbers
    }

    // If decimalRange is provided, limit the number of digits after the decimal
    if (decimalRange != null) {
      regexPattern += r'\d{0,' + decimalRange.toString() + r'}$';
    } else {
      regexPattern += r'\d*$'; // No limit on decimal places if decimalRange is null
    }

    final RegExp regex = RegExp(regexPattern);

    if (!regex.hasMatch(newText)) {
      return oldValue;
    }

    return newValue;
  }
}
