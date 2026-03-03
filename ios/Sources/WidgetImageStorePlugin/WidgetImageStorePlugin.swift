import Capacitor
import Foundation
import ImageIO
import UniformTypeIdentifiers
import UIKit

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
        CAPPluginMethod(name: "exists", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getPath", returnType: CAPPluginReturnPromise),
    ]
    private let implementation = WidgetImageStore()
    private enum ImageFormat {
        case jpeg
        case png
        case webp
    }

    @objc public func save(_ call: CAPPluginCall) {
        guard let base64 = call.getString("base64"),
            let filename = call.getString("filename"),
            let appGroup = call.getString("appGroup")
        else {
            call.reject("Missing parameters")
            return
        }

        let fileURL: URL
        switch WidgetImageStorePathGuard.resolveFileURLWithReason(filename: filename, appGroup: appGroup) {
        case .success(let resolvedURL):
            fileURL = resolvedURL
        case .failure(let error):
            switch error {
            case .invalidFilename:
                call.reject("Invalid filename or path")
            case .appGroupUnavailable:
                call.reject("App group container unavailable. Check appGroup configuration.")
            case .invalidPath:
                call.reject("Invalid filename or path")
            }
            return
        }

        let shouldResize = call.getBool("resize") ?? false
        let requestedFormat = call.getString("format")
        if let requestedFormat, normalizeFormat(requestedFormat) == nil {
            call.reject("Invalid format. Supported values: auto, jpeg, jpg, png, webp")
            return
        }
        let requestedQuality = call.getDouble("quality") ?? 0.85
        let quality = requestedQuality.isFinite
            ? max(0.0, min(requestedQuality, 1.0))
            : 0.85

        let base64Clean = base64.replacingOccurrences(
            of: "^data:image/[^;]+;base64,", with: "", options: .regularExpression)
        let mimeType = extractMimeType(from: base64)

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

        let format = resolveFormat(
            requestedFormat: requestedFormat,
            filename: filename,
            mimeType: mimeType,
            hasAlpha: imageHasAlpha(image)
        )
        let fileExtension = (filename as NSString).pathExtension.lowercased()
        if !fileExtension.isEmpty {
            guard isExtensionCompatible(fileExtension, with: format) else {
                let actualExtension = fileExtension.isEmpty ? "(none)" : fileExtension
                let expectedExtensions = compatibleExtensions(for: format).joined(separator: "/")
                call.reject(
                    "Filename extension '\(actualExtension)' does not match resolved format '\(formatName(format))'. Use .\(expectedExtensions)."
                )
                return
            }
        }

        guard let encodedData = encodeImage(image, format: format, quality: quality) else {
            call.reject("Image conversion failed")
            return
        }

        do {
            try encodedData.write(to: fileURL, options: .atomic)
            call.resolve(["path": fileURL.path])
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
        guard WidgetImageStorePathGuard.isSafeFilename(filename) else {
            call.reject("Invalid filename or path")
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

    @objc public func exists(_ call: CAPPluginCall) {
        guard let filename = call.getString("filename"),
            let appGroup = call.getString("appGroup")
        else {
            call.reject("Missing parameters")
            return
        }
        guard WidgetImageStorePathGuard.isSafeFilename(filename) else {
            call.reject("Invalid filename or path")
            return
        }
        let exists = implementation.imageExists(filename: filename, appGroup: appGroup)
        call.resolve(["exists": exists])
    }

    @objc public func getPath(_ call: CAPPluginCall) {
        guard let filename = call.getString("filename"),
            let appGroup = call.getString("appGroup")
        else {
            call.reject("Missing parameters")
            return
        }
        guard WidgetImageStorePathGuard.isSafeFilename(filename) else {
            call.reject("Invalid filename or path")
            return
        }
        guard let path = implementation.imagePath(filename: filename, appGroup: appGroup) else {
            call.reject("Path unavailable")
            return
        }
        call.resolve(["path": path])
    }

    private func normalizeFormat(_ value: String?) -> String? {
        guard let value else { return nil }
        switch value.lowercased() {
        case "auto":
            return "auto"
        case "jpg", "jpeg":
            return "jpeg"
        case "png":
            return "png"
        case "webp":
            return "webp"
        default:
            return nil
        }
    }

    private func formatFromNormalized(_ value: String) -> ImageFormat {
        switch value {
        case "png":
            return .png
        case "webp":
            return .webp
        default:
            return .jpeg
        }
    }

    private func extractMimeType(from base64: String) -> String? {
        guard
            let regex = try? NSRegularExpression(
                pattern: "^data:image/([^;]+);base64,",
                options: [.caseInsensitive]
            ),
            let match = regex.firstMatch(
                in: base64,
                options: [],
                range: NSRange(base64.startIndex..., in: base64)
            ),
            let range = Range(match.range(at: 1), in: base64)
        else {
            return nil
        }
        return base64[range].lowercased()
    }

    private func resolveFormat(
        requestedFormat: String?,
        filename: String,
        mimeType: String?,
        hasAlpha: Bool
    ) -> ImageFormat {
        if let normalizedRequested = normalizeFormat(requestedFormat), normalizedRequested != "auto" {
            return formatFromNormalized(normalizedRequested)
        }

        let fileExtension = (filename as NSString).pathExtension.lowercased()
        let preferred = normalizeFormat(mimeType) ?? normalizeFormat(fileExtension)

        if preferred == "jpeg", hasAlpha {
            return .png
        }
        if let preferred, preferred != "auto" {
            return formatFromNormalized(preferred)
        }

        return hasAlpha ? .png : .jpeg
    }

    private func imageHasAlpha(_ image: UIImage) -> Bool {
        guard let alphaInfo = image.cgImage?.alphaInfo else {
            return false
        }
        switch alphaInfo {
        case .first, .last, .premultipliedFirst, .premultipliedLast:
            return true
        default:
            return false
        }
    }

    private func compatibleExtensions(for format: ImageFormat) -> [String] {
        switch format {
        case .jpeg:
            return ["jpg", "jpeg"]
        case .png:
            return ["png"]
        case .webp:
            return ["webp"]
        }
    }

    private func isExtensionCompatible(_ fileExtension: String, with format: ImageFormat) -> Bool {
        return compatibleExtensions(for: format).contains(fileExtension)
    }

    private func formatName(_ format: ImageFormat) -> String {
        switch format {
        case .jpeg:
            return "jpeg"
        case .png:
            return "png"
        case .webp:
            return "webp"
        }
    }

    private func encodeImage(_ image: UIImage, format: ImageFormat, quality: Double) -> Data? {
        switch format {
        case .jpeg:
            return image.jpegData(compressionQuality: quality)
        case .png:
            return image.pngData()
        case .webp:
            return webpData(from: image, quality: quality)
        }
    }

    private func webpData(from image: UIImage, quality: Double) -> Data? {
        let sourceImage: UIImage
        if image.cgImage == nil {
            let renderer = UIGraphicsImageRenderer(size: image.size)
            sourceImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: image.size))
            }
        } else {
            sourceImage = image
        }

        guard let cgImage = sourceImage.cgImage else {
            return nil
        }

        let data = NSMutableData()
        let webpTypeIdentifier = UTType(filenameExtension: "webp")?.identifier ?? "org.webmproject.webp"
        guard
            let destination = CGImageDestinationCreateWithData(
                data,
                webpTypeIdentifier as CFString,
                1,
                nil
            )
        else {
            return nil
        }

        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: quality]
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return data as Data
    }
}
