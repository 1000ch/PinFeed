import Foundation

class Setting {
    static let shared = Setting()
    
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
