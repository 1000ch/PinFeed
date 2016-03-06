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
        let cell = tableView.dequeueReusableCellWithIdentifier("data", forIndexPath: indexPath) as! BookmarkCell
        cell.titleLabel?.text = timeline[indexPath.row].title
        cell.authorLabel?.text = timeline[indexPath.row].author
        cell.dateTimeLabel?.text = timeline[indexPath.row].dateTime
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