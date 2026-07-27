/// A geometric decoder for seven-segment meter displays.
///
/// Pure Dart, no Flutter or ML Kit, so it unit-tests against plain bytes.
///
/// General text recognition is unreliable on these displays: the glyphs have no
/// letterforms, the strokes are thin and isolated, and `8`/`3`, `5`/`6`, `1`/`7`
/// collapse into one another under glare. Measured on a real meter, ML Kit read
/// `228235` from a display showing `02282385` — six of eight digits, wrong
/// overall.
///
/// This exploits the very rigidity that defeats OCR. A seven-segment display is
/// fixed-pitch with segments in known positions, so instead of recognising
/// shapes it asks a much narrower question per digit: which of the seven bars are
/// lit? Seven yes/no measurements, then a table lookup.
///
/// Digit cells are positioned by *pitch*, not by ink, which is what makes a `1`
/// (ink only on one edge) and a blank leading digit tractable — both would defeat
/// gap-based splitting.
library;

import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Segment order used throughout: A top, B top-right, C bottom-right, D bottom,
/// E bottom-left, F top-left, G middle.
///
/// ```
///  AAAA
/// F    B
/// F    B
///  GGGG
/// E    C
/// E    C
///  DDDD
/// ```
const List<String> segmentNames = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];

/// Which segments are lit for each digit.
const Map<String, List<bool>> _digitPatterns = {
  '0': [true, true, true, true, true, true, false],
  '1': [false, true, true, false, false, false, false],
  '2': [true, true, false, true, true, false, true],
  '3': [true, true, true, true, false, false, true],
  '4': [false, true, true, false, false, true, true],
  '5': [true, false, true, true, false, true, true],
  '6': [true, false, true, true, true, true, true],
  '7': [true, true, true, false, false, false, false],
  '8': [true, true, true, true, true, true, true],
  '9': [true, true, true, true, false, true, true],
};

/// Where each segment sits inside a digit cell, as fractions of cell width and
/// height: (left, top, right, bottom).
///
/// Sampling windows sit inside the bars rather than spanning them, so a slightly
/// skewed or bleeding capture does not leak one segment's ink into its
/// neighbour's window.
const List<List<double>> _segmentBoxes = [
  [0.28, 0.02, 0.72, 0.17], // A
  [0.80, 0.14, 0.99, 0.44], // B
  [0.80, 0.56, 0.99, 0.86], // C
  [0.28, 0.83, 0.72, 0.98], // D
  [0.01, 0.56, 0.20, 0.86], // E
  [0.01, 0.14, 0.20, 0.44], // F
  [0.28, 0.43, 0.72, 0.57], // G
];

/// Outcome of a decode attempt.
class SevenSegmentResult {
  const SevenSegmentResult({
    required this.digits,
    required this.confidence,
    required this.value,
  });

  /// Digits as read, left to right, leading zeros preserved.
  final String digits;

  /// 0–1, from how decisively each segment read on or off and how many cells
  /// matched a real digit pattern.
  final double confidence;

  /// [digits] parsed, or null when nothing usable was found.
  final double? value;
}

/// Reads a seven-segment display from [bytes], which should already be cropped
/// to the LCD.
///
/// Returns null when no digit layout scores well enough to be worth trusting —
/// callers should then fall back to general OCR rather than accept a guess.
SevenSegmentResult? decodeSevenSegment(
  Uint8List bytes, {
  int minDigits = 4,
  int maxDigits = 9,
  // A reading containing a 1 scores lower by nature: a cell with two lit bars
  // offers less corroborating structure than one with six. 0.35 admits those
  // without admitting noise, and callers cross-check the value against the
  // meter's history before trusting it either way.
  double minConfidence = 0.35,
}) {
  final img.Image gray;
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    gray = img.grayscale(img.bakeOrientation(decoded));
  } catch (_) {
    return null;
  }

  // Both polarities are tried: most meter LCDs are dark segments on a pale green
  // field, but backlit and inverted panels exist and the caller cannot know
  // which it photographed.
  SevenSegmentResult? best;
  for (final inkIsDark in [true, false]) {
    final mask = _binarise(gray, inkIsDark: inkIsDark);
    if (mask == null) continue;
    final result = _decodeMask(
      mask,
      minDigits: minDigits,
      maxDigits: maxDigits,
    );
    if (result == null) continue;
    if (best == null || result.confidence > best.confidence) best = result;
  }

  if (best == null || best.confidence < minConfidence) return null;
  return best;
}

/// A binary ink mask plus the bounding box of its content.
class _Mask {
  _Mask(this.on, this.width, this.height, this.box);

  final Uint8List on; // 1 = ink
  final int width;
  final int height;
  final _Box box;

  bool at(int x, int y) => on[y * width + x] == 1;
}

class _Box {
  const _Box(this.left, this.top, this.right, this.bottom);
  final int left, top, right, bottom;
  int get width => right - left + 1;
  int get height => bottom - top + 1;
}

/// Thresholds [gray] with Otsu's method and locates the digit block.
_Mask? _binarise(img.Image gray, {required bool inkIsDark}) {
  final w = gray.width;
  final h = gray.height;
  if (w < 8 || h < 8) return null;

  final histogram = List<int>.filled(256, 0);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      histogram[gray.getPixel(x, y).r.toInt().clamp(0, 255)]++;
    }
  }
  final threshold = _otsu(histogram, w * h);

  final on = Uint8List(w * h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final v = gray.getPixel(x, y).r.toInt();
      final isInk = inkIsDark ? v < threshold : v > threshold;
      if (isInk) on[y * w + x] = 1;
    }
  }

  // Ignore rows and columns holding only a trace of ink: speckle, the panel
  // bezel and glare edges would otherwise inflate the box and throw off pitch.
  final colInk = List<int>.filled(w, 0);
  final rowInk = List<int>.filled(h, 0);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (on[y * w + x] == 1) {
        colInk[x]++;
        rowInk[y]++;
      }
    }
  }
  final colFloor = (h * 0.04).ceil();
  final rowFloor = (w * 0.04).ceil();

  var left = 0, right = w - 1, top = 0, bottom = h - 1;
  while (left < right && colInk[left] < colFloor) {
    left++;
  }
  while (right > left && colInk[right] < colFloor) {
    right--;
  }
  while (top < bottom && rowInk[top] < rowFloor) {
    top++;
  }
  while (bottom > top && rowInk[bottom] < rowFloor) {
    bottom--;
  }

  final box = _Box(left, top, right, bottom);
  if (box.width < 8 || box.height < 8) return null;
  // A digit block is wider than it is tall; a near-square blob is not a display.
  if (box.width / box.height < 0.8) return null;

  return _Mask(on, w, h, box);
}

/// Otsu's threshold: the grey level maximising between-class variance.
int _otsu(List<int> histogram, int total) {
  var sum = 0.0;
  for (var i = 0; i < 256; i++) {
    sum += i * histogram[i];
  }
  var sumB = 0.0;
  var weightB = 0;
  var maxVariance = -1.0;
  var threshold = 128;

  for (var t = 0; t < 256; t++) {
    weightB += histogram[t];
    if (weightB == 0) continue;
    final weightF = total - weightB;
    if (weightF == 0) break;
    sumB += t * histogram[t];
    final meanB = sumB / weightB;
    final meanF = (sum - sumB) / weightF;
    final variance = weightB * weightF * (meanB - meanF) * (meanB - meanF);
    if (variance > maxVariance) {
      maxVariance = variance;
      threshold = t;
    }
  }
  return threshold;
}

/// Tries every plausible digit count and keeps the layout that reads best.
///
/// The count is unknown up front — a meter may show six digits or eight, with
/// leading zeros — so rather than guess, each candidate layout is scored and the
/// most self-consistent one wins.
SevenSegmentResult? _decodeMask(
  _Mask mask, {
  required int minDigits,
  required int maxDigits,
}) {
  SevenSegmentResult? best;

  for (var n = minDigits; n <= maxDigits; n++) {
    // The ink box is not the cell grid. Segments are drawn *inset* within their
    // cell, so the leftmost ink starts inside the first cell and the rightmost
    // ends inside the last. Dividing the ink box by n therefore yields cells
    // narrower than the true pitch, and the error accumulates until later cells
    // are misaligned by a third of a digit — every window then straddles a bar
    // and reads "on", which is why an unaligned grid decodes as all 8s.
    //
    // So the inset is solved for rather than ignored: with a fraction `inset` of
    // a cell unused at each end, ink spans (n - 2*inset) cells.
    // Left and right insets are searched independently, not as one symmetric
    // value. A leading or trailing `1` inks only one edge of its cell, so the ink
    // box can start ~80% of the way into the first cell — an asymmetry a single
    // shared inset cannot express, which made any reading beginning with 1
    // undecodable ("12345" came out as "6915").
    for (final leftInset in const [0.0, 0.15, 0.3, 0.5, 0.7, 0.85]) {
      for (final rightInset in const [0.0, 0.15, 0.3, 0.5, 0.7, 0.85]) {
        final span = n - leftInset - rightInset;
        if (span < 1) continue;
        final cellWidth = mask.box.width / span;
        // Below ~6px the segment windows collapse to single pixels.
        if (cellWidth < 6) continue;
        final gridLeft = mask.box.left - leftInset * cellWidth;

      final digits = StringBuffer();
      var totalMargin = 0.0;
      var exact = 0;
      var matched = 0;

      for (var i = 0; i < n; i++) {
        final reading = _readCell(
          mask,
          left: gridLeft + cellWidth * i,
          top: mask.box.top.toDouble(),
          width: cellWidth,
          height: mask.box.height.toDouble(),
        );
        if (reading == null) {
          digits.write('?');
          continue;
        }
        digits.write(reading.digit);
        totalMargin += reading.margin;
        if (reading.exact) exact++;
        matched++;
      }

      if (matched == 0) continue;
      final text = digits.toString();
      // Every cell must resolve: a '?' anywhere makes the number unusable, so a
      // partial decode is not worth reporting.
      if (text.contains('?')) continue;

      final value = double.tryParse(text);
      if (value == null) continue;

      // Does the grid actually land in the gaps between digits?
      //
      // This is the decisive test, because a wrong pitch can still yield seven
      // valid-looking patterns per cell — shifted windows consistently read as
      // 0s and 6s, so digit validity alone cannot distinguish a real alignment
      // from a fictional one. Cell boundaries on a correct grid fall in the
      // unlit gutters between digits; on a wrong one they slice through bars.
      final gridFit = _gridFit(mask, gridLeft, cellWidth, n);

      // Normalised by n, never the absolute count: more cells mean more chances
      // to match, so ranking on the raw total structurally favours splitting the
      // display into too many digits.
      final confidence =
          (totalMargin / matched * (exact / n) * gridFit).clamp(0.0, 0.99);

        if (best == null || confidence > best.confidence) {
          best = SevenSegmentResult(
            digits: text,
            confidence: confidence,
            value: value,
          );
        }
      }
    }
  }

  return best;
}

/// How well a candidate grid's cell boundaries fall into the unlit gutters
/// between digits. 1.0 means every boundary is clear; low values mean boundaries
/// cut through lit bars, i.e. the pitch or phase is wrong.
double _gridFit(_Mask mask, double gridLeft, double cellWidth, int n) {
  if (n < 2) return 1;
  final strip = max(1, (cellWidth * 0.06).round());
  var total = 0.0;
  var counted = 0;

  for (var i = 1; i < n; i++) {
    final x = (gridLeft + cellWidth * i).round();
    if (x - strip < 0 || x + strip >= mask.width) continue;
    total += _fillRatio(
      mask,
      x - strip,
      mask.box.top,
      x + strip,
      mask.box.bottom,
    );
    counted++;
  }

  if (counted == 0) return 1;
  // Squared so a boundary sitting on a bar is punished sharply rather than
  // merely discounted.
  final ink = (total / counted).clamp(0.0, 1.0);
  return ((1 - ink) * (1 - ink)).clamp(0.0, 1.0);
}

class _CellReading {
  const _CellReading(this.digit, this.margin, {required this.exact});
  final String digit;

  /// How cleanly the lit and unlit windows separate, 0–1. Near-identical fills
  /// across all seven windows — the signature of a misaligned grid — score low.
  final double margin;

  /// Whether the segment pattern matched a digit exactly, rather than being the
  /// nearest pattern one segment away.
  final bool exact;
}

/// Measures the seven segments of one cell and maps them to a digit.
_CellReading? _readCell(
  _Mask mask, {
  required double left,
  required double top,
  required double width,
  required double height,
}) {
  final fills = <double>[];
  for (final box in _segmentBoxes) {
    final x0 = (left + box[0] * width).round();
    final y0 = (top + box[1] * height).round();
    final x1 = (left + box[2] * width).round();
    final y1 = (top + box[3] * height).round();
    fills.add(_fillRatio(mask, x0, y0, x1, y1));
  }

  // Threshold adaptively, against this cell's own fills, rather than a fixed
  // fraction. How much of a window a lit bar covers depends on the panel's stroke
  // weight, the crop's scale and the sampling window's proportions — a thin bar in
  // a tall window fills only ~0.44, so an absolute cut-off sits right on top of
  // the lit/unlit boundary and flips with a pixel of drift. Within one cell the
  // lit and unlit windows are strongly bimodal, so the midpoint between the
  // extremes separates them regardless of stroke weight.
  // Split the seven fills into lit and unlit by the largest gap between them,
  // rather than at the midpoint of their range.
  //
  // A midpoint cut is mathematically incapable of reading an 8: with all seven
  // segments lit there is no unlit group, yet `min + spread/2` always leaves the
  // weakest window below the cut, so an 8 decoded as 4, 3 or 6 depending on which
  // window happened to be dimmest. Clustering on the largest gap instead lets a
  // cell legitimately come out all-on or all-off.
  final sorted = [...fills]..sort();
  var gapSize = 0.0;
  var gapAt = 0.0;
  for (var i = 0; i < sorted.length - 1; i++) {
    final gap = sorted[i + 1] - sorted[i];
    if (gap > gapSize) {
      gapSize = gap;
      gapAt = (sorted[i] + sorted[i + 1]) / 2;
    }
  }

  final List<bool> on;
  final double separation;
  if (gapSize >= 0.18) {
    // Genuinely bimodal: some segments lit, some not.
    on = fills.map((f) => f >= gapAt).toList();
    separation = gapSize;
  } else {
    // Uniform cell — every segment is in the same state, so an absolute floor is
    // the only thing that can decide which. This is the 8-and-blank case.
    final mean = fills.reduce((a, b) => a + b) / fills.length;
    if (mean >= 0.30) {
      on = List<bool>.filled(7, true);
      // Corroborated only by absolute level, so it is capped below a clean
      // bimodal read.
      separation = (mean * 0.7).clamp(0.0, 0.7);
    } else {
      return null; // blank cell — not a digit
    }
  }

  // Confidence comes from *separation*, not distance to the threshold. A grid
  // that has slipped sideways puts part of a bar into every window, so all seven
  // fills land high and uniform: measuring each one's distance from the threshold
  // would score that as excellent. The gap between the dimmest lit window and the
  // brightest unlit one cannot be faked that way.
  // Confidence is the lit/unlit separation established above, normalised so a
  // wide, unambiguous gap approaches 1. Measuring each fill's distance from a
  // fixed threshold would instead score a misaligned grid — which puts part of a
  // bar in every window, giving uniformly high fills — as excellent.
  final margin = (separation / 0.5).clamp(0.0, 1.0);

  // Exact match first, then the nearest pattern one segment away — a single
  // dropped or bled bar is common on a glare-lit panel and should not discard an
  // otherwise clean digit, though it costs confidence and is not counted as exact.
  for (final entry in _digitPatterns.entries) {
    if (_patternsEqual(entry.value, on)) {
      return _CellReading(entry.key, margin.clamp(0.0, 1.0), exact: true);
    }
  }

  String? nearest;
  var nearestDistance = 99;
  for (final entry in _digitPatterns.entries) {
    var distance = 0;
    for (var i = 0; i < 7; i++) {
      if (entry.value[i] != on[i]) distance++;
    }
    if (distance < nearestDistance) {
      nearestDistance = distance;
      nearest = entry.key;
    }
  }
  if (nearest != null && nearestDistance <= 1) {
    return _CellReading(nearest, (margin * 0.6).clamp(0.0, 1.0), exact: false);
  }
  return null;
}

bool _patternsEqual(List<bool> a, List<bool> b) {
  for (var i = 0; i < 7; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Proportion of ink inside a rectangle.
double _fillRatio(_Mask mask, int x0, int y0, int x1, int y1) {
  final left = x0.clamp(0, mask.width - 1);
  final right = x1.clamp(0, mask.width - 1);
  final top = y0.clamp(0, mask.height - 1);
  final bottom = y1.clamp(0, mask.height - 1);
  if (right <= left || bottom <= top) return 0;

  var ink = 0;
  var total = 0;
  for (var y = top; y <= bottom; y++) {
    for (var x = left; x <= right; x++) {
      total++;
      if (mask.at(x, y)) ink++;
    }
  }
  return total == 0 ? 0 : ink / total;
}
