import Foundation

@objcMembers
public class ShowTemplateEventParams: TemplateEventParams {

    public let delayBy: DelayBy?
    
    internal(set) public var templateUrl: String = ""
    internal(set) public var trackingId: String = ""
    internal(set) public var endpointUrl: String = ""

    
    init?(dict: [String: Any]?) {
        guard let d = dict else {
            return nil
        }
        
        if let delayByDict = d["delayBy"] as? [String: Any] {
            delayBy = DelayBy(dict: delayByDict)
        } else {
            delayBy = nil
        }
        
        super.init(d: d)
    }
}
