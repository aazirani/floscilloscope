import 'package:fl_chart/fl_chart.dart';

class OscilloscopeAxisChartData {
  final List<FlSpot> dataPoints;
  final int numberOfDivisions;
  final String horizontalAxisTitlePerDivisionLabel;
  final String verticalAxisTitlePerDivisionLabel;
  final String horizontalAxisLabel;
  final String verticalAxisLabel;
  final String horizontalAxisUnit;
  final String verticalAxisUnit;
  final String updateButtonLabel;
  final String settingsTitleLabel;
  final double defaultHorizontalAxisValuePerDivision;
  final double defaultVerticalAxisValuePerDivision;

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
    this.settingsTitleLabel = 'Settings',
  });
}