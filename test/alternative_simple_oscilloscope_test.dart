import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floscilloscope/floscilloscope.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

    testWidgets('exposes a public state reachable via GlobalKey', (WidgetTester tester) async {
      final key = GlobalKey<AlternativeSimpleOscilloscopeState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlternativeSimpleOscilloscope(
              key: key,
              oscilloscopeAxisChartData: testData,
            ),
          ),
        ),
      );

      expect(key.currentState, isA<AlternativeSimpleOscilloscopeState>());
    });

    testWidgets('handles data shrink without throwing', (WidgetTester tester) async {
      final harnessKey = GlobalKey<_DataHarnessState>();
      final shorter = OscilloscopeAxisChartData(
        dataPoints: [
          [const OscilloscopePoint(0, 0)],
        ],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _DataHarness(key: harnessKey, data: testData),
          ),
        ),
      );
      await tester.pump();

      harnessKey.currentState!.replace(shorter);
      await tester.pump();

      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);
    });

    testWidgets('handles data grow without throwing', (WidgetTester tester) async {
      final harnessKey = GlobalKey<_DataHarnessState>();
      final longer = OscilloscopeAxisChartData(
        dataPoints: [
          [
            const OscilloscopePoint(0, 0),
            const OscilloscopePoint(1, 1),
            const OscilloscopePoint(2, 2),
            const OscilloscopePoint(3, 3),
            const OscilloscopePoint(4, 4),
          ],
        ],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _DataHarness(key: harnessKey, data: testData),
          ),
        ),
      );
      await tester.pump();

      harnessKey.currentState!.replace(longer);
      await tester.pump();

      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);
    });

    testWidgets('handles series count changes without throwing', (WidgetTester tester) async {
      final harnessKey = GlobalKey<_DataHarnessState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _DataHarness(key: harnessKey, data: testData),
          ),
        ),
      );
      await tester.pump();

      harnessKey.currentState!.replace(OscilloscopeAxisChartData(
        dataPoints: <List<OscilloscopePoint>>[],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      ));
      await tester.pump();

      harnessKey.currentState!.replace(OscilloscopeAxisChartData(
        dataPoints: [
          [const OscilloscopePoint(0, 0)],
          [const OscilloscopePoint(0, 1)],
          [const OscilloscopePoint(0, 2)],
        ],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      ));
      await tester.pump();

      harnessKey.currentState!.replace(testData);
      await tester.pump();

      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);
    });

    testWidgets('clearData() immediately empties the chart without throwing', (WidgetTester tester) async {
      final chartKey = GlobalKey<AlternativeSimpleOscilloscopeState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlternativeSimpleOscilloscope(
              key: chartKey,
              oscilloscopeAxisChartData: testData,
            ),
          ),
        ),
      );
      await tester.pump();

      chartKey.currentState!.clearData();
      await tester.pump();

      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);
      expect(chartKey.currentState, isNotNull);
    });

    testWidgets('chart can be repopulated after clearData()', (WidgetTester tester) async {
      final chartKey = GlobalKey<AlternativeSimpleOscilloscopeState>();
      final harnessKey = GlobalKey<_DataWrapperState>();
      final freshData = OscilloscopeAxisChartData(
        dataPoints: [
          [const OscilloscopePoint(5, 5), const OscilloscopePoint(6, 6)],
        ],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _DataWrapper(
              key: harnessKey,
              chartKey: chartKey,
              data: testData,
            ),
          ),
        ),
      );
      await tester.pump();

      harnessKey.currentState!.clearAndReplace(freshData);
      await tester.pump();

      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);
    });

    testWidgets('recaptures series controllers after a count change',
        (WidgetTester tester) async {
      final chartKey = GlobalKey<AlternativeSimpleOscilloscopeState>();
      final harnessKey = GlobalKey<_DataHarnessState>();

      final threeSeries = OscilloscopeAxisChartData(
        dataPoints: [
          [const OscilloscopePoint(0, 0), const OscilloscopePoint(1, 1)],
          [const OscilloscopePoint(0, 1), const OscilloscopePoint(1, 2)],
          [const OscilloscopePoint(0, 2), const OscilloscopePoint(1, 3)],
        ],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      );
      final oneSeries = OscilloscopeAxisChartData(
        dataPoints: [
          [
            const OscilloscopePoint(0, 0),
            const OscilloscopePoint(1, 1),
            const OscilloscopePoint(2, 2)
          ],
        ],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _DataHarness(
                key: harnessKey, chartKey: chartKey, data: threeSeries),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(chartKey.currentState!.controllerCount, 3);

      // Shrink 3 -> 1: surviving series must recapture its controller.
      harnessKey.currentState!.replace(oneSeries);
      await tester.pumpAndSettle();
      expect(chartKey.currentState!.controllerCount, 1);

      // A subsequent same-count data update must still reach the controller
      // (this is exactly the stale-data regression).
      harnessKey.currentState!.replace(OscilloscopeAxisChartData(
        dataPoints: [
          [
            const OscilloscopePoint(0, 5),
            const OscilloscopePoint(1, 6),
            const OscilloscopePoint(2, 7)
          ],
        ],
        horizontalAxisLabel: 'Time',
        verticalAxisLabel: 'Voltage',
        horizontalAxisUnit: 's',
        verticalAxisUnit: 'V',
      ));
      await tester.pumpAndSettle();
      expect(chartKey.currentState!.controllerCount, 1);

      // Grow 1 -> 3.
      harnessKey.currentState!.replace(threeSeries);
      await tester.pumpAndSettle();
      expect(chartKey.currentState!.controllerCount, 3);
    });

    testWidgets('threshold value is not reverted by a data-tick rebuild',
        (WidgetTester tester) async {
      final chartKey = GlobalKey<AlternativeSimpleOscilloscopeState>();
      final harnessKey = GlobalKey<_DataHarnessState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _DataHarness(
                key: harnessKey, chartKey: chartKey, data: testData),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(chartKey.currentState!.currentThresholdValue, 1.0);

      // Simulate a user drag that set the local threshold.
      chartKey.currentState!.currentThresholdValue = 3.5;

      // Data-tick rebuild with the SAME threshold prop (consumer did not
      // round-trip the dragged value back into the data model).
      harnessKey.currentState!.replace(testData);
      await tester.pumpAndSettle();

      // Must NOT have reverted to the prop value.
      expect(chartKey.currentState!.currentThresholdValue, 3.5);
    });

    testWidgets('wraps the chart in a RepaintBoundary',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlternativeSimpleOscilloscope(
              oscilloscopeAxisChartData: testData,
            ),
          ),
        ),
      );
      await tester.pump();

      final chart = find.byType(SfCartesianChart);
      expect(chart, findsOneWidget);
      expect(
        find.ancestor(of: chart, matching: find.byType(RepaintBoundary)),
        findsWidgets,
      );
    });

    testWidgets(
        'threshold slider drag-end without a callback reverts to the prop threshold',
        (WidgetTester tester) async {
      final key = GlobalKey<AlternativeSimpleOscilloscopeState>();
      final data = OscilloscopeAxisChartData(
        dataPoints: testData.dataPoints,
        horizontalAxisLabel: testData.horizontalAxisLabel,
        verticalAxisLabel: testData.verticalAxisLabel,
        horizontalAxisUnit: testData.horizontalAxisUnit,
        verticalAxisUnit: testData.verticalAxisUnit,
        threshold: 2.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlternativeSimpleOscilloscope(
              key: key,
              oscilloscopeAxisChartData: data,
            ),
          ),
        ),
      );

      final slider =
          tester.widget<ThresholdSlider>(find.byType(ThresholdSlider));
      slider.onChangeEnd(4.5);
      await tester.pump();

      expect(key.currentState!.currentThresholdValue, 2.0);
    });

    testWidgets(
        'threshold slider drag-end with a callback commits the value and invokes the callback',
        (WidgetTester tester) async {
      final key = GlobalKey<AlternativeSimpleOscilloscopeState>();
      double? receivedValue;
      final data = OscilloscopeAxisChartData(
        dataPoints: testData.dataPoints,
        horizontalAxisLabel: testData.horizontalAxisLabel,
        verticalAxisLabel: testData.verticalAxisLabel,
        horizontalAxisUnit: testData.horizontalAxisUnit,
        verticalAxisUnit: testData.verticalAxisUnit,
        threshold: 2.0,
        onThresholdValueChanged: (value) => receivedValue = value,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlternativeSimpleOscilloscope(
              key: key,
              oscilloscopeAxisChartData: data,
            ),
          ),
        ),
      );

      final slider =
          tester.widget<ThresholdSlider>(find.byType(ThresholdSlider));
      slider.onChangeEnd(4.5);
      await tester.pump();

      expect(key.currentState!.currentThresholdValue, 4.5);
      expect(receivedValue, 4.5);
    });
  });
}

class _DataHarness extends StatefulWidget {
  final OscilloscopeAxisChartData data;
  final GlobalKey<AlternativeSimpleOscilloscopeState>? chartKey;
  const _DataHarness({super.key, required this.data, this.chartKey});

  @override
  State<_DataHarness> createState() => _DataHarnessState();
}

class _DataHarnessState extends State<_DataHarness> {
  late OscilloscopeAxisChartData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  void replace(OscilloscopeAxisChartData data) {
    setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    return AlternativeSimpleOscilloscope(
      key: widget.chartKey,
      oscilloscopeAxisChartData: _data,
    );
  }
}

class _DataWrapper extends StatefulWidget {
  final GlobalKey<AlternativeSimpleOscilloscopeState> chartKey;
  final OscilloscopeAxisChartData data;
  const _DataWrapper({
    super.key,
    required this.chartKey,
    required this.data,
  });

  @override
  State<_DataWrapper> createState() => _DataWrapperState();
}

class _DataWrapperState extends State<_DataWrapper> {
  late OscilloscopeAxisChartData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  void clearAndReplace(OscilloscopeAxisChartData data) {
    widget.chartKey.currentState?.clearData();
    setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    return AlternativeSimpleOscilloscope(
      key: widget.chartKey,
      oscilloscopeAxisChartData: _data,
    );
  }
}