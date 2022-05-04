import Foundation

@objcMembers
public class ShowRecommendationsEventParams: TemplateEventParams {

    public let widgetId: String
    public let placeholder: String
    public let siteId: String
    
    init?(dict: [String: Any]?) {
        guard let d = dict else {
            return nil
        }

        let type = (d["type"] as? String ?? "").lowercased()
        if type != "cxense" {
            return nil
        }

        widgetId = d["widgetId"] as? String ?? ""
        placeholder = d["placeholder"] as? String ?? ""
        siteId = d["siteId"] as? String ?? ""
        
        super.init(d: d)
    }
}
