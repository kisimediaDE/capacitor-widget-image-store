import Foundation

enum WidgetImageStorePathGuard {
    enum ResolutionError {
        case invalidFilename
        case appGroupUnavailable
        case invalidPath
    }

    static func isSafeFilename(_ filename: String) -> Bool {
        if filename.isEmpty { return false }
        if filename == "." || filename == ".." { return false }
        if filename.contains("/") || filename.contains("\\") { return false }
        if filename.utf8.contains(0) { return false }
        return filename == (filename as NSString).lastPathComponent
    }

    static func resolveFileURL(filename: String, appGroup: String) -> URL? {
        switch resolveFileURLWithReason(filename: filename, appGroup: appGroup) {
        case .success(let fileURL):
            return fileURL
        case .failure:
            return nil
        }
    }

    static func resolveFileURLWithReason(filename: String, appGroup: String) -> Result<URL, ResolutionError> {
        guard isSafeFilename(filename) else {
            return .failure(.invalidFilename)
        }

        guard
            let container = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroup)
        else {
            return .failure(.appGroupUnavailable)
        }

        let containerURL = container.resolvingSymlinksInPath().standardizedFileURL
        let fileURL = containerURL.appendingPathComponent(filename).standardizedFileURL
        let resolvedURL = fileURL.resolvingSymlinksInPath().standardizedFileURL

        let basePath = containerURL.path.hasSuffix("/") ? containerURL.path : containerURL.path + "/"
        guard resolvedURL.path.hasPrefix(basePath) else {
            return .failure(.invalidPath)
        }

        if FileManager.default.fileExists(atPath: fileURL.path),
            let values = try? fileURL.resourceValues(forKeys: [.isSymbolicLinkKey]),
            values.isSymbolicLink == true
        {
            return .failure(.invalidPath)
        }

        return .success(fileURL)
    }
}
