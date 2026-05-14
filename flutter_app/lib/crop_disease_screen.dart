import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'crop_disease_classifier.dart';

/// Pick or capture a leaf photo, validate it is crop-related, then run optional disease TFLite.
class CropDiseaseScreen extends StatefulWidget {
  const CropDiseaseScreen({super.key});

  @override
  State<CropDiseaseScreen> createState() => _CropDiseaseScreenState();
}

class _CropDiseaseScreenState extends State<CropDiseaseScreen> {
  final CropDiseaseClassifier _classifier = CropDiseaseClassifier();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _previewBytes;
  CropDiseaseResult? _last;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _classifier.init().then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }

  Future<void> _run(Uint8List bytes) async {
    setState(() {
      _previewBytes = bytes;
      _busy = true;
    });
    final r = _classifier.analyzeBytes(bytes);
    if (!mounted) return;
    setState(() {
      _last = r;
      _busy = false;
    });
  }

  Future<void> _takePhoto() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 88);
    if (x == null) return;
    final b = await x.readAsBytes();
    await _run(b);
  }

  Future<void> _pickGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 88);
    if (x == null) return;
    final b = await x.readAsBytes();
    await _run(b);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20), brightness: Brightness.light);

    return Theme(
      data: ThemeData(useMaterial3: true, colorScheme: scheme),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Crop Disease Detection'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: _busy
                            ? const Center(child: CircularProgressIndicator())
                            : _previewBytes == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined,
                                          size: 56, color: scheme.primary),
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: Text(
                                          'Capture a clear photo of an affected leaf',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: scheme.primary,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.memory(
                                      _previewBytes!,
                                      fit: BoxFit.contain,
                                      gaplessPlayback: true,
                                    ),
                                  ),
                      ),
                    ),
                    if (_last != null) ...[
                      const SizedBox(height: 14),
                      Material(
                        color: _last!.acceptedForDiseaseModel && _last!.diseaseLabel != null
                            ? scheme.secondaryContainer
                            : scheme.errorContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            _last!.userMessage,
                            style: TextStyle(
                              height: 1.35,
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _busy ? null : _takePhoto,
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('Take photo'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _busy ? null : _pickGallery,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Pick from gallery'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
