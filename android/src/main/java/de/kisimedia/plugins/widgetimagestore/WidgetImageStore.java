package de.kisimedia.plugins.widgetimagestore;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.util.Base64;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class WidgetImageStore {

    private enum ImageFormat {
        JPEG,
        PNG,
        WEBP
    }

    public String saveBase64Image(
        Context context,
        String base64,
        String filename,
        boolean resize,
        String requestedFormat,
        Float requestedQuality
    ) {
        try {
            String cleanBase64 = base64.replaceAll("^data:image/[^;]+;base64,", "");
            byte[] decoded = Base64.decode(cleanBase64, Base64.DEFAULT);
            String mimeType = extractMimeType(base64);

            Bitmap bitmap = BitmapFactory.decodeByteArray(decoded, 0, decoded.length);
            if (bitmap == null) {
                return null;
            }

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

            ImageFormat format = resolveFormat(requestedFormat, filename, mimeType, bitmap.hasAlpha());
            int compressionQuality = Math.round(sanitizeQuality(requestedQuality) * 100f);

            File file = new File(context.getFilesDir(), filename);
            try (FileOutputStream out = new FileOutputStream(file)) {
                bitmap.compress(resolveCompressFormat(format, bitmap.hasAlpha()), compressionQuality, out);
                out.flush();
                return file.getAbsolutePath();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private Bitmap.CompressFormat resolveCompressFormat(ImageFormat format, boolean hasAlpha) {
        switch (format) {
            case PNG:
                return Bitmap.CompressFormat.PNG;
            case WEBP:
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    return hasAlpha ? Bitmap.CompressFormat.WEBP_LOSSLESS : Bitmap.CompressFormat.WEBP_LOSSY;
                }
                return Bitmap.CompressFormat.WEBP;
            case JPEG:
            default:
                return Bitmap.CompressFormat.JPEG;
        }
    }

    private float sanitizeQuality(Float quality) {
        if (quality == null) {
            return 0.85f;
        }
        return Math.max(0f, Math.min(quality, 1f));
    }

    private String extractMimeType(String base64) {
        String[] parts = base64.split(",", 2);
        if (parts.length == 0) {
            return null;
        }

        String prefix = parts[0].toLowerCase();
        if (!prefix.startsWith("data:image/") || !prefix.contains(";base64")) {
            return null;
        }

        int start = "data:image/".length();
        int end = prefix.indexOf(';');
        if (end <= start) {
            return null;
        }

        return prefix.substring(start, end);
    }

    private ImageFormat resolveFormat(String requestedFormat, String filename, String mimeType, boolean hasAlpha) {
        String normalizedRequested = normalizeFormat(requestedFormat);
        if (normalizedRequested != null && !normalizedRequested.equals("auto")) {
            return formatFromNormalized(normalizedRequested);
        }

        String extension = "";
        int lastDot = filename.lastIndexOf('.');
        if (lastDot >= 0 && lastDot < filename.length() - 1) {
            extension = filename.substring(lastDot + 1).toLowerCase();
        }

        String preferred = normalizeFormat(mimeType);
        if (preferred == null) {
            preferred = normalizeFormat(extension);
        }

        if ("jpeg".equals(preferred) && hasAlpha) {
            return ImageFormat.PNG;
        }
        if (preferred != null && !preferred.equals("auto")) {
            return formatFromNormalized(preferred);
        }

        return hasAlpha ? ImageFormat.PNG : ImageFormat.JPEG;
    }

    private String normalizeFormat(String value) {
        if (value == null) {
            return null;
        }

        switch (value.toLowerCase()) {
            case "auto":
                return "auto";
            case "jpg":
            case "jpeg":
                return "jpeg";
            case "png":
                return "png";
            case "webp":
                return "webp";
            default:
                return null;
        }
    }

    private ImageFormat formatFromNormalized(String value) {
        switch (value) {
            case "png":
                return ImageFormat.PNG;
            case "webp":
                return ImageFormat.WEBP;
            case "jpeg":
            default:
                return ImageFormat.JPEG;
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

            boolean isImage = name.endsWith(".jpg") || name.endsWith(".jpeg")
                || name.endsWith(".png") || name.endsWith(".webp");

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
            .filter(
                name -> name.toLowerCase().endsWith(".jpg")
                    || name.toLowerCase().endsWith(".jpeg")
                    || name.toLowerCase().endsWith(".png")
                    || name.toLowerCase().endsWith(".webp")
            )
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
