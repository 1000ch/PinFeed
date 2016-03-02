import Foundation

class Setting {
    class var sharedInstance: Setting {
        struct Static {
            static let instance = Setting()
        }
        return Static.instance
    }
    
    enum SettingKey: String {
        case userId = "userId"
        case password = "password"
        case apiToken = "apiToken"
        case secretToken = "secretToken"
    }

    var userId: String {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.valueForKey(SettingKey.userId.rawValue) as? String ?? ""
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setValue(newValue, forKey: SettingKey.userId.rawValue)
            userDefaults.synchronize()
        }
    }

    var password: String {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.valueForKey(SettingKey.password.rawValue) as? String ?? ""
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setValue(newValue, forKey: SettingKey.password.rawValue)
            userDefaults.synchronize()
        }
    }
    
    var apiToken: String {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.valueForKey(SettingKey.apiToken.rawValue) as? String ?? ""
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setValue(newValue, forKey: SettingKey.apiToken.rawValue)
            userDefaults.synchronize()
        }
    }

    var secretToken: String {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.valueForKey(SettingKey.secretToken.rawValue) as? String ?? ""
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setValue(newValue, forKey: SettingKey.secretToken.rawValue)
            userDefaults.synchronize()
        }
    }
}