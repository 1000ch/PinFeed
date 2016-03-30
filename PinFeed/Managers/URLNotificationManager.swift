import Foundation

class URLNotificationManager {
    class var sharedInstance: URLNotificationManager {
        struct Static {
            static let instance = URLNotificationManager()
        }
        return Static.instance
    }
    
    let notificationName = "url-notification"
    
    private var center: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    func listen(observer: AnyObject, selector: Selector, object: AnyObject?) {
        center.addObserver(observer, selector: selector, name: notificationName, object: object)
    }
    
    func unlisten(observer: AnyObject) {
        center.removeObserver(observer)
    }
    
    func emit(object: AnyObject?, userInfo: [NSObject: AnyObject]?) {
        center.postNotificationName(notificationName, object: object, userInfo: userInfo)
    }
}