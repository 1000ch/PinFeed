import UIKit

class URLNotificationView : UIControl {
    
    @IBOutlet weak var faviconImageView: UIImageView!

    @IBOutlet weak var urlLabel: UILabel!
    
    var url: NSURL?
}