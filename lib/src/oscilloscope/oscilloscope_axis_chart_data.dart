import 'package:fl_chart/fl_chart.dart';
import 'package:floscilloscope/src/oscilloscope/settings/dynamic_settings.dart';
import 'package:flutter/material.dart';

class OscilloscopeAxisChartData {
  List<List<FlSpot>> dataPoints;
  final int numberOfDivisions;
  final String horizontalAxisTitlePerDivisionLabel;
  final String verticalAxisTitlePerDivisionLabel;
  final String horizontalAxisLabel;
  final String verticalAxisLabel;
  final String horizontalAxisUnit;
  final String verticalAxisUnit;
  double horizontalAxisValuePerDivision;
  double verticalAxisValuePerDivision;
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
  final Widget settingsIcon;
  final List<DynamicSetting>? settings;

  OscilloscopeAxisChartData({
    required this.dataPoints,
    this.numberOfDivisions = 5,
    required this.horizontalAxisTitlePerDivisionLabel,
    required this.verticalAxisTitlePerDivisionLabel,
    required this.horizontalAxisLabel,
    required this.verticalAxisLabel,
    required this.horizontalAxisUnit,
    required this.verticalAxisUnit,
    this.horizontalAxisValuePerDivision = 1.0,
    this.verticalAxisValuePerDivision = 1.0,
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
    this.settingsIcon = const Icon(Icons.settings),
    this.settings
  });
}