import Foundation

@objc public class WidgetImageStore: NSObject {

    @objc public func saveBase64Image(_ base64: String, filename: String, appGroup: String)
        -> String?
    {
        guard
            let url = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroup)
        else {
            print("❌ App Group Container URL not found")
            return nil
        }

        let path = url.appendingPathComponent(filename)

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
        guard
            let url = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroup)
        else {
            print("❌ App Group Container URL not found")
            return false
        }

        let path = url.appendingPathComponent(filename)

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

}
