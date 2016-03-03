import UIKit
import WebKit
import Alamofire
import SwiftyJSON

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
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBAction func reloadWebView(sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @IBAction func showEditView(sender: UIBarButtonItem) {
        guard let bookmarkEditTableVC = UIStoryboard.instantiateViewController("Main", identifier: "BookmarkEditTableViewController") as? BookmarkEditTableViewController else {
            return
        }
        
        guard let URL = webView.URL else {
            return
        }
        
        guard let title = webView.title else {
            return
        }
        
        let urlString = URL.absoluteString
        guard let requestString = PinboardURLProvider.getPost(nil, dt: nil, url: urlString, meta: nil) else {
            return
        }
        
        Alamofire
            .request(.GET, requestString)
            .responseJSON { response in
                guard let data = response.result.value else {
                    return
                }
                
                if let post = JSON(data)["posts"].arrayValue.first {
                    bookmarkEditTableVC.bookmark.url = post["href"].stringValue
                    bookmarkEditTableVC.bookmark.title = post["description"].stringValue
                    bookmarkEditTableVC.bookmark.tags = post["tags"].stringValue
                    bookmarkEditTableVC.bookmark.description = post["extended"].stringValue
                    bookmarkEditTableVC.bookmark.isPrivate = post["shared"].stringValue == "no"
                    bookmarkEditTableVC.bookmark.isReadLater = post["toread"].stringValue == "yes"
                } else {
                    bookmarkEditTableVC.bookmark.url = URL.absoluteString
                    bookmarkEditTableVC.bookmark.title = title
                }
                
                self.navigationController?.pushViewController(bookmarkEditTableVC, animated: true)
        }
    }
    
    @IBAction func showActivityView(sender: UIBarButtonItem) {
        guard let text = webView.title else {
            return
        }

        guard let url = webView.URL else {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidesBottomBarWhenPushed = true
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
        let bottomConstraint = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: toolbar, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        view.addConstraint(leftConstraint)
        view.addConstraint(rightConstraint)
        view.addConstraint(topConstraint)
        view.addConstraint(bottomConstraint)
        view.sendSubviewToBack(webView)
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
        
        tabBarController?.tabBar.hidden = true
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

extension WebViewController: WKNavigationDelegate {}

extension WebViewController: WKUIDelegate {
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.loadRequest(navigationAction.request)
        return nil
    }
}