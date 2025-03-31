import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A class representing the data for an oscilloscope axis chart.
class OscilloscopeAxisChartData {
  /// A list of data points for the chart.
  List<List<FlSpot>> dataPoints;

  /// The number of divisions on the chart.
  final int numberOfDivisions;

  /// The label for the horizontal axis.
  final String horizontalAxisLabel;

  /// The label for the vertical axis.
  final String verticalAxisLabel;

  /// The unit for the horizontal axis.
  final String horizontalAxisUnit;

  /// The unit for the vertical axis.
  final String verticalAxisUnit;

  /// The value per division for the horizontal axis.
  double horizontalAxisValuePerDivision;

  /// The value per division for the vertical axis.
  double verticalAxisValuePerDivision;

  /// The label for the update button.
  final String updateButtonLabel;

  /// The label for the cancel button.
  final String cancelButtonLabel;

  /// The label for the threshold.
  final String thresholdLabel;

  /// Whether the threshold is visible.
  final bool isThresholdVisible;

  /// A callback function that is called when the threshold value changes.
  final Function(double)? onThresholdValueChanged;

  /// A list of colors for the chart.
  final List<Color> colors;

  /// Whether the threshold slider is active.
  final bool isThresholdSliderActive;

  /// The threshold value.
  final double threshold;

  /// The step size for dragging the threshold.
  final double? thresholdDragStepSize;

  /// Extra plot lines on the chart.
  final Map<double, Color>? extraPlotLines;

  /// Whether tooltips are enabled.
  final bool enableTooltip;

  /// Creates a new instance of [OscilloscopeAxisChartData].
  OscilloscopeAxisChartData({
    required this.dataPoints,
    this.numberOfDivisions = 5,
    required this.horizontalAxisLabel,
    required this.verticalAxisLabel,
    required this.horizontalAxisUnit,
    required this.verticalAxisUnit,
    this.horizontalAxisValuePerDivision = 1.0,
    this.verticalAxisValuePerDivision = 1.0,
    this.updateButtonLabel = 'Update',
    this.cancelButtonLabel = 'Cancel',
    this.thresholdLabel = 'Threshold',
    this.isThresholdVisible = true,
    this.onThresholdValueChanged,
    this.colors = const [Colors.teal, Colors.yellow, Colors.purple],
    this.isThresholdSliderActive = true,
    this.threshold = 0.0,
    this.thresholdDragStepSize,
    this.extraPlotLines,
    this.enableTooltip = false,
  });
}
