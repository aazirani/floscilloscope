import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floscilloscope/floscilloscope.dart';

void main() {
  group('OscilloscopeAxisChartData', () {
    late List<List<OscilloscopePoint>> testDataPoints;

    setUp(() {
      testDataPoints = [
        [
          const OscilloscopePoint(0, 0),
          const OscilloscopePoint(1, 1),
          const OscilloscopePoint(2, 0.5),
        ],
        [
          const OscilloscopePoint(0, 1),
          const OscilloscopePoint(1, 2),
          const OscilloscopePoint(2, 1.5),
        ],
      ];
    });

    test('should create with required parameters', () {
      final data = OscilloscopeAxisChartData(
        dataPoints: testDataPoints,
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      );

      expect(data.dataPoints, equals(testDataPoints));
      expect(data.horizontalAxisLabel, equals('Time'));
      expect(data.verticalAxisLabel, equals('Voltage'));
      expect(data.horizontalAxisUnit, equals('s'));
      expect(data.verticalAxisUnit, equals('V'));
    });

    test('should use default values for optional parameters', () {
      final data = OscilloscopeAxisChartData(
        dataPoints: testDataPoints,
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      );

      expect(data.numberOfDivisions, equals(5));
      expect(data.horizontalAxisValuePerDivision, equals(1.0));
      expect(data.verticalAxisValuePerDivision, equals(1.0));
      expect(data.updateButtonLabel, equals('Update'));
      expect(data.cancelButtonLabel, equals('Cancel'));
      expect(data.thresholdLabel, equals('Threshold'));
      expect(data.isThresholdVisible, isTrue);
      expect(data.colors, equals([Colors.teal, Colors.yellow, Colors.purple]));
      expect(data.isThresholdSliderActive, isTrue);
      expect(data.threshold, equals(0.0));
      expect(data.enableTooltip, isFalse);
    });

    test('should accept custom values for optional parameters', () {
      final customColors = [Colors.red, Colors.blue];
      final extraPlotLines = {1.5: Colors.grey, 2.5: Colors.black};

      final data = OscilloscopeAxisChartData(
        dataPoints: testDataPoints,
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 'ms',
        verticalAxisUnit: 'mV',
        numberOfDivisions: 10,
        horizontalAxisValuePerDivision: 2.0,
        verticalAxisValuePerDivision: 0.5,
        updateButtonLabel: 'Apply',
        cancelButtonLabel: 'Dismiss',
        thresholdLabel: 'Voltage Threshold',
        isThresholdVisible: false,
        colors: customColors,
        isThresholdSliderActive: false,
        threshold: 1.5,
        thresholdDragStepSize: 0.1,
        extraPlotLines: extraPlotLines,
        enableTooltip: true,
      );

      expect(data.numberOfDivisions, equals(10));
      expect(data.horizontalAxisValuePerDivision, equals(2.0));
      expect(data.verticalAxisValuePerDivision, equals(0.5));
      expect(data.updateButtonLabel, equals('Apply'));
      expect(data.cancelButtonLabel, equals('Dismiss'));
      expect(data.thresholdLabel, equals('Voltage Threshold'));
      expect(data.isThresholdVisible, isFalse);
      expect(data.colors, equals(customColors));
      expect(data.isThresholdSliderActive, isFalse);
      expect(data.threshold, equals(1.5));
      expect(data.thresholdDragStepSize, equals(0.1));
      expect(data.extraPlotLines, equals(extraPlotLines));
      expect(data.enableTooltip, isTrue);
    });

    test('should handle empty data points', () {
      final data = OscilloscopeAxisChartData(
        dataPoints: <List<OscilloscopePoint>>[],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      );

      expect(data.dataPoints, isEmpty);
    });

    test('should handle single data series', () {
      final singleSeries = [
        [
          const OscilloscopePoint(0, 0),
          const OscilloscopePoint(1, 1),
        ]
      ];

      final data = OscilloscopeAxisChartData(
        dataPoints: singleSeries,
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      );

      expect(data.dataPoints.length, equals(1));
      expect(data.dataPoints[0].length, equals(2));
    });

    test('should handle threshold callback', () {
      double? callbackValue;
      
      final data = OscilloscopeAxisChartData(
        dataPoints: testDataPoints,
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
        onThresholdValueChanged: (value) => callbackValue = value,
      );

      expect(data.onThresholdValueChanged, isNotNull);
      
      // Test callback execution
      data.onThresholdValueChanged!(2.5);
      expect(callbackValue, equals(2.5));
    });
  });
}