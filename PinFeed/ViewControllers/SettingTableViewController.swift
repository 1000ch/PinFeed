import UIKit
import Alamofire
import SwiftyJSON

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var apiToken: UITextField!
    
    var secretTokenURL: String {
        get {
            return String(
                format: "https://api.pinboard.in/v1/user/secret/?format=json&auth_token=%@",
                Setting.sharedInstance.apiToken
            )
        }
    }
    
    enum SettingTableViewCellType: Int {
        case UserId = 0
        case APIToken = 1
        case PinboardSettingPage = 2
        case AppVersion = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userId.delegate = self
        apiToken.delegate = self

        userId.text = Setting.sharedInstance.userId
        apiToken.text = Setting.sharedInstance.apiToken
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else {
            return
        }
        
        guard let cellType = SettingTableViewCellType(rawValue: cell.tag) else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch cellType {
        case .UserId:
            cell.editing = true
            break
        case .APIToken:
            cell.editing = true
            break
        case .PinboardSettingPage:
            guard let webViewController = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as? WebViewController else {
                return
            }

            webViewController.url = NSURL(string: "https://pinboard.in/settings/password")
            webViewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(webViewController, animated: true)
        case .AppVersion:
            break
        }
    }
}

extension SettingTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case userId:
            Setting.sharedInstance.userId = textField.text ?? ""
            break
        case apiToken:
            Setting.sharedInstance.apiToken = textField.text ?? ""
            Alamofire
                .request(.GET, secretTokenURL)
                .responseJSON { response in
                    guard let data = response.result.value else {
                        return
                    }
                    
                    Setting.sharedInstance.secretToken = JSON(data)["result"].stringValue
            }
            break
        default:
            break
        }
        return true
    }
}
