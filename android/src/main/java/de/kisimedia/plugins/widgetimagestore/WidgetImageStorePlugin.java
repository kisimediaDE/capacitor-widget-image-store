package de.kisimedia.plugins.widgetimagestore;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.util.Locale;
import org.json.JSONException;

@CapacitorPlugin(name = "WidgetImageStore")
public class WidgetImageStorePlugin extends Plugin {

    private final WidgetImageStore implementation = new WidgetImageStore();

    @PluginMethod
    public void save(PluginCall call) {
        String base64 = call.getString("base64");
        String filename = call.getString("filename");
        boolean resize = call.getBoolean("resize", false);
        String format = call.getString("format");
        Float quality = call.getFloat("quality");

        if (base64 == null || filename == null) {
            call.reject("Missing parameters");
            return;
        }
        if (format != null && !isSupportedFormat(format)) {
            call.reject("Invalid format. Supported values: auto, jpeg, jpg, png, webp");
            return;
        }

        String path = implementation.saveBase64Image(getContext(), base64, filename, resize, format, quality);
        if (path != null) {
            JSObject ret = new JSObject();
            ret.put("path", path);
            call.resolve(ret);
        } else {
            String error = implementation.getLastError();
            call.reject(error != null ? error : "Image save failed");
        }
    }

    @PluginMethod
    public void delete(PluginCall call) {
        String filename = call.getString("filename");

        if (filename == null) {
            call.reject("Filename is required");
            return;
        }

        boolean success = implementation.deleteImage(getContext(), filename);
        if (success) {
            call.resolve();
        } else {
            call.reject("Failed to delete image");
        }
    }

    @PluginMethod
    public void deleteExcept(PluginCall call) throws JSONException {
        JSArray keepArray = call.getArray("keep");
        String appGroup = call.getString("appGroup");

        if (keepArray == null) {
            call.reject("Missing 'keep' array");
            return;
        }

        String[] keep = keepArray.toList().toArray(new String[0]);
        implementation.deleteExcept(getContext(), keep);
        call.resolve();
    }

    @PluginMethod
    public void list(PluginCall call) {
        String[] files = implementation.listImages(getContext());
        JSObject result = new JSObject();
        result.put("files", JSArray.from(files));
        call.resolve(result);
    }

    @PluginMethod
    public void exists(PluginCall call) {
        String filename = call.getString("filename");
        if (filename == null) {
            call.reject("Filename is required");
            return;
        }
        boolean exists = implementation.imageExists(getContext(), filename);
        JSObject result = new JSObject();
        result.put("exists", exists);
        call.resolve(result);
    }

    @PluginMethod
    public void getPath(PluginCall call) {
        String filename = call.getString("filename");
        if (filename == null) {
            call.reject("Filename is required");
            return;
        }
        String path = implementation.getImagePath(getContext(), filename);
        JSObject result = new JSObject();
        result.put("path", path);
        call.resolve(result);
    }

    private boolean isSupportedFormat(String value) {
        switch (value.toLowerCase(Locale.ROOT)) {
            case "auto":
            case "jpeg":
            case "jpg":
            case "png":
            case "webp":
                return true;
            default:
                return false;
        }
    }
}
