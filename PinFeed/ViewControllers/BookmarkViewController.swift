import UIKit
import Alamofire
import SwiftyJSON

class BookmarkViewController: UIViewController {

    @IBOutlet weak var bookmarkTableView: UITableView!

    var bookmarkURL: String {
        get {
            return String(
                format: "https://feeds.pinboard.in/json/secret:%@/u:%@/?count=400",
                Setting.sharedInstance.secretToken,
                Setting.sharedInstance.userId
            )
        }
    }
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
            .request(.GET, bookmarkURL)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let webViewController = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as? WebViewController else {
            return
        }
        
        webViewController.url = bookmark[indexPath.row].url
        webViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webViewController, animated: true)
    }
}