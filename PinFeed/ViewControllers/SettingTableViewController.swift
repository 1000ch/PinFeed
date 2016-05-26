import UIKit
import Alamofire
import SwiftyJSON

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var userId: UITextField!

    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var appVersion: UILabel!
        
    enum SettingTableViewCellType: Int {
        case UserId = 0
        case Password = 1
        case LocalCache = 2
        case AppVersion = 3
        case Credits = 4
        case GitHubRepository = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userId.delegate = self
        password.delegate = self

        userId.text = Setting.sharedInstance.userId
        password.text = Setting.sharedInstance.password
        clearButton.addTarget(self, action: #selector(didTapClearButton), forControlEvents: .TouchUpInside)
        appVersion.text = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTableView(_:)))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else {
            return
        }
        
        guard let cellType = SettingTableViewCellType(rawValue: cell.tag) else {
            return
        }
        
        switch cellType {
        case .UserId:
            cell.editing = true
            break
        case .Password:
            cell.editing = true
            break
        case .LocalCache:
            break
        case .AppVersion:
            break
        case .Credits:
            guard let webViewController = UIStoryboard.instantiateViewController("Main", identifier: "WebViewController") as? WebViewController else {
                return
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            webViewController.url = NSBundle.mainBundle().URLForResource("credits", withExtension: "html")
            webViewController.hideToolbar = true
            navigationController?.pushViewController(webViewController, animated: true)
            break
        case .GitHubRepository:
            guard let webViewController = UIStoryboard.instantiateViewController("Main", identifier: "WebViewController") as? WebViewController else {
                return
            }

            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            webViewController.url = NSURL(string: "https://github.com/1000ch/PinFeed")
            navigationController?.pushViewController(webViewController, animated: true)
            break
        }
    }
    
    func didTapTableView(gestureRecognizer: UITapGestureRecognizer) {
        tableView.endEditing(true)
    }
    
    @IBAction func didTapClearButton(sender: UIButton) {
        TimelineManager.sharedInstance.clear {}
        BookmarkManager.sharedInstance.clear {}
    }
}

extension SettingTableViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
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
                .request(.GET, PinboardURLProvider.secretToken ?? "")
                .responseJSON { response in
                    guard let data = response.result.value else {
                        return
                    }
                    
                    Setting.sharedInstance.secretToken = JSON(data)["result"].stringValue
            }
        }
    }
    
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
                .request(.GET, PinboardURLProvider.secretToken ?? "")
                .responseJSON { response in
                    guard let data = response.result.value else {
                        return
                    }
                    
                    Setting.sharedInstance.secretToken = JSON(data)["result"].stringValue
                }
        }
        
        textField.resignFirstResponder()

        return true
    }
}
