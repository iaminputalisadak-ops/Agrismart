import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'crop_disease_image_gate.dart';

/// Result of the two-stage pipeline: (1) plant/crop relevance, (2) optional disease TFLite.
class CropDiseaseResult {
  const CropDiseaseResult({
    required this.acceptedForDiseaseModel,
    required this.userMessage,
    this.diseaseLabel,
    this.confidence = 0,
    this.modelReady = false,
    this.margin = 0,
  });

  /// Passed foliar / non-crop gate so a disease model may run.
  final bool acceptedForDiseaseModel;
  final String userMessage;
  final String? diseaseLabel;
  final double confidence;
  final bool modelReady;
  final double margin;
}

/// Optional `assets/crop_disease_model.tflite` + `assets/crop_disease_labels.txt`
/// (same input layout as Teachable / MobileNet export: 224×224 RGB float 0–1).
class CropDiseaseClassifier {
  static const int _inputSize = 224;
  static const String _modelAsset = 'assets/crop_disease_model.tflite';
  static const String _labelsAsset = 'assets/crop_disease_labels.txt';

  Interpreter? _interpreter;
  List<String> _labels = const [];
  bool _modelReady = false;
  String _modelError = '';

  bool get diseaseModelReady => _modelReady;
  String get diseaseModelError => _modelError;

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      final raw = await rootBundle.loadString(_labelsAsset);
      _labels = raw
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      if (_labels.isEmpty) {
        throw Exception('crop_disease_labels.txt has no class names');
      }
      _modelReady = true;
      _modelError = '';
    } catch (e) {
      _interpreter?.close();
      _interpreter = null;
      _modelReady = false;
      _modelError = 'Disease model not loaded ($e). Add crop_disease_model.tflite '
          'and crop_disease_labels.txt to flutter_app/assets/ (see assets/README_CROP_DISEASE_MODEL.txt).';
    }
  }

  /// Decode JPEG/PNG bytes, reject obvious non-crop scenes, then run disease head if loaded.
  CropDiseaseResult analyzeBytes(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return const CropDiseaseResult(
        acceptedForDiseaseModel: false,
        userMessage: 'Could not read this image. Try another photo (JPEG or PNG).',
      );
    }
    final rgb = _ensureRgb(decoded);
    final gate = CropDiseaseImageGate.rejectionReason(rgb);
    if (gate != null) {
      return CropDiseaseResult(
        acceptedForDiseaseModel: false,
        userMessage: gate,
      );
    }

    if (!_modelReady || _interpreter == null) {
      return CropDiseaseResult(
        acceptedForDiseaseModel: true,
        modelReady: false,
        userMessage: 'Image looks plant-related, but no disease model is installed yet. '
            '${_modelError.isEmpty ? "Add crop_disease_model.tflite + labels to assets." : _modelError}',
      );
    }

    final resized = img.copyResize(rgb, width: _inputSize, height: _inputSize);
    final input = Float32List(_inputSize * _inputSize * 3);
    var idx = 0;
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final p = resized.getPixel(x, y);
        input[idx++] = p.r / 255.0;
        input[idx++] = p.g / 255.0;
        input[idx++] = p.b / 255.0;
      }
    }

    final reshaped = input.reshape([1, _inputSize, _inputSize, 3]);
    final output = List.generate(1, (_) => List<double>.filled(_labels.length, 0));
    _interpreter!.run(reshaped, output);
    final probs = List<double>.from(output[0]);
    final nClass = math.min(_labels.length, probs.length);

    var bestIdx = 0;
    var best = probs[0];
    for (var i = 1; i < nClass; i++) {
      if (probs[i] > best) {
        best = probs[i];
        bestIdx = i;
      }
    }
    final sorted = List<double>.from(probs.sublist(0, nClass))..sort();
    final second = sorted.length >= 2 ? sorted[sorted.length - 2] : 0.0;
    final margin = best - second;
    final highProb = probs.sublist(0, nClass).where((p) => p > 0.1).length;

    const minConf = 0.44;
    const minMargin = 0.07;
    const maxHigh = 4;

    if (best < minConf || margin < minMargin || highProb > maxHigh) {
      return CropDiseaseResult(
        acceptedForDiseaseModel: true,
        modelReady: true,
        confidence: best,
        margin: margin,
        userMessage: 'Plant-like image accepted, but the model is not confident enough to name a disease '
            '(top ${(best * 100).toStringAsFixed(1)}%, margin ${(margin * 100).toStringAsFixed(1)}%). '
            'Use sharper close-ups of symptomatic leaves, consistent lighting, and retrain with more per-class photos.',
      );
    }

    final label = _labels[bestIdx];
    return CropDiseaseResult(
      acceptedForDiseaseModel: true,
      modelReady: true,
      diseaseLabel: label,
      confidence: best,
      margin: margin,
        userMessage: 'Best match: $label (${(best * 100).toStringAsFixed(1)}% confidence). '
            'Always verify with a local agronomist before treatment.',
    );
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _modelReady = false;
  }

  static img.Image _ensureRgb(img.Image src) {
    if (src.numChannels == 3) return src;
    final o = img.Image(width: src.width, height: src.height, numChannels: 3);
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final p = src.getPixel(x, y);
        o.setPixelRgb(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt());
      }
    }
    return o;
  }
}
