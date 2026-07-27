import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:meter_pulse/core/utils/image_crop.dart';

/// A source image whose four quadrants differ, so a crop can be checked by the
/// colour it lands on rather than by size alone.
Uint8List _quadrantJpeg({int width = 800, int height = 600}) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final right = x >= width / 2;
      final bottom = y >= height / 2;
      final color = switch ((right, bottom)) {
        (false, false) => img.ColorRgb8(255, 0, 0),
        (true, false) => img.ColorRgb8(0, 255, 0),
        (false, true) => img.ColorRgb8(0, 0, 255),
        (true, true) => img.ColorRgb8(255, 255, 0),
      };
      image.setPixel(x, y, color);
    }
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 100));
}

void main() {
  group('cropImageToRoi', () {
    test('crops to the requested region', () {
      // Bottom-right quadrant only, kept inside its bounds so JPEG ringing at
      // the quadrant seams cannot bleed in.
      const roi = NormalizedRoi(left: 0.6, top: 0.6, width: 0.3, height: 0.3);

      final out = cropImageToRoi(_quadrantJpeg(), roi, upscaleTo: 0);
      expect(out, isNotNull);

      final decoded = img.decodeImage(out!)!;
      expect(decoded.width, closeTo(800 * 0.3, 2));
      expect(decoded.height, closeTo(600 * 0.3, 2));

      final centre = decoded.getPixel(decoded.width ~/ 2, decoded.height ~/ 2);
      expect(centre.r, greaterThan(200)); // yellow
      expect(centre.g, greaterThan(200));
      expect(centre.b, lessThan(80));
    });

    test('upscales a small crop so ML Kit sees larger glyphs', () {
      const roi = NormalizedRoi(left: 0.4, top: 0.4, width: 0.1, height: 0.1);

      final out = cropImageToRoi(_quadrantJpeg(), roi, upscaleTo: 1400);
      final decoded = img.decodeImage(out!)!;

      final longest =
          decoded.width > decoded.height ? decoded.width : decoded.height;
      expect(longest, greaterThanOrEqualTo(1400));
    });

    test('does not upscale a crop that is already large enough', () {
      const roi = NormalizedRoi(left: 0.0, top: 0.0, width: 1.0, height: 1.0);

      final out = cropImageToRoi(_quadrantJpeg(), roi, upscaleTo: 400);
      final decoded = img.decodeImage(out!)!;

      expect(decoded.width, 800);
      expect(decoded.height, 600);
    });

    test('returns null for undecodable bytes so capture can fall back', () {
      final out = cropImageToRoi(
        Uint8List.fromList([1, 2, 3, 4, 5]),
        NormalizedRoi.meterDisplay,
      );

      expect(out, isNull);
    });

    test('clamps a region extending past the image edge', () {
      const roi = NormalizedRoi(left: 0.9, top: 0.9, width: 0.5, height: 0.5);

      final out = cropImageToRoi(_quadrantJpeg(), roi, upscaleTo: 0);
      expect(out, isNotNull);

      final decoded = img.decodeImage(out!)!;
      expect(decoded.width, lessThanOrEqualTo(80));
      expect(decoded.height, lessThanOrEqualTo(60));
    });

    test('inflated() grows the region but stays inside the frame', () {
      final roi = NormalizedRoi.meterDisplay.inflated(0.06);

      expect(roi.left, lessThan(NormalizedRoi.meterDisplay.left));
      expect(roi.width, greaterThan(NormalizedRoi.meterDisplay.width));
      expect(roi.left + roi.width, lessThanOrEqualTo(1.0));
      expect(roi.top + roi.height, lessThanOrEqualTo(1.0));
    });

    test('inflating an edge-hugging region cannot exceed the frame', () {
      const roi = NormalizedRoi(left: 0.0, top: 0.0, width: 1.0, height: 1.0);
      final inflated = roi.inflated(0.5);

      expect(inflated.left + inflated.width, lessThanOrEqualTo(1.0));
      expect(inflated.top + inflated.height, lessThanOrEqualTo(1.0));
    });
  });
}
