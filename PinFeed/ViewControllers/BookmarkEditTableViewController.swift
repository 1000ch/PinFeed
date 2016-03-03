import UIKit

class BookmarkEditTableViewController: UITableViewController {
    
    var bookmark = (
        url: "",
        title: "",
        description: "",
        tags: "",
        isPrivate: false,
        isReadLater: false
    )
    
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
        
        url.text = bookmark.url
        pageTitle.text = bookmark.title
        pageDescription.text = bookmark.description
        tags.text = bookmark.tags
        isPrivate.on = bookmark.isPrivate
        isReadLater.on = bookmark.isReadLater
    }
}