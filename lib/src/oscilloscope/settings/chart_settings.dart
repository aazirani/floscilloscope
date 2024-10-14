import 'package:floscilloscope/src/oscilloscope/settings/dynamic_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChartSettings extends StatefulWidget {
  final List<DynamicSetting> dynamicSettings;

  const ChartSettings({
    super.key,
    required this.dynamicSettings,
  });

  @override
  State<ChartSettings> createState() => _ChartSettingsState();
}

class _ChartSettingsState extends State<ChartSettings> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _focusNodes = {};

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
            child: const Text('Save Settings'),
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
        child: _buildSettingField(
          controller: _controllers[index]!,
          focusNode: _focusNodes[index]!,
          label: setting.label,
          unit: setting.unit,
          onSave: setting.onSave,
        ),
      );
    }).toList();
  }

  Widget _buildSettingField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String unit,
    required Function(double) onSave,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus && controller.text.isEmpty) {
          // Reset the value if the field is left empty
          controller.text = "0.0";
        }
      },
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        decoration: InputDecoration(
          labelText: '$label ($unit)',
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        onSubmitted: (value) {
          _saveSettings();
          focusNode.unfocus();
        },
      ),
    );
  }

  void _saveSettings() {
    // Iterate through all settings and call their save functions
    widget.dynamicSettings.asMap().forEach((index, setting) {
      double updatedValue = double.tryParse(_controllers[index]!.text) ?? setting.value;
      setting.onSave(updatedValue);
    });
    Navigator.of(context).pop();
  }
}

