PLACE YOUR MODEL HERE

Required file name:
insect_model.tflite

Required labels file:
labels.txt

Important:
The included Java classifier assumes a CLASSIFICATION model with:
Input: 224 x 224 x 3 float32
Output: 1 x number_of_labels float32

If you use YOLO object detection TFLite, you must update InsectClassifier.java
for YOLO output parsing and bounding boxes.

Recommended easiest method:
Train an image classification model first using Teachable Machine or TensorFlow.
Export as TensorFlow Lite float model.
Rename it insect_model.tflite.
Keep labels.txt matching your model order.
