/// A generic chart data point that can be used with multiple chart libraries.
///
/// This class represents a single point in a 2D coordinate system, typically
/// used for plotting oscilloscope data. The point consists of an x-coordinate
/// (usually representing time) and a y-coordinate (usually representing amplitude
/// or voltage).
///
/// Example:
/// ```dart
/// const point = OscilloscopePoint(1.5, 2.0);
/// print('X: ${point.x}, Y: ${point.y}'); // X: 1.5, Y: 2.0
/// ```
class OscilloscopePoint {
  /// The x coordinate of the point.
  ///
  /// This typically represents the horizontal axis value, such as time
  /// in oscilloscope measurements.
  final double x;

  /// The y coordinate of the point.
  ///
  /// This typically represents the vertical axis value, such as voltage
  /// or amplitude in oscilloscope measurements.
  final double y;

  /// Creates a new [OscilloscopePoint] with the given coordinates.
  ///
  /// Both [x] and [y] parameters are required and specify the position
  /// of the point in a 2D coordinate system.
  ///
  /// Example:
  /// ```dart
  /// const point = OscilloscopePoint(0.5, 1.2);
  /// ```
  const OscilloscopePoint(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OscilloscopePoint &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'OscilloscopePoint($x, $y)';
}
