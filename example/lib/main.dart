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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
            Expanded(
              child: SimpleOscilloscope(
                oscilloscopeAxisChartData: OscilloscopeAxisChartData(
                  dataPoints: [
                    const FlSpot(5, 10),
                    const FlSpot(10, 10),
                    const FlSpot(12, -45),
                  ],
                  numberOfDivisions: 5,
                  horizontalAxisTitlePerDivisionLabel: 'Time/Division',
                  horizontalAxisLabel: 'Time',
                  horizontalAxisUnit: 'µs',
                  verticalAxisTitlePerDivisionLabel: 'Voltage/Division',
                  verticalAxisLabel: 'Voltage',
                  verticalAxisUnit: 'mV',
                  settingsTitleLabel: 'Settings',
                  updateButtonLabel: 'Update',
                  onThresholdValueChanged: (value) => log(value.toString())
                ),
              )
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
