import UIKit
import WebKit
import SafariServices

class WebViewController: UIViewController {
    
    var webView: WKWebView!

    var url: NSURL? {
        didSet {
            guard let url = url where !isViewLoaded() else {
                return
            }

            webView?.loadRequest(NSURLRequest(URL: url))
        }
    }

    private var webViewPropertyObserver: WebViewPropertyObserver!
    
    @IBOutlet weak var progressViewOffset: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView! {
        didSet {
            progressView.hidden = true
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        config.processPool = WKProcessPool()
        webView = WKWebView(frame: CGRectZero, configuration: config)
        view.addSubview(webView)
        
        webView.UIDelegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        
        let leftConstraint = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        view.addConstraint(leftConstraint)
        view.addConstraint(rightConstraint)
        view.addConstraint(topConstraint)
        view.addConstraint(bottomConstraint)
        view.bringSubviewToFront(progressView)
        view.layoutIfNeeded()
        
        if url != nil {
            webView.loadRequest(NSURLRequest(URL: url!))
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let navigationController = navigationController {
            if navigationController.navigationBarHidden {
                progressViewOffset.constant = UIApplication.sharedApplication().statusBarFrame.size.height
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.translucent = true
        
        webViewPropertyObserver = WebViewPropertyObserver(webView: webView, handler: handleWebViewPropertyChange)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        webViewPropertyObserver = nil
    }
    
    private func handleWebViewPropertyChange(property: WebViewPropertyObserver.WebViewProperty) {
        switch property {
        case .Title(let title):
            navigationItem.title = title
        case .EstimatedProgress(let progress):
            updateProgressView(progress)
        default:
            break
        }
    }
    
    private func updateProgressView(progress: Float) {
        if 0.0 < progress && progress < 1.0 {
            
            UIView.animateWithDuration(0.2) { [weak self] in
                self?.progressView?.hidden = false
                self?.progressView?.progress = progress
                self?.view.layoutIfNeeded()
            }
        } else if progress == 1.0 {
            progressView?.progress = progress
            
            // Wait 0.2 seconds and hide progress view to let a user know that progress becomes 100%
            let delay = 0.2 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) { [weak self] in
                self?.progressView?.hidden = true
                self?.progressView?.progress = 0.0
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension WebViewController: WKNavigationDelegate {
}


extension WebViewController: WKUIDelegate {
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.loadRequest(navigationAction.request)
        return nil
    }
}