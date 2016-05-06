import UIKit
import MisterFusion

class TimelineViewController: UIViewController {

    @IBOutlet weak var timelineTableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    private let notificationView = UINib.instantiate("URLNotificationView", ownerOrNil: TimelineViewController.self) as? URLNotificationView
    
    private let timelineManager = TimelineManager()
    
    private var timeline: [Bookmark] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Recent bookmarks"
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: UIControlEvents.ValueChanged)
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        timelineTableView.registerNib(UINib(nibName: "BookmarkCell", bundle: nil), forCellReuseIdentifier: "data")
        timelineTableView.alwaysBounceVertical = true
        timelineTableView.addSubview(refreshControl)
        
        if let notificationView = notificationView {
            notificationView.hidden = true
            notificationView.addTarget(self, action: #selector(TimelineViewController.didTapNotification(_:)), forControlEvents: .TouchUpInside)
            view?.addLayoutSubview(notificationView, andConstraints:
                notificationView.Top |==| self.view.Bottom |-| 103,
                notificationView.Right,
                notificationView.Left,
                notificationView.Bottom |==| self.view.Bottom |-| 49
            )
        }
        
        timeline = timelineManager.timeline
        refresh()
        
        URLNotificationManager.sharedInstance.listen(self, selector: #selector(TimelineViewController.didCopyURL(_:)), object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refresh() {
        timelineManager.fetch {
            if self.refreshControl.refreshing {
                self.refreshControl.endRefreshing()
            }

            self.timeline = self.timelineManager.timeline
            self.timelineTableView.reloadData()
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
        
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(TimelineViewController.didTimeoutNotification), userInfo: nil, repeats: false)
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

extension TimelineViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Normal, title: "★") { (rowAction, indexPath) -> Void in
            guard let bookmarkEditTableVC = UIStoryboard.instantiateViewController("Main", identifier: "BookmarkEditTableViewController") as? BookmarkEditTableViewController else {
                return
            }
            
            let bookmark = self.timeline[indexPath.row]
            bookmarkEditTableVC.urlString = bookmark.url.absoluteString
            bookmarkEditTableVC.titleString = bookmark.title

            self.navigationController?.pushViewController(bookmarkEditTableVC, animated: true)
        }

        editAction.backgroundColor = UIColor.lightGrayColor()
        return [editAction]
    }
}

extension TimelineViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeline.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let data = timeline[indexPath.row]
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
        webViewController.url = timeline[indexPath.row].url
        navigationController?.pushViewController(webViewController, animated: true)
    }
}