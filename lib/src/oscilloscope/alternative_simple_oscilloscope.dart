import 'package:fl_chart/fl_chart.dart';
import 'package:floscilloscope/src/oscilloscope/oscilloscope_axis_chart_data.dart';
import 'package:floscilloscope/src/oscilloscope/threshold_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AlternativeSimpleOscilloscope extends StatefulWidget {
  final OscilloscopeAxisChartData oscilloscopeAxisChartData;

  const AlternativeSimpleOscilloscope({
    super.key,
    required this.oscilloscopeAxisChartData,
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

  @override
  void initState() {
    super.initState();
    _thresholdProgressbarMaximum = widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions;
    _thresholdProgressbarMinimum = -widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions;
    _updateThresholdValue(widget.oscilloscopeAxisChartData.threshold);
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

    if (widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision != oldWidget.oscilloscopeAxisChartData.verticalAxisValuePerDivision ||
        widget.oscilloscopeAxisChartData.numberOfDivisions != oldWidget.oscilloscopeAxisChartData.numberOfDivisions) {

      setState(() {
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

  void _updateThresholdValue([double? value]) {
    if (value != null) {
      value = double.parse(value.toStringAsFixed(2));
      _thresholdProgressbarValue = value;
      _thresholdValue = value;
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
                      zoomPanBehavior: ZoomPanBehavior(
                          enablePanning: true,
                          enableMouseWheelZooming: true,
                          enableDoubleTapZooming: true,
                          enableSelectionZooming: true
                      ),
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
                            text: widget.oscilloscopeAxisChartData.horizontalAxisLabel
                        ),
                        labelFormat: "{value}${widget.oscilloscopeAxisChartData.horizontalAxisUnit}",
                        key: _primaryXAxisRenderKey,
                        minimum: 0,
                        maximum: widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions * 2,
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        minorGridLines: const MinorGridLines(width: 0),
                        interval: widget.oscilloscopeAxisChartData.horizontalAxisValuePerDivision,
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(
                            text: widget.oscilloscopeAxisChartData.verticalAxisLabel
                        ),
                        labelFormat: "{value}${widget.oscilloscopeAxisChartData.verticalAxisUnit}",
                        plotBands: [
                          PlotBand(
                              start: _thresholdProgressbarValue,
                              end: _thresholdProgressbarValue,
                              borderColor: Theme.of(context).primaryColor, // Line color
                              borderWidth: 2,
                              dashArray: const <double>[5, 5]
                          ),
                        ],
                        key: _primaryYAxisRenderKey,
                        minimum: -widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                        maximum: widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions,
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        minorGridLines: const MinorGridLines(width: 0),
                        interval: widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision,
                      ),
                      series: [
                        ...widget.oscilloscopeAxisChartData.dataPoints.map((list) {
                          return LineSeries<FlSpot, double>(
                            dataLabelSettings: const DataLabelSettings(isVisible: false),
                            enableTooltip: false,
                            dataSource: list,
                            xValueMapper: (FlSpot data, _) => data.x,
                            yValueMapper: (FlSpot data, _) => data.y,
                            animationDuration: 0,
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
                  isSliderActive: widget.oscilloscopeAxisChartData.isThresholdSliderActive,
                  isThresholdVisible: widget.oscilloscopeAxisChartData.isThresholdVisible,
                  stepSize: widget.oscilloscopeAxisChartData.thresholdDragStepSize,
                  thresholdValue: _thresholdValue,
                  onDoubleTap: () {
                    _showThresholdDialog(context);
                  },
                  onChanged: (dynamic value) {
                    setState(() {
                      _updateThresholdValue(value);
                    });
                  },
                  onChangeEnd: (dynamic value) {
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

  void _handleZoom() {
    // Calculate the zoomed min and max for the Y-axis
    double currentMin = -widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions;
    double currentMax = widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision * widget.oscilloscopeAxisChartData.numberOfDivisions;

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

}