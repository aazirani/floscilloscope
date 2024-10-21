import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class ThresholdSlider extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final double sliderBottomPadding;
  final bool isSliderActive;
  final bool isThresholdVisible;
  final double? stepSize;
  final double thresholdValue;
  final String? tooltipText;
  final VoidCallback? onDoubleTap;
  final ValueChanged<dynamic>? onChanged;
  final ValueChanged<dynamic>? onChangeEnd;

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
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return isThresholdVisible
        ? RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, sliderBottomPadding),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onDoubleTap: onDoubleTap,
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
                    stepSize: stepSize,
                    tooltipTextFormatterCallback: (dynamic actualValue,
                        String formattedText) =>
                        thresholdValue.toStringAsFixed(2),
                    overlayShape:
                    const CustomOverlayShape(overlayRadius: 10),
                    thumbShape: const CustomThumbShape(thumbRadius: 10),
                    min: min,
                    max: max,
                    value: value,
                    showTicks: false,
                    showLabels: false,
                    enableTooltip: true,
                    tooltipPosition: SliderTooltipPosition.left,
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Theme.of(context).primaryColor,
                    minorTicksPerInterval: 1,
                    onChanged: isSliderActive ? onChanged : null,
                    onChangeEnd: onChangeEnd,
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

// Custom thumb shape
class CustomThumbShape extends SfThumbShape {
  final double thumbRadius;

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

// Custom overlay shape
class CustomOverlayShape extends SfOverlayShape {
  final double overlayRadius;

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
