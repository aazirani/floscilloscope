import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class ThresholdSlider extends StatefulWidget {
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
  final ValueChanged<dynamic> onChanged;
  final ValueChanged<dynamic> onChangeEnd;

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
                    tooltipTextFormatterCallback: (dynamic actualValue,
                        String formattedText) =>
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
                      if(widget.isSliderActive){
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
