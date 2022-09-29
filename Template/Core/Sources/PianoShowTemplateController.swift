import WebKit

import PianoComposer

public class PianoShowTemplateController: PianoTemplateController {
    
    private let params: ShowTemplateEventParams
    
    public weak var delegate: PianoShowTemplateDelegate? {
        didSet {
            self.inlineDelegate = delegate
        }
    }
    
    public init(_ params: ShowTemplateEventParams) {
        self.params = params
        
        super.init(params: params)
        
        self.delayBy = params.delayBy
    }
    
    override func prepare(webView: WKWebView) -> PianoTemplateLoader? {
        guard let url = URL(string: params.templateUrl) else {
            return nil
        }
        
        let userContentController = webView.configuration.userContentController
        userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.close.description)
        userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.closeAndRefresh.description)
        userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.register.description)
        userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.login.description)
        userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.logout.description)
        userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.customEvent.description)
        userContentController.add(self, name: JSMessageHandlerType.close.description)
        userContentController.add(self, name: JSMessageHandlerType.closeAndRefresh.description)
        userContentController.add(self, name: JSMessageHandlerType.register.description)
        userContentController.add(self, name: JSMessageHandlerType.login.description)
        userContentController.add(self, name: JSMessageHandlerType.logout.description)
        userContentController.add(self, name: JSMessageHandlerType.customEvent.description)
        
        return PianoTemplateRequestLoader(request: URLRequest(url: url))
    }
    
    public func reloadWithToken(userToken: String) {
        eval("piano.reloadTemplateWithUserToken('\(userToken)')")
    }

    
    override func onClose() {
        ExternalEventService.sharedInstance.logExternalEvent(endpointUrl: params.endpointUrl, trackingId: params.trackingId, eventType: "EXTERNAL_EVENT", eventGroupId: "close", customParams: "{}")
        self.delegate?.onClose?(eventData: "")
    }
}

extension PianoShowTemplateController: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let handlerType = JSMessageHandlerType.fromString(value: message.name)
        DispatchQueue.main.async {
            switch handlerType {
            case .close:
                self.close()
            case .closeAndRefresh:
                self.delegate?.onCloseAndRefresh?(eventData: message.body)
            case .register:
                self.delegate?.onRegister?(eventData: message.body)
            case .login:
                self.delegate?.onLogin?(eventData: message.body)
            case .logout:
                self.delegate?.onLogout?(eventData: message.body)
            case .customEvent:
                self.delegate?.onCustomEvent?(eventData: message.body)
            case .unknown:
                break
            }
        }
    }
}
