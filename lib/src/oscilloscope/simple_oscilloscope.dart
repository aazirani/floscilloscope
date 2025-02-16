import 'package:fl_chart/fl_chart.dart';
import 'package:floscilloscope/src/oscilloscope/oscilloscope_axis_chart_data.dart';
import 'package:floscilloscope/src/oscilloscope/threshold_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleOscilloscope extends StatefulWidget {
  final OscilloscopeChartData oscilloscopeChartData;
  final List<List<FlSpot>> dataPoints;

  const SimpleOscilloscope({
    super.key,
    required this.oscilloscopeChartData,
    required this.dataPoints
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
    _thresholdValue = widget.oscilloscopeChartData.threshold;
    _updateThresholdProgressbarValue(_thresholdValue);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateBottomPadding();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SimpleOscilloscope oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.oscilloscopeChartData.verticalAxisValuePerDivision != oldWidget.oscilloscopeChartData.verticalAxisValuePerDivision ||
        widget.oscilloscopeChartData.numberOfDivisions != oldWidget.oscilloscopeChartData.numberOfDivisions ||
        _thresholdValue != widget.oscilloscopeChartData.threshold) {

      setState(() {
        _thresholdValue = widget.oscilloscopeChartData.threshold;
        _thresholdProgressbarValue = _thresholdValue;
        _clampThresholdProgressbarValue();
      });
    }
  }

  void _clampThresholdProgressbarValue() {
    _thresholdProgressbarValue = _thresholdProgressbarValue.clamp(
      -widget.oscilloscopeChartData.verticalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions,
      widget.oscilloscopeChartData.verticalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions,
    );
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

  void _updateThresholdProgressbarValue([double? value]) {
    if (value != null) {
      value = double.parse(value.toStringAsFixed(2));
      _thresholdProgressbarValue = value;
    }
    _clampThresholdProgressbarValue();
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
                        lineTouchData: LineTouchData(
                          enabled: widget.oscilloscopeChartData.enableTooltip,
                          getTouchLineStart: (barData, spotIndex) => 0,
                          getTouchLineEnd: (barData, spotIndex) => 0,
                        ),
                        lineBarsData: widget.dataPoints.isNotEmpty ? widget.dataPoints.asMap().entries.map((entry) =>
                            LineChartBarData(
                              spots: entry.value,
                              isCurved: false,
                              preventCurveOverShooting: true,
                              color: widget.oscilloscopeChartData.colors[entry.key % widget.oscilloscopeChartData.colors.length],
                              dotData: const FlDotData(
                                show: false,  // Disable dots to improve performance
                              ),
                            ),
                        ).toList() : [LineChartBarData()],
                        gridData: FlGridData(
                          drawHorizontalLine: true,
                          drawVerticalLine: true,
                          horizontalInterval: widget.oscilloscopeChartData.verticalAxisValuePerDivision,
                          verticalInterval: widget.oscilloscopeChartData.horizontalAxisValuePerDivision,
                          getDrawingHorizontalLine: (value) {
                            return value % widget.oscilloscopeChartData.verticalAxisValuePerDivision.abs() < widget.oscilloscopeChartData.verticalAxisValuePerDivision
                                ? defaultGridLine(value)
                                : const FlLine(color: Colors.transparent);
                          },
                          getDrawingVerticalLine: (value) {
                            return value % widget.oscilloscopeChartData.horizontalAxisValuePerDivision.abs() < widget.oscilloscopeChartData.horizontalAxisValuePerDivision
                                ? defaultGridLine(value)
                                : const FlLine(color: Colors.transparent);
                          },
                        ),
                        minX: 0,
                        maxX: widget.oscilloscopeChartData.horizontalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions * 2,
                        minY: -widget.oscilloscopeChartData.verticalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions,
                        maxY: widget.oscilloscopeChartData.verticalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions,
                        clipData: const FlClipData.all(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: Text(widget.oscilloscopeChartData.verticalAxisLabel),
                            axisNameSize: 18,
                            sideTitles: SideTitles(
                              interval: widget.oscilloscopeChartData.verticalAxisValuePerDivision,
                              showTitles: true,
                              reservedSize: 85,
                              getTitlesWidget: (value, meta) {
                                return RepaintBoundary(
                                  child: SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      '${meta.formattedValue} ${widget.oscilloscopeChartData.verticalAxisUnit}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text(widget.oscilloscopeChartData.horizontalAxisLabel),
                            axisNameSize: 18,
                            sideTitles: SideTitles(
                              interval: widget.oscilloscopeChartData.horizontalAxisValuePerDivision,
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) {
                                return RepaintBoundary(
                                  child: SideTitleWidget(
                                    meta: meta,
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
                                            child: Text(widget.oscilloscopeChartData.horizontalAxisUnit),
                                          ),
                                        ),
                                      ],
                                    ),
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
                        extraLinesData: widget.oscilloscopeChartData.isThresholdVisible ?
                        ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: _thresholdProgressbarValue,
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 2,
                              dashArray: const [5, 5],
                            ),
                            if (widget.oscilloscopeChartData.extraPlotLines != null)
                              ...widget.oscilloscopeChartData.extraPlotLines!.entries.map((entry) {
                                return HorizontalLine(
                                    y: entry.key,
                                    color: entry.value,
                                    strokeWidth: 2,
                                    dashArray: const [5, 5]
                                );
                              })
                          ],
                        ) : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ThresholdSlider(
                  min: -widget.oscilloscopeChartData.verticalAxisValuePerDivision *
                      widget.oscilloscopeChartData.numberOfDivisions,
                  max: widget.oscilloscopeChartData.verticalAxisValuePerDivision *
                      widget.oscilloscopeChartData.numberOfDivisions,
                  value: _thresholdProgressbarValue,
                  sliderBottomPadding: _sliderBottomPadding,
                  isSliderActive: widget.oscilloscopeChartData.isThresholdSliderActive,
                  isThresholdVisible: widget.oscilloscopeChartData.isThresholdVisible,
                  stepSize: widget.oscilloscopeChartData.thresholdDragStepSize,
                  thresholdValue: _thresholdValue,
                  onDoubleTap: () {
                    _showThresholdDialog(context);
                  },
                  onChanged: (dynamic value) {
                    setState(() {
                      _updateThresholdProgressbarValue(value);
                    });
                  },
                  onChangeEnd: (dynamic value) {
                    _thresholdValue = value;
                    setState(() {
                      _updateThresholdProgressbarValue(value);
                    });
                    widget.oscilloscopeChartData
                        .onThresholdValueChanged
                        ?.call(double.parse(value.toStringAsFixed(2)));
                  },
                ),
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
          title: Text(widget.oscilloscopeChartData.thresholdLabel),
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
                _thresholdValue = newValue;
                _updateThresholdProgressbarValue(newValue);
                widget.oscilloscopeChartData.onThresholdValueChanged?.call(double.parse(newValue.toStringAsFixed(2)));
              });
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(widget.oscilloscopeChartData.updateButtonLabel),
              onPressed: () {
                setState(() {
                  _thresholdValue = newValue;
                  _updateThresholdProgressbarValue(newValue);
                  widget.oscilloscopeChartData.onThresholdValueChanged?.call(double.parse(newValue.toStringAsFixed(2)));
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(widget.oscilloscopeChartData.cancelButtonLabel),
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