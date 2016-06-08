import UIKit
import Alamofire
import MisterFusion

class BookmarkViewController: UIViewController {

    @IBOutlet weak var bookmarkTableView: UITableView!

    private let refreshControl = UIRefreshControl()
    
    private let indicatorView = UIActivityIndicatorView()

    private let notificationView = UINib.instantiate("URLNotificationView", ownerOrNil: BookmarkViewController.self) as? URLNotificationView

    private var bookmark: [Bookmark] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Bookmark"
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: UIControlEvents.ValueChanged)
        indicatorView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        indicatorView.activityIndicatorViewStyle = .Gray
        view?.addSubview(indicatorView)
        bookmarkTableView.delegate = self
        bookmarkTableView.dataSource = self
        bookmarkTableView.registerNib(UINib(nibName: "BookmarkCell", bundle: nil), forCellReuseIdentifier: "data")
        bookmarkTableView.alwaysBounceVertical = true
        bookmarkTableView.addSubview(refreshControl)
        bookmarkTableView.rowHeight = UITableViewAutomaticDimension
        bookmarkTableView.estimatedRowHeight = 2
        
        if let notificationView = notificationView {
            notificationView.hidden = true
            notificationView.addTarget(self, action: #selector(didTapNotification(_:)), forControlEvents: .TouchUpInside)
            view?.addLayoutSubview(notificationView, andConstraints:
                notificationView.Top |==| self.view.Bottom |-| 103,
                notificationView.Right,
                notificationView.Left,
                notificationView.Bottom |==| self.view.Bottom |-| 49
            )
        }
        
        indicatorView.startAnimating()
        refresh()

        URLNotificationManager.sharedInstance.listen(self, selector: #selector(didCopyURL(_:)), object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refresh() {
        BookmarkManager.sharedInstance.fetch {
            self.bookmark = BookmarkManager.sharedInstance.bookmark.sort { a, b in
                return a.date.compare(b.date).rawValue > 0
            }

            if self.refreshControl.refreshing {
                self.refreshControl.endRefreshing()
            }
            
            if self.indicatorView.isAnimating() {
                self.indicatorView.stopAnimating()
            }
            
            self.bookmarkTableView.reloadData()
        }
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

        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(didTimeoutNotification), userInfo: nil, repeats: false)
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

extension BookmarkViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let urlString = bookmark[indexPath.row].url.absoluteString

            guard let requestString = PinboardURLProvider.deletePost(urlString) else {
                return
            }

            bookmark.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            Alamofire.request(.GET, requestString)
        }
    }
}

extension BookmarkViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmark.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let data = bookmark[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("data", forIndexPath: indexPath) as! BookmarkCell
        cell.authorLabel?.text = data.author
        cell.dateTimeLabel?.text = data.relativeDateTime
        cell.faviconImageView?.image = nil
        if let faviconURL = NSURL(string: "https://www.google.com/s2/favicons?domain=\(data.url.absoluteString)") {
            AsyncDispatcher.global {
                if let faviconData = NSData(contentsOfURL: faviconURL) {
                    AsyncDispatcher.main {
                        cell.faviconImageView?.image = UIImage(data: faviconData)
                    }
                }
            }
        }
        cell.descriptionLabel?.text = data.description
        cell.titleLabel?.text = data.title
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let webViewController = UIStoryboard.instantiateViewController("Main", identifier: "WebViewController") as? WebViewController else {
            return
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        webViewController.url = bookmark[indexPath.row].url
        navigationController?.pushViewController(webViewController, animated: true)
    }
}