/// A Flutter package providing customizable oscilloscope widgets for data visualization.
///
/// This library offers multiple oscilloscope widget implementations with features
/// like threshold manipulation, zoom/pan capabilities, multi-series support,
/// and interactive controls. Perfect for scientific applications, signal analysis,
/// or any use case requiring real-time data visualization.
///
/// ## Main Widgets
///
/// - [SimpleOscilloscope]: Basic oscilloscope using fl_chart (lightweight)
/// - [AlternativeSimpleOscilloscope]: Advanced oscilloscope with zoom/pan using Syncfusion
/// - [ThresholdSlider]: Interactive threshold adjustment control
///
/// ## Data Models
///
/// - [OscilloscopeAxisChartData]: Configuration and data container
/// - [OscilloscopePoint]: Individual data point representation
///
/// ## Quick Start
///
/// ```dart
/// import 'package:floscilloscope/floscilloscope.dart';
///
/// // Create some sample data
/// final data = OscilloscopeAxisChartData(
///   dataPoints: [
///     [OscilloscopePoint(0, 0), OscilloscopePoint(1, 1)],
///   ],
///   horizontalAxisLabel: 'Time',
///   verticalAxisLabel: 'Voltage',
///   horizontalAxisUnit: 's',
///   verticalAxisUnit: 'V',
/// );
///
/// // Use the simple oscilloscope
/// SimpleOscilloscope(oscilloscopeAxisChartData: data)
///
/// // Or use the advanced version with zoom/pan
/// AlternativeSimpleOscilloscope(oscilloscopeAxisChartData: data)
/// ```
library;

export 'src/oscilloscope/alternative_simple_oscilloscope.dart';
export 'src/oscilloscope/oscilloscope_point.dart';
export 'src/oscilloscope/oscilloscope_axis_chart_data.dart';
export 'src/oscilloscope/simple_oscilloscope.dart';
export 'src/oscilloscope/threshold_slider.dart';
