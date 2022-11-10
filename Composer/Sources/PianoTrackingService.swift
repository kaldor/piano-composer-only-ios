import Foundation

public class PianoTrackingService {
    
    public static let shared = PianoTrackingService()
    
    fileprivate let userAgent = ComposerHelper.generateUserAgent()
    fileprivate let externalLogAction = "/api/v3/conversion/logAutoMicroConversion"
    fileprivate let impressionLogAction = "/api/v3/customform/log/impression"
    fileprivate let submissionLogAction = "/api/v3/customform/log/submission"
    fileprivate let session: URLSession
    
    fileprivate init() {
        session = PianoTrackingService.createSession()
    }
    
    fileprivate static func createSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = nil
        config.httpCookieAcceptPolicy = .never
        return URLSession(configuration: config)
    }
    
    private func trackExternalEvent(endpointUrl: String, trackingId: String, eventType: String, eventGroupId: String, customParams: String) {
        guard let requestUrl = URL(string: "\(endpointUrl)\(externalLogAction)") else {
           return
        }
        
        let requestBody = RequestParamBuilder()
            .add(name: "tracking_id", value: trackingId)
            .add(name: "event_type", value: eventType)
            .add(name: "event_group_id", value: eventGroupId)
            .add(name: "custom_params", value: customParams)
            .build().data(using: String.Encoding.utf8)
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTask(with: request)
        dataTask.resume()
    }
    
    public func trackCustomForm(params: ShowFormEventParams, userToken: String?, isImpression: Bool = true) {
        guard var url = URLComponents(string: "\(params.endpointUrl)\(isImpression ? impressionLogAction : submissionLogAction)") else {
            return
        }
        url.queryItems = [
            URLQueryItem(name: "aid", value: params.aid),
            URLQueryItem(name: "tracking_id", value: params.trackingId),
            URLQueryItem(name: "pageview_id", value: params.pageViewId),
            URLQueryItem(name: "custom_form_name", value: params.formName),
            URLQueryItem(name: "custom_form_source", value: "show_form"),
            URLQueryItem(name: "user_token", value: userToken ?? "")
        ]
        
        guard let requestUrl = url.url else {
            return
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        let dataTask = session.dataTask(with: request)
        dataTask.resume()
    }
    
    public func trackCloseEvent(endpointUrl: String, trackingId: String) {
        trackExternalEvent(
            endpointUrl: endpointUrl,
            trackingId: trackingId,
            eventType: "EXTERNAL_EVENT",
            eventGroupId: "close",
            customParams: "{}"
        )
    }
    
    
    public func trackCloseEvent(params: TemplateEventParams) {
        trackCloseEvent(
            endpointUrl: params.endpointUrl,
            trackingId: params.trackingId
        )
    }
    
    
    public func trackRecommendationsDisplay(endpointUrl: String, trackingId: String) {
        trackExternalEvent(
            endpointUrl: endpointUrl,
            trackingId: trackingId,
            eventType: "EXTERNAL_LINK",
            eventGroupId: "init",
            customParams: "{\"source\":\"CX\"}"
        )
    }
    
    public func trackRecommendationsDisplay(params: TemplateEventParams) {
        trackRecommendationsDisplay(
            endpointUrl: params.endpointUrl,
            trackingId: params.trackingId
        )
    }
    
    public func trackRecommendationsClick(endpointUrl: String, trackingId: String) {
        trackExternalEvent(
            endpointUrl: endpointUrl,
            trackingId: trackingId,
            eventType: "EXTERNAL_LINK",
            eventGroupId: "click",
            customParams: "{\"source\":\"CX\"}"
        )
    }
    
    public func trackRecommendationsClick(params: TemplateEventParams) {
        trackRecommendationsDisplay(
            endpointUrl: params.endpointUrl,
            trackingId: params.trackingId
        )
    }
}
