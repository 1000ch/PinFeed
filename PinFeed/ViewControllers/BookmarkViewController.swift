import UIKit
import Alamofire
import SwiftyJSON

class BookmarkViewController: UIViewController {

    @IBOutlet weak var bookmarkTableView: UITableView!

    private var refreshControl = UIRefreshControl()

    private var bookmark: [Bookmark] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Your bookmarks"
        refreshControl.addTarget(self, action: Selector("refresh"), forControlEvents: UIControlEvents.ValueChanged)
        bookmarkTableView.delegate = self
        bookmarkTableView.dataSource = self
        bookmarkTableView.registerNib(UINib(nibName: "BookmarkCell", bundle: nil), forCellReuseIdentifier: "data")
        bookmarkTableView.alwaysBounceVertical = true
        bookmarkTableView.addSubview(refreshControl)
        
        refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func refresh() {
        Alamofire
            .request(.GET, PinboardURLProvider.bookmark ?? "")
            .responseJSON { response in
                guard let data = response.result.value else {
                    if self.refreshControl.refreshing {
                        self.refreshControl.endRefreshing()
                    }
                    return
                }
                
                self.bookmark.removeAll()
                
                JSON(data).forEach { (_, json) in
                    self.bookmark.append(Bookmark(json: json))
                }
                
                self.bookmarkTableView.reloadData()
                
                if self.refreshControl.refreshing {
                    self.refreshControl.endRefreshing()
                }
        }
    }
}

extension BookmarkViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Normal, title: "★") { (rowAction, indexPath) -> Void in
            guard let bookmarkEditTableVC = UIStoryboard.instantiateViewController("Main", identifier: "BookmarkEditTableViewController") as? BookmarkEditTableViewController else {
                return
            }
            
            let bookmark = self.bookmark[indexPath.row]
            bookmarkEditTableVC.urlString = bookmark.url.absoluteString
            bookmarkEditTableVC.titleString = bookmark.title

            self.navigationController?.pushViewController(bookmarkEditTableVC, animated: true)
        }

        editAction.backgroundColor = UIColor.lightGrayColor()
        return [editAction]
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
        let cell = tableView.dequeueReusableCellWithIdentifier("data", forIndexPath: indexPath) as! BookmarkCell
        cell.titleLabel?.text = bookmark[indexPath.row].title
        cell.authorLabel?.text = bookmark[indexPath.row].author
        cell.dateTimeLabel?.text = bookmark[indexPath.row].dateTime
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let webViewController = UIStoryboard.instantiateViewController("Main", identifier: "WebViewController") as? WebViewController else {
            return
        }
        
        webViewController.url = bookmark[indexPath.row].url
        navigationController?.pushViewController(webViewController, animated: true)
    }
}