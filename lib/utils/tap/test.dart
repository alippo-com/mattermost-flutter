import 'package:flutter_test/flutter_test.dart';
import 'package:mattermost_flutter/utils/prevent_double_tap.dart';

void main() {
  group('Prevent double tap', () {
    test('should prevent double taps within the 300ms default', () async {
      final testFunction = () {};
      final test = preventDoubleTap(testFunction);

      test();
      test();
      expect(testFunction.callCount, 1);
      await Future.delayed(const Duration(milliseconds: 100), () {
        test();
        expect(testFunction.callCount, 1);
      });
    });

    test('should prevent double taps within 1 second', () async {
      final testFunction = () {};
      final test = preventDoubleTap(testFunction, 1000);

      test();
      test();
      expect(testFunction.callCount, 1);
      await Future.delayed(const Duration(milliseconds: 900), () {
        test();
        expect(testFunction.callCount, 1);
      });
    });

    test('should register multiple taps when done > 300ms apart', () async {
      final testFunction = () {};
      final test = preventDoubleTap(testFunction);

      test();
      test();
      expect(testFunction.callCount, 1);
      await Future.delayed(const Duration(milliseconds: 750), () {
        test();
        expect(testFunction.callCount, 2);
      });
    });
  });
}