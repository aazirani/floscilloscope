import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OscilloscopeAxisChartData {
  List<List<FlSpot>> dataPoints;
  final int numberOfDivisions;
  final String horizontalAxisLabel;
  final String verticalAxisLabel;
  final String horizontalAxisUnit;
  final String verticalAxisUnit;
  double horizontalAxisValuePerDivision;
  double verticalAxisValuePerDivision;
  final String updateButtonLabel;
  final String cancelButtonLabel;
  final String thresholdLabel;
  final bool isThresholdVisible;
  final Function(double)? onThresholdValueChanged;
  final List<Color> colors;
  final bool isThresholdSliderActive;
  final double threshold;
  final double? thresholdDragStepSize;

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
    this.thresholdDragStepSize
  });
}