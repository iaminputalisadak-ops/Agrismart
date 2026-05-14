Place your trained model here as:

    insect_model.tflite

Model spec expected by the app:
- Input  : 224 x 224 x 3, float32, values normalized to [0, 1]
- Output : float32 array of size N, where N == number of lines in labels.txt
           (one probability per insect class, in the same order as labels.txt)

How to train one quickly (no code, free):

1. Open https://teachablemachine.withgoogle.com/
2. Pick "Image Project" -> "Standard image model".
3. Create one class per line in labels.txt (aphid, whitefly, grasshopper, ...).
4. Upload 30+ photos per class. Train.
5. Export -> Tensorflow Lite -> Floating point -> Download.
6. Rename the downloaded model file to "insect_model.tflite".
7. Drop it in this assets/ folder. Run the app.

If the file is missing, the app still launches and shows a "MODEL NEEDED" banner
instead of crashing.
