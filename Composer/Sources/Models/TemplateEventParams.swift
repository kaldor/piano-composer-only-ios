import Foundation

@objcMembers
public class TemplateEventParams: NSObject {
    
    public let templateId: String
    public let templateVariantId: String
    public let displayMode: DisplayMode
    public let containerSelector: String
    public let showCloseButton: Bool
    
    internal(set) public var trackingId: String = ""
    
    internal init(d: [String: Any]) {
        templateId = d["templateId"] as? String ?? ""
        templateVariantId = d["templateVariantId"] as? String ?? ""
        displayMode = DisplayMode(name: (d["displayMode"] as? String ?? ""))
        containerSelector = d["containerSelector"] as? String ?? ""
        showCloseButton = d["showCloseButton"] as? Bool ?? false
    }
}
