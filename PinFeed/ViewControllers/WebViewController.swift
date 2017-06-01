import UIKit
import WebKit
import Alamofire
import SwiftyJSON
import MisterFusion

class WebViewController: UIViewController {
    
    var webView: WKWebView!

    var url: URL? {
        didSet {
            guard let url = url , !isViewLoaded else {
                return
            }

            webView?.load(URLRequest(url: url))
        }
    }
    
    var hidesToolbar: Bool = false

    private var webViewPropertyObserver: WebViewPropertyObserver!
    
    @IBOutlet weak var progressViewOffset: NSLayoutConstraint!

    @IBOutlet weak var progressView: UIProgressView! {
        didSet {
            progressView.isHidden = true
        }
    }

    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    @IBAction func backWebView(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func forwardWebView(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func reloadWebView(sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @IBAction func showEditView(sender: UIBarButtonItem) {
        guard let bookmarkEditTableVC = UIStoryboard.instantiateViewController(name: "Main", identifier: "BookmarkEditTableViewController") as? BookmarkEditTableViewController else {
            return
        }
        
        guard let URL = webView.url else {
            return
        }
        
        guard let title = webView.title else {
            return
        }
        
        bookmarkEditTableVC.urlString = URL.absoluteString
        bookmarkEditTableVC.titleString = title

        navigationController?.pushViewController(bookmarkEditTableVC, animated: true)
    }
    
    @IBAction func showActivityView(sender: UIBarButtonItem) {
        guard let text = webView.title else {
            return
        }

        guard let url = webView.url else {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        config.processPool = WKProcessPool()
        webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        toolbar.isHidden = hidesToolbar
        progressView.isHidden = hidesToolbar

        if hidesToolbar {
            view.addLayoutSubview(webView, andConstraints:
                webView.top,
                webView.right,
                webView.left,
                webView.bottom
            )
        } else {
            view.addLayoutSubview(webView, andConstraints:
                webView.top,
                webView.right,
                webView.left,
                webView.bottom |==| toolbar.top
            )
        }

        view.sendSubview(toBack: webView)
        view.layoutIfNeeded()
        
        if url != nil {
            webView.load(URLRequest(url: url!))
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let navigationController = navigationController {
            if navigationController.isNavigationBarHidden {
                progressViewOffset.constant = UIApplication.shared.statusBarFrame.size.height
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = true
        webViewPropertyObserver = WebViewPropertyObserver(webView: webView, handler: handleWebViewPropertyChange)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        webViewPropertyObserver = nil
    }
    
    private func handleWebViewPropertyChange(property: WebViewPropertyObserver.WebViewProperty) {
        switch property {
        case .Title(let title):
            navigationItem.title = title
        case .EstimatedProgress(let progress):
            updateProgressView(progress: progress)
        case .CanGoBack(let canGoback):
            backButton.isEnabled = canGoback
        case .CanGoForward(let canGoForward):
            forwardButton.isEnabled = canGoForward
        default:
            break
        }
    }
    
    private func updateProgressView(progress: Float) {
        if hidesToolbar {
            return
        }

        if 0.0 < progress && progress < 1.0 {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.progressView?.isHidden = false
                self?.progressView?.progress = progress
                self?.view.layoutIfNeeded()
            }
        } else if progress == 1.0 {
            progressView?.progress = progress
            DispatchQueue.main.async { [weak self] in
                self?.progressView?.isHidden = true
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
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
}
