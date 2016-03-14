import UIKit
import MisterFusion

class SettingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Setting"
        
        guard let settingTableViewController = UIStoryboard.instantiateViewController("Main", identifier: "SettingTableViewController") else {
            return
        }
        
        settingTableViewController.didMoveToParentViewController(self)

        addChildViewController(settingTableViewController)
        view.addLayoutSubview(settingTableViewController.view, andConstraints:
            settingTableViewController.view.Top,
            settingTableViewController.view.Right,
            settingTableViewController.view.Left,
            settingTableViewController.view.Bottom
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

