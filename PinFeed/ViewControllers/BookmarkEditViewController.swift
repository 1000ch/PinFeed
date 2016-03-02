import UIKit

class BookmarkEditViewController: UIViewController {
    
    var bookmark: Bookmark? {
        didSet {
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}