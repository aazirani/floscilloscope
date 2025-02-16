import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final OscilloscopeAxisChartData _oscilloscopeAxisChartData = OscilloscopeAxisChartData(
      threshold: 2.0,
      thresholdDragStepSize: 2.0,
      dataPoints: [
        [
          const FlSpot(0, 0),
          const FlSpot(2, 3),
          const FlSpot(5, 10),
          const FlSpot(10, 10),
          const FlSpot(12, -45),
        ],
        [
          const FlSpot(1, 4),
          const FlSpot(75, 23),
          const FlSpot(19, -20),
        ],
        [
          const FlSpot(56, 2),
          const FlSpot(98, 101),
          const FlSpot(109, 150),
        ]
      ],
      numberOfDivisions: 5,
      horizontalAxisLabel: 'Time',
      horizontalAxisUnit: 'µs',
      verticalAxisLabel: 'Voltage',
      verticalAxisUnit: 'mV',
      updateButtonLabel: 'Update',
      onThresholdValueChanged: (value) => log(value.toString()),
      enableTooltip: true
  );

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
            Expanded(
                child: AlternativeSimpleOscilloscope(
                  oscilloscopeAxisChartData: _oscilloscopeAxisChartData,
                )
            ),
          ],
        ),
      ),
    );
  }

}
