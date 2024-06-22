import 'package:fl_chart/fl_chart.dart';
import 'package:floscilloscope/src/oscilloscope/oscilloscope_axis_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

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
  double _thresholdProgressbarValue = 0.0;
  double _thresholdValue = 0.0;

  // Define FocusNodes for text fields
  final FocusNode _horizontalAxisFocusNode = FocusNode();
  final FocusNode _verticalAxisFocusNode = FocusNode();
  final GlobalKey _chartAndLabelAreaRenderKey = GlobalKey();
  final GlobalKey _chartAreaRenderKey = GlobalKey();

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
    _horizontalAxisValuePerDivision = double.tryParse(_horizontalAxisValuePerDivisionController.text) ?? _horizontalAxisValuePerDivision;
    _verticalAxisValuePerDivision = double.tryParse(_verticalAxisValuePerDivisionController.text) ?? _verticalAxisValuePerDivision;
    _horizontalAxisValuePerDivisionController.text = _horizontalAxisValuePerDivision.toString();
    _verticalAxisValuePerDivisionController.text = _verticalAxisValuePerDivision.toString();
    widget.oscilloscopeAxisChartData.onValuePerDivisionsChanged?.call(_horizontalAxisValuePerDivision, _verticalAxisValuePerDivision);
  }

  void _updateThresholdValue([double? value]) {
    if (value != null) {
      value = double.parse(value.toStringAsFixed(2));
      _thresholdProgressbarValue = value;
      _thresholdValue = value;
    }
    _thresholdProgressbarValue = _thresholdProgressbarValue.clamp(
      -_verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
      _verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
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
          setState(() {
            _updateValuePerDivisions();
            _updateThresholdValue();
          });
          focusNode.unfocus();
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Flex(
        direction: isPortrait ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: isPortrait ? 3 : 4,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: LineChart(
                    key: _chartAndLabelAreaRenderKey,
                    chartRendererKey: _chartAreaRenderKey,
                    LineChartData(
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: widget.oscilloscopeAxisChartData.dataPoints,
                          isCurved: false,
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
                      minX: 0,
                      maxX: _horizontalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions * 2,
                      minY: -_verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                      maxY: _verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                      clipData: const FlClipData.all(),
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
                      extraLinesData: widget.oscilloscopeAxisChartData.isThresholdActive ?
                      ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: _thresholdProgressbarValue,
                            color: Theme.of(context).dividerColor,
                            strokeWidth: 2,
                            dashArray: [5, 5],
                          ),
                        ],
                      ) : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                widget.oscilloscopeAxisChartData.isThresholdActive ?
                LayoutBuilder(
                  builder: (context, constraints) {
                    final chartAndLabelAreaRenderBox = _chartAndLabelAreaRenderKey.currentContext?.findRenderObject() as RenderBox?;
                    final chartAreaRenderBox = _chartAreaRenderKey.currentContext?.findRenderObject() as RenderBox?;
                    final bottomPadding = chartAndLabelAreaRenderBox != null && chartAreaRenderBox != null ? chartAndLabelAreaRenderBox.size.height - chartAreaRenderBox.size.height : 0.0;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPadding),
                      child: Column(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onDoubleTap: () {
                                _showThresholdDialog(context);
                              },
                              child: SfSliderTheme(
                                data: const SfSliderThemeData(
                                  activeTrackHeight: 5,
                                  inactiveTrackHeight: 5,
                                  overlayRadius: 0,
                                  thumbRadius: 0,
                                  labelOffset: Offset(60, 0),
                                ),
                                child: SfSlider.vertical(
                                  tooltipTextFormatterCallback: (dynamic actualValue, String formattedText) => _thresholdValue.toStringAsFixed(2),
                                    overlayShape: CustomOverlayShape(overlayRadius: 10),
                                    thumbShape: CustomThumbShape(thumbRadius: 10),
                                    min: -_verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                                    max: _verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                                    value: _thresholdProgressbarValue,
                                    showTicks: false,
                                    showLabels: false,
                                    enableTooltip: true,
                                    tooltipPosition: SliderTooltipPosition.left,
                                    activeColor: Theme.of(context).primaryColor,
                                    inactiveColor: Theme.of(context).primaryColor,
                                    minorTicksPerInterval: 1,
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        _updateThresholdValue(value);
                                      });
                                    },
                                    onChangeEnd: (dynamic value) =>  widget.oscilloscopeAxisChartData.onThresholdValueChanged?.call(double.parse(value.toStringAsFixed(2))),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ) : Container(),
              ],
            ),
          ),
          if (isPortrait) const SizedBox(height: 16),
          Expanded(
            flex: isPortrait ? 1 : 2,
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
                        onPressed: () => setState(() {
                          _updateValuePerDivisions();
                          _updateThresholdValue();
                        }),
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

  void _showThresholdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double newValue = _thresholdValue;
        return AlertDialog(
          title: Text(widget.oscilloscopeAxisChartData.thresholdLabel),
          content: TextFormField(
            initialValue: _thresholdValue.toStringAsFixed(2),
            onChanged: (value) {
              newValue = double.tryParse(value) ?? _thresholdValue;
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
            ],
            onFieldSubmitted: (value) {
              setState(() {
                _updateThresholdValue(newValue);
              });
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(widget.oscilloscopeAxisChartData.updateButtonLabel),
              onPressed: () {
                setState(() {
                  _updateThresholdValue(newValue);
                  widget.oscilloscopeAxisChartData.onThresholdValueChanged?.call(double.parse(newValue.toStringAsFixed(2)));
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(widget.oscilloscopeAxisChartData.cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  FlLine defaultGridLine(double value) {
    return const FlLine(
      color: Colors.grey,
      strokeWidth: 0.5,
    );
  }
}

// Custom thumb shape
class CustomThumbShape extends SfThumbShape {
  final double thumbRadius;

  CustomThumbShape({required this.thumbRadius});

  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
        required RenderBox? child,
        required SfSliderThemeData themeData,
        SfRangeValues? currentValues,
        dynamic currentValue,
        required Paint? paint,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required SfThumb? thumb}) {
    final Paint paint = Paint()
      ..color = themeData.thumbColor ?? Colors.blue;

    context.canvas.drawCircle(center, thumbRadius, paint);
  }
}

// Custom overlay shape
class CustomOverlayShape extends SfOverlayShape {
  final double overlayRadius;

  CustomOverlayShape({required this.overlayRadius});

  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
        required SfSliderThemeData themeData,
        SfRangeValues? currentValues,
        dynamic currentValue,
        required Paint? paint,
        required Animation<double> animation,
        required SfThumb? thumb}) {
    final Paint paint = Paint()
      ..color = themeData.thumbColor ?? Colors.blue;

    context.canvas.drawCircle(center, overlayRadius, paint);
  }
}
