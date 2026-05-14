package com.example.insectcropcamera;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.os.Bundle;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ExperimentalGetImage;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.content.ContextCompat;

import com.google.common.util.concurrent.ListenableFuture;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainActivity extends AppCompatActivity {

    private PreviewView previewView;
    private Spinner cropSpinner;
    private LinearLayout resultPanel;
    private TextView txtInsect, txtCrop, txtSignal, txtAdvice;

    private ExecutorService cameraExecutor;
    private InsectClassifier classifier;
    private CropRiskDatabase riskDatabase;

    private long lastAlertTime = 0;
    private long lastAnalysisTime = 0;

    private final String[] crops = {
            "Rice", "Maize", "Wheat", "Potato", "Tomato", "Mustard", "Sugarcane", "Cotton"
    };

    private final ActivityResultLauncher<String> cameraPermissionLauncher =
            registerForActivityResult(new ActivityResultContracts.RequestPermission(), granted -> {
                if (granted) {
                    startCamera();
                } else {
                    txtSignal.setText("Camera permission denied.");
                }
            });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        previewView = findViewById(R.id.previewView);
        cropSpinner = findViewById(R.id.cropSpinner);
        resultPanel = findViewById(R.id.resultPanel);
        txtInsect = findViewById(R.id.txtInsect);
        txtCrop = findViewById(R.id.txtCrop);
        txtSignal = findViewById(R.id.txtSignal);
        txtAdvice = findViewById(R.id.txtAdvice);

        ArrayAdapter<String> adapter = new ArrayAdapter<>(
                this,
                android.R.layout.simple_spinner_dropdown_item,
                crops
        );
        cropSpinner.setAdapter(adapter);

        cameraExecutor = Executors.newSingleThreadExecutor();
        classifier = new InsectClassifier(this);
        riskDatabase = new CropRiskDatabase();

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED) {
            startCamera();
        } else {
            cameraPermissionLauncher.launch(Manifest.permission.CAMERA);
        }
    }

    private void startCamera() {
        ListenableFuture<ProcessCameraProvider> cameraProviderFuture =
                ProcessCameraProvider.getInstance(this);

        cameraProviderFuture.addListener(() -> {
            try {
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();

                Preview preview = new Preview.Builder().build();
                preview.setSurfaceProvider(previewView.getSurfaceProvider());

                ImageAnalysis imageAnalysis = new ImageAnalysis.Builder()
                        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                        .build();

                imageAnalysis.setAnalyzer(cameraExecutor, this::analyzeImage);

                CameraSelector cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA;

                cameraProvider.unbindAll();
                cameraProvider.bindToLifecycle(
                        this,
                        cameraSelector,
                        preview,
                        imageAnalysis
                );

            } catch (Exception e) {
                runOnUiThread(() -> txtSignal.setText("Camera error: " + e.getMessage()));
            }
        }, ContextCompat.getMainExecutor(this));
    }

    private void analyzeImage(@NonNull ImageProxy imageProxy) {
        long now = System.currentTimeMillis();

        if (now - lastAnalysisTime < 1500) {
            imageProxy.close();
            return;
        }
        lastAnalysisTime = now;

        Bitmap bitmap = ImageUtils.imageProxyToBitmap(imageProxy);
        imageProxy.close();

        if (bitmap == null) return;

        InsectResult result = classifier.classify(bitmap);
        String selectedCrop = cropSpinner.getSelectedItem().toString();

        boolean harmful = result.modelReady && result.plausibleSubject
                && riskDatabase.isHarmful(result.insectName, selectedCrop);
        String advice = result.plausibleSubject
                ? riskDatabase.getAdvice(result.insectName, selectedCrop, harmful)
                : result.message;

        runOnUiThread(() -> updateUI(result, selectedCrop, harmful, advice));
    }

    private void updateUI(InsectResult result, String crop, boolean harmful, String advice) {
        txtInsect.setText("Insect: " + result.insectName + " (" + String.format("%.1f", result.confidence * 100) + "%)");
        txtCrop.setText("Crop: " + crop);

        if (!result.modelReady) {
            resultPanel.setBackgroundColor(Color.parseColor("#DD444444"));
            txtSignal.setText("MODEL NEEDED");
            txtAdvice.setText(result.message);
            return;
        }

        if (!result.plausibleSubject) {
            resultPanel.setBackgroundColor(Color.parseColor("#DD6D4C41"));
            txtSignal.setText("NOT A CROP / INSECT PHOTO");
            txtAdvice.setText(result.message);
            return;
        }

        if (result.confidence < 0.50f) {
            resultPanel.setBackgroundColor(Color.parseColor("#DD444444"));
            txtSignal.setText("Signal: LOW CONFIDENCE");
            txtAdvice.setText("Move camera closer to the insect and keep image clear.");
            return;
        }

        if (harmful) {
            resultPanel.setBackgroundColor(Color.parseColor("#DDB71C1C"));
            txtSignal.setText("⚠ DANGER: Harmful for " + crop);
            txtAdvice.setText(advice);
            triggerAlert();
        } else {
            resultPanel.setBackgroundColor(Color.parseColor("#DD1B5E20"));
            txtSignal.setText("✅ SAFE: Not harmful for " + crop);
            txtAdvice.setText(advice);
        }
    }

    private void triggerAlert() {
        long now = System.currentTimeMillis();

        if (now - lastAlertTime < 5000) return;
        lastAlertTime = now;

        ToneGenerator toneGenerator = new ToneGenerator(AudioManager.STREAM_ALARM, 100);
        toneGenerator.startTone(ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 600);

        Vibrator vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);

        if (vibrator != null && android.os.Build.VERSION.SDK_INT >= 26) {
            vibrator.vibrate(VibrationEffect.createOneShot(500, VibrationEffect.DEFAULT_AMPLITUDE));
        } else if (vibrator != null) {
            vibrator.vibrate(500);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        cameraExecutor.shutdown();
        classifier.close();
    }
}
