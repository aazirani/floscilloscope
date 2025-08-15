/// A generic chart data point that can be used with multiple chart libraries.
class OscilloscopePoint {
  /// The x coordinate.
  final double x;

  /// The y coordinate.
  final double y;

  /// Creates a new [OscilloscopePoint] with the given coordinates.
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