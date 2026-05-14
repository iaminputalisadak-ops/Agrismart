package com.example.insectcropcamera;

public class InsectResult {
    public String insectName;
    public float confidence;
    public boolean modelReady;
    public String message;
    /** False when heuristics decide the image is not a plausible farm subject. */
    public boolean plausibleSubject;

    public InsectResult(String insectName, float confidence, boolean modelReady, String message,
                        boolean plausibleSubject) {
        this.insectName = insectName;
        this.confidence = confidence;
        this.modelReady = modelReady;
        this.message = message;
        this.plausibleSubject = plausibleSubject;
    }
}
