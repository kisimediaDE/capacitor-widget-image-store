package de.kisimedia.plugins.widgetimagestore;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

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

    public void deleteExcept(Context context, String[] keep) {
        File dir = context.getFilesDir();
        File[] files = dir.listFiles();
        if (files == null) return;
    
        Set<String> keepSet = new HashSet<>(Arrays.asList(keep));
    
        for (File file : files) {
            String name = file.getName().toLowerCase();
    
            boolean isImage = name.endsWith(".jpg") || name.endsWith(".jpeg") ||
                              name.endsWith(".png") || name.endsWith(".webp");
    
            if (file.isFile() && isImage && !keepSet.contains(file.getName())) {
                file.delete();
            }
        }
    }

    public String[] listImages(Context context) {
        File dir = context.getFilesDir();
        File[] files = dir.listFiles();
        if (files == null) return new String[0];
    
        return Arrays.stream(files)
            .filter(File::isFile)
            .map(File::getName)
            .filter(name -> name.toLowerCase().endsWith(".jpg")
                         || name.toLowerCase().endsWith(".jpeg")
                         || name.toLowerCase().endsWith(".png")
                         || name.toLowerCase().endsWith(".webp"))
            .toArray(String[]::new);
    }

    public boolean imageExists(Context context, String filename) {
        File file = new File(context.getFilesDir(), filename);
        return file.exists();
    }
    
    public String getImagePath(Context context, String filename) {
        return new File(context.getFilesDir(), filename).getAbsolutePath();
    }
}
