import UIKit
import Alamofire
import SwiftyJSON

class TimelineViewController: UIViewController {

    @IBOutlet weak var timelineTableView: UITableView!
    
    var timelineURL: String {
        get {
            return String(
                format: "https://feeds.pinboard.in/json/secret:%@/u:%@/network/?count=400",
                Setting.sharedInstance.secretToken,
                Setting.sharedInstance.userId
            )
        }
    }
    var timeline: [Bookmark] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Timeline"
        
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        timelineTableView.registerNib(
            UINib(nibName: "BookmarkCell", bundle: nil),
            forCellReuseIdentifier: "data"
        )
        
        Alamofire
            .request(.GET, timelineURL)
            .responseJSON { response in
                guard let data = response.result.value else {
                    return
                }
                
                JSON(data).forEach { (_, json) in
                    self.timeline.append(Bookmark(json: json))
                }

                self.timelineTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TimelineViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Normal, title: "Bookmark") { (rowAction, indexPath) -> Void in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let bookmarkEditVC = storyboard.instantiateViewControllerWithIdentifier("BookmarkEditViewController") as? BookmarkEditViewController else {
                return
            }
            bookmarkEditVC.bookmark = self.timeline[indexPath.row]
            self.navigationController?.pushViewController(bookmarkEditVC, animated: true)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let webViewController = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as? WebViewController else {
            return
        }

        webViewController.url = timeline[indexPath.row].url
        webViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webViewController, animated: true)
    }
}