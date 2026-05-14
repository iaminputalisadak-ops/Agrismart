# TensorFlow Lite (tflite_flutter) — R8 strips optional GPU delegate classes referenced from core API.
-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
