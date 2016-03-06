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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
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
        let data = bookmark[indexPath.row]
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
        
        webViewController.url = bookmark[indexPath.row].url
        navigationController?.pushViewController(webViewController, animated: true)
    }
}