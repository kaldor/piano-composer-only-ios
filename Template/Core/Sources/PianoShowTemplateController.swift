import WebKit

import PianoComposer

public class PianoShowTemplateController: PianoTemplateController {
    
    private let params: ShowTemplateEventParams
    
    private var userContentController: WKUserContentController? = nil
    
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
        
        let uc = webView.configuration.userContentController
        uc.removeScriptMessageHandler(forName: JSMessageHandlerType.close.description)
        uc.removeScriptMessageHandler(forName: JSMessageHandlerType.closeAndRefresh.description)
        uc.removeScriptMessageHandler(forName: JSMessageHandlerType.register.description)
        uc.removeScriptMessageHandler(forName: JSMessageHandlerType.login.description)
        uc.removeScriptMessageHandler(forName: JSMessageHandlerType.logout.description)
        uc.removeScriptMessageHandler(forName: JSMessageHandlerType.customEvent.description)
        uc.add(self, name: JSMessageHandlerType.close.description)
        uc.add(self, name: JSMessageHandlerType.closeAndRefresh.description)
        uc.add(self, name: JSMessageHandlerType.register.description)
        uc.add(self, name: JSMessageHandlerType.login.description)
        uc.add(self, name: JSMessageHandlerType.logout.description)
        uc.add(self, name: JSMessageHandlerType.customEvent.description)
        
        userContentController = uc
        
        return PianoTemplateRequestLoader(request: URLRequest(url: url))
    }
    
    public func reloadWithToken(userToken: String) {
        eval("piano.reloadTemplateWithUserToken('\(userToken)')")
    }
    
    override func onClose() {
        if let uc = userContentController {
            uc.removeScriptMessageHandler(forName: JSMessageHandlerType.close.description)
            uc.removeScriptMessageHandler(forName: JSMessageHandlerType.closeAndRefresh.description)
            uc.removeScriptMessageHandler(forName: JSMessageHandlerType.register.description)
            uc.removeScriptMessageHandler(forName: JSMessageHandlerType.login.description)
            uc.removeScriptMessageHandler(forName: JSMessageHandlerType.logout.description)
            uc.removeScriptMessageHandler(forName: JSMessageHandlerType.customEvent.description)
        }
        
        PianoTrackingService.shared.trackCloseEvent(params: params)
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
