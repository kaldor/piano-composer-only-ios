import Foundation
import WebKit

import PianoComposer

fileprivate let ACTION_PATH = "/id/form"

fileprivate let INIT_SCRIPT = """
    window.PianoIDMobileSDK=window.PianoIDMobileSDK||{};
    window.PianoIDMobileSDK.postMessage=function(data){try{webkit.messageHandlers.postMessage.postMessage(data)}catch(err){console.log(err)}};
"""

fileprivate let JS_HANDLER_POST_MESSAGE = "postMessage"

fileprivate let EVENT_READY = "stateReady"
fileprivate let EVENT_SIGN_IN = "tokenRejected"
fileprivate let EVENT_SKIP = "formSkip"
fileprivate let EVENT_SEND = "formSend"

public class PianoShowFormController: PianoTemplateController {
    
    private let params: ShowFormEventParams
    private let signIn: (_: @escaping (_: String) -> Void) -> Void
    
    private var userContentController: WKUserContentController? = nil
    
    public var accessToken: String? = nil
    
    public weak var delegate: PianoTemplateInlineDelegate? {
        didSet {
            self.inlineDelegate = delegate
        }
    }
    
    public init(params: ShowFormEventParams, signIn: @escaping (_: @escaping (_: String) -> Void) -> Void) {
        self.params = params
        self.signIn = signIn
        
        super.init(params: params)
    }
    
    override func prepare(webView: WKWebView) -> PianoTemplateLoader? {
        guard var urlComponents = URLComponents(string: "\(params.endpointUrl)\(ACTION_PATH)") else {
            return nil
        }
        
        var queryItems = [
            URLQueryItem(name: "client_id", value: params.aid),
            URLQueryItem(name: "form_name", value: params.formName),
            URLQueryItem(name: "hide_if_complete", value: params.hideCompletedFields ? "true" : "false")
        ]
        
        if !params.trackingId.isEmpty {
            queryItems.append(URLQueryItem(name: "tracking_id", value: params.trackingId))
        }
        
        if let t = accessToken {
            queryItems.append(URLQueryItem(name: "Authorization", value: t))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        var uc = webView.configuration.userContentController
        uc.removeAllUserScripts()
        uc.removeScriptMessageHandler(forName: JS_HANDLER_POST_MESSAGE)
        
        uc.add(self, name: JS_HANDLER_POST_MESSAGE)
        uc.addUserScript(
            WKUserScript(source: INIT_SCRIPT, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        )
        
        userContentController = uc
        
        return PianoTemplateRequestLoader(request: request)
    }
    
    override func onClose() {
        if let uc = userContentController {
            uc.removeScriptMessageHandler(forName: JS_HANDLER_POST_MESSAGE)
        }
    }
}

extension PianoShowFormController: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case JS_HANDLER_POST_MESSAGE:
            if let b = message.body as? String, let d = b.data(using: .utf8), let p = try? JSONSerialization.jsonObject(with: d) as? [String:Any], let e = p["event"] as? String {
                switch e {
                case EVENT_READY:
                    if let token = accessToken {
                        ExternalEventService.sharedInstance.logCustomForm(params: params, userToken: accessToken)
                        self.eval("window.PianoIDMobileSDK.messageCallback(JSON.stringify({event: 'setToken', params: '\(token)'}))")
                    }
                case EVENT_SIGN_IN:
                    self.signIn { token in
                        ExternalEventService.sharedInstance.logCustomForm(params: self.params, userToken: token)
                        self.accessToken = token
                        self.eval("window.PianoIDMobileSDK.messageCallback(JSON.stringify({event: 'setToken', params: '\(token)'}))")
                    }
                case EVENT_SKIP:
                    close()
                case EVENT_SEND:
                    ExternalEventService.sharedInstance.logCustomForm(params: params, userToken: accessToken, isImpression: false)
                    close()
                default:
                    return
                }
            }
        default:
            return
        }
    }
}
