import Foundation

import PianoComposer

internal class ExternalEventService {
    
    internal static let sharedInstance = ExternalEventService()
    
    fileprivate let userAgent = ComposerHelper.generateUserAgent()
    fileprivate let externalLogAction = "/api/v3/conversion/logAutoMicroConversion"
    fileprivate let impressionLogAction = "/api/v3/customform/log/impression"
    fileprivate let submissionLogAction = "/api/v3/customform/log/submission"
    fileprivate let session: URLSession
    
    fileprivate init() {
        session = ExternalEventService.createSession()
    }
    
    fileprivate static func createSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = nil
        config.httpCookieAcceptPolicy = .never
        return URLSession(configuration: config)
    }
    
    func logExternalEvent(endpointUrl: String, trackingId: String, eventType: String, eventGroupId: String, customParams: String) {
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
    
    func logCustomForm(params: ShowFormEventParams, userToken: String?, isImpression: Bool = true) {
        guard let requestUrl = URL(string: "\(params.endpointUrl)\(isImpression ? impressionLogAction : submissionLogAction)") else {
           return
        }
        
        let requestBody = RequestParamBuilder()
            .add(name: "aid", value: params.aid)
            .add(name: "tracking_id", value: params.trackingId)
            .add(name: "page_view_id", value: params.pageViewId)
            .add(name: "custom_form_name", value: params.formName)
            .add(name: "custom_form_source", value: "show_form")
            .add(name: "user_token", value: userToken ?? "")
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
}
