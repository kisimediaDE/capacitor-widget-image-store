import Capacitor
import Foundation

/// Please read the Capacitor iOS Plugin Development Guide
/// here: https://capacitorjs.com/docs/plugins/ios
@objc(WidgetImageStorePlugin)
public class WidgetImageStorePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "WidgetImageStorePlugin"
    public let jsName = "WidgetImageStore"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "save", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "delete", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "deleteExcept", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "list", returnType: CAPPluginReturnPromise),
    ]
    private let implementation = WidgetImageStore()

    @objc public func save(_ call: CAPPluginCall) {
        guard let base64 = call.getString("base64"),
            let filename = call.getString("filename"),
            let appGroup = call.getString("appGroup")
        else {
            call.reject("Missing parameters")
            return
        }

        let shouldResize = call.getBool("resize") ?? false

        let base64Clean = base64.replacingOccurrences(
            of: "^data:image/[^;]+;base64,", with: "", options: .regularExpression)

        guard let data = Data(base64Encoded: base64Clean),
            var image = UIImage(data: data)
        else {
            call.reject("Image decoding failed")
            return
        }

        if shouldResize {
            let maxSize: CGFloat = 1024
            let scale = min(maxSize / image.size.width, maxSize / image.size.height, 1.0)
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            image = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }

        guard let jpgData = image.jpegData(compressionQuality: 0.85) else {
            call.reject("Image conversion failed")
            return
        }

        let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
        let fileURL = dir?.appendingPathComponent(filename)

        do {
            try jpgData.write(to: fileURL!)
            call.resolve(["path": fileURL!.path])
        } catch {
            call.reject("File write error: \(error.localizedDescription)")
        }
    }

    @objc func delete(_ call: CAPPluginCall) {
        let filename = call.getString("filename") ?? ""
        let appGroup = call.getString("appGroup") ?? ""

        guard !filename.isEmpty && !appGroup.isEmpty else {
            call.reject("Filename and App Group are required")
            return
        }

        if implementation.deleteImage(filename, appGroup: appGroup) {
            call.resolve()
        } else {
            call.reject("Failed to delete image")
        }
    }

    @objc public func deleteExcept(_ call: CAPPluginCall) {
        guard let appGroup = call.getString("appGroup"),
            let keep = call.getArray("keep") as? [String]
        else {
            call.reject("Missing parameters")
            return
        }

        implementation.deleteExcept(keep: keep, appGroup: appGroup)
        call.resolve()
    }

    @objc public func list(_ call: CAPPluginCall) {
        guard let appGroup = call.getString("appGroup") else {
            call.reject("Missing appGroup")
            return
        }

        let files = implementation.listImages(appGroup: appGroup)
        call.resolve(["files": files])
    }
}
