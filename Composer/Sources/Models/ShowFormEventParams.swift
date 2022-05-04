import Foundation

public class ShowFormEventParams: TemplateEventParams {
    
    public let formName: String
    public let hideCompletedFields: Bool
    
    internal(set) public var trackingId: String? = nil
    
    public var aid: String = ""
    public var endpointUrl: String = ""
    
    init?(dict: [String: Any]?) {
        guard let d = dict else {
            return nil
        }
        
        guard let fn = d["formName"] as? String else {
            return nil
        }
        
        formName = fn
        hideCompletedFields = d["hideCompletedFields"] as? Bool ?? true
        
        super.init(d: d)
    }
}
