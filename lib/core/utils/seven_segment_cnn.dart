/// A learned per-digit classifier for seven-segment displays.
///
/// Why this exists alongside the geometric decoder: general text recognition is
/// structurally unable to read these panels. A published benchmark of ~25
/// pretrained scene-text recognisers on real seven-segment images put the best at
/// 56.97% word accuracy (ITM Web of Conferences 63, 01007, 2024). ML Kit's
/// failure in this app — reading 228235 from a display showing 02282385 — is that
/// limit, not a bug. The geometric decoder handles clean panels but samples fixed
/// windows, so glare or skew that shifts a bar past a window boundary flips a
/// digit.
///
/// The split of labour is deliberate: the decoder's grid search *localises* the
/// digits, which it does reliably, and this classifies each cell, which it does
/// better than segment sampling because it was trained on degraded images rather
/// than assuming clean bars.
///
/// Model contract — must match tool/train_seven_segment/train_cnn.py exactly:
///
///     input   float32 [1, 28, 28, 1] greyscale, scaled x/255 into [0,1]
///     output  float32 [1, 10] softmax over '0'..'9'
library;


import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'seven_segment_decoder.dart';

/// Reading produced by the classifier.
class CnnDigitsResult {
  const CnnDigitsResult({
    required this.digits,
    required this.confidence,
    required this.value,
    required this.perDigitConfidence,
  });

  /// Digits left to right, leading zeros preserved.
  final String digits;

  /// The *lowest* per-digit confidence, not the mean.
  ///
  /// A meter reading is only as good as its weakest digit: one uncertain cell
  /// makes the whole number wrong, and averaging would let eight confident digits
  /// disguise a coin-flip on the ninth.
  final double confidence;

  final double? value;
  final List<double> perDigitConfidence;
}

/// Loads and runs the digit classifier.
///
/// Lazily initialised and reused; the interpreter is a native resource and
/// rebuilding it per scan would dominate the inference cost.
class SevenSegmentCnn {
  SevenSegmentCnn({this.assetPath = 'assets/models/seven_segment_digit.tflite'});

  final String assetPath;

  Interpreter? _interpreter;
  bool _loadFailed = false;

  static const int _cell = 28;
  static const int _classes = 10;

  /// True once a usable interpreter exists.
  bool get isReady => _interpreter != null;

  /// Whether loading was attempted and failed, so callers can stop retrying.
  bool get isUnavailable => _loadFailed;

  Future<void> _ensureLoaded() async {
    if (_interpreter != null || _loadFailed) return;
    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(assetPath, options: options);

      // Fail loudly at load rather than silently mispredicting: a model whose
      // shape disagrees with this code would still run and return plausible
      // nonsense, which is the failure mode this class exists to remove.
      final inShape = _interpreter!.getInputTensor(0).shape;
      final outShape = _interpreter!.getOutputTensor(0).shape;
      final inOk = inShape.length == 4 &&
          inShape[1] == _cell &&
          inShape[2] == _cell &&
          inShape[3] == 1;
      final outOk = outShape.last == _classes;
      if (!inOk || !outOk) {
        debugPrint('SevenSegmentCnn: unexpected model shape '
            'in=$inShape out=$outShape — disabling');
        _interpreter!.close();
        _interpreter = null;
        _loadFailed = true;
      }
    } catch (e) {
      debugPrint('SevenSegmentCnn: could not load $assetPath: $e');
      _loadFailed = true;
    }
  }

  /// Classifies the digits in [cells], which must already be normalised to 0–1.
  Future<CnnDigitsResult?> classifyCells(List<Float32List> cells) async {
    if (cells.isEmpty) return null;
    await _ensureLoaded();
    final interpreter = _interpreter;
    if (interpreter == null) return null;

    final digits = StringBuffer();
    final confidences = <double>[];

    try {
      for (final cell in cells) {
        if (cell.length != _cell * _cell) return null;

        // Reshaped to the model's NHWC input; tflite_flutter takes nested lists.
        final input = [
          [
            for (var y = 0; y < _cell; y++)
              [
                for (var x = 0; x < _cell; x++) [cell[y * _cell + x]],
              ],
          ],
        ];
        final output = [List<double>.filled(_classes, 0)];
        interpreter.run(input, output);

        var best = 0;
        var bestP = output[0][0];
        for (var c = 1; c < _classes; c++) {
          if (output[0][c] > bestP) {
            bestP = output[0][c];
            best = c;
          }
        }
        digits.write(best.toString());
        confidences.add(bestP);
      }
    } catch (e) {
      debugPrint('SevenSegmentCnn: inference failed: $e');
      return null;
    }

    final text = digits.toString();
    return CnnDigitsResult(
      digits: text,
      confidence: confidences.reduce((a, b) => a < b ? a : b),
      value: double.tryParse(text),
      perDigitConfidence: confidences,
    );
  }

  /// Convenience: locate the digits in a cropped LCD image and classify them.
  Future<CnnDigitsResult?> readDisplay(Uint8List croppedBytes) async {
    final extracted = extractDigitCells(croppedBytes, cellSize: _cell);
    if (extracted == null) return null;
    return classifyCells(extracted.cells);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
