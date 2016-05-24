import UIKit
import Alamofire
import SwiftyJSON

class BookmarkEditTableViewController: UITableViewController {
    
    var urlString = ""
    
    var titleString = ""
    
    @IBOutlet weak var url: UITextField!

    @IBOutlet weak var pageTitle: UITextField!
    
    @IBOutlet weak var pageDescription: UITextView!
    
    @IBOutlet weak var tags: UITextField!

    @IBOutlet weak var isPrivate: UISwitch!
    
    @IBOutlet weak var isReadLater: UISwitch!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        url.text = urlString
        pageTitle.text = titleString
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(saveBookmark))

        guard let requestString = PinboardURLProvider.getPost(
            nil,
            dt: nil,
            url: urlString,
            meta: nil) else {
            return
        }

        Alamofire
            .request(.GET, requestString)
            .responseJSON { response in
                guard let data = response.result.value else {
                    return
                }

                if let post = JSON(data)["posts"].arrayValue.first {
                    self.url.text = post["href"].stringValue
                    self.pageTitle.text = post["description"].stringValue
                    self.pageDescription.text = post["extended"].stringValue
                    self.tags.text = post["tags"].stringValue
                    self.isPrivate.on = post["shared"].stringValue == "no"
                    self.isReadLater.on = post["toread"].stringValue == "yes"
                }
        }
    }
    
    func saveBookmark(sender: UIButton) {
        guard let urlString = url.text else {
            return
        }
        
        guard let titleString = pageTitle.text else {
            return
        }
        
        guard let requestString = PinboardURLProvider.addPost(
            urlString,
            description: titleString,
            extended: pageDescription.text,
            tags: tags.text,
            dt: nil, replace: nil,
            isPrivate: isPrivate.on,
            isReadLater: isReadLater.on) else {
                return
        }
        
        self.navigationController?.popViewControllerAnimated(true)
        
        Alamofire.request(.GET, requestString)
    }
}