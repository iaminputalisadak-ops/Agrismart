package com.example.insectcropcamera;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import androidx.camera.core.ImageProxy;

import java.nio.ByteBuffer;

public class ImageUtils {

    public static Bitmap imageProxyToBitmap(ImageProxy imageProxy) {
        try {
            ImageProxy.PlaneProxy[] planes = imageProxy.getPlanes();

            if (planes.length < 1) {
                return null;
            }

            ByteBuffer buffer = planes[0].getBuffer();
            byte[] bytes = new byte[buffer.remaining()];
            buffer.get(bytes);

            Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);

            if (bitmap != null) {
                return bitmap;
            }

            return Bitmap.createBitmap(224, 224, Bitmap.Config.ARGB_8888);

        } catch (Exception e) {
            return null;
        }
    }
}
