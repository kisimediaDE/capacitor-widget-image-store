package de.kisimedia.plugins.widgetimagestore;

import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.JSObject;

@CapacitorPlugin(name = "WidgetImageStore")
public class WidgetImageStorePlugin extends Plugin {

    private final WidgetImageStore implementation = new WidgetImageStore();

    @PluginMethod
    public void save(PluginCall call) {
        String base64 = call.getString("base64");
        String filename = call.getString("filename");
        boolean resize = call.getBoolean("resize", false);

        if (base64 == null || filename == null) {
            call.reject("Missing parameters");
            return;
        }

        String path = implementation.saveBase64Image(getContext(), base64, filename, resize);
        if (path != null) {
            JSObject ret = new JSObject();
            ret.put("path", path);
            call.resolve(ret);
        } else {
            call.reject("Image save failed");
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
}
