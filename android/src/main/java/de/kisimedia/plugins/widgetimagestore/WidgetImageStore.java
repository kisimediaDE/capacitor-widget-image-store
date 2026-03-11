package de.kisimedia.plugins.widgetimagestore;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.util.Base64;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

public class WidgetImageStore {

    private enum ImageFormat {
        JPEG,
        PNG,
        WEBP
    }

    public static final class SaveResult {

        private final String path;
        private final String error;

        private SaveResult(String path, String error) {
            this.path = path;
            this.error = error;
        }

        public static SaveResult success(String path) {
            return new SaveResult(path, null);
        }

        public static SaveResult failure(String error) {
            return new SaveResult(null, error);
        }

        public String getPath() {
            return path;
        }

        public String getError() {
            return error;
        }
    }

    public SaveResult saveBase64Image(
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
                return SaveResult.failure("Image decoding failed");
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
            String fileExtension = extractFileExtension(filename);
            if (!fileExtension.isEmpty()) {
                if (!isExtensionCompatible(fileExtension, format)) {
                    String actualExtension = fileExtension.isEmpty() ? "(none)" : fileExtension;
                    String[] compatible = compatibleExtensions(format);
                    StringBuilder expectedBuilder = new StringBuilder();
                    for (int i = 0; i < compatible.length; i++) {
                        if (i > 0) {
                            expectedBuilder.append("/");
                        }
                        expectedBuilder.append(compatible[i]);
                    }
                    String expectedExtensions = expectedBuilder.toString();
                    return SaveResult.failure(
                        "Filename extension '" +
                            actualExtension +
                            "' does not match resolved format '" +
                            formatName(format) +
                            "'. Use ." +
                            expectedExtensions +
                            "."
                    );
                }
            }
            int compressionQuality = Math.round(sanitizeQuality(requestedQuality) * 100f);

            File file = resolveSafeFile(context, filename);
            if (file == null) {
                return SaveResult.failure("Invalid filename path");
            }
            try (FileOutputStream out = new FileOutputStream(file)) {
                boolean success = bitmap.compress(resolveCompressFormat(format), compressionQuality, out);
                if (!success) {
                    return SaveResult.failure("Image encoding failed");
                }
                out.flush();
                return SaveResult.success(file.getAbsolutePath());
            }
        } catch (Exception e) {
            e.printStackTrace();
            return SaveResult.failure("Image save failed");
        }
    }

    private Bitmap.CompressFormat resolveCompressFormat(ImageFormat format) {
        switch (format) {
            case PNG:
                return Bitmap.CompressFormat.PNG;
            case WEBP:
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    return Bitmap.CompressFormat.WEBP_LOSSY;
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
        float q = quality;
        if (Float.isNaN(q) || Float.isInfinite(q)) {
            return 0.85f;
        }
        return Math.max(0f, Math.min(q, 1f));
    }

    private String extractMimeType(String base64) {
        String[] parts = base64.split(",", 2);
        if (parts.length < 2) {
            return null;
        }

        String prefix = parts[0].toLowerCase(Locale.ROOT);
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
            extension = filename.substring(lastDot + 1).toLowerCase(Locale.ROOT);
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

        switch (value.toLowerCase(Locale.ROOT)) {
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

    private String extractFileExtension(String filename) {
        int lastDot = filename.lastIndexOf('.');
        if (lastDot >= 0 && lastDot < filename.length() - 1) {
            return filename.substring(lastDot + 1).toLowerCase(Locale.ROOT);
        }
        return "";
    }

    private boolean isExtensionCompatible(String extension, ImageFormat format) {
        for (String expectedExtension : compatibleExtensions(format)) {
            if (expectedExtension.equals(extension)) {
                return true;
            }
        }
        return false;
    }

    private String[] compatibleExtensions(ImageFormat format) {
        switch (format) {
            case PNG:
                return new String[] { "png" };
            case WEBP:
                return new String[] { "webp" };
            case JPEG:
            default:
                return new String[] { "jpg", "jpeg" };
        }
    }

    private String formatName(ImageFormat format) {
        switch (format) {
            case PNG:
                return "png";
            case WEBP:
                return "webp";
            case JPEG:
            default:
                return "jpeg";
        }
    }

    public boolean deleteImage(Context context, String filename) {
        try {
            File file = resolveSafeFile(context, filename);
            return file != null && file.exists() && file.delete();
        } catch (IOException e) {
            return false;
        }
    }

    public void deleteExcept(Context context, String[] keep) {
        File dir = context.getFilesDir();
        File[] files = dir.listFiles();
        if (files == null) return;

        Set<String> keepSet = new HashSet<>(Arrays.asList(keep));

        for (File file : files) {
            String name = file.getName().toLowerCase(Locale.ROOT);

            boolean isImage = name.endsWith(".jpg") || name.endsWith(".jpeg") || name.endsWith(".png") || name.endsWith(".webp");

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
            .filter((name) -> {
                String nameLower = name.toLowerCase(Locale.ROOT);
                return (
                    nameLower.endsWith(".jpg") || nameLower.endsWith(".jpeg") || nameLower.endsWith(".png") || nameLower.endsWith(".webp")
                );
            })
            .toArray(String[]::new);
    }

    public boolean imageExists(Context context, String filename) {
        try {
            File file = resolveSafeFile(context, filename);
            return file != null && file.exists();
        } catch (IOException e) {
            return false;
        }
    }

    public String getImagePath(Context context, String filename) {
        try {
            File file = resolveSafeFile(context, filename);
            return file == null ? null : file.getAbsolutePath();
        } catch (IOException e) {
            return null;
        }
    }

    private File resolveSafeFile(Context context, String filename) throws IOException {
        File baseDir = context.getFilesDir().getCanonicalFile();
        File targetFile = new File(baseDir, filename).getCanonicalFile();
        String basePath = baseDir.getPath();
        String allowedPrefix = basePath.endsWith(File.separator) ? basePath : basePath + File.separator;
        if (!targetFile.getPath().startsWith(allowedPrefix)) {
            return null;
        }
        return targetFile;
    }
}
