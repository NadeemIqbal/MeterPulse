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

  @override
  bool operator ==(Object other) =>
      other is NormalizedRoi &&
      other.left == left &&
      other.top == top &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(left, top, width, height);

  /// A centred band shaped like a meter's LCD.
  ///
  /// [previewAspect] is width/height of the preview box (≈0.5625 for a 9:16
  /// portrait frame); [lcdAspect] is the display's own width:height, ~3.5:1 on a
  /// domestic single-phase meter.
  ///
  /// The height must be *derived*, not fixed. A hard-coded 0.28 produced a band
  /// 1.69:1 on screen — nothing like an LCD, and tall enough to swallow the rows
  /// printed above and below it. That is how nameplate text ("3200imp/kWh",
  /// "240V", "50Hz") reached the OCR candidates the crop exists to exclude.
  factory NormalizedRoi.forDisplay({
    required double previewAspect,
    double lcdAspect = 3.5,
    double width = 0.86,
  }) {
    // Convert the desired on-screen aspect into a height *fraction*: fractions
    // are of different physical lengths on each axis, so the frame's own aspect
    // has to be folded in.
    final height = (width * previewAspect / lcdAspect).clamp(0.06, 0.5);
    return NormalizedRoi(
      left: (1 - width) / 2,
      top: 0.5 - height / 2,
      width: width,
      height: height,
    );
  }

  /// Fallback for callers with no preview aspect to hand (assumes 9:16).
  static final NormalizedRoi meterDisplay =
      NormalizedRoi.forDisplay(previewAspect: 9 / 16);

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
/// Set by the last [cropImageToRoi] call, for logging what the crop actually did.
/// Not thread-safe and purely diagnostic — never branch on it.
String? lastDiagnostics;

/// [expectPortrait] states the orientation [roi] was measured in. Pass true when
/// the reticle was drawn over a portrait preview; the image is rotated to match
/// if the decoded still disagrees. Null skips the correction entirely.
Uint8List? cropImageToRoi(
  Uint8List bytes,
  NormalizedRoi roi, {
  int quality = 95,
  int upscaleTo = 1400,
  bool? expectPortrait,
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
    var oriented = img.bakeOrientation(decoded);

    // The reticle is described in the portrait frame the user was looking at,
    // but Android hands back a landscape still (1920x1080) and does not always
    // set the EXIF rotation that would correct it. Applying a portrait band to a
    // landscape image crops a stripe across the meter's body instead of its
    // display — which is how nameplate text ("3200imp/kWh", "240V") ends up in
    // the OCR candidates. Rotate to the orientation the region was measured in.
    if (expectPortrait != null &&
        expectPortrait != (oriented.height >= oriented.width)) {
      oriented = img.copyRotate(oriented, angle: 90);
    }
    lastDiagnostics = 'decoded=${decoded.width}x${decoded.height} '
        'oriented=${oriented.width}x${oriented.height} '
        'expectPortrait=$expectPortrait';

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
