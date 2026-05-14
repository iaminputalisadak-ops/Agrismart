package com.example.insectcropcamera;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.graphics.Bitmap;

import org.tensorflow.lite.Interpreter;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class InsectClassifier {

    private static final int INPUT_SIZE = 224;
    private static final int PIXEL_SIZE = 3;
    private static final String MODEL_FILE = "insect_model.tflite";
    private static final String LABEL_FILE = "labels.txt";

    private Interpreter interpreter;
    private List<String> labels = new ArrayList<>();
    private boolean modelReady = false;
    private String errorMessage = "";

    public InsectClassifier(Context context) {
        try {
            interpreter = new Interpreter(loadModelFile(context, MODEL_FILE));
            labels = loadLabels(context, LABEL_FILE);
            modelReady = true;
        } catch (Exception e) {
            modelReady = false;
            errorMessage = "Add your trained insect_model.tflite and labels.txt into app/src/main/assets/. "
                    + "Current error: " + e.getMessage();
        }
    }

    public InsectResult classify(Bitmap bitmap) {
        if (!modelReady) {
            return new InsectResult("Unknown", 0f, false, errorMessage, false);
        }

        Bitmap resizedBitmap = Bitmap.createScaledBitmap(bitmap, INPUT_SIZE, INPUT_SIZE, true);
        ByteBuffer inputBuffer = convertBitmapToByteBuffer(resizedBitmap);

        float[][] output = new float[1][labels.size()];
        interpreter.run(inputBuffer, output);

        float[] probs = output[0];
        int bestIndex = 0;
        float bestConfidence = probs[0];

        for (int i = 1; i < labels.size(); i++) {
            if (probs[i] > bestConfidence) {
                bestConfidence = probs[i];
                bestIndex = i;
            }
        }

        float[] sorted = Arrays.copyOf(probs, probs.length);
        Arrays.sort(sorted);
        float second = sorted.length >= 2 ? sorted[sorted.length - 2] : 0f;
        float margin = bestConfidence - second;

        int highProbClasses = 0;
        for (float p : probs) {
            if (p > 0.11f) highProbClasses++;
        }

        float agriRatio = agriRelevantPixelRatio(resizedBitmap);
        boolean plausible = isPlausibleSubject(bestConfidence, margin, highProbClasses, agriRatio);

        if (!plausible) {
            return new InsectResult(
                    "No clear crop / insect",
                    bestConfidence,
                    true,
                    "This image does not look like a plant, seed, food crop, or a clear insect "
                            + "close-up—or the model is unsure. Center the camera on leaves, fruit, "
                            + "seeds, or the insect. Random objects are not supported.",
                    false
            );
        }

        String insectName = labels.get(bestIndex);
        return new InsectResult(insectName, bestConfidence, true, "Detection completed.", true);
    }

    private static boolean isPlausibleSubject(float top, float margin, int highProbClasses, float agriColorRatio) {
        final float minTop = 0.46f;
        final float minMargin = 0.12f;
        final int maxHighProbClasses = 3;
        final float minAgriRatio = 0.038f;
        final float agriEscapeMargin = 0.34f;
        final float agriEscapeTop = 0.86f;

        if (top < minTop) return false;
        if (margin < minMargin) return false;
        if (highProbClasses > maxHighProbClasses) return false;

        boolean agriOk = agriColorRatio >= minAgriRatio || margin >= agriEscapeMargin || top >= agriEscapeTop;
        return agriOk;
    }

    private static float agriRelevantPixelRatio(Bitmap bitmap) {
        int w = bitmap.getWidth();
        int h = bitmap.getHeight();
        if (w <= 0 || h <= 0) return 0f;

        int[] pixels = new int[w * h];
        bitmap.getPixels(pixels, 0, w, 0, 0, w, h);

        int hit = 0;
        for (int pixel : pixels) {
            int r = (pixel >> 16) & 0xFF;
            int g = (pixel >> 8) & 0xFF;
            int b = pixel & 0xFF;

            boolean greenLeaf = g > r + 14 && g > b + 14 && g > 52;
            boolean yellowCrop = r > 118 && g > 98 && b < 105 && r + g > b + 80 && Math.abs(r - g) < 55;
            if (greenLeaf || yellowCrop) hit++;
        }
        return hit / (float) pixels.length;
    }

    private ByteBuffer convertBitmapToByteBuffer(Bitmap bitmap) {
        ByteBuffer byteBuffer = ByteBuffer.allocateDirect(4 * INPUT_SIZE * INPUT_SIZE * PIXEL_SIZE);
        byteBuffer.order(ByteOrder.nativeOrder());

        int[] pixels = new int[INPUT_SIZE * INPUT_SIZE];
        bitmap.getPixels(pixels, 0, INPUT_SIZE, 0, 0, INPUT_SIZE, INPUT_SIZE);

        int pixelIndex = 0;

        for (int y = 0; y < INPUT_SIZE; y++) {
            for (int x = 0; x < INPUT_SIZE; x++) {
                int pixel = pixels[pixelIndex++];

                float r = ((pixel >> 16) & 0xFF) / 255.0f;
                float g = ((pixel >> 8) & 0xFF) / 255.0f;
                float b = (pixel & 0xFF) / 255.0f;

                byteBuffer.putFloat(r);
                byteBuffer.putFloat(g);
                byteBuffer.putFloat(b);
            }
        }

        return byteBuffer;
    }

    private MappedByteBuffer loadModelFile(Context context, String fileName) throws IOException {
        AssetFileDescriptor fileDescriptor = context.getAssets().openFd(fileName);
        FileInputStream inputStream = new FileInputStream(fileDescriptor.getFileDescriptor());
        FileChannel fileChannel = inputStream.getChannel();

        long startOffset = fileDescriptor.getStartOffset();
        long declaredLength = fileDescriptor.getDeclaredLength();

        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength);
    }

    private List<String> loadLabels(Context context, String fileName) throws IOException {
        List<String> labelList = new ArrayList<>();

        BufferedReader reader = new BufferedReader(
                new InputStreamReader(context.getAssets().open(fileName))
        );

        String line;

        while ((line = reader.readLine()) != null) {
            if (!line.trim().isEmpty()) {
                labelList.add(line.trim().toLowerCase());
            }
        }

        reader.close();
        return labelList;
    }

    public void close() {
        if (interpreter != null) {
            interpreter.close();
        }
    }
}
