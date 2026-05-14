Insect TFLite model (optional)
=============================

The Live scan tab works out of the box in "demo" mode (colour heuristics + labels.txt).

For real species recognition:

1. Train or export a float32 model with input shape [1, 224, 224, 3] (RGB 0–1) and
   one output logit per line in assets/labels.txt (same order).

2. Save as flutter_app/assets/insect_model.tflite (valid file, typically tens of KB+).

3. Register the file under flutter: assets: in pubspec.yaml next to labels.txt.

4. Rebuild the app.
