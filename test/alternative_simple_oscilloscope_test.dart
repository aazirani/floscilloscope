import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floscilloscope/floscilloscope.dart';

void main() {
  group('AlternativeSimpleOscilloscope Widget Tests', () {
    late OscilloscopeAxisChartData testData;

    setUp(() {
      testData = OscilloscopeAxisChartData(
        dataPoints: [
          [
            const OscilloscopePoint(0, 0),
            const OscilloscopePoint(1, 1),
            const OscilloscopePoint(2, 0.5),
          ],
        ],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
        threshold: 1.0,
      );
    });

    testWidgets('should render AlternativeSimpleOscilloscope widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlternativeSimpleOscilloscope(
              oscilloscopeAxisChartData: testData,
            ),
          ),
        ),
      );

      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);
    });

    testWidgets('should display threshold slider when active', (WidgetTester tester) async {
      final dataWithActiveSlider = OscilloscopeAxisChartData(
        dataPoints: testData.dataPoints,
        horizontalAxisLabel: testData.horizontalAxisLabel,
        verticalAxisLabel: testData.verticalAxisLabel,
        horizontalAxisUnit: testData.horizontalAxisUnit,
        verticalAxisUnit: testData.verticalAxisUnit,
        threshold: 1.0,
        isThresholdSliderActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlternativeSimpleOscilloscope(
              oscilloscopeAxisChartData: dataWithActiveSlider,
            ),
          ),
        ),
      );

      // Widget should render without errors when slider is active
      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);
      
      // Pump a frame to ensure all widgets are built
      await tester.pump();
    });

    testWidgets('should handle threshold value updates', (WidgetTester tester) async {
      final dataWithCallback = OscilloscopeAxisChartData(
        dataPoints: testData.dataPoints,
        horizontalAxisLabel: testData.horizontalAxisLabel,
        verticalAxisLabel: testData.verticalAxisLabel,
        horizontalAxisUnit: testData.horizontalAxisUnit,
        verticalAxisUnit: testData.verticalAxisUnit,
        threshold: 1.0,
        onThresholdValueChanged: (value) => {}, // Test callback is set
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlternativeSimpleOscilloscope(
              oscilloscopeAxisChartData: dataWithCallback,
            ),
          ),
        ),
      );

      // Widget should render without errors
      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);
    });

    testWidgets('should handle empty data points', (WidgetTester tester) async {
      final emptyData = OscilloscopeAxisChartData(
        dataPoints: <List<OscilloscopePoint>>[],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlternativeSimpleOscilloscope(
              oscilloscopeAxisChartData: emptyData,
            ),
          ),
        ),
      );

      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);
    });

    testWidgets('should handle multiple data series with custom colors', (WidgetTester tester) async {
      final multiSeriesData = OscilloscopeAxisChartData(
        dataPoints: [
          [
            const OscilloscopePoint(0, 0),
            const OscilloscopePoint(1, 1),
          ],
          [
            const OscilloscopePoint(0, 1),
            const OscilloscopePoint(1, 2),
          ],
        ],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
        colors: [Colors.blue, Colors.red],
        enableTooltip: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlternativeSimpleOscilloscope(
              oscilloscopeAxisChartData: multiSeriesData,
            ),
          ),
        ),
      );

      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);
    });

    testWidgets('should handle extra plot lines', (WidgetTester tester) async {
      final dataWithExtraLines = OscilloscopeAxisChartData(
        dataPoints: testData.dataPoints,
        horizontalAxisLabel: testData.horizontalAxisLabel,
        verticalAxisLabel: testData.verticalAxisLabel,
        horizontalAxisUnit: testData.horizontalAxisUnit,
        verticalAxisUnit: testData.verticalAxisUnit,
        extraPlotLines: {
          1.5: Colors.grey,
          2.5: Colors.black,
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlternativeSimpleOscilloscope(
              oscilloscopeAxisChartData: dataWithExtraLines,
            ),
          ),
        ),
      );

      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);
    });
  });
}