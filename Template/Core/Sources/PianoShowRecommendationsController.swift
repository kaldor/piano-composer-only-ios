import WebKit

import PianoComposer

public class PianoShowRecommendationsController: PianoTemplateController {
    
    private static let templateUrl = "https://s3.amazonaws.com/sdk.cxense.com/recommendations.html"
    
    private let params: ShowRecommendationsEventParams
    private let renderTemplateUrl: String?
    private let userId: String?
    
    public weak var delegate: PianoTemplateInlineDelegate? {
        didSet {
            self.inlineDelegate = delegate
        }
    }
    
    public init(params: ShowRecommendationsEventParams, renderTemplateUrl: String = "auto", userId: String? = nil) {
        self.params = params
        self.renderTemplateUrl = renderTemplateUrl
        self.userId = userId
        
        super.init(params: params)
    }
    
    override func prepare(webView: WKWebView) -> PianoTemplateLoader? {
        guard var urlComponents = URLComponents(string: PianoShowRecommendationsController.templateUrl) else {
            return nil
        }
        
        var queryItems = [
            URLQueryItem(name: "widget_id", value: params.widgetId),
            URLQueryItem(name: "render_template_url", value: renderTemplateUrl)
        ]
        
        if let uid = userId {
            queryItems.append(URLQueryItem(name: "user_id", value: uid))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return nil
        }

        return PianoTemplateRequestLoader(request: URLRequest(url: url))
    }
}
