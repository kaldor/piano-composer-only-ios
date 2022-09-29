import WebKit

import PianoComposer

internal protocol PianoTemplateLoader {
    var url: String? { get }
    
    func load(webView: WKWebView)
}

internal class PianoTemplateRequestLoader: NSObject, PianoTemplateLoader {
    
    private let request: URLRequest
    
    public var url: String? { request.url?.absoluteString }
    
    init(request: URLRequest) {
        self.request = request
    }
    
    public func load(webView: WKWebView) {
        webView.load(request)
    }
}

public class PianoTemplateController: NSObject {
    
    private let templateParams: TemplateEventParams
    
    private var modalViewController: PianoTemplateModalViewController? = nil
    
    internal weak var inlineDelegate: PianoTemplateInlineDelegate? = nil
    
    internal var delayBy: DelayBy? = nil
    
    internal init(params: TemplateEventParams) {
        self.templateParams = params
    }
    
    internal func prepare(webView: WKWebView) -> PianoTemplateLoader? { return nil }
    internal func onClose() {}
    
    @objc public func show() {
        DispatchQueue.main.async {
            self.showTemplate()
        }
    }
    
    @objc public func close() {
        if let m = modalViewController {
            m.close()
        } else {
            onClose()
        }
    }
    
    @objc func eval(_ js: String) {
        switch templateParams.displayMode {
        case .inline:
            guard let view = inlineDelegate?.findViewBySelector(selector: templateParams.containerSelector) else {
                return
            }
            
            if view is WKWebView {
                let wkWebView = (view as! WKWebView)
                wkWebView.evaluateJavaScript(js)
            }
        case .modal:
            modalViewController?.eval(js)
        }
    }
    
    private func showTemplate() {
        var webView: WKWebView
        if templateParams.displayMode == .inline {
            guard let wv = inlineDelegate?.findViewBySelector(selector: templateParams.containerSelector) as? WKWebView else {
                return
            }
            
            webView = wv
        } else {
            webView = WKWebView(frame: .zero)
        }
        
        guard let loader = prepare(webView: webView) else {
            return
        }
        
        if templateParams.displayMode == .modal {
            modalViewController = PianoTemplateModalViewController(loader: loader, params: templateParams, webView: webView)
            modalViewController!.onClose = onClose
            
            asyncWithDelay {
                self.modalViewController!.show()
            }
            
        } else {
            asyncWithDelay {
                loader.load(webView: webView)
            }
        }
    }
    
    private func asyncWithDelay(completion: @escaping () -> Void) {
        if let d = delayBy, d.type == .time, d.value > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(d.value)) {
                completion()
            }
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}


