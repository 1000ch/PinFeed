import UIKit
import Alamofire
import SwiftyJSON

class TimelineViewController: UIViewController {

    @IBOutlet weak var timelineTableView: UITableView!
    
    private var refreshControl = UIRefreshControl()
    
    private var timeline: [Bookmark] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Recent bookmarks"
        refreshControl.addTarget(self, action: Selector("refresh"), forControlEvents: UIControlEvents.ValueChanged)
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        timelineTableView.registerNib(UINib(nibName: "BookmarkCell", bundle: nil), forCellReuseIdentifier: "data")
        timelineTableView.alwaysBounceVertical = true
        timelineTableView.addSubview(refreshControl)
        
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func refresh() {
        Alamofire
            .request(.GET, PinboardURLProvider.network ?? "")
            .responseJSON { response in
                guard let data = response.result.value else {
                    if self.refreshControl.refreshing {
                        self.refreshControl.endRefreshing()
                    }
                    return
                }
                
                self.timeline.removeAll()
                
                JSON(data).forEach { (_, json) in
                    self.timeline.append(Bookmark(json: json))
                }
                
                self.timelineTableView.reloadData()
                
                if self.refreshControl.refreshing {
                    self.refreshControl.endRefreshing()
                }
        }
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
        cell.dateTimeLabel?.text = data.dateTime
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

        webViewController.url = timeline[indexPath.row].url
        navigationController?.pushViewController(webViewController, animated: true)
    }
}