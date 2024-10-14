import 'package:floscilloscope/src/oscilloscope/oscilloscope_axis_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChartSettings extends StatefulWidget {
  final OscilloscopeAxisChartData oscilloscopeAxisChartData;
  final Function onSettingUpdateFunction;

  const ChartSettings({super.key, required this.oscilloscopeAxisChartData, required this.onSettingUpdateFunction});

  @override
  State<ChartSettings> createState() => _ChartSettingsState();
}

class _ChartSettingsState extends State<ChartSettings> {

  late final TextEditingController _horizontalAxisValuePerDivisionController;
  late final TextEditingController _verticalAxisValuePerDivisionController;

  final FocusNode _horizontalAxisFocusNode = FocusNode();
  final FocusNode _verticalAxisFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _horizontalAxisValuePerDivisionController = TextEditingController(text: widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision.toString());
    _verticalAxisValuePerDivisionController = TextEditingController(text: widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision.toString());
  }

  @override
  void dispose() {
    _horizontalAxisValuePerDivisionController.dispose();
    _verticalAxisValuePerDivisionController.dispose();
    _horizontalAxisFocusNode.dispose();
    _verticalAxisFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.oscilloscopeAxisChartData.settingsTitleLabel.isNotEmpty)
            Text(
              widget.oscilloscopeAxisChartData.settingsTitleLabel,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 20),
          _buildAxisInputField(
            controller: _horizontalAxisValuePerDivisionController,
            focusNode: _horizontalAxisFocusNode,
            label: widget.oscilloscopeAxisChartData.horizontalAxisTitlePerDivisionLabel,
            unit: widget.oscilloscopeAxisChartData.horizontalAxisUnit,
          ),
          const SizedBox(height: 20),
          _buildAxisInputField(
            controller: _verticalAxisValuePerDivisionController,
            focusNode: _verticalAxisFocusNode,
            label: widget.oscilloscopeAxisChartData.verticalAxisTitlePerDivisionLabel,
            unit: widget.oscilloscopeAxisChartData.verticalAxisUnit,
          ),
          const SizedBox(height: 20),
          if (widget.oscilloscopeAxisChartData.updateButtonLabel.isNotEmpty)
            ElevatedButton(
              onPressed: () => setState(() {
                _updateValuePerDivisions();
                widget.onSettingUpdateFunction();
              }),
              child: Text(widget.oscilloscopeAxisChartData.updateButtonLabel),
            ),
        ],
      ),
    );
  }

  Widget _buildAxisInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String unit,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus && controller.text.isEmpty) {
          controller.text = focusNode == _horizontalAxisFocusNode
              ? widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision.toString()
              : widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision.toString();
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
          setState(() {
            _updateValuePerDivisions();
            widget.onSettingUpdateFunction();
          });
          focusNode.unfocus();
        },
      ),
    );
  }

  void _updateValuePerDivisions() {
    widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision = double.tryParse(_horizontalAxisValuePerDivisionController.text) ?? widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision;
    widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision = double.tryParse(_verticalAxisValuePerDivisionController.text) ?? widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision;
    _horizontalAxisValuePerDivisionController.text = widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision.toString();
    _verticalAxisValuePerDivisionController.text = widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision.toString();
    widget.oscilloscopeAxisChartData.onValuePerDivisionsChanged?.call(widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision, widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision);
  }
}
