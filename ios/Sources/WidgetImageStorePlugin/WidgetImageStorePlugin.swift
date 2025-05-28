import Capacitor
import Foundation

/// Please read the Capacitor iOS Plugin Development Guide
/// here: https://capacitorjs.com/docs/plugins/ios
@objc(WidgetImageStorePlugin)
public class WidgetImageStorePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "WidgetImageStorePlugin"
    public let jsName = "WidgetImageStore"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "save", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = WidgetImageStore()

    @objc func save(_ call: CAPPluginCall) {
        let base64 = call.getString("base64") ?? ""
        let filename = call.getString("filename") ?? "image.jpg"
        let appGroup = call.getString("appGroup") ?? ""

        guard !appGroup.isEmpty else {
            call.reject("App Group is required")
            return
        }

        if let path = implementation.saveBase64Image(base64, filename: filename, appGroup: appGroup)
        {
            call.resolve([
                "path": path
            ])
        } else {
            call.reject("Failed to save image")
        }
    }

}
