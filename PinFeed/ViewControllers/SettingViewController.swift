import UIKit
import MisterFusion

class SettingViewController: UIViewController {
    
    private let notificationView = UINib.instantiate(nibName: "URLNotificationView", ownerOrNil: BookmarkViewController.self) as? URLNotificationView

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Setting"
        
        guard let settingTableViewController = UIStoryboard.instantiateViewController(name: "Main", identifier: "SettingTableViewController") else {
            return
        }
        
        settingTableViewController.didMove(toParentViewController: self)

        addChildViewController(settingTableViewController)
        view.addLayoutSubview(settingTableViewController.view, andConstraints:
            settingTableViewController.view.top,
            settingTableViewController.view.right,
            settingTableViewController.view.left,
            settingTableViewController.view.bottom
        )
        
        if let notificationView = notificationView {
            notificationView.isHidden = true
            notificationView.addTarget(self, action: #selector(didTapNotification), for: .touchUpInside)
            view?.addLayoutSubview(notificationView, andConstraints:
                notificationView.top |==| view.bottom |-| 103,
                notificationView.right,
                notificationView.left,
                notificationView.bottom |==| view.bottom |-| 49
            )
        }
        
        URLNotificationManager.shared.listen(observer: self, selector: #selector(didCopyURL), object: nil)
    }
    
    func didCopyURL(notification: Notification?) {
        guard let url = notification?.userInfo?["url"] as? URL else {
            return
        }
        
        guard let notificationView = notificationView else {
            return
        }
        
        notificationView.isHidden = false
        notificationView.url = url
        notificationView.urlLabel.text = url.absoluteString
        if let faviconURL = URL(string: "https://www.google.com/s2/favicons?domain=\(url.absoluteString)") {
            DispatchQueue.global().async {
                if let faviconData = try? Data(contentsOf: faviconURL) {
                    DispatchQueue.main.async {
                        notificationView.faviconImageView?.image = UIImage(data: faviconData)
                    }
                }
            }
        }

        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(didTimeoutNotification), userInfo: nil, repeats: false)
    }
    
    func didTapNotification(sender: UIControl) {
        guard let webViewController = UIStoryboard.instantiateViewController(name: "Main", identifier: "WebViewController") as? WebViewController else {
            return
        }
        
        guard let notificationView = sender as? URLNotificationView else {
            return
        }
        
        notificationView.isHidden = true
        webViewController.url = notificationView.url
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func didTimeoutNotification() {
        notificationView?.isHidden = true
    }
}

