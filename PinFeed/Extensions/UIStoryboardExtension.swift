import UIKit

extension UIStoryboard {
    static func instantiateViewController(name: String, identifier: String) -> UIViewController? {
        return UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}
