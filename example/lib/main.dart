import 'dart:developer';

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
  final OscilloscopeAxisChartData _oscilloscopeAxisChartData =
      OscilloscopeAxisChartData(
          threshold: 2.0,
          thresholdDragStepSize: 2.0,
          dataPoints: [
            [
              const OscilloscopePoint(0, 0),
              const OscilloscopePoint(2, 3),
              const OscilloscopePoint(5, 10),
              const OscilloscopePoint(10, 10),
              const OscilloscopePoint(12, -45),
            ],
            [
              const OscilloscopePoint(1, 4),
              const OscilloscopePoint(75, 23),
              const OscilloscopePoint(19, -20),
            ],
            [
              const OscilloscopePoint(56, 2),
              const OscilloscopePoint(98, 101),
              const OscilloscopePoint(109, 150),
            ]
          ],
          numberOfDivisions: 5,
          horizontalAxisLabel: 'Time',
          horizontalAxisUnit: 'µs',
          verticalAxisLabel: 'Voltage',
          verticalAxisUnit: 'mV',
          updateButtonLabel: 'Update',
          onThresholdValueChanged: (value) => log(value.toString()),
          enableTooltip: true);

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
                  oscilloscopeAxisChartData: _oscilloscopeAxisChartData,
                )),
            Flexible(
              flex: 1,
                child: AlternativeSimpleOscilloscope(
              oscilloscopeAxisChartData: _oscilloscopeAxisChartData,
            ))
          ],
        ),
      ),
    );
  }
}
