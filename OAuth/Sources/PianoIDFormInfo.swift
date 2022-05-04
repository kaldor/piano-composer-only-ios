import Foundation

@objcMembers
public class PianoIDFormInfo: NSObject {
    
    public let hasAllCustomFieldValuesFilled: Bool
    
    internal init(hasAllCustomFieldValuesFilled: Bool) {
        self.hasAllCustomFieldValuesFilled = hasAllCustomFieldValuesFilled
    }
}
