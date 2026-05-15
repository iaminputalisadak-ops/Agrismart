import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

import 'camera_holder.dart';
import 'crop_live_intelligence.dart';
import 'crop_risk_database.dart';
import 'insect_classifier.dart';
import 'live_scan_crop_heuristics.dart';
import 'live_scan_web_insight_service.dart';
import 'l10n/app_localizations.dart';

/// Live camera scan: insect risk, crop disease context, IPM guidance, and optional Wikipedia context.
class InsectLiveScanScreen extends StatefulWidget {
  const InsectLiveScanScreen({super.key});

  @override
  State<InsectLiveScanScreen> createState() => _InsectLiveScanScreenState();
}

class _InsectLiveScanScreenState extends State<InsectLiveScanScreen>
    with WidgetsBindingObserver {
  final InsectClassifier _classifier = InsectClassifier();
  final CropRiskDatabase _riskDb = CropRiskDatabase();

  CameraController? _controller;
  String _selectedCrop = LiveScanCropHeuristics.crops.first;
  double _cropAutoConfidence = 0.45;
  String? _cropVoteCrop;
  int _cropVoteStreak = 0;

  InsectResult? _lastResult;
  bool _harmful = false;
  String _advice = '';

  LiveScanInsightBundle? _insightBundle;
  String? _wikiExtract;
  bool _wikiLoading = false;
  Timer? _wikiDebounce;

  bool _busy = false;
  DateTime _lastAnalysis = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastAlert = DateTime.fromMillisecondsSinceEpoch(0);

  String? _fatalError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final camStatus = await Permission.camera.request();
    if (!camStatus.isGranted) {
      if (mounted) {
        setState(() {
          _fatalError =
              'Camera permission is required for live insect scan. '
              'Allow camera access in Settings, then open this tab again.';
        });
      }
      return;
    }

    await _classifier.init();
    if (mounted) setState(() {});

    if (appCameras.isEmpty) {
      setState(() => _fatalError = 'No camera detected on this device.');
      return;
    }
    final selected = appCameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => appCameras.first,
    );
    debugPrint(
      'Available cameras: ${appCameras.map((c) => "${c.name}/${c.lensDirection.name}").join(", ")}; '
      'using: ${selected.name}/${selected.lensDirection.name}',
    );
    final controller = CameraController(
      selected,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    try {
      await controller.initialize();
    } catch (e) {
      setState(() => _fatalError = 'Camera init failed: $e');
      return;
    }
    try {
      await controller.startImageStream(_onFrame);
    } catch (e) {
      await controller.dispose();
      setState(() => _fatalError = 'Could not start camera preview: $e');
      return;
    }
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  void _applyScanState({
    required String crop,
    required InsectResult result,
    required bool harmful,
    required String advice,
  }) {
    final bundle = CropLiveIntelligence.build(
      crop: crop,
      insectLabel: result.insectName,
      plausibleFrame: result.plausibleSubject,
      modelReady: result.modelReady,
      harmfulInsect: harmful,
      isDemo: result.isDemo,
      confidence: result.confidence,
    );
    setState(() {
      _selectedCrop = crop;
      _lastResult = result;
      _harmful = harmful;
      _advice = advice;
      _insightBundle = bundle;
    });
    _scheduleWikiFetch(result, crop: crop);
  }

  String _smoothCropChoice(LiveScanCropEstimate estimate) {
    if (estimate.crop == _cropVoteCrop) {
      _cropVoteStreak++;
    } else {
      _cropVoteCrop = estimate.crop;
      _cropVoteStreak = 1;
    }
    if (_cropVoteStreak >= 2 || estimate.confidence >= 0.62) {
      _cropAutoConfidence = (_cropAutoConfidence * 0.62 + estimate.confidence * 0.38)
          .clamp(0.25, 0.95);
      return estimate.crop;
    }
    _cropAutoConfidence = (_cropAutoConfidence * 0.85 + estimate.confidence * 0.15)
        .clamp(0.22, 0.92);
    return _selectedCrop;
  }

  void _scheduleWikiFetch(InsectResult result, {required String crop}) {
    _wikiDebounce?.cancel();
    if (!result.modelReady || !result.plausibleSubject) {
      if (mounted) {
        setState(() {
          _wikiLoading = false;
          _wikiExtract = null;
        });
      }
      return;
    }
    if (mounted) setState(() => _wikiLoading = true);
    _wikiDebounce = Timer(const Duration(seconds: 2), () async {
      final text = await LiveScanWebInsightService.instance.fetchInsightForScan(
        crop: crop,
        insectName: result.insectName,
        plausible: result.plausibleSubject,
      );
      if (!mounted) return;
      setState(() {
        _wikiLoading = false;
        _wikiExtract = text;
      });
    });
  }

  void _onFrame(CameraImage frame) {
    if (_busy) return;
    final now = DateTime.now();
    if (now.difference(_lastAnalysis).inMilliseconds < 1500) return;
    _lastAnalysis = now;
    _busy = true;

    Future(() => _classifier.classify(frame)).then((result) {
      if (!mounted) {
        _busy = false;
        return;
      }
      if (result == null) {
        _busy = false;
        return;
      }
      final rgb = _classifier.decodeCameraRgb(frame);
      final est = rgb != null ? LiveScanCropHeuristics.estimate(rgb) : null;
      final cropNow = est == null ? _selectedCrop : _smoothCropChoice(est);

      final plausible = result.plausibleSubject;
      final harmful = result.modelReady &&
          plausible &&
          _riskDb.isHarmful(result.insectName, cropNow);
      final advice = plausible
          ? _riskDb.getAdvice(result.insectName, cropNow, harmful)
          : result.message;

      _applyScanState(crop: cropNow, result: result, harmful: harmful, advice: advice);

      if (harmful &&
          plausible &&
          result.confidence >= 0.5 &&
          !result.isDemo) {
        _triggerAlert();
      }
      _busy = false;
    }).catchError((e) {
      debugPrint('Classification error: $e');
      _busy = false;
    });
  }

  Future<void> _triggerAlert() async {
    final now = DateTime.now();
    if (now.difference(_lastAlert).inMilliseconds < 5000) return;
    _lastAlert = now;

    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
    try {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 500);
      }
    } catch (_) {
      // Vibration plugin not available on this platform - ignore.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      c.dispose();
      _controller = null;
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      _bootstrap();
    }
  }

  @override
  void dispose() {
    _wikiDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _classifier.close();
    super.dispose();
  }

  ({Color bg, String signal, String advice, String insectLine, String cropLine}) _statusParts() {
    final r = _lastResult;
    Color bg = const Color(0xDD444444);
    String signal = 'Waiting for detection…';
    String advice = 'Point the camera at crop leaves or an insect.';
    String insectLine = 'Insect: —';
    final confPct = (_cropAutoConfidence * 100).round();
    final cropLine = 'Crop: $_selectedCrop · auto (confidence ~$confPct%)';

    if (r != null) {
      insectLine =
          'Insect: ${r.insectName} (${(r.confidence * 100).toStringAsFixed(1)}%)';
      if (!r.modelReady) {
        bg = const Color(0xDD444444);
        signal = 'MODEL NEEDED';
        advice = r.message;
      } else if (!r.plausibleSubject) {
        bg = const Color(0xDD6D4C41);
        signal = 'NOT A CROP / INSECT PHOTO';
        advice = r.message;
      } else if (r.confidence < 0.5) {
        bg = const Color(0xDD444444);
        signal = 'LOW CONFIDENCE';
        advice = 'Move closer to the insect or foliage and reduce motion blur.';
      } else if (_harmful) {
        bg = const Color(0xDDB71C1C);
        signal = r.isDemo
            ? 'DANGER (demo): May harm $_selectedCrop'
            : 'DANGER: Harmful for $_selectedCrop';
        advice = _advice;
      } else {
        bg = const Color(0xDD1B5E20);
        signal = r.isDemo
            ? 'SAFE (demo): Not a major listed pest for $_selectedCrop'
            : 'SAFE: Not a major listed pest for $_selectedCrop';
        advice = _advice;
      }
    }
    return (bg: bg, signal: signal, advice: advice, insectLine: insectLine, cropLine: cropLine);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).liveScanTitle),
        centerTitle: true,
      ),
      body: _fatalError != null
          ? _errorView(_fatalError!)
          : (_controller == null || !_controller!.value.isInitialized)
              ? Column(
                  children: [
                    if (_classifier.usesDemoModel) _demoModeBanner(),
                    const Expanded(child: Center(child: CircularProgressIndicator())),
                  ],
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final scheme = Theme.of(context).colorScheme;
                    return Column(
                      children: [
                        if (_classifier.usesDemoModel) _demoModeBanner(),
                        Expanded(
                          flex: 11,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: scheme.outlineVariant.withValues(alpha: 0.55),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: ColoredBox(
                                  color: Colors.black,
                                  child: _cameraPreview(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 13,
                          child: _insightsPanel(context),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _insightsPanel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = _statusParts();
    final bundle = _insightBundle;

    return Material(
      color: scheme.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: s.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.insectLine,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.cropLine,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  s.signal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.advice,
                  style: const TextStyle(color: Colors.white, height: 1.3, fontSize: 13),
                ),
              ],
            ),
          ),
          if (_wikiLoading) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 4),
            Text(
              'Fetching live reference from Wikipedia…',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
          ],
          if (_wikiExtract != null && _wikiExtract!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.public, size: 18, color: scheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Live web note',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _wikiExtract!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Source: English Wikipedia (CC BY-SA). Connection required.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (bundle != null) ...[
            const SizedBox(height: 6),
            _expansion(
              context,
              initiallyExpanded: true,
              icon: Icons.bug_report_outlined,
              title: 'Insect risk (for $_selectedCrop · auto)',
              child: Text(
                bundle.insectRiskSummary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ),
            _expansion(
              context,
              icon: Icons.biotech_outlined,
              title: 'Crop disease risks',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bundle.diseaseRisks
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                e,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            _expansion(
              context,
              icon: Icons.shield_outlined,
              title: 'Prevention & field hygiene',
              child: _bulleted(context, bundle.preventionSteps),
            ),
            _expansion(
              context,
              icon: Icons.medical_services_outlined,
              title: 'Treatment & IPM (general)',
              child: _bulleted(context, bundle.treatmentNotes),
            ),
            _expansion(
              context,
              icon: Icons.lightbulb_outline,
              title: 'Related recommendations',
              child: _bulleted(context, bundle.recommendations),
            ),
          ],
        ],
      ),
    );
  }

  Widget _expansion(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
    bool initiallyExpanded = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: scheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [child],
      ),
    );
  }

  Widget _bulleted(BuildContext context, List<String> lines) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      e,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _demoModeBanner() => Material(
        color: const Color(0xFFFFF3E0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(Icons.science_outlined, color: Colors.orange.shade800, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Demo mode — add assets/insect_model.tflite for trained insect ID. '
                  'Crop row is estimated from frame colours (not a crop classifier).',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade900,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _errorView(String msg) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(msg, textAlign: TextAlign.center),
        ),
      );

  Widget _cameraPreview(BuildContext context) {
    final c = _controller!;
    if (!c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final previewSize = c.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(
        c,
        key: ValueKey<String>('${c.description.name}_${c.description.lensDirection}'),
      );
    }
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    final imageWidth = isPortrait ? previewSize.height : previewSize.width;
    final imageHeight = isPortrait ? previewSize.width : previewSize.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          clipBehavior: Clip.hardEdge,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(
            width: imageWidth,
            height: imageHeight,
            child: CameraPreview(
              c,
              key: ValueKey<String>(
                '${c.description.name}_${c.description.lensDirection}',
              ),
            ),
          ),
        );
      },
    );
  }
}
