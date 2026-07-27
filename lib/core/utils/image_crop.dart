/// Pure image cropping used to reduce a meter photo to just its LCD panel.
///
/// Free of Flutter imports so it can be unit-tested with plain bytes. Running
/// OCR over a whole meter photo forces the parser to compete with everything
/// printed on the nameplate — voltage, frequency, imp/kWh, serial, model, date.
/// Cropping to the display removes that competition entirely, which is the
/// single largest accuracy win available to the scanner.
library;

import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// A crop region as fractions (0–1) of the source image's width and height,
/// measured from the top-left *after* EXIF orientation has been applied.
///
/// Fractions rather than pixels because the on-screen reticle is laid out
/// against a preview whose pixel size differs from the captured photo. The
/// preview is letterboxed to the sensor's aspect ratio, so the same fractions
/// describe the same physical area in both.
class NormalizedRoi {
  const NormalizedRoi({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// The reticle used by the capture screen: a wide, short band across the
  /// middle, shaped like a meter's LCD.
  static const NormalizedRoi meterDisplay = NormalizedRoi(
    left: 0.08,
    top: 0.36,
    width: 0.84,
    height: 0.28,
  );

  final double left;
  final double top;
  final double width;
  final double height;

  /// Expands the region by [factor] of its own size on every side, clamped to
  /// the image. A little margin keeps digits from being clipped when the user's
  /// alignment is slightly off, which OCR handles far worse than extra space.
  NormalizedRoi inflated(double factor) {
    final dx = width * factor;
    final dy = height * factor;
    final newLeft = (left - dx).clamp(0.0, 1.0);
    final newTop = (top - dy).clamp(0.0, 1.0);
    return NormalizedRoi(
      left: newLeft,
      top: newTop,
      width: (width + dx * 2).clamp(0.0, 1.0 - newLeft),
      height: (height + dy * 2).clamp(0.0, 1.0 - newTop),
    );
  }
}

/// Crops [bytes] to [roi] and re-encodes as JPEG.
///
/// Returns null when the bytes cannot be decoded or the region resolves to
/// nothing, so callers can fall back to the uncropped image rather than fail the
/// whole capture.
///
/// [upscaleTo] enlarges the crop so its longest edge is at least that many
/// pixels. ML Kit is markedly better on larger glyphs, and a tightly cropped
/// LCD is often only a couple of hundred pixels wide.
Uint8List? cropImageToRoi(
  Uint8List bytes,
  NormalizedRoi roi, {
  int quality = 95,
  int upscaleTo = 1400,
}) {
  // decodeImage does not merely return null on bad input — its format sniffing
  // over-reads short or corrupt buffers and throws (RangeError from the PSD
  // probe, for one). A failed crop must degrade to "use the full photo", never
  // take down the capture, so everything below is guarded.
  final img.Image decoded;
  try {
    final candidate = img.decodeImage(bytes);
    if (candidate == null) return null;
    decoded = candidate;
  } catch (_) {
    return null;
  }

  try {
    // Photos carry rotation in EXIF rather than in the pixels. Bake it first, or
    // the region would be measured against a differently-oriented image.
    final oriented = img.bakeOrientation(decoded);

    final x = (roi.left * oriented.width).round().clamp(0, oriented.width - 1);
    final y = (roi.top * oriented.height).round().clamp(0, oriented.height - 1);
    final w = (roi.width * oriented.width).round().clamp(1, oriented.width - x);
    final h =
        (roi.height * oriented.height).round().clamp(1, oriented.height - y);
    if (w < 2 || h < 2) return null;

    var cropped = img.copyCrop(oriented, x: x, y: y, width: w, height: h);

    final longestEdge =
        cropped.width > cropped.height ? cropped.width : cropped.height;
    if (longestEdge < upscaleTo) {
      final scale = upscaleTo / longestEdge;
      cropped = img.copyResize(
        cropped,
        width: (cropped.width * scale).round(),
        height: (cropped.height * scale).round(),
        interpolation: img.Interpolation.cubic,
      );
    }

    return Uint8List.fromList(img.encodeJpg(cropped, quality: quality));
  } catch (_) {
    return null;
  }
}
