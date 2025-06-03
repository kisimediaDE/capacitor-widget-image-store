package de.kisimedia.plugins.widgetimagestore;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;

public class WidgetImageStore {

    public String saveBase64Image(Context context, String base64, String filename, boolean resize) {
        try {
            // Strip data:image/... prefix
            String cleanBase64 = base64.replaceAll("^data:image/[^;]+;base64,", "");
            byte[] decoded = Base64.decode(cleanBase64, Base64.DEFAULT);

            Bitmap bitmap = BitmapFactory.decodeByteArray(decoded, 0, decoded.length);
            if (bitmap == null) return null;

            if (resize) {
                int maxSize = 1024;
                int width = bitmap.getWidth();
                int height = bitmap.getHeight();

                float scale = Math.min((float) maxSize / width, (float) maxSize / height);
                if (scale < 1.0f) {
                    int newWidth = Math.round(scale * width);
                    int newHeight = Math.round(scale * height);
                    bitmap = Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true);
                }
            }

            File file = new File(context.getFilesDir(), filename);
            try (FileOutputStream out = new FileOutputStream(file)) {
                bitmap.compress(Bitmap.CompressFormat.JPEG, 85, out);
                out.flush();
                return file.getAbsolutePath();
            }

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public boolean deleteImage(Context context, String filename) {
        File file = new File(context.getFilesDir(), filename);
        return file.exists() && file.delete();
    }
}
