import 'package:fl_chart/fl_chart.dart';
import 'package:floscilloscope/src/oscilloscope/oscilloscope_axis_chart_data.dart';
import 'package:floscilloscope/src/oscilloscope/threshold_slider.dart';
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

  double _thresholdProgressbarValue = 0.0;
  double _thresholdValue = 0.0;
  double _sliderBottomPadding = 0.0;

  final GlobalKey<_SimpleOscilloscopeState> _chartAndLabelAreaRenderKey = GlobalKey<_SimpleOscilloscopeState>();
  final GlobalKey<_SimpleOscilloscopeState> _chartAreaRenderKey = GlobalKey<_SimpleOscilloscopeState>();

  @override
  void initState() {
    super.initState();
    _thresholdValue = widget.oscilloscopeAxisChartData.threshold;
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

    if (widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision != oldWidget.oscilloscopeAxisChartData.verticalAxisValuePerDivision ||
        widget.oscilloscopeAxisChartData.numberOfDivisions != oldWidget.oscilloscopeAxisChartData.numberOfDivisions ||
        _thresholdValue != widget.oscilloscopeAxisChartData.threshold) {

      setState(() {
        _thresholdValue = widget.oscilloscopeAxisChartData.threshold;
        _thresholdProgressbarValue = _thresholdValue;
        _clampThresholdProgressbarValue();
      });
    }
  }

  void _clampThresholdProgressbarValue() {
    _thresholdProgressbarValue = _thresholdProgressbarValue.clamp(
      -widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
      widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
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
                          enabled: widget.oscilloscopeAxisChartData.enableTooltip,
                          getTouchLineStart: (barData, spotIndex) => 0,
                          getTouchLineEnd: (barData, spotIndex) => 0,
                        ),
                        lineBarsData: widget.oscilloscopeAxisChartData.dataPoints.isNotEmpty ? widget.oscilloscopeAxisChartData.dataPoints.asMap().entries.map((entry) =>
                            LineChartBarData(
                              spots: entry.value,
                              isCurved: false,
                              preventCurveOverShooting: true,
                              color: widget.oscilloscopeAxisChartData.colors[entry.key % widget.oscilloscopeAxisChartData.colors.length],
                              dotData: const FlDotData(
                                show: false,  // Disable dots to improve performance
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
                                return RepaintBoundary(
                                  child: SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      '${meta.formattedValue} ${widget.oscilloscopeAxisChartData.verticalAxisUnit}',
                                    ),
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
                                            child: Text(widget.oscilloscopeAxisChartData.horizontalAxisUnit),
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
                        extraLinesData: widget.oscilloscopeAxisChartData.isThresholdVisible ?
                        ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: _thresholdProgressbarValue,
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 2,
                              dashArray: const [5, 5],
                            ),
                            if (widget.oscilloscopeAxisChartData.extraPlotLines != null)
                              ...widget.oscilloscopeAxisChartData.extraPlotLines!.entries.map((entry) {
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
                  min: -widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision *
                      widget.oscilloscopeAxisChartData.numberOfDivisions,
                  max: widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision *
                      widget.oscilloscopeAxisChartData.numberOfDivisions,
                  value: _thresholdProgressbarValue,
                  sliderBottomPadding: _sliderBottomPadding,
                  isSliderActive: widget.oscilloscopeAxisChartData.isThresholdSliderActive,
                  isThresholdVisible: widget.oscilloscopeAxisChartData.isThresholdVisible,
                  stepSize: widget.oscilloscopeAxisChartData.thresholdDragStepSize,
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
                    widget.oscilloscopeAxisChartData
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
                _thresholdValue = newValue;
                _updateThresholdProgressbarValue(newValue);
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
                  _thresholdValue = newValue;
                  _updateThresholdProgressbarValue(newValue);
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