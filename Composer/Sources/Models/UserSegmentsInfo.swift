import Foundation

@objcMembers
public class UserSegmentsInfo: NSObject {
 
    public let segments: [String]
    
    public let expiresAt: Date
    
    init(dict: [String: Any]) {
        segments = dict["segments"] as? [String] ?? []
        expiresAt = Date(timeIntervalSince1970: dict["expiresAt"] ?? 0)
    }
}
