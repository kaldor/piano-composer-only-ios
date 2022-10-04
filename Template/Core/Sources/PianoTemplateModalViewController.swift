import Foundation
import WebKit

import PianoCommon
import PianoComposer

public class PianoTemplateModalViewController: BasePopupViewController {
    
    private static let indicatorSize: CGFloat = 50
    private static let blueColor = UIColor(red: 56 / 255.0, green: 120 / 255.0, blue: 212 / 255.0, alpha: 1)
    
    private let loader: PianoTemplateLoader
    private let params: TemplateEventParams
    
    private(set) public var webView: WKWebView
    
    public var activityIndicator: UIActivityIndicatorView!
    
    public weak var closeDelegate: PianoEventDelegate? = nil
    
    internal init(loader: PianoTemplateLoader, params: TemplateEventParams, webView: WKWebView) {
        self.loader = loader
        self.params = params
        self.webView = webView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.isHidden = !params.showCloseButton
        view.backgroundColor = UIColor.white
        
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        activityIndicator = UIActivityIndicatorView(
            frame: CGRect(
                x: (view.frame.width - PianoTemplateModalViewController.indicatorSize) / 2,
                y: (view.frame.height - PianoTemplateModalViewController.indicatorSize) / 2,
                width: PianoTemplateModalViewController.indicatorSize,
                height: PianoTemplateModalViewController.indicatorSize
            )
        )
        
        activityIndicator.color = PianoTemplateModalViewController.blueColor
        
        view.addSubview(webView)
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        loader.load(webView: webView)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let topMargin = getTopMargin()
        webView.frame = CGRect(x: 0, y: topMargin, width: view.frame.width, height: view.frame.height - topMargin)
    }
    
    public override func close() {
        super.close()
        
        DispatchQueue.main.async {
            self.closeDelegate?.onEvent(event: nil)
        }
    }
    
    public func eval(_ js: String) {
        webView.evaluateJavaScript(js)
    }
}

extension PianoTemplateModalViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if url.description.range(of: loader.url ?? "") != nil {
            decisionHandler(.allow)
            return
        }
        
        if !(navigationAction.targetFrame?.isMainFrame ?? true) {
            decisionHandler(.allow)
            return
        }
        
        if navigationAction.navigationType == .linkActivated {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        decisionHandler(.cancel)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
