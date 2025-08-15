import 'package:flutter_test/flutter_test.dart';
import 'package:floscilloscope/floscilloscope.dart';

void main() {
  group('OscilloscopePoint', () {
    test('should create a point with given coordinates', () {
      const point = OscilloscopePoint(1.0, 2.0);
      
      expect(point.x, equals(1.0));
      expect(point.y, equals(2.0));
    });

    test('should handle equality correctly', () {
      const point1 = OscilloscopePoint(1.0, 2.0);
      const point2 = OscilloscopePoint(1.0, 2.0);
      const point3 = OscilloscopePoint(2.0, 1.0);
      
      expect(point1, equals(point2));
      expect(point1, isNot(equals(point3)));
    });

    test('should have consistent hashCode for equal objects', () {
      const point1 = OscilloscopePoint(1.0, 2.0);
      const point2 = OscilloscopePoint(1.0, 2.0);
      
      expect(point1.hashCode, equals(point2.hashCode));
    });

    test('should provide meaningful string representation', () {
      const point = OscilloscopePoint(1.5, 2.5);
      
      expect(point.toString(), equals('OscilloscopePoint(1.5, 2.5)'));
    });

    test('should handle negative coordinates', () {
      const point = OscilloscopePoint(-1.0, -2.0);
      
      expect(point.x, equals(-1.0));
      expect(point.y, equals(-2.0));
    });

    test('should handle zero coordinates', () {
      const point = OscilloscopePoint(0.0, 0.0);
      
      expect(point.x, equals(0.0));
      expect(point.y, equals(0.0));
    });
  });
}