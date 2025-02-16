import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:floscilloscope/src/oscilloscope/oscilloscope_axis_chart_data.dart';
import 'package:floscilloscope/src/oscilloscope/threshold_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AlternativeSimpleOscilloscope extends StatefulWidget {
  final OscilloscopeChartData oscilloscopeChartData;
  final List<List<FlSpot>> dataPoints;

  const AlternativeSimpleOscilloscope({
    super.key,
    required this.oscilloscopeChartData,
    required this.dataPoints
  });

  @override
  State<AlternativeSimpleOscilloscope> createState() => _AlternativeSimpleOscilloscopeState();
}

class _AlternativeSimpleOscilloscopeState extends State<AlternativeSimpleOscilloscope> {

  double _thresholdProgressbarValue = 0.0;
  double _thresholdValue = 0.0;
  double _sliderBottomPadding = 0.0;

  final GlobalKey<_AlternativeSimpleOscilloscopeState> _primaryXAxisRenderKey = GlobalKey<_AlternativeSimpleOscilloscopeState>();
  final GlobalKey<_AlternativeSimpleOscilloscopeState> _primaryYAxisRenderKey = GlobalKey<_AlternativeSimpleOscilloscopeState>();

  late double _thresholdProgressbarMaximum;
  late double _thresholdProgressbarMinimum;
  late double _zoomFactor = 1.0;
  late double _zoomPosition = 0.0;

  Timer? _doubleTapTimer;
  int _pointerCount = 0;
  final _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enableMouseWheelZooming: true,
      enableSelectionZooming: true
  );

  @override
  void initState() {
    super.initState();
    _thresholdProgressbarMaximum = widget.oscilloscopeChartData.verticalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions;
    _thresholdProgressbarMinimum = -widget.oscilloscopeChartData.verticalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions;
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
  void didUpdateWidget(covariant AlternativeSimpleOscilloscope oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.oscilloscopeChartData.verticalAxisValuePerDivision != oldWidget.oscilloscopeChartData.verticalAxisValuePerDivision ||
        widget.oscilloscopeChartData.numberOfDivisions != oldWidget.oscilloscopeChartData.numberOfDivisions ||
        _thresholdValue != widget.oscilloscopeChartData.threshold) {

      setState(() {
        _thresholdValue = widget.oscilloscopeChartData.threshold;
        _thresholdProgressbarValue = _thresholdValue;
        _handleZoom();
      });
    }
  }

  void _clampThresholdProgressbarValue() {
    _thresholdProgressbarValue = _thresholdProgressbarValue.clamp(
      _thresholdProgressbarMinimum,
      _thresholdProgressbarMaximum,
    );
  }

  void _calculateBottomPadding() {
    final primaryXAxisRenderBox = _primaryXAxisRenderKey.currentContext?.findRenderObject() as RenderBox?;
    final primaryYAxisRenderBox = _primaryYAxisRenderKey.currentContext?.findRenderObject() as RenderBox?;
    if (primaryYAxisRenderBox != null && primaryXAxisRenderBox != null) {
      setState(() {
        _sliderBottomPadding = primaryXAxisRenderBox.size.height;
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

  double calculateZoomedMin(double currentMin, double currentMax, double zoomFactor, double zoomPosition) {
    double range = currentMax - currentMin;
    double zoomedMin = currentMin + range * zoomPosition;
    return zoomedMin;
  }

  double calculateZoomedMax(double zoomedMin, double currentMin, double currentMax, double zoomFactor) {
    double range = currentMax - currentMin;
    double zoomedRange = range * zoomFactor;
    return zoomedMin + zoomedRange;
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
                    child: SfCartesianChart(
                      tooltipBehavior: TooltipBehavior(
                        enable: widget.oscilloscopeChartData.enableTooltip,
                        animationDuration: 0,
                        duration: 1000,
                        header: "",
                        shouldAlwaysShow: true,
                      ),
                      onChartTouchInteractionDown: (tapArgs) {
                        _doubleTapTimer ??=
                            Timer(kDoubleTapTimeout, _resetDoubleTapTimer);
                      },
                      onChartTouchInteractionUp: (tapArgs) {
                        // If the second tap is detected, increment the pointer count
                        if (_doubleTapTimer != null && _doubleTapTimer!.isActive) {
                          _pointerCount++;
                        }
                        // If the pointer count is 2, then the double tap is detected
                        if (_pointerCount == 2) {
                          _resetDoubleTapTimer();
                          setState(() {
                            _zoomPanBehavior.reset();
                            _zoomFactor = 1.0;
                            _zoomPosition = 0.0;
                            _handleZoom();
                          });
                        }
                      },
                      zoomPanBehavior: _zoomPanBehavior,
                      onZoomEnd: (zoom) {
                        if(zoom.axis?.isVertical ?? false){
                          _zoomFactor = zoom.currentZoomFactor;
                          _zoomPosition = zoom.currentZoomPosition;
                          _handleZoom();
                        }
                      },
                      margin: EdgeInsets.zero,
                      enableAxisAnimation: false,
                      primaryXAxis: NumericAxis(
                        title: AxisTitle(
                            text: widget.oscilloscopeChartData.horizontalAxisLabel
                        ),
                        labelFormat: "{value}${widget.oscilloscopeChartData.horizontalAxisUnit}",
                        key: _primaryXAxisRenderKey,
                        minimum: 0,
                        maximum: widget.oscilloscopeChartData.horizontalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions * 2,
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        minorGridLines: const MinorGridLines(width: 0),
                        interval: widget.oscilloscopeChartData.horizontalAxisValuePerDivision,
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(
                            text: widget.oscilloscopeChartData.verticalAxisLabel
                        ),
                        labelFormat: "{value}${widget.oscilloscopeChartData.verticalAxisUnit}",
                        plotBands: [
                          PlotBand(
                              start: _thresholdProgressbarValue,
                              end: _thresholdProgressbarValue,
                              borderColor: Theme.of(context).primaryColor, // Line color
                              borderWidth: 2,
                              dashArray: const <double>[5, 5],
                              shouldRenderAboveSeries: true
                          ),
                          if (widget.oscilloscopeChartData.extraPlotLines != null)
                            ...widget.oscilloscopeChartData.extraPlotLines!.entries.map((entry) {
                              return PlotBand(
                                start: entry.key,
                                end: entry.key,
                                borderColor: entry.value,
                                borderWidth: 2,
                                dashArray: const <double>[5, 5],
                                shouldRenderAboveSeries: true
                              );
                            })
                        ],
                        key: _primaryYAxisRenderKey,
                        minimum: -widget.oscilloscopeChartData.verticalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions,
                        maximum: widget.oscilloscopeChartData.verticalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions,
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        minorGridLines: const MinorGridLines(width: 0),
                        interval: widget.oscilloscopeChartData.verticalAxisValuePerDivision,
                      ),
                      series: [
                        ...widget.dataPoints.asMap().entries.map((entry) {
                          return LineSeries<FlSpot, double>(
                            dataLabelSettings: const DataLabelSettings(isVisible: false),
                            enableTooltip: widget.oscilloscopeChartData.enableTooltip,
                            dataSource: entry.value,
                            xValueMapper: (FlSpot data, _) => data.x,
                            yValueMapper: (FlSpot data, _) => data.y,
                            animationDuration: 0,
                            color: widget.oscilloscopeChartData.colors[entry.key % widget.oscilloscopeChartData.colors.length],
                          );
                        })

                      ],
                    )
                ),
                const SizedBox(width: 16),
                ThresholdSlider(
                  min: _thresholdProgressbarMinimum,
                  max: _thresholdProgressbarMaximum,
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

  // Reset the double tap timer and pointer count
  void _resetDoubleTapTimer() {
    _pointerCount = 0;
    if (_doubleTapTimer != null) {
      _doubleTapTimer!.cancel();
      _doubleTapTimer = null;
    }
  }

  void _handleZoom() {
    // Calculate the zoomed min and max for the Y-axis
    double currentMin = -widget.oscilloscopeChartData.verticalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions;
    double currentMax = widget.oscilloscopeChartData.verticalAxisValuePerDivision * widget.oscilloscopeChartData.numberOfDivisions;

    double zoomedMin = calculateZoomedMin(currentMin, currentMax, _zoomFactor, _zoomPosition);
    double zoomedMax = calculateZoomedMax(zoomedMin, currentMin, currentMax, _zoomFactor);

    setState(() {
      _thresholdProgressbarMaximum = zoomedMax;
      _thresholdProgressbarMinimum = zoomedMin;
      _thresholdProgressbarValue = _thresholdValue;
      _clampThresholdProgressbarValue();
    });
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

}