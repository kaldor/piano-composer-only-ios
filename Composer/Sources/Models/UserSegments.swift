import Foundation

@objcMembers
public class UserSegments: NSObject {
 
    public let standart: UserSegmentsInfo?
    
    public let composer1x: UserSegmentsInfo?
    
    init(dict: [String: Any]) {
        if let d = dict["STANDARD"] as? [String:Any] {
            standart = UserSegmentsInfo(dict: d)
        } else {
            standart = nil
        }
        
        if let d = dict["COMPOSER1X"] as? [String:Any] {
            composer1x = UserSegmentsInfo(dict: d)
        } else {
            composer1x = nil
        }
    }
}
