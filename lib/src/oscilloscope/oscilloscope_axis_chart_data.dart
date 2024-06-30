import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OscilloscopeAxisChartData {
  final List<List<FlSpot>> dataPoints;
  final int numberOfDivisions;
  final String horizontalAxisTitlePerDivisionLabel;
  final String verticalAxisTitlePerDivisionLabel;
  final String horizontalAxisLabel;
  final String verticalAxisLabel;
  final String horizontalAxisUnit;
  final String verticalAxisUnit;
  final double defaultHorizontalAxisValuePerDivision;
  final double defaultVerticalAxisValuePerDivision;
  final String updateButtonLabel;
  final String cancelButtonLabel;
  final String settingsTitleLabel;
  final String thresholdLabel;
  final bool isThresholdVisible;
  final Function(double)? onThresholdValueChanged;
  final Function(double, double)? onValuePerDivisionsChanged;
  final double pointRadius;
  final List<Color> colors;
  final bool isThresholdSliderActive;

  OscilloscopeAxisChartData({
    required this.dataPoints,
    this.numberOfDivisions = 5,
    required this.horizontalAxisTitlePerDivisionLabel,
    required this.verticalAxisTitlePerDivisionLabel,
    required this.horizontalAxisLabel,
    required this.verticalAxisLabel,
    required this.horizontalAxisUnit,
    required this.verticalAxisUnit,
    this.defaultHorizontalAxisValuePerDivision = 1.0,
    this.defaultVerticalAxisValuePerDivision = 1.0,
    this.updateButtonLabel = 'Update',
    this.cancelButtonLabel = 'Cancel',
    this.settingsTitleLabel = 'Settings',
    this.thresholdLabel = 'Threshold',
    this.isThresholdVisible = true,
    this.onThresholdValueChanged,
    this.onValuePerDivisionsChanged,
    this.pointRadius = 1.0,
    this.colors = const [Colors.teal, Colors.yellow, Colors.purple],
    this.isThresholdSliderActive = true,
  });
}