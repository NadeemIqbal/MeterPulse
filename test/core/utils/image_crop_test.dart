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

    test('forDisplay yields an LCD-shaped band, not a tall block', () {
      // 9:16 portrait frame, 3.5:1 display.
      final roi = NormalizedRoi.forDisplay(previewAspect: 9 / 16);

      // The on-screen aspect of the band must come out as the LCD's, which is
      // the whole point of deriving height instead of hard-coding it.
      const frameW = 1080.0;
      const frameH = 1920.0;
      final onScreenAspect =
          (roi.width * frameW) / (roi.height * frameH);
      expect(onScreenAspect, closeTo(3.5, 0.01));

      // The previous hard-coded 0.28 was tall enough to include the nameplate
      // rows above and below the display.
      expect(roi.height, lessThan(0.2));
      expect(roi.top + roi.height / 2, closeTo(0.5, 0.001)); // vertically centred
      expect(roi.left, closeTo((1 - roi.width) / 2, 0.001)); // horizontally centred
    });

    test('forDisplay adapts the band to the frame it is drawn in', () {
      // A 3:4 frame is relatively taller, so the same on-screen shape needs a
      // smaller height fraction than in 9:16.
      final wide = NormalizedRoi.forDisplay(previewAspect: 3 / 4);
      final tall = NormalizedRoi.forDisplay(previewAspect: 9 / 16);

      expect(wide.height, greaterThan(tall.height));
    });

    test('forDisplay clamps an absurd aspect instead of producing a sliver', () {
      final roi = NormalizedRoi.forDisplay(previewAspect: 9 / 16, lcdAspect: 500);

      expect(roi.height, greaterThanOrEqualTo(0.06));
      expect(roi.top, greaterThanOrEqualTo(0.0));
      expect(roi.top + roi.height, lessThanOrEqualTo(1.0));
    });

    test('a portrait region applied to a landscape still is corrected', () {
      // Android hands back a landscape frame (1920x1080) and does not always set
      // the EXIF rotation that would fix it. Applying a portrait-measured band to
      // it crops a stripe across the meter body instead of its display.
      final landscape = _quadrantJpeg(width: 1920, height: 1080);
      final roi = NormalizedRoi.forDisplay(previewAspect: 9 / 16);

      final corrected =
          cropImageToRoi(landscape, roi, upscaleTo: 0, expectPortrait: true);
      final uncorrected =
          cropImageToRoi(landscape, roi, upscaleTo: 0, expectPortrait: null);

      expect(corrected, isNotNull);
      expect(uncorrected, isNotNull);

      final a = img.decodeImage(corrected!)!;
      final b = img.decodeImage(uncorrected!)!;

      // Corrected: the band is measured against the rotated (portrait) frame, so
      // it is wide relative to a 1080-wide image. Uncorrected it is measured
      // against 1920 of width. The two must not agree.
      expect(a.width, isNot(b.width));
      expect(a.width / a.height, closeTo(3.5, 0.35));
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
