import 'dart:async';

import 'package:floscilloscope/src/oscilloscope/oscilloscope_point.dart';
import 'package:floscilloscope/src/oscilloscope/oscilloscope_axis_chart_data.dart';
import 'package:floscilloscope/src/oscilloscope/threshold_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// An advanced oscilloscope widget with zoom/pan capabilities using Syncfusion charts.
///
/// This widget provides a feature-rich oscilloscope visualization with advanced
/// interaction capabilities including zooming, panning, and selection. It uses
/// the Syncfusion Flutter Charts library, offering professional-grade charting
/// capabilities suitable for complex data analysis and technical applications.
///
/// Advanced Features:
/// - Interactive zoom and pan gestures for detailed data exploration
/// - Mouse wheel zooming support for desktop applications
/// - Selection zooming for precise region analysis
/// - Professional-grade chart rendering with smooth performance
/// - Multi-touch gesture support for mobile devices
/// - All standard oscilloscope features from [SimpleOscilloscope]
///
/// Standard Features:
/// - Multiple data series support with customizable colors
/// - Interactive threshold line with drag-to-adjust capability
/// - Configurable axes with labels and units
/// - Grid divisions for easier reading
/// - Threshold slider for precise value adjustment
/// - Extra plot lines for additional reference markers
/// - Tooltip support for data point inspection
///
/// Data updates are pushed to the chart through
/// [ChartSeriesController.updateDataSource] so that replacing a series with a
/// shorter list correctly removes the stale trailing points, and high-frequency
/// data-only refreshes avoid a full [SfCartesianChart] rebuild. Use
/// [AlternativeSimpleOscilloscopeState.clearData] through a [GlobalKey] to
/// immediately clear all rendered data.
///
/// Example usage:
/// ```dart
/// AlternativeSimpleOscilloscope(
///   oscilloscopeAxisChartData: OscilloscopeAxisChartData(
///     dataPoints: [
///       [OscilloscopePoint(0, 0), OscilloscopePoint(1, 1)],
///       [OscilloscopePoint(0, 1), OscilloscopePoint(1, 2)],
///     ],
///     horizontalAxisLabel: 'Time',
///     verticalAxisLabel: 'Voltage',
///     horizontalAxisUnit: 'ms',
///     verticalAxisUnit: 'V',
///     threshold: 1.5,
///     enableTooltip: true,
///     colors: [Colors.blue, Colors.red],
///   ),
/// )
/// ```
///
/// See also:
/// * [SimpleOscilloscope] for a lightweight alternative without zoom/pan
/// * [OscilloscopeAxisChartData] for configuration options
/// * [ThresholdSlider] for threshold manipulation controls
class AlternativeSimpleOscilloscope extends StatefulWidget {
  /// The configuration and data for the oscilloscope chart.
  ///
  /// This contains all the necessary information to render the advanced
  /// oscilloscope, including data points, axis configuration, threshold
  /// settings, visual customization options, and interaction behaviors.
  final OscilloscopeAxisChartData oscilloscopeAxisChartData;

  /// Creates an [AlternativeSimpleOscilloscope] widget.
  ///
  /// The [oscilloscopeAxisChartData] parameter is required and contains
  /// all the configuration and data needed to render the advanced
  /// oscilloscope chart with zoom/pan capabilities.
  const AlternativeSimpleOscilloscope({
    super.key,
    required this.oscilloscopeAxisChartData,
  });

  @override
  State<AlternativeSimpleOscilloscope> createState() =>
      AlternativeSimpleOscilloscopeState();
}

/// State for [AlternativeSimpleOscilloscope].
///
/// Exposed publicly so consumers can drive imperative updates through a
/// [GlobalKey]:
///
/// ```dart
/// final key = GlobalKey<AlternativeSimpleOscilloscopeState>();
/// AlternativeSimpleOscilloscope(key: key, ...);
/// key.currentState?.clearData();
/// ```
///
/// The state owns the mutable per-series data sources handed to the chart and
/// keeps them in sync with [OscilloscopeAxisChartData.dataPoints] via
/// [ChartSeriesController.updateDataSource]. This avoids a full
/// [SfCartesianChart] rebuild on data-only changes and correctly truncates the
/// stale trailing points when a series shrinks.
class AlternativeSimpleOscilloscopeState
    extends State<AlternativeSimpleOscilloscope> {
  double _thresholdProgressbarValue = 0.0;
  double _thresholdValue = 0.0;
  double _sliderBottomPadding = 0.0;

  final GlobalKey<AlternativeSimpleOscilloscopeState> _primaryXAxisRenderKey =
      GlobalKey<AlternativeSimpleOscilloscopeState>();
  final GlobalKey<AlternativeSimpleOscilloscopeState> _primaryYAxisRenderKey =
      GlobalKey<AlternativeSimpleOscilloscopeState>();

  late double _thresholdProgressbarMaximum;
  late double _thresholdProgressbarMinimum;
  late double _zoomFactor = 1.0;
  late double _zoomPosition = 0.0;

  /// Mutable data source lists owned by this state. These are the lists handed
  /// to each [LineSeries] as its `dataSource`; they are updated in place so the
  /// series keep a stable list identity while their contents change.
  late List<List<OscilloscopePoint>> _dataSources;

  /// Syncfusion series controllers, one per series, captured through
  /// [LineSeries.onRendererCreated]. Used to push incremental data updates
  /// without rebuilding the whole chart.
  late List<ChartSeriesController?> _seriesControllers;

  Timer? _doubleTapTimer;
  int _pointerCount = 0;
  final _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enableMouseWheelZooming: true,
      enableSelectionZooming: true);

  @override
  void initState() {
    super.initState();
    _dataSources = widget.oscilloscopeAxisChartData.dataPoints
        .map((list) => List<OscilloscopePoint>.from(list))
        .toList();
    _seriesControllers =
        List<ChartSeriesController?>.generate(_dataSources.length, (_) => null);
    _thresholdProgressbarMaximum =
        widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision *
            widget.oscilloscopeAxisChartData.numberOfDivisions;
    _thresholdProgressbarMinimum =
        -widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision *
            widget.oscilloscopeAxisChartData.numberOfDivisions;
    _thresholdValue = widget.oscilloscopeAxisChartData.threshold;
    _updateThresholdProgressbarValue(_thresholdValue);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateBottomPadding();
    });
  }

  @override
  void dispose() {
    _dataSources.clear();
    _seriesControllers.clear();
    _doubleTapTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AlternativeSimpleOscilloscope oldWidget) {
    super.didUpdateWidget(oldWidget);

    _handleDataUpdate(oldWidget.oscilloscopeAxisChartData.dataPoints,
        widget.oscilloscopeAxisChartData.dataPoints);

    if (widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision !=
            oldWidget.oscilloscopeAxisChartData.verticalAxisValuePerDivision ||
        widget.oscilloscopeAxisChartData.numberOfDivisions !=
            oldWidget.oscilloscopeAxisChartData.numberOfDivisions ||
        _thresholdValue != widget.oscilloscopeAxisChartData.threshold) {
      setState(() {
        _thresholdValue = widget.oscilloscopeAxisChartData.threshold;
        _thresholdProgressbarValue = _thresholdValue;
        _handleZoom();
      });
    }
  }

  /// Pushes incremental data updates to the chart through the series
  /// controllers.
  ///
  /// When the number of series changes the chart is rebuilt via [setState]
  /// (this is rare). Otherwise each series' owned data source is updated in
  /// place and the change is described to Syncfusion with
  /// [ChartSeriesController.updateDataSource]:
  ///
  /// * same length -> re-render the whole range,
  /// * shrink      -> re-render the survivors then remove the trailing points
  ///                  (this is what clears the stale trailing points),
  /// * grow        -> re-render the existing points then append the new ones.
  ///
  /// No [setState] is needed for same-count updates, so high-frequency
  /// data-only refreshes skip a full [SfCartesianChart] reconciliation.
  void _handleDataUpdate(
      List<List<OscilloscopePoint>> oldData,
      List<List<OscilloscopePoint>> newData) {
    if (newData.length != _dataSources.length) {
      setState(() {
        _dataSources =
            newData.map((list) => List<OscilloscopePoint>.from(list)).toList();
        _seriesControllers =
            List<ChartSeriesController?>.generate(_dataSources.length, (_) => null);
      });
      return;
    }

    for (int i = 0; i < newData.length; i++) {
      final controller = _seriesControllers[i];
      final source = _dataSources[i];
      final incoming = newData[i];

      if (identical(source, incoming) && source.length == incoming.length) {
        continue;
      }

      final oldLen = source.length;
      source
        ..clear()
        ..addAll(incoming);
      final newLen = source.length;

      if (controller == null) {
        continue;
      }

      if (newLen == oldLen) {
        if (newLen > 0) {
          controller.updateDataSource(
            updatedDataIndexes: List<int>.generate(newLen, (i) => i),
          );
        }
      } else if (newLen < oldLen) {
        if (newLen > 0) {
          controller.updateDataSource(
            updatedDataIndexes: List<int>.generate(newLen, (i) => i),
          );
        }
        controller.updateDataSource(
          removedDataIndexes:
              List<int>.generate(oldLen - newLen, (i) => newLen + i),
        );
      } else {
        if (oldLen > 0) {
          controller.updateDataSource(
            updatedDataIndexes: List<int>.generate(oldLen, (i) => i),
          );
        }
        controller.updateDataSource(
          addedDataIndexes:
              List<int>.generate(newLen - oldLen, (i) => oldLen + i),
        );
      }
    }
  }

  /// Immediately clears every rendered series.
  ///
  /// This bypasses the widget rebuild cycle so the chart is emptied on the next
  /// frame regardless of the consumer's refresh cadence. Subsequent updates
  /// delivered through [didUpdateWidget] repopulate the chart normally.
  ///
  /// ```dart
  /// final key = GlobalKey<AlternativeSimpleOscilloscopeState>();
  /// AlternativeSimpleOscilloscope(key: key, ...);
  /// key.currentState?.clearData();
  /// ```
  void clearData() {
    for (int i = 0; i < _dataSources.length; i++) {
      final controller = _seriesControllers[i];
      final oldLen = _dataSources[i].length;
      _dataSources[i].clear();
      if (controller != null && oldLen > 0) {
        controller.updateDataSource(
          removedDataIndexes: List<int>.generate(oldLen, (i) => i),
        );
      }
    }
  }

  void _clampThresholdProgressbarValue() {
    _thresholdProgressbarValue = _thresholdProgressbarValue.clamp(
      _thresholdProgressbarMinimum,
      _thresholdProgressbarMaximum,
    );
  }

  void _calculateBottomPadding() {
    final primaryXAxisRenderBox =
        _primaryXAxisRenderKey.currentContext?.findRenderObject() as RenderBox?;
    final primaryYAxisRenderBox =
        _primaryYAxisRenderKey.currentContext?.findRenderObject() as RenderBox?;
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

  double calculateZoomedMin(double currentMin, double currentMax,
      double zoomFactor, double zoomPosition) {
    double range = currentMax - currentMin;
    double zoomedMin = currentMin + range * zoomPosition;
    return zoomedMin;
  }

  double calculateZoomedMax(double zoomedMin, double currentMin,
      double currentMax, double zoomFactor) {
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
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
              children: [
                Flexible(
                    flex: 3,
                    child: SfCartesianChart(
                      tooltipBehavior: TooltipBehavior(
                        enable: widget.oscilloscopeAxisChartData.enableTooltip,
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
                        if (_doubleTapTimer != null &&
                            _doubleTapTimer!.isActive) {
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
                        if (zoom.axis?.isVertical ?? false) {
                          _zoomFactor = zoom.currentZoomFactor;
                          _zoomPosition = zoom.currentZoomPosition;
                          _handleZoom();
                        }
                      },
                      margin: EdgeInsets.zero,
                      enableAxisAnimation: false,
                      primaryXAxis: NumericAxis(
                        title: AxisTitle(
                            text: widget
                                .oscilloscopeAxisChartData.horizontalAxisLabel),
                        labelFormat:
                            "{value}${widget.oscilloscopeAxisChartData.horizontalAxisUnit}",
                        key: _primaryXAxisRenderKey,
                        minimum: 0,
                        maximum: widget.oscilloscopeAxisChartData
                                .horizontalAxisValuePerDivision *
                            widget.oscilloscopeAxisChartData.numberOfDivisions *
                            2,
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        minorGridLines: const MinorGridLines(width: 0),
                        interval: widget.oscilloscopeAxisChartData
                            .horizontalAxisValuePerDivision,
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(
                            text: widget
                                .oscilloscopeAxisChartData.verticalAxisLabel),
                        labelFormat:
                            "{value}${widget.oscilloscopeAxisChartData.verticalAxisUnit}",
                        plotBands: [
                          PlotBand(
                              start: _thresholdProgressbarValue,
                              end: _thresholdProgressbarValue,
                              borderColor:
                                  Theme.of(context).primaryColor, // Line color
                              borderWidth: 2,
                              dashArray: const <double>[5, 5],
                              shouldRenderAboveSeries: true),
                          if (widget.oscilloscopeAxisChartData.extraPlotLines !=
                              null)
                            ...widget.oscilloscopeAxisChartData.extraPlotLines!
                                .entries
                                .map((entry) {
                              return PlotBand(
                                  start: entry.key,
                                  end: entry.key,
                                  borderColor: entry.value,
                                  borderWidth: 2,
                                  dashArray: const <double>[5, 5],
                                  shouldRenderAboveSeries: true);
                            })
                        ],
                        key: _primaryYAxisRenderKey,
                        minimum: -widget.oscilloscopeAxisChartData
                                .verticalAxisValuePerDivision *
                            widget.oscilloscopeAxisChartData.numberOfDivisions,
                        maximum: widget.oscilloscopeAxisChartData
                                .verticalAxisValuePerDivision *
                            widget.oscilloscopeAxisChartData.numberOfDivisions,
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        minorGridLines: const MinorGridLines(width: 0),
                        interval: widget.oscilloscopeAxisChartData
                            .verticalAxisValuePerDivision,
                      ),
                      series: [
                        ..._dataSources.asMap().entries.map((entry) {
                          return LineSeries<OscilloscopePoint, double>(
                            key: ValueKey<String>('series_${entry.key}'),
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: false),
                            enableTooltip:
                                widget.oscilloscopeAxisChartData.enableTooltip,
                            dataSource: _dataSources[entry.key],
                            onRendererCreated: (ChartSeriesController controller) {
                              if (entry.key < _seriesControllers.length) {
                                _seriesControllers[entry.key] = controller;
                              }
                            },
                            xValueMapper: (OscilloscopePoint data, _) => data.x,
                            yValueMapper: (OscilloscopePoint data, _) => data.y,
                            animationDuration: 0,
                            color: widget.oscilloscopeAxisChartData.colors[entry
                                    .key %
                                widget.oscilloscopeAxisChartData.colors.length],
                          );
                        })
                      ],
                    )),
                const SizedBox(width: 16),
                ThresholdSlider(
                  min: _thresholdProgressbarMinimum,
                  max: _thresholdProgressbarMaximum,
                  value: _thresholdProgressbarValue,
                  sliderBottomPadding: _sliderBottomPadding,
                  isSliderActive:
                      widget.oscilloscopeAxisChartData.isThresholdSliderActive,
                  isThresholdVisible:
                      widget.oscilloscopeAxisChartData.isThresholdVisible,
                  stepSize:
                      widget.oscilloscopeAxisChartData.thresholdDragStepSize,
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
                    widget.oscilloscopeAxisChartData.onThresholdValueChanged
                        ?.call(double.parse(value.toStringAsFixed(2)));
                  },
                ),
              ],
            ),
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
    double currentMin =
        -widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision *
            widget.oscilloscopeAxisChartData.numberOfDivisions;
    double currentMax =
        widget.oscilloscopeAxisChartData.verticalAxisValuePerDivision *
            widget.oscilloscopeAxisChartData.numberOfDivisions;

    double zoomedMin =
        calculateZoomedMin(currentMin, currentMax, _zoomFactor, _zoomPosition);
    double zoomedMax =
        calculateZoomedMax(zoomedMin, currentMin, currentMax, _zoomFactor);

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
          content: Directionality(
            textDirection: TextDirection.ltr,
            child: TextFormField(
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
                widget.oscilloscopeAxisChartData.onThresholdValueChanged
                    ?.call(double.parse(newValue.toStringAsFixed(2)));
              });
              Navigator.of(context).pop();
            },
          ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(widget.oscilloscopeAxisChartData.updateButtonLabel),
              onPressed: () {
                setState(() {
                  _thresholdValue = newValue;
                  _updateThresholdProgressbarValue(newValue);
                  widget.oscilloscopeAxisChartData.onThresholdValueChanged
                      ?.call(double.parse(newValue.toStringAsFixed(2)));
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
