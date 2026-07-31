import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:floscilloscope/floscilloscope.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'floscilloscope demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'floscilloscope streaming demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// A streaming demo: a 120ms timer overwrites a fixed-size buffer with a sine
/// wave on two channels, exercising the real-time data-update path of both
/// oscilloscopes (grow during warmup, same-length update afterwards).
class _MyHomePageState extends State<MyHomePage> {
  static const int _maxPoints = 40;
  static const Duration _tickInterval = Duration(milliseconds: 120);

  late final Timer _timer;
  late final OscilloscopeAxisChartData _chartData;
  int _tick = 0;

  final List<List<OscilloscopePoint>> _dataPoints = [
    <OscilloscopePoint>[const OscilloscopePoint(0, 0)],
    <OscilloscopePoint>[const OscilloscopePoint(0, 0)],
  ];

  @override
  void initState() {
    super.initState();
    _chartData = OscilloscopeAxisChartData(
      threshold: 2.0,
      thresholdDragStepSize: 2.0,
      dataPoints: _dataPoints,
      numberOfDivisions: 5,
      horizontalAxisValuePerDivision: 4.0,
      verticalAxisValuePerDivision: 1.0,
      horizontalAxisLabel: 'Time',
      horizontalAxisUnit: 'µs',
      verticalAxisLabel: 'Voltage',
      verticalAxisUnit: 'mV',
      updateButtonLabel: 'Update',
      onThresholdValueChanged: (value) => log('threshold=$value'),
      enableTooltip: true,
    );
    _timer = Timer.periodic(_tickInterval, (_) {
      _tick++;
      _appendData();
      setState(() {});
    });
  }

  void _appendData() {
    final int index = _tick % _maxPoints;
    final double phaseStep = _tick * 0.3;
    for (int s = 0; s < _dataPoints.length; s++) {
      final double phase = s == 0 ? 0.0 : pi;
      final double y = 5 * sin(phaseStep + phase);
      final List<OscilloscopePoint> series = _dataPoints[s];
      if (series.length < _maxPoints) {
        series.add(OscilloscopePoint(index.toDouble(), y));
      } else {
        series[index] = OscilloscopePoint(index.toDouble(), y);
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: SimpleOscilloscope(
                oscilloscopeAxisChartData: _chartData,
              ),
            ),
            Flexible(
              flex: 1,
              child: AlternativeSimpleOscilloscope(
                oscilloscopeAxisChartData: _chartData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
