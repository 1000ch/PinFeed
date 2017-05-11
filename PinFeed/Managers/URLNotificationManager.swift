import Foundation

class URLNotificationManager {
    static let shared = URLNotificationManager()
    
    let notificationName = "url-notification"
    
    private var center: NotificationCenter {
        return NotificationCenter.default
    }
    
    func listen(observer: AnyObject, selector: Selector, object: AnyObject?) {
        center.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: notificationName), object: object)
    }
    
    func unlisten(observer: AnyObject) {
        center.removeObserver(observer)
    }
    
    func emit(object: AnyObject?, userInfo: [NSObject: AnyObject]?) {
        center.post(name: NSNotification.Name(rawValue: notificationName), object: object, userInfo: userInfo)
    }
}
