import Foundation

@objc public class WidgetImageStore: NSObject {

    @objc public func saveBase64Image(_ base64: String, filename: String, appGroup: String)
        -> String?
    {
        guard let path = resolveFileURL(filename: filename, appGroup: appGroup) else {
            print("❌ Invalid file path")
            return nil
        }

        let base64Clean = base64.replacingOccurrences(
            of: "^data:image/[^;]+;base64,", with: "", options: .regularExpression)

        guard let imageData = Data(base64Encoded: base64Clean) else {
            print("❌ Invalid Base64")
            return nil
        }

        do {
            try imageData.write(to: path)
            print("✅ Image saved to path: \(path.path)")
            return path.path
        } catch {
            print("❌ Write failed:", error)
            return nil
        }
    }

    @objc public func deleteImage(_ filename: String, appGroup: String) -> Bool {
        guard let path = resolveFileURL(filename: filename, appGroup: appGroup) else {
            print("❌ Invalid file path")
            return false
        }

        do {
            try FileManager.default.removeItem(at: path)
            return true
        } catch {
            print("❌ Delete failed:", error)
            return false
        }
    }

    @objc public func deleteExcept(keep: [String], appGroup: String) {
        guard
            let url = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroup)
        else {
            print("❌ App Group Container URL not found")
            return
        }

        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url, includingPropertiesForKeys: nil)

            for fileURL in contents {
                let filename = fileURL.lastPathComponent

                if !keep.contains(filename),
                    !fileURL.hasDirectoryPath,
                    filename.lowercased().hasSuffix(".jpg")
                        || filename.lowercased().hasSuffix(".jpeg")
                        || filename.lowercased().hasSuffix(".png")
                        || filename.lowercased().hasSuffix(".webp")
                {

                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            print("❌ DeleteExcept failed:", error)
        }
    }

    @objc public func listImages(appGroup: String) -> [String] {
        guard
            let url = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroup)
        else {
            print("❌ App Group Container URL not found")
            return []
        }

        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url, includingPropertiesForKeys: nil)
            let imageFiles =
                contents
                .filter { $0.hasDirectoryPath == false }
                .filter {
                    $0.lastPathComponent.lowercased().hasSuffix(".jpg")
                        || $0.lastPathComponent.lowercased().hasSuffix(".jpeg")
                        || $0.lastPathComponent.lowercased().hasSuffix(".png")
                        || $0.lastPathComponent.lowercased().hasSuffix(".webp")
                }
                .map { $0.lastPathComponent }

            return imageFiles
        } catch {
            print("❌ Failed to list directory:", error)
            return []
        }
    }

    @objc public func imageExists(filename: String, appGroup: String) -> Bool {
        guard let fileURL = resolveFileURL(filename: filename, appGroup: appGroup) else {
            return false
        }
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    @objc public func imagePath(filename: String, appGroup: String) -> String? {
        return resolveFileURL(filename: filename, appGroup: appGroup)?.path
    }

    private func resolveFileURL(filename: String, appGroup: String) -> URL? {
        guard isSafeFilename(filename) else {
            return nil
        }
        guard
            let url = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroup)
        else {
            return nil
        }
        let containerURL = url.standardizedFileURL
        let fileURL = containerURL.appendingPathComponent(filename).standardizedFileURL
        let allowedPrefix = containerURL.path.hasSuffix("/") ? containerURL.path : containerURL.path + "/"
        guard fileURL.path.hasPrefix(allowedPrefix) else {
            return nil
        }
        return fileURL
    }

    private func isSafeFilename(_ filename: String) -> Bool {
        if filename.isEmpty { return false }
        if filename == "." || filename == ".." { return false }
        if filename.contains("/") || filename.contains("\\") { return false }
        if filename.contains("\0") { return false }
        return filename == (filename as NSString).lastPathComponent
    }

}
