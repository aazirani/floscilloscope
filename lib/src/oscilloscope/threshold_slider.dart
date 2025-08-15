import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

/// A specialized slider widget for adjusting oscilloscope threshold values.
///
/// This widget provides an interactive slider control specifically designed
/// for threshold value adjustment in oscilloscope applications. It uses
/// Syncfusion's slider components to offer smooth interaction and precise
/// value control with optional step increments.
///
/// Features:
/// - Smooth value adjustment with optional step increments
/// - Visual feedback with customizable tooltips
/// - Double-tap support for quick reset or special actions
/// - Responsive design with configurable padding
/// - Active/inactive states for dynamic enabling/disabling
/// - Integration with oscilloscope threshold visualization
///
/// The slider is typically used in conjunction with [SimpleOscilloscope]
/// or [AlternativeSimpleOscilloscope] widgets to provide users with an
/// intuitive way to adjust threshold values.
///
/// Example usage:
/// ```dart
/// ThresholdSlider(
///   min: 0.0,
///   max: 5.0,
///   value: 2.5,
///   sliderBottomPadding: 16.0,
///   isSliderActive: true,
///   isThresholdVisible: true,
///   stepSize: 0.1,
///   thresholdValue: 2.5,
///   onChanged: (value) => setState(() => _threshold = value),
///   onChangeEnd: (value) => print('Final threshold: $value'),
/// )
/// ```
class ThresholdSlider extends StatefulWidget {
  /// The minimum allowable value for the threshold slider.
  ///
  /// This establishes the lower bound of the slider's range and should
  /// typically correspond to the minimum expected threshold value.
  final double min;

  /// The maximum allowable value for the threshold slider.
  ///
  /// This establishes the upper bound of the slider's range and should
  /// typically correspond to the maximum expected threshold value.
  final double max;

  /// The current value displayed and controlled by the slider.
  ///
  /// This represents the active threshold value and should be within
  /// the range defined by [min] and [max].
  final double value;

  /// The bottom padding applied to the slider widget.
  ///
  /// This controls the spacing between the slider and other UI elements
  /// below it, allowing for proper visual separation and layout.
  final double sliderBottomPadding;

  /// Whether the slider is currently active and interactive.
  ///
  /// When false, the slider is disabled and does not respond to user
  /// input. This is useful for temporarily disabling threshold adjustment.
  final bool isSliderActive;

  /// Whether the threshold visualization should be visible.
  ///
  /// This controls whether threshold-related visual elements are shown
  /// in the interface. When false, the slider may be hidden or styled
  /// differently to indicate it's not currently relevant.
  final bool isThresholdVisible;

  /// The increment/decrement step size for discrete value adjustment.
  ///
  /// When specified, the slider will snap to multiples of this value,
  /// providing precise control over threshold adjustments. If null,
  /// the slider allows continuous value adjustment.
  final double? stepSize;

  /// The current threshold value being controlled.
  ///
  /// This should match the [value] parameter and represents the actual
  /// threshold level displayed on the oscilloscope chart.
  final double thresholdValue;

  /// Optional tooltip text displayed when interacting with the slider.
  ///
  /// This provides contextual information about the current threshold
  /// value or usage instructions to help users understand the control.
  final String? tooltipText;

  /// Callback function invoked when the slider is double-tapped.
  ///
  /// This can be used for special actions like resetting the threshold
  /// to a default value or opening configuration dialogs.
  final VoidCallback? onDoubleTap;

  /// Callback function invoked when the slider value changes.
  ///
  /// This is called continuously as the user drags the slider, allowing
  /// for real-time updates to the threshold visualization.
  ///
  /// The parameter contains the new threshold value.
  final ValueChanged<dynamic> onChanged;

  /// Callback function invoked when the slider interaction completes.
  ///
  /// This is called when the user finishes adjusting the slider value,
  /// typically used for final value processing or triggering related actions.
  ///
  /// The parameter contains the final threshold value.
  final ValueChanged<dynamic> onChangeEnd;

  /// Creates a [ThresholdSlider] widget.
  ///
  /// All parameters except [stepSize], [tooltipText], and [onDoubleTap]
  /// are required. The [value] should be within the range defined by
  /// [min] and [max].
  ///
  /// Example:
  /// ```dart
  /// ThresholdSlider(
  ///   min: 0.0,
  ///   max: 10.0,
  ///   value: 5.0,
  ///   sliderBottomPadding: 16.0,
  ///   isSliderActive: true,
  ///   isThresholdVisible: true,
  ///   thresholdValue: 5.0,
  ///   onChanged: (value) => updateThreshold(value),
  ///   onChangeEnd: (value) => finalizeThreshold(value),
  /// )
  /// ```
  const ThresholdSlider({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.sliderBottomPadding,
    required this.isSliderActive,
    required this.isThresholdVisible,
    this.stepSize,
    required this.thresholdValue,
    this.tooltipText,
    this.onDoubleTap,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  State<ThresholdSlider> createState() => _ThresholdSliderState();
}

/// The state for the [ThresholdSlider] widget.
class _ThresholdSliderState extends State<ThresholdSlider> {
  late double _tempThresholdValue;
  bool _isUserDragging = false; // New flag to track user interaction

  @override
  void initState() {
    super.initState();
    _tempThresholdValue = widget.thresholdValue;
  }

  @override
  void didUpdateWidget(covariant ThresholdSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isUserDragging) {
      _tempThresholdValue = widget.thresholdValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isThresholdVisible
        ? RepaintBoundary(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, widget.sliderBottomPadding),
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onDoubleTap: widget.onDoubleTap,
                      child: SfSliderTheme(
                        data: SfSliderThemeData(
                          activeTrackHeight: 5,
                          inactiveTrackHeight: 5,
                          overlayRadius: 0,
                          thumbRadius: 0,
                          labelOffset: const Offset(60, 0),
                          disabledActiveTrackColor:
                              Theme.of(context).disabledColor,
                          disabledInactiveTrackColor:
                              Theme.of(context).disabledColor,
                        ),
                        child: SfSlider.vertical(
                          stepSize: widget.stepSize,
                          tooltipTextFormatterCallback:
                              (dynamic actualValue, String formattedText) =>
                                  _tempThresholdValue.toStringAsFixed(2),
                          overlayShape:
                              const CustomOverlayShape(overlayRadius: 10),
                          thumbShape: const CustomThumbShape(thumbRadius: 10),
                          min: widget.min,
                          max: widget.max,
                          value: widget.value,
                          showTicks: false,
                          showLabels: false,
                          enableTooltip: true,
                          tooltipPosition: SliderTooltipPosition.left,
                          activeColor: Theme.of(context).primaryColor,
                          inactiveColor: Theme.of(context).primaryColor,
                          minorTicksPerInterval: 1,
                          onChanged: (value) {
                            if (widget.isSliderActive) {
                              setState(() {
                                _isUserDragging = true;
                                _tempThresholdValue = value;
                              });
                              widget.onChanged(value);
                            }
                          },
                          onChangeEnd: (value) {
                            setState(() {
                              _isUserDragging = false;
                              _tempThresholdValue = value;
                            });
                            widget.onChangeEnd(value);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}

/// Custom thumb shape for the slider.
class CustomThumbShape extends SfThumbShape {
  /// The radius of the thumb.
  final double thumbRadius;

  /// Creates a [CustomThumbShape] with the given [thumbRadius].
  const CustomThumbShape({required this.thumbRadius});

  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required RenderBox? child,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required SfThumb? thumb}) {
    final Paint paint = Paint()..color = themeData.thumbColor ?? Colors.blue;
    context.canvas.drawCircle(center, thumbRadius, paint);
  }
}

/// Custom overlay shape for the slider.
class CustomOverlayShape extends SfOverlayShape {
  /// The radius of the overlay.
  final double overlayRadius;

  /// Creates a [CustomOverlayShape] with the given [overlayRadius].
  const CustomOverlayShape({required this.overlayRadius});

  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> animation,
      required SfThumb? thumb}) {
    final Paint paint = Paint()..color = themeData.thumbColor ?? Colors.blue;
    context.canvas.drawCircle(center, overlayRadius, paint);
  }
}
