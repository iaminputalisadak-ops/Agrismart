import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class InsectResult {
  final String insectName;
  final double confidence;
  final bool modelReady;
  final String message;
  /// False when the frame does not pass plausibility checks (random scene,
  /// ambiguous softmax, or unlikely plant-like colours for crop-style use).
  final bool plausibleSubject;
  /// True when inference uses the built-in heuristic (no valid TFLite on device).
  final bool isDemo;

  InsectResult({
    required this.insectName,
    required this.confidence,
    required this.modelReady,
    required this.message,
    this.plausibleSubject = true,
    this.isDemo = false,
  });

  factory InsectResult.notReady(String reason) => InsectResult(
        insectName: 'Unknown',
        confidence: 0,
        modelReady: false,
        message: reason,
        plausibleSubject: false,
        isDemo: false,
      );
}

class InsectClassifier {
  static const int _inputSize = 224;
  /// Optional: add this file under `flutter:` assets in pubspec when you have a
  /// trained model (float input [1,224,224,3], logits length == labels.txt lines).
  static const String _modelAsset = 'assets/insect_model.tflite';
  static const String _labelsAsset = 'assets/labels.txt';
  /// Bundled files smaller than this are treated as placeholders, not TFLite.
  static const int _minModelBytes = 4096;

  Interpreter? _interpreter;
  List<String> _labels = const [];
  bool _ready = false;
  bool _demoMode = false;
  String _error = '';

  bool get isReady => _ready;
  String get errorMessage => _error;
  bool get usesDemoModel => _demoMode;

  Future<void> init() async {
    _interpreter?.close();
    _interpreter = null;
    _demoMode = false;
    _error = '';
    _ready = false;

    try {
      final raw = await rootBundle.loadString(_labelsAsset);
      _labels = raw
          .split('\n')
          .map((l) => l.trim().toLowerCase())
          .where((l) => l.isNotEmpty)
          .toList();
    } catch (e) {
      _error = 'Missing assets/labels.txt: $e';
      return;
    }

    if (_labels.isEmpty) {
      _error = 'labels.txt has no class names.';
      return;
    }

    ByteData? modelData;
    try {
      modelData = await rootBundle.load(_modelAsset);
    } catch (_) {
      modelData = null;
    }

    if (modelData == null || modelData.lengthInBytes < _minModelBytes) {
      _demoMode = true;
      _ready = true;
      if (modelData != null && modelData.lengthInBytes < _minModelBytes) {
        debugPrint(
          'InsectClassifier: insect_model.tflite is missing or too small '
          '(${modelData.lengthInBytes} B); using demo heuristics.',
        );
      } else {
        debugPrint(
          'InsectClassifier: no insect_model.tflite in asset bundle; '
          'using demo heuristics. Add the file to assets/ and pubspec.yaml for '
          'real inference.',
        );
      }
      return;
    }

    try {
      final buf = modelData.buffer.asUint8List();
      _interpreter = Interpreter.fromBuffer(buf);
      _demoMode = false;
      _ready = true;
    } catch (e) {
      debugPrint('InsectClassifier: failed to load TFLite ($e); demo heuristics.');
      _interpreter = null;
      _demoMode = true;
      _ready = true;
    }
  }

  /// Run inference on a single camera frame. Returns null if the frame
  /// could not be converted (rare; happens on platform format mismatches).
  InsectResult? classify(CameraImage frame) {
    if (!_ready) {
      return InsectResult.notReady(
        _error.isEmpty
            ? 'Classifier not initialised.'
            : _error,
      );
    }

    if (_demoMode) {
      return _classifyDemo(frame);
    }

    if (_interpreter == null) {
      return InsectResult.notReady(_error);
    }

    final rgb = _cameraImageToRgb(frame);
    if (rgb == null) return null;

    final resized = img.copyResize(rgb, width: _inputSize, height: _inputSize);

    final input = Float32List(_inputSize * _inputSize * 3);
    int idx = 0;
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final p = resized.getPixel(x, y);
        input[idx++] = p.r / 255.0;
        input[idx++] = p.g / 255.0;
        input[idx++] = p.b / 255.0;
      }
    }

    final reshapedInput =
        input.reshape([1, _inputSize, _inputSize, 3]);
    final output = List.generate(
      1,
      (_) => List<double>.filled(_labels.length, 0),
    );

    _interpreter!.run(reshapedInput, output);

    final probs = List<double>.from(output[0]);
    int bestIdx = 0;
    double best = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > best) {
        best = probs[i];
        bestIdx = i;
      }
    }

    final sorted = List<double>.from(probs)..sort();
    final second = sorted.length >= 2 ? sorted[sorted.length - 2] : 0.0;
    final margin = best - second;
    final highProbClasses = probs.where((p) => p > 0.11).length;
    final agriRatio = _agriRelevantPixelRatio(resized);

    final plausible = _isPlausibleSubject(
      top: best,
      margin: margin,
      highProbClasses: highProbClasses,
      agriColorRatio: agriRatio,
    );

    if (!plausible) {
      return InsectResult(
        insectName: 'No clear crop / insect',
        confidence: best,
        modelReady: true,
        message:
            'This image does not look like a plant, seed, food crop, or a '
            'clear insect close-up—or the model is unsure. Use a photo centered '
            'on leaves, fruit, seeds, or the insect. Random objects (laptop, '
            'floor, etc.) are not supported.',
        plausibleSubject: false,
        isDemo: false,
      );
    }

    return InsectResult(
      insectName: _labels[bestIdx],
      confidence: best,
      modelReady: true,
      message: 'Detection completed.',
      plausibleSubject: true,
      isDemo: false,
    );
  }

  /// Colour- and texture-inspired guess when no neural model is available.
  InsectResult? _classifyDemo(CameraImage frame) {
    final rgb = _cameraImageToRgb(frame);
    if (rgb == null) return null;

    final resized = img.copyResize(rgb, width: 112, height: 112);
    final agriRatio = _agriRelevantPixelRatio(resized);

    if (agriRatio < 0.038) {
      return InsectResult(
        insectName: 'No clear crop / insect',
        confidence: 0.35,
        modelReady: true,
        message:
            'Demo mode: point the camera at leaves, fruit, soil with plants, or '
            'a clear insect. Add insect_model.tflite for trained detection.',
        plausibleSubject: false,
        isDemo: true,
      );
    }

    int h = _labels.length * 17;
    for (var y = 0; y < resized.height; y += 5) {
      for (var x = 0; x < resized.width; x += 5) {
        final p = resized.getPixel(x, y);
        final ri = p.r.toInt();
        final gi = p.g.toInt();
        final bi = p.b.toInt();
        h = (h * 1315423911 + ri + (gi << 8) + (bi << 16)) & 0x7fffffff;
      }
    }
    final idx = h % _labels.length;
    final conf = (0.52 + (agriRatio * 1.1).clamp(0.0, 0.24)).clamp(0.52, 0.76);

    return InsectResult(
      insectName: _labels[idx],
      confidence: conf,
      modelReady: true,
      message:
          'Demo estimate only (scene-based placeholder). Replace with a trained '
          'insect_model.tflite matching labels.txt for real species recognition.',
      plausibleSubject: true,
      isDemo: true,
    );
  }

  /// Heuristic gate so random / indoor photos do not get a confident wrong label.
  /// For strongest OOD handling, add a "background" class when training the model.
  static bool _isPlausibleSubject({
    required double top,
    required double margin,
    required int highProbClasses,
    required double agriColorRatio,
  }) {
    const minTop = 0.46;
    const minMargin = 0.12;
    const maxHighProbClasses = 3;
    const minAgriRatio = 0.038;
    const agriEscapeMargin = 0.34;
    const agriEscapeTop = 0.86;

    if (top < minTop) return false;
    if (margin < minMargin) return false;
    if (highProbClasses > maxHighProbClasses) return false;

    final agriOk = agriColorRatio >= minAgriRatio ||
        margin >= agriEscapeMargin ||
        top >= agriEscapeTop;
    return agriOk;
  }

  /// Rough fraction of pixels that look like vegetation or yellow / ripe crop tissue.
  static double _agriRelevantPixelRatio(img.Image im) {
    final w = im.width;
    final h = im.height;
    if (w == 0 || h == 0) return 0;
    int hit = 0;
    int n = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = im.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        n++;
        final greenLeaf = g > r + 14 && g > b + 14 && g > 52;
        final yellowCrop =
            r > 118 && g > 98 && b < 105 && r + g > b + 80 && (r - g).abs() < 55;
        if (greenLeaf || yellowCrop) hit++;
      }
    }
    return hit / n;
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _ready = false;
    _demoMode = false;
  }

  /// Decodes a camera frame to RGB for auxiliary heuristics (e.g. crop colour hints).
  /// Not used for TFLite tensor layout.
  img.Image? decodeCameraRgb(CameraImage frame) => _cameraImageToRgb(frame);

  // ---------- camera frame conversion ----------

  img.Image? _cameraImageToRgb(CameraImage frame) {
    switch (frame.format.group) {
      case ImageFormatGroup.yuv420:
        return _yuv420ToRgb(frame);
      case ImageFormatGroup.bgra8888:
        return _bgra8888ToRgb(frame);
      default:
        return null;
    }
  }

  img.Image _yuv420ToRgb(CameraImage frame) {
    final w = frame.width;
    final h = frame.height;
    final image = img.Image(width: w, height: h);

    final yPlane = frame.planes[0];
    final uPlane = frame.planes[1];
    final vPlane = frame.planes[2];

    final yRowStride = yPlane.bytesPerRow;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final yIdx = y * yRowStride + x;
        final uvIdx = (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;

        final yp = yPlane.bytes[yIdx];
        final up = uPlane.bytes[uvIdx];
        final vp = vPlane.bytes[uvIdx];

        int r = (yp + 1.402 * (vp - 128)).round();
        int g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).round();
        int b = (yp + 1.772 * (up - 128)).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        image.setPixelRgb(x, y, r, g, b);
      }
    }
    return image;
  }

  img.Image _bgra8888ToRgb(CameraImage frame) {
    final w = frame.width;
    final h = frame.height;
    final bytes = frame.planes[0].bytes;
    final rowStride = frame.planes[0].bytesPerRow;

    final image = img.Image(width: w, height: h);
    for (int y = 0; y < h; y++) {
      final row = y * rowStride;
      for (int x = 0; x < w; x++) {
        final i = row + x * 4;
        final b = bytes[i];
        final g = bytes[i + 1];
        final r = bytes[i + 2];
        image.setPixelRgb(x, y, r, g, b);
      }
    }
    return image;
  }
}
