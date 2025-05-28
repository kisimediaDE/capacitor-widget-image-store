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
}
