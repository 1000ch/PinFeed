import UIKit
import Alamofire
import SwiftyJSON

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var apiTokenURL: String {
        get {
            return String(
                format: "https://%@:%@@api.pinboard.in/v1/user/api_token/?format=json",
                Setting.sharedInstance.userId,
                Setting.sharedInstance.password
            )
        }
    }
    
    var secretTokenURL: String {
        get {
            return String(
                format: "https://%@:%@@api.pinboard.in/v1/user/secret/?format=json",
                Setting.sharedInstance.userId,
                Setting.sharedInstance.password
            )
        }
    }
    
    enum SettingTableViewCellType: Int {
        case UserId = 0
        case Password = 1
        case AppVersion = 2
        case GitHubRepository = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userId.delegate = self
        password.delegate = self

        userId.text = Setting.sharedInstance.userId
        password.text = Setting.sharedInstance.password
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
        case .Password:
            cell.editing = true
            break
        case .GitHubRepository:
            guard let webViewController = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as? WebViewController else {
                return
            }

            webViewController.url = NSURL(string: "https://github.com/1000ch/PinFeed")
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
        case password:
            Setting.sharedInstance.password = textField.text ?? ""
            break
        default:
            break
        }
        
        let userIdString = Setting.sharedInstance.userId
        let passwordString = Setting.sharedInstance.password
        
        if !userIdString.isEmpty && !passwordString.isEmpty {
            Alamofire
                .request(.GET, apiTokenURL)
                .responseJSON { response in
                    guard let data = response.result.value else {
                        return
                    }

                    Setting.sharedInstance.apiToken = JSON(data)["result"].stringValue
                }
                
            Alamofire
                .request(.GET, secretTokenURL)
                .responseJSON { response in
                    guard let data = response.result.value else {
                        return
                    }
                    
                    Setting.sharedInstance.secretToken = JSON(data)["result"].stringValue
                }
        }

        return true
    }
}
