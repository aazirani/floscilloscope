import 'package:floscilloscope/src/oscilloscope/oscilloscope_point.dart';
import 'package:flutter/material.dart';

/// Configuration and data model for oscilloscope chart widgets.
///
/// This class contains all the necessary data and configuration options
/// to render an oscilloscope chart, including data points, axis labels,
/// threshold settings, colors, and various behavioral options.
///
/// The class supports multiple data series, customizable axes, interactive
/// thresholds, and extra plot lines for reference markers.
///
/// Example:
/// ```dart
/// final data = OscilloscopeAxisChartData(
///   dataPoints: [
///     [OscilloscopePoint(0, 0), OscilloscopePoint(1, 1)],
///     [OscilloscopePoint(0, 1), OscilloscopePoint(1, 2)],
///   ],
///   horizontalAxisLabel: 'Time',
///   verticalAxisLabel: 'Voltage',
///   horizontalAxisUnit: 's',
///   verticalAxisUnit: 'V',
///   threshold: 1.5,
///   colors: [Colors.blue, Colors.red],
/// );
/// ```
class OscilloscopeAxisChartData {
  /// A list of data series for the chart.
  ///
  /// Each inner list represents a separate data series that will be plotted
  /// as a distinct line on the oscilloscope. Multiple series allow for
  /// comparison of different signals or measurements.
  ///
  /// Example:
  /// ```dart
  /// dataPoints: [
  ///   [OscilloscopePoint(0, 0), OscilloscopePoint(1, 1)], // Series 1
  ///   [OscilloscopePoint(0, 1), OscilloscopePoint(1, 2)], // Series 2
  /// ]
  /// ```
  List<List<OscilloscopePoint>> dataPoints;

  /// The number of grid divisions displayed on the chart.
  ///
  /// This determines how many major grid lines are shown on both axes,
  /// providing visual reference points for reading measurements.
  /// Default value is 5.
  final int numberOfDivisions;

  /// The label for the horizontal axis.
  ///
  /// This typically describes what the x-axis represents, such as 'Time',
  /// 'Frequency', or 'Sample Number'.
  final String horizontalAxisLabel;

  /// The label for the vertical axis.
  ///
  /// This typically describes what the y-axis represents, such as 'Voltage',
  /// 'Amplitude', or 'Current'.
  final String verticalAxisLabel;

  /// The unit of measurement for the horizontal axis.
  ///
  /// Examples: 's', 'ms', 'Hz', 'kHz'. This is displayed alongside
  /// the horizontal axis values.
  final String horizontalAxisUnit;

  /// The unit of measurement for the vertical axis.
  ///
  /// Examples: 'V', 'mV', 'A', 'mA'. This is displayed alongside
  /// the vertical axis values.
  final String verticalAxisUnit;

  /// The value represented by each division on the horizontal axis.
  ///
  /// This determines the scale of the horizontal axis. For example,
  /// if set to 1.0, each major grid line represents 1 unit.
  /// Default value is 1.0.
  double horizontalAxisValuePerDivision;

  /// The value represented by each division on the vertical axis.
  ///
  /// This determines the scale of the vertical axis. For example,
  /// if set to 0.5, each major grid line represents 0.5 units.
  /// Default value is 1.0.
  double verticalAxisValuePerDivision;

  /// The text displayed on the update/apply button in threshold dialogs.
  ///
  /// This button confirms threshold value changes when users interact
  /// with threshold adjustment dialogs. Default value is 'Update'.
  final String updateButtonLabel;

  /// The text displayed on the cancel/dismiss button in threshold dialogs.
  ///
  /// This button cancels threshold value changes when users interact
  /// with threshold adjustment dialogs. Default value is 'Cancel'.
  final String cancelButtonLabel;

  /// The label displayed for the threshold setting.
  ///
  /// This text appears in threshold-related UI elements to identify
  /// the threshold value setting. Default value is 'Threshold'.
  final String thresholdLabel;

  /// Whether the threshold line should be displayed on the chart.
  ///
  /// When true, a horizontal line is drawn at the threshold value,
  /// providing a visual reference. Default value is true.
  final bool isThresholdVisible;

  /// Callback function invoked when the threshold value changes.
  ///
  /// This function receives the new threshold value as a parameter
  /// and can be used to respond to threshold adjustments made by the user.
  ///
  /// Example:
  /// ```dart
  /// onThresholdValueChanged: (value) {
  ///   print('New threshold: $value');
  ///   // Update your application state
  /// }
  /// ```
  final Function(double)? onThresholdValueChanged;

  /// Colors used for rendering different data series.
  ///
  /// Each data series is assigned a color from this list in order.
  /// If there are more series than colors, colors are recycled.
  /// Default colors are [Colors.teal, Colors.yellow, Colors.purple].
  final List<Color> colors;

  /// Whether the threshold slider control is enabled.
  ///
  /// When true, users can interact with a slider to adjust the threshold
  /// value dynamically. Default value is true.
  final bool isThresholdSliderActive;

  /// The current threshold value.
  ///
  /// This horizontal reference line helps identify when signals cross
  /// a specific amplitude level. Default value is 0.0.
  final double threshold;

  /// The increment/decrement step size when adjusting the threshold.
  ///
  /// This determines how much the threshold value changes with each
  /// adjustment when using drag gestures or step controls. If null,
  /// smooth continuous adjustment is used.
  final double? thresholdDragStepSize;

  /// Additional horizontal reference lines to display on the chart.
  ///
  /// The map keys represent the y-axis values where lines should be drawn,
  /// and the values represent the colors of those lines. These provide
  /// additional reference markers beyond the main threshold.
  ///
  /// Example:
  /// ```dart
  /// extraPlotLines: {
  ///   1.5: Colors.grey,   // Grey line at y=1.5
  ///   2.5: Colors.black, // Black line at y=2.5
  /// }
  /// ```
  final Map<double, Color>? extraPlotLines;

  /// Whether interactive tooltips are enabled for data points.
  ///
  /// When true, users can hover over or tap data points to see their
  /// exact values. Default value is false.
  final bool enableTooltip;

  /// Creates a new instance of [OscilloscopeAxisChartData].
  ///
  /// The [dataPoints], [horizontalAxisLabel], [verticalAxisLabel],
  /// [horizontalAxisUnit], and [verticalAxisUnit] parameters are required.
  /// All other parameters have sensible defaults and are optional.
  ///
  /// Example:
  /// ```dart
  /// final data = OscilloscopeAxisChartData(
  ///   dataPoints: [
  ///     [OscilloscopePoint(0, 0), OscilloscopePoint(1, 1)],
  ///   ],
  ///   horizontalAxisLabel: 'Time',
  ///   verticalAxisLabel: 'Voltage',
  ///   horizontalAxisUnit: 's',
  ///   verticalAxisUnit: 'V',
  ///   threshold: 0.5,
  ///   colors: [Colors.blue],
  /// );
  /// ```
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
