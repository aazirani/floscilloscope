import 'package:fl_chart/fl_chart.dart';
import 'package:floscilloscope/src/oscilloscope/oscilloscope_axis_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleOscilloscope extends StatefulWidget {
  final OscilloscopeAxisChartData oscilloscopeAxisChartData;

  const SimpleOscilloscope({
    super.key,
    required this.oscilloscopeAxisChartData,
  });

  @override
  State<SimpleOscilloscope> createState() => _SimpleOscilloscopeState();
}

class _SimpleOscilloscopeState extends State<SimpleOscilloscope> {
  late final TextEditingController _horizontalAxisValuePerDivisionController;
  late final TextEditingController _verticalAxisValuePerDivisionController;
  late double _horizontalAxisValuePerDivision;
  late double _verticalAxisValuePerDivision;

  // Define FocusNodes for text fields
  final FocusNode _horizontalAxisFocusNode = FocusNode();
  final FocusNode _verticalAxisFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _horizontalAxisValuePerDivision = widget.oscilloscopeAxisChartData.defaultHorizontalAxisValuePerDivision;
    _verticalAxisValuePerDivision = widget.oscilloscopeAxisChartData.defaultVerticalAxisValuePerDivision;
    _horizontalAxisValuePerDivisionController = TextEditingController(text: _horizontalAxisValuePerDivision.toString());
    _verticalAxisValuePerDivisionController = TextEditingController(text: _verticalAxisValuePerDivision.toString());
  }

  @override
  void dispose() {
    _horizontalAxisValuePerDivisionController.dispose();
    _verticalAxisValuePerDivisionController.dispose();
    _horizontalAxisFocusNode.dispose();
    _verticalAxisFocusNode.dispose();
    super.dispose();
  }

  void _updateValuePerDivisions() {
    setState(() {
      _horizontalAxisValuePerDivision = double.tryParse(_horizontalAxisValuePerDivisionController.text) ?? _horizontalAxisValuePerDivision;
      _verticalAxisValuePerDivision = double.tryParse(_verticalAxisValuePerDivisionController.text) ?? _verticalAxisValuePerDivision;
      _horizontalAxisValuePerDivisionController.text = _horizontalAxisValuePerDivision.toString();
      _verticalAxisValuePerDivisionController.text = _verticalAxisValuePerDivision.toString();
    });
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
              ? _horizontalAxisValuePerDivision.toString()
              : _verticalAxisValuePerDivision.toString();
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
          _updateValuePerDivisions();
          focusNode.unfocus();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Flex(
        direction: MediaQuery.of(context).orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: widget.oscilloscopeAxisChartData.dataPoints,
                    isCurved: true,
                    preventCurveOverShooting: true,
                  ),
                ],
                gridData: FlGridData(
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  horizontalInterval: _verticalAxisValuePerDivision,
                  verticalInterval: _horizontalAxisValuePerDivision,
                  getDrawingHorizontalLine: (value) {
                    return value % _verticalAxisValuePerDivision.abs() < _verticalAxisValuePerDivision
                        ? defaultGridLine(value)
                        : const FlLine(color: Colors.transparent);
                  },
                  getDrawingVerticalLine: (value) {
                    return value % _horizontalAxisValuePerDivision.abs() < _horizontalAxisValuePerDivision
                        ? defaultGridLine(value)
                        : const FlLine(color: Colors.transparent);
                  },
                ),
                minX: -_horizontalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                maxX: _horizontalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                minY: -_verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                maxY: _verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                clipData: const FlClipData.all(),
                lineTouchData: const LineTouchData(
                  enabled: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(widget.oscilloscopeAxisChartData.verticalAxisLabel),
                    axisNameSize: 18,
                    sideTitles: SideTitles(
                      interval: _verticalAxisValuePerDivision,
                      showTitles: true,
                      reservedSize: 85,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${meta.formattedValue} ${widget.oscilloscopeAxisChartData.verticalAxisUnit}',
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(widget.oscilloscopeAxisChartData.horizontalAxisLabel),
                    axisNameSize: 18,
                    sideTitles: SideTitles(
                      interval: _horizontalAxisValuePerDivision,
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Column(
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(meta.formattedValue),
                                ),
                              ),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(widget.oscilloscopeAxisChartData.horizontalAxisUnit),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        onPressed: _updateValuePerDivisions,
                        child: Text(widget.oscilloscopeAxisChartData.updateButtonLabel),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
