import 'package:floscilloscope/src/oscilloscope/oscilloscope_axis_chart_data.dart';
import 'package:floscilloscope/src/oscilloscope/settings/decimal_text_input_formatter.dart';
import 'package:floscilloscope/src/oscilloscope/settings/dynamic_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChartSettings extends StatefulWidget {
  final OscilloscopeAxisChartData oscilloscopeAxisChartData;
  final List<DynamicSetting> dynamicSettings;

  const ChartSettings({
    super.key,
    required this.oscilloscopeAxisChartData,
    required this.dynamicSettings,
  });

  @override
  State<ChartSettings> createState() => _ChartSettingsState();
}

class _ChartSettingsState extends State<ChartSettings> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _focusNodes = {};
  final Map<int, String?> _validationMessages = {};

  @override
  void initState() {
    super.initState();

    // Initialize controllers and focus nodes for each setting
    for (int i = 0; i < widget.dynamicSettings.length; i++) {
      _controllers[i] = TextEditingController(text: widget.dynamicSettings[i].value.toString());
      _focusNodes[i] = FocusNode();
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers and focus nodes when the widget is disposed
    _controllers.forEach((_, controller) => controller.dispose());
    _focusNodes.forEach((_, focusNode) => focusNode.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildDynamicSettingFields(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveSettings,
            child: Text(widget.oscilloscopeAxisChartData.updateButtonLabel),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicSettingFields() {
    return widget.dynamicSettings.asMap().entries.map((entry) {
      int index = entry.key;
      DynamicSetting setting = entry.value;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingField(
              controller: _controllers[index]!,
              focusNode: _focusNodes[index]!,
              setting: setting,
              index: index,
            ),
            if (setting.widgetBuilder != null && _validationMessages[index] != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  _validationMessages[index]!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSettingField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required DynamicSetting setting,
    required int index,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus && controller.text.isEmpty) {
          // Reset the value if the field is left empty
          controller.text = setting.value.toString();
        }
      },
      child: setting.widgetBuilder != null
          ? setting.widgetBuilder!(context, controller, focusNode, (value) {
        _validateAndSave(setting, value, index);
      })
          : _buildDefaultTextField(controller, focusNode, setting, index),
    );
  }

  Widget _buildDefaultTextField(
      TextEditingController controller,
      FocusNode focusNode,
      DynamicSetting setting,
      int index,
      ) {
    // Define input formatters based on input type and decimal control
    List<TextInputFormatter> inputFormatters = [];
    if (setting.inputType == InputType.number) {
      // If decimalPlaces is null, allow unrestricted decimals
      inputFormatters.add(DecimalTextInputFormatter(decimalRange: setting.decimalPlaces));
    }

    return TextField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        labelText: '${setting.label} (${setting.unit})',
        border: const OutlineInputBorder(),
        // Set the errorText to display validation messages natively
        errorText: _validationMessages[index],
      ),
      keyboardType: setting.inputType == InputType.number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: inputFormatters,
      onSubmitted: (value) {
        _saveSettings();
        focusNode.unfocus();
      },
    );
  }

  void _validateAndSave(DynamicSetting setting, dynamic inputValue, int index) {
    setState(() {
      // Perform validation if a custom validator is provided
      final validationMessage = setting.validator?.call(inputValue);
      _validationMessages[index] = validationMessage;

      // Stop if validation fails
      if (validationMessage != null) return;

      // Handle number input or text input based on the setting's input type
      final valueToSave = setting.inputType == InputType.number
          ? (double.tryParse(inputValue) ?? setting.value)
          : inputValue;

      // Update the controller text if it's a number input
      if (setting.inputType == InputType.number) {
        _controllers[index]?.text = valueToSave.toString();
      }

      // Trigger onSave callback with the appropriate value
      setting.onSave(valueToSave);
    });
  }


  void _saveSettings() {
    widget.dynamicSettings.asMap().forEach((index, setting) {
      _validateAndSave(setting, _controllers[index]!.text, index);
    });
    if(_validationMessages.values.where((v) => v != null).isEmpty) Navigator.of(context).pop();
  }
}

