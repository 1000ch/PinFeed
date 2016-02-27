import WebKit

class WebViewPropertyObserver: NSObject {
    enum WebViewProperty {
        static let keys = ["title", "URL", "estimatedProgress", "canGoBack", "canGoForward", "hasOnlySecureContent", "loading"]
        case Title(String?), URL(NSURL?), CanGoBack(Bool), CanGoForward(Bool), EstimatedProgress(Float), Loading(Bool), HasOnlySecureContent(Bool)
        
        init?(webView: WKWebView, key: String) {
            switch key {
            case "title":
                self = .Title(webView.title)
                
            case "URL":
                self = .URL(webView.URL)
                
            case "estimatedProgress":
                var progress = Float(webView.estimatedProgress)
                progress = max(0.0, progress)
                progress = min(1.0, progress)
                self = .EstimatedProgress(progress)
                
            case "canGoBack":
                self = .CanGoBack(webView.canGoBack)
                
            case "canGoForward":
                self = .CanGoForward(webView.canGoForward)
                
            case "hasOnlySecureContent":
                self = .HasOnlySecureContent(webView.hasOnlySecureContent)
                
            case "loading":
                self = .Loading(webView.loading)
                
            default:
                return nil
            }
        }
    }
    
    private weak var webView: WKWebView?
    private let handler: WebViewPropertyChangeHandler
    typealias WebViewPropertyChangeHandler = (WebViewProperty) -> ()
    
    init(webView: WKWebView, handler: WebViewPropertyChangeHandler) {
        self.webView = webView
        self.handler = handler
        super.init()
        startObservingProperties()
    }
    
    deinit {
        stopObservingPrpoperties()
    }
    
    private func startObservingProperties() {
        for key in WebViewProperty.keys {
            webView?.addObserver(self, forKeyPath: key, options: NSKeyValueObservingOptions.New, context: nil)
        }
    }
    
    private func stopObservingPrpoperties() {
        for key in WebViewProperty.keys {
            webView?.removeObserver(self, forKeyPath: key, context: nil)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let wv = object as? WKWebView, keyPath = keyPath, property = WebViewProperty(webView: wv, key: keyPath) else {
            return
        }

        handler(property)
    }
}
