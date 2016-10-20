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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveBookmark))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapTableView))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
        
        guard let requestString = PinboardURLProvider.getPost(
            tag: nil,
            dt: nil,
            url: urlString,
            meta: nil) else {
            return
        }

        Alamofire
            .request(requestString)
            .responseJSON { response in
                guard let data = response.result.value else {
                    return
                }

                if let post = JSON(data)["posts"].arrayValue.first {
                    self.url.text = post["href"].stringValue
                    self.pageTitle.text = post["description"].stringValue
                    self.pageDescription.text = post["extended"].stringValue
                    self.tags.text = post["tags"].stringValue
                    self.isPrivate.isOn = post["shared"].stringValue == "no"
                    self.isReadLater.isOn = post["toread"].stringValue == "yes"
                }
        }
    }
    
    func didTapTableView(gestureRecognizer: UITapGestureRecognizer) {
        tableView.endEditing(true)
    }
    
    func saveBookmark(sender: UIButton) {
        guard let urlString = url.text else {
            return
        }
        
        guard let titleString = pageTitle.text else {
            return
        }
        
        guard let requestString = PinboardURLProvider.addPost(
            url: urlString,
            description: titleString,
            extended: pageDescription.text,
            tags: tags.text,
            dt: nil, replace: nil,
            isPrivate: isPrivate.isOn,
            isReadLater: isReadLater.isOn) else {
                return
        }
        
        self.navigationController?.popViewController(animated: true)
        
        Alamofire.request(requestString).responseJSON { response in
            print(response.result)
        }
    }
}
