import UIKit
import Alamofire
import SwiftyJSON

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var userId: UITextField!

    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var appVersion: UILabel!
        
    enum SettingTableViewCellType: Int {
        case UserId = 0
        case Password = 1
        case Version = 2
        case AppStore = 3
        case Credits = 4
        case GitHubRepository = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userId.delegate = self
        password.delegate = self

        userId.text = Setting.sharedInstance.userId
        password.text = Setting.sharedInstance.password
        appVersion.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTableView))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        guard let cellType = SettingTableViewCellType(rawValue: cell.tag) else {
            return
        }
        
        switch cellType {
        case .UserId:
            cell.isEditing = true
            break
        case .Password:
            cell.isEditing = true
            break
        case .Version:
            break
        case .AppStore:
            guard let url = URL(string: "itms-apps://itunes.apple.com/app/id1090705533") else {
                return
            }

            UIApplication.shared.openURL(url)
            break
        case .Credits:
            guard let webViewController = UIStoryboard.instantiateViewController(name: "Main", identifier: "WebViewController") as? WebViewController else {
                return
            }
            
            tableView.deselectRow(at: indexPath, animated: false)
            webViewController.url = Bundle.main.url(forResource: "credits", withExtension: "html")
            webViewController.hidesToolbar = true
            webViewController.hidesBarsOnSwipe = false
            navigationController?.pushViewController(webViewController, animated: true)
            break
        case .GitHubRepository:
            guard let webViewController = UIStoryboard.instantiateViewController(name: "Main", identifier: "WebViewController") as? WebViewController else {
                return
            }

            tableView.deselectRow(at: indexPath, animated: false)
            webViewController.url = URL(string: "https://github.com/1000ch/PinFeed")
            webViewController.hidesBarsOnSwipe = false
            navigationController?.pushViewController(webViewController, animated: true)
            break
        }
    }
    
    func didTapTableView(gestureRecognizer: UITapGestureRecognizer) {
        tableView.endEditing(true)
    }
}

extension SettingTableViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
                .request(PinboardURLProvider.secretToken ?? "")
                .responseJSON(queue: .global()) { response in
                    guard let data = response.result.value else {
                        return
                    }
                    
                    Setting.sharedInstance.secretToken = JSON(data)["result"].stringValue
                    
                    let concurrent = DispatchGroup()
                    TimelineManager.sharedInstance.fetch(group: concurrent)
                    BookmarkManager.sharedInstance.fetch(group: concurrent)
                    
                    concurrent.notify(queue: .global()) {
                        DispatchQueue.global().async {
                            TimelineManager.sharedInstance.sync()
                            BookmarkManager.sharedInstance.sync()
                        }
                    }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
                .request(PinboardURLProvider.secretToken ?? "")
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
