import UIKit
import Alamofire
import SwiftyJSON

class BookmarkViewController: UIViewController {

    @IBOutlet weak var bookmarkTableView: UITableView!

    var bookmark: [Bookmark] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Bookmark"
        bookmarkTableView.delegate = self
        bookmarkTableView.dataSource = self
        bookmarkTableView.registerNib(
            UINib(nibName: "BookmarkCell", bundle: nil),
            forCellReuseIdentifier: "data"
        )
        
        Alamofire
            .request(.GET, PinboardURLProvider.bookmark ?? "")
            .responseJSON { response in
                guard let data = response.result.value else {
                    return
                }
                
                JSON(data).forEach { (_, json) in
                    self.bookmark.append(Bookmark(json: json))
                }

                self.bookmarkTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BookmarkViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Normal, title: "★") { (rowAction, indexPath) -> Void in
            guard let bookmarkEditTableVC = UIStoryboard.instantiateViewController("Main", identifier: "BookmarkEditTableViewController") as? BookmarkEditTableViewController else {
                return
            }
            
            let bookmark = self.bookmark[indexPath.row]
            let urlString = bookmark.url.absoluteString
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
                        bookmarkEditTableVC.bookmark.url = bookmark.url.absoluteString
                        bookmarkEditTableVC.bookmark.title = bookmark.title
                    }
                    
                    self.navigationController?.pushViewController(bookmarkEditTableVC, animated: true)
            }
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