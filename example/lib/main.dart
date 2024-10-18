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

  OscilloscopeAxisChartData _oscilloscopeAxisChartData = OscilloscopeAxisChartData(
      chartTitle: "Oscilloscope",
      dataPoints: [
        [
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
      horizontalAxisTitlePerDivisionLabel: 'Time/Division',
      horizontalAxisLabel: 'Time',
      horizontalAxisUnit: 'µs',
      verticalAxisTitlePerDivisionLabel: 'Voltage/Division',
      verticalAxisLabel: 'Voltage',
      verticalAxisUnit: 'mV',
      settingsTitleLabel: 'Settings',
      updateButtonLabel: 'Update',
      onThresholdValueChanged: (value) => log(value.toString()),
      settings: [DynamicSetting(
        order: 0,
        widgetBuilder: (context, controller, focusNode, onSubmitted) {
          // A dropdown instead of a text field
          return DropdownButtonFormField<double>(
            value: double.tryParse(controller.text),
            decoration: const InputDecoration(
              labelText: 'Vertical Axis (V)',
              border: OutlineInputBorder(),
            ),
            items: [1.0, 2.5, 5.0, 10.0].map((value) {
              return DropdownMenuItem<double>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                controller.text = newValue.toString();
              }
            },
          );
        },
      ),
      ]
  );

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
                  oscilloscopeAxisChartData: _oscilloscopeAxisChartData,
                  onSettingsChanged: _handleSettingsChanged,
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

  void _handleSettingsChanged(OscilloscopeAxisChartData newData) {
    setState(() {
      _oscilloscopeAxisChartData = newData;
    });
  }

}
