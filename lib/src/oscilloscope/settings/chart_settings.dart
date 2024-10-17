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
          Text(
              widget.oscilloscopeAxisChartData.settingsTitleLabel,
              style: Theme.of(context).textTheme.titleMedium
          ),
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
    // Sort the settings based on the `order` field
    List<MapEntry<int, DynamicSetting>> sortedSettings = widget.dynamicSettings
        .asMap()
        .entries
        .toList()
      ..sort((a, b) {
        // Sort by `order`, if orders are the same, retain original order in the list
        int orderComparison = a.value.order.compareTo(b.value.order);
        return orderComparison != 0 ? orderComparison : a.key.compareTo(b.key);
      });

    return sortedSettings.map((entry) {
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
    TextEditingController? controller,
    FocusNode? focusNode,
    required DynamicSetting setting,
    required int index,
  }) {
    // If widgetBuilder is set, use it to build the widget
    if (setting.widgetBuilder != null) {
      return setting.widgetBuilder!(
        context,
        controller!,
        focusNode!,
            (value) => _validateAndSave(setting, value, index),
      );
    }

    // If widgetBuilder is null, build the default TextField
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus && controller!.text.isEmpty && setting.value != null) {
          // Reset the value if the field is left empty
          controller.text = setting.value.toString();
        }
      },
      child: _buildDefaultTextField(controller!, focusNode!, setting, index),
    );
  }

  Widget _buildDefaultTextField(
      TextEditingController controller,
      FocusNode focusNode,
      DynamicSetting setting,
      int index,
      ) {
    // If label or value is null, we can't build the default field
    if (setting.label == null || setting.value == null) {
      return const SizedBox.shrink(); // Return an empty widget if key fields are missing
    }

    // Define input formatters based on input type and decimal control
    List<TextInputFormatter> inputFormatters = [];
    if (setting.inputType == InputType.number) {
      inputFormatters.add(
        DecimalTextInputFormatter(
          decimalRange: setting.decimalPlaces,
          allowNegativeNumbers: setting.allowNegativeNumbers,
        ),
      );
    }

    // Build the label text, including the unit only if it's not null
    String labelText = setting.unit != null
        ? '${setting.label} (${setting.unit})'
        : setting.label!;

    return TextField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        errorText: _validationMessages[index],
      ),
      keyboardType: setting.inputType == InputType.number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: inputFormatters,
      onSubmitted: (value) {
        if (setting.onSave != null) {
          _validateAndSave(setting, value, index);
        }
        _saveSettings();
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

      if (setting.onSave == null) return; // Skip saving if onSave is null

      // Handle number input or text input based on the setting's input type
      final valueToSave = setting.inputType == InputType.number
          ? (double.tryParse(inputValue) ?? setting.value)
          : inputValue;

      // Update the controller text if it's a number input
      if (setting.inputType == InputType.number) {
        _controllers[index]?.text = valueToSave.toString();
      }

      // Trigger onSave callback with the appropriate value
      setting.onSave!(valueToSave);
    });
  }

  void _saveSettings() {
    widget.dynamicSettings.asMap().forEach((index, setting) {
      _validateAndSave(setting, _controllers[index]!.text, index);
    });
    if(_validationMessages.values.where((v) => v != null).isEmpty) Navigator.of(context).pop();
  }
}