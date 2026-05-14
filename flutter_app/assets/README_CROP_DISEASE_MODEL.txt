Crop disease TFLite (optional)
=============================

1. Train a model (e.g. Teachable Machine image project) with one class per disease
   PLUS recommended: a "not_a_leaf" or "other" class for obvious non-crop images.

2. Export to TensorFlow Lite with FLOAT input, 224 x 224 x 3, RGB 0–1 (same style as
   the optional insect_model.tflite used by Live scan; see assets/README_INSECT_MODEL.txt).

3. Copy into flutter_app/assets/:
   - crop_disease_model.tflite
   - crop_disease_labels.txt   (one class name per line, same order as model outputs)

4. Register both files under flutter: assets: in pubspec.yaml next to labels.txt.

5. Rebuild the app. The screen runs a heuristic "foliage" gate first; only if that
   passes will the disease model run. Low confidence or ambiguous softmax is rejected.

For production accuracy, replace heuristics with a dedicated plant-vs-background
binary classifier trained on your domain.
