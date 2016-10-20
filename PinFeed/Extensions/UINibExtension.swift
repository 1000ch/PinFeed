import UIKit

extension UINib {
    static func instantiate(nibName: String, ownerOrNil: AnyObject?) -> UIView? {
        let views = UINib(nibName: nibName, bundle: nil).instantiate(withOwner: ownerOrNil, options: nil)
        
        guard views.count != 0 else {
            return nil
        }
        
        guard let view = views[0] as? UIView else {
            return nil
        }
        
        return view
    }
}
