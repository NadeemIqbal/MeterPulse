import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:meter_pulse/core/utils/seven_segment_decoder.dart';

/// Segments lit for each digit, in A,B,C,D,E,F,G order. Duplicated from the
/// decoder on purpose: the test renders from its own table, so a mistake in the
/// decoder's table cannot cancel out against the same mistake here.
const Map<String, List<bool>> _render = {
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

/// Draws [digits] as a seven-segment display: dark bars on a pale field, as a
/// meter LCD appears.
Uint8List renderDisplay(
  String digits, {
  int cellWidth = 60,
  int cellHeight = 100,
  int padding = 12,
  bool invert = false,
  int noise = 0,
}) {
  final w = cellWidth * digits.length + padding * 2;
  final h = cellHeight + padding * 2;
  final image = img.Image(width: w, height: h);

  final background = invert ? img.ColorRgb8(20, 24, 20) : img.ColorRgb8(196, 214, 180);
  final ink = invert ? img.ColorRgb8(220, 240, 220) : img.ColorRgb8(28, 34, 28);
  img.fill(image, color: background);

  final bar = max(4, (cellWidth * 0.14).round());

  for (var i = 0; i < digits.length; i++) {
    final segments = _render[digits[i]]!;
    final x = padding + i * cellWidth;
    final y = padding;
    // Bar centrelines placed as a real seven-segment panel does: inset from the
    // cell edges rather than flush against them. Drawing them flush (centre at
    // 0.04 of cell height) made this fixture unrepresentative and would have had
    // the decoder tuned to match the renderer instead of actual hardware.
    final l = x + (cellWidth * 0.15).round();
    final r = x + (cellWidth * 0.85).round();
    final t = y + (cellHeight * 0.08).round();
    final b = y + (cellHeight * 0.92).round();
    final mid = y + (cellHeight * 0.50).round();

    void hbar(int yy) => img.fillRect(image,
        x1: l, y1: yy - bar ~/ 2, x2: r, y2: yy + bar ~/ 2, color: ink);
    void vbar(int xx, int y1, int y2) => img.fillRect(image,
        x1: xx - bar ~/ 2, y1: y1, x2: xx + bar ~/ 2, y2: y2, color: ink);

    if (segments[0]) hbar(t);
    if (segments[1]) vbar(r, t, mid);
    if (segments[2]) vbar(r, mid, b);
    if (segments[3]) hbar(b);
    if (segments[4]) vbar(l, mid, b);
    if (segments[5]) vbar(l, t, mid);
    if (segments[6]) hbar(mid);
  }

  if (noise > 0) {
    // Deterministic speckle — a fixed seed keeps the test from flaking.
    final rnd = Random(7);
    for (var i = 0; i < noise; i++) {
      final x = rnd.nextInt(w);
      final y = rnd.nextInt(h);
      image.setPixel(x, y, rnd.nextBool() ? ink : background);
    }
  }

  return Uint8List.fromList(img.encodeJpg(image, quality: 95));
}

void main() {
  group('decodeSevenSegment', () {
    test('reads the display ML Kit got wrong on the real meter', () {
      // ML Kit returned 228235 from this display — six of eight digits, wrong
      // overall. The decoder has to get it exactly.
      final result = decodeSevenSegment(renderDisplay('02282385'));

      expect(result, isNotNull);
      expect(result!.digits, '02282385');
      expect(result.value, 2282385);
      expect(result.confidence, greaterThan(0.55));
    });

    test('reads every digit correctly', () {
      for (final digit in '0123456789'.split('')) {
        // Padded to four cells: a lone cell gives the layout search nothing to
        // establish pitch from.
        final target = '8$digit${digit}8';
        final result = decodeSevenSegment(renderDisplay(target));
        expect(result?.digits, target, reason: 'digit $digit');
      }
    });

    test('handles a reading with a 1 in it', () {
      // A `1` inks only one edge of its cell, which defeats gap-based splitting.
      // Cells are placed by pitch precisely so this still works.
      final result = decodeSevenSegment(renderDisplay('20981'));

      expect(result?.digits, '20981');
    });

    test('preserves leading zeros', () {
      final result = decodeSevenSegment(renderDisplay('004849'));

      expect(result?.digits, '004849');
      expect(result?.value, 4849);
    });

    test('reads an inverted panel (light digits on dark)', () {
      final result = decodeSevenSegment(renderDisplay('12345', invert: true));

      expect(result?.digits, '12345');
    });

    test('survives speckle noise', () {
      final result =
          decodeSevenSegment(renderDisplay('20981', noise: 400));

      expect(result?.digits, '20981');
    });

    test('reads a six-digit display', () {
      final result = decodeSevenSegment(renderDisplay('228238'));

      expect(result?.digits, '228238');
    });

    test('returns null rather than guessing at a non-display', () {
      // Flat noise with no digit structure must be declined, so the caller falls
      // back to general OCR instead of recording a fabricated reading.
      final image = img.Image(width: 400, height: 120);
      img.fill(image, color: img.ColorRgb8(128, 128, 128));
      final rnd = Random(3);
      for (var i = 0; i < 4000; i++) {
        image.setPixel(rnd.nextInt(400), rnd.nextInt(120),
            img.ColorRgb8(rnd.nextInt(255), rnd.nextInt(255), rnd.nextInt(255)));
      }
      final result =
          decodeSevenSegment(Uint8List.fromList(img.encodeJpg(image)));

      expect(result, isNull);
    });

    test('returns null for undecodable bytes', () {
      expect(decodeSevenSegment(Uint8List.fromList([1, 2, 3])), isNull);
    });

    test('declines a blank panel', () {
      final image = img.Image(width: 400, height: 120);
      img.fill(image, color: img.ColorRgb8(196, 214, 180));
      expect(
        decodeSevenSegment(Uint8List.fromList(img.encodeJpg(image))),
        isNull,
      );
    });

    test('exposes the digit cell geometry it found', () {
      // The learned classifier reuses this localisation instead of re-deriving
      // it, so the layout has to be correct and exposed.
      final result = decodeSevenSegment(renderDisplay('20981'));

      expect(result?.layout, isNotNull);
      final layout = result!.layout!;
      expect(layout.digitCount, 5);
      expect(layout.cellWidth, greaterThan(0));
      expect(layout.height, greaterThan(0));

      // Cells must tile left to right without overlapping.
      var previousRight = -1;
      for (var i = 0; i < layout.digitCount; i++) {
        final (l, t, r, b) = layout.cellBounds(i);
        expect(l, greaterThan(previousRight - 2));
        expect(r, greaterThan(l));
        expect(b, greaterThan(t));
        previousRight = r;
      }
    });

    test('extractDigitCells yields one normalised cell per digit', () {
      final cells = extractDigitCells(renderDisplay('02282385'), cellSize: 28);

      expect(cells, isNotNull);
      expect(cells!.cells.length, 8);
      for (final c in cells.cells) {
        expect(c.length, 28 * 28);
        // Contract with the trained model: greyscale scaled into 0..1.
        expect(c.reduce((a, b) => a < b ? a : b), greaterThanOrEqualTo(0.0));
        expect(c.reduce((a, b) => a > b ? a : b), lessThanOrEqualTo(1.0));
      }
      // Cells must differ; identical tensors would mean the crop is not moving.
      expect(cells.cells[0], isNot(equals(cells.cells[1])));
    });

    test('extractDigitCells declines a non-display image', () {
      final image = img.Image(width: 300, height: 100);
      img.fill(image, color: img.ColorRgb8(120, 120, 120));
      expect(
        extractDigitCells(Uint8List.fromList(img.encodeJpg(image))),
        isNull,
      );
    });
  });
}
