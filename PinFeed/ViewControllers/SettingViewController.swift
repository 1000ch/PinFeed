import UIKit

class SettingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Setting"
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingTableViewController = storyboard.instantiateViewControllerWithIdentifier("SettingTableViewController") as? UITableViewController else {
            return
        }
        
        view.addSubview(settingTableViewController.view)
        addChildViewController(settingTableViewController)
        settingTableViewController.didMoveToParentViewController(self)
        settingTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let leftConstraint = NSLayoutConstraint(item: settingTableViewController.view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: settingTableViewController.view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: settingTableViewController.view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: settingTableViewController.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)

        view.addConstraint(leftConstraint)
        view.addConstraint(rightConstraint)
        view.addConstraint(topConstraint)
        view.addConstraint(bottomConstraint)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

