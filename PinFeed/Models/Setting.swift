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
            return UserDefaults.standard.value(forKey: SettingKey.userId.rawValue) as? String ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: SettingKey.userId.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    var password: String {
        get {
            return UserDefaults.standard.value(forKey: SettingKey.password.rawValue) as? String ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: SettingKey.password.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    var secretToken: String {
        get {
            return UserDefaults.standard.value(forKey: SettingKey.secretToken.rawValue) as? String ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: SettingKey.secretToken.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}
