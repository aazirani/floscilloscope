import 'package:fl_chart/fl_chart.dart';
import 'package:floscilloscope/src/oscilloscope/oscilloscope_axis_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class SimpleOscilloscope extends StatefulWidget {
  final OscilloscopeAxisChartData oscilloscopeAxisChartData;
  final Function(OscilloscopeAxisChartData) onSettingsChanged;

  const SimpleOscilloscope({
    super.key,
    required this.oscilloscopeAxisChartData,
    required this.onSettingsChanged,
  });

  @override
  State<SimpleOscilloscope> createState() => _SimpleOscilloscopeState();
}

class _SimpleOscilloscopeState extends State<SimpleOscilloscope> {

  double _thresholdProgressbarValue = 0.0;
  double _thresholdValue = 0.0;
  double _sliderBottomPadding = 0.0;

  final GlobalKey<_SimpleOscilloscopeState> _chartAndLabelAreaRenderKey = GlobalKey<_SimpleOscilloscopeState>();
  final GlobalKey<_SimpleOscilloscopeState> _chartAreaRenderKey = GlobalKey<_SimpleOscilloscopeState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateBottomPadding();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _calculateBottomPadding() {
    final chartAndLabelAreaRenderBox = _chartAndLabelAreaRenderKey.currentContext?.findRenderObject() as RenderBox?;
    final chartAreaRenderBox = _chartAreaRenderKey.currentContext?.findRenderObject() as RenderBox?;
    if (chartAndLabelAreaRenderBox != null && chartAreaRenderBox != null) {
      setState(() {
        _sliderBottomPadding = chartAndLabelAreaRenderBox.size.height - chartAreaRenderBox.size.height;
      });
    }
  }

  void _updateThresholdValue([double? value]) {
    if (value != null) {
      value = double.parse(value.toStringAsFixed(2));
      _thresholdProgressbarValue = value;
      _thresholdValue = value;
    }
    _thresholdProgressbarValue = _thresholdProgressbarValue.clamp(
      -widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
      widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Flexible(
                  flex: 3,
                  child: RepaintBoundary(
                    child: LineChart(
                      duration: Duration.zero,
                      curve: Curves.linear,
                      key: _chartAndLabelAreaRenderKey,
                      chartRendererKey: _chartAreaRenderKey,
                      LineChartData(
                        lineTouchData: const LineTouchData(enabled: false),
                        lineBarsData: widget.oscilloscopeAxisChartData.dataPoints.isNotEmpty ? widget.oscilloscopeAxisChartData.dataPoints.asMap().entries.map((entry) =>
                            LineChartBarData(
                              spots: entry.value,
                              isCurved: false,
                              preventCurveOverShooting: true,
                              color: widget.oscilloscopeAxisChartData.colors[entry.key % widget.oscilloscopeAxisChartData.colors.length],
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                    radius: widget.oscilloscopeAxisChartData.pointRadius,
                                    color: widget.oscilloscopeAxisChartData.colors[entry.key % widget.oscilloscopeAxisChartData.colors.length]
                                ),
                              ),
                            ),
                        ).toList() : [LineChartBarData()],
                        gridData: FlGridData(
                          drawHorizontalLine: true,
                          drawVerticalLine: true,
                          horizontalInterval: widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision,
                          verticalInterval: widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision,
                          getDrawingHorizontalLine: (value) {
                            return value % widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision.abs() < widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision
                                ? defaultGridLine(value)
                                : const FlLine(color: Colors.transparent);
                          },
                          getDrawingVerticalLine: (value) {
                            return value % widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision.abs() < widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision
                                ? defaultGridLine(value)
                                : const FlLine(color: Colors.transparent);
                          },
                        ),
                        minX: 0,
                        maxX: widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions * 2,
                        minY: -widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                        maxY: widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                        clipData: const FlClipData.all(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: Text(widget.oscilloscopeAxisChartData.verticalAxisLabel),
                            axisNameSize: 18,
                            sideTitles: SideTitles(
                              interval: widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision,
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
                              interval: widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision,
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
                        extraLinesData: widget.oscilloscopeAxisChartData.isThresholdVisible ?
                        ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: _thresholdProgressbarValue,
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 2,
                              dashArray: [5, 5],
                            ),
                          ],
                        ) : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                widget.oscilloscopeAxisChartData.isThresholdVisible ?
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, _sliderBottomPadding),
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onDoubleTap: () {
                            _showThresholdDialog(context);
                          },
                          child: SfSliderTheme(
                            data: SfSliderThemeData(
                              activeTrackHeight: 5,
                              inactiveTrackHeight: 5,
                              overlayRadius: 0,
                              thumbRadius: 0,
                              labelOffset: const Offset(60, 0),
                              disabledActiveTrackColor: Theme.of(context).disabledColor,
                              disabledInactiveTrackColor: Theme.of(context).disabledColor,
                            ),
                            child: SfSlider.vertical(
                              tooltipTextFormatterCallback: (dynamic actualValue, String formattedText) => _thresholdValue.toStringAsFixed(2),
                              overlayShape: const CustomOverlayShape(overlayRadius: 10),
                              thumbShape: const CustomThumbShape(thumbRadius: 10),
                              min: -widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                              max: widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                              value: _thresholdProgressbarValue,
                              showTicks: false,
                              showLabels: false,
                              enableTooltip: true,
                              tooltipPosition: SliderTooltipPosition.left,
                              activeColor: Theme.of(context).primaryColor,
                              inactiveColor: Theme.of(context).primaryColor,
                              minorTicksPerInterval: 1,
                              onChanged: !widget.oscilloscopeAxisChartData.isThresholdSliderActive ? null : (dynamic value) {
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
                ) : Container(),
              ],
            ),
          ),
        ),
      ],
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
                widget.oscilloscopeAxisChartData.onThresholdValueChanged?.call(double.parse(newValue.toStringAsFixed(2)));
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

  const CustomThumbShape({required this.thumbRadius});

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

  const CustomOverlayShape({required this.overlayRadius});

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