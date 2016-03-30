import UIKit
import MisterFusion

class SettingViewController: UIViewController {
    
    private let notificationView = UINib.instantiate("URLNotificationView", ownerOrNil: BookmarkViewController.self) as? URLNotificationView

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Setting"
        
        guard let settingTableViewController = UIStoryboard.instantiateViewController("Main", identifier: "SettingTableViewController") else {
            return
        }
        
        settingTableViewController.didMoveToParentViewController(self)

        addChildViewController(settingTableViewController)
        view.addLayoutSubview(settingTableViewController.view, andConstraints:
            settingTableViewController.view.Top,
            settingTableViewController.view.Right,
            settingTableViewController.view.Left,
            settingTableViewController.view.Bottom
        )
        
        if let notificationView = notificationView {
            notificationView.hidden = true
            notificationView.addTarget(self, action: #selector(SettingViewController.didTapNotification(_:)), forControlEvents: .TouchUpInside)
            view?.addLayoutSubview(notificationView, andConstraints:
                notificationView.Top |==| self.view.Bottom |-| 103,
                notificationView.Right,
                notificationView.Left,
                notificationView.Bottom |==| self.view.Bottom |-| 49
            )
        }
        
        URLNotificationManager.sharedInstance.listen(self, selector: #selector(SettingViewController.didCopyURL(_:)), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didCopyURL(notification: NSNotification?) {
        guard let url = notification?.userInfo?["url"] as? NSURL else {
            return
        }
        
        guard let notificationView = notificationView else {
            return
        }
        
        notificationView.hidden = false
        notificationView.url = url
        notificationView.urlLabel.text = url.absoluteString
        if let faviconURL = NSURL(string: "https://www.google.com/s2/favicons?domain=\(url.absoluteString)") {
            AsyncDispatcher.global {
                if let faviconData = NSData(contentsOfURL: faviconURL) {
                    AsyncDispatcher.main {
                        notificationView.faviconImageView?.image = UIImage(data: faviconData)
                    }
                }
            }
        }

        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(SettingViewController.didTimeoutNotification), userInfo: nil, repeats: false)
    }
    
    func didTapNotification(sender: UIControl) {
        guard let webViewController = UIStoryboard.instantiateViewController("Main", identifier: "WebViewController") as? WebViewController else {
            return
        }
        
        guard let notificationView = sender as? URLNotificationView else {
            return
        }
        
        notificationView.hidden = true
        webViewController.url = notificationView.url
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func didTimeoutNotification() {
        notificationView?.hidden = true
    }
}

