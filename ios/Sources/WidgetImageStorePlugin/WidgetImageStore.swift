import Foundation

@objc public class WidgetImageStore: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
