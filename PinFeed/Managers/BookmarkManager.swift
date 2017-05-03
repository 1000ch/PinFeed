import Alamofire
import SwiftyJSON
import RealmSwift

class BookmarkManager {
    class var sharedInstance: BookmarkManager {
        struct Static {
            static let instance = BookmarkManager()
        }
        return Static.instance
    }
    
    var bookmark: [Bookmark] = []
    
    init() {
        autoreleasepool {
            let realm = try! Realm()
            
            for recent in realm.objects(Bookmarks.self) {
                bookmark.append(Bookmark(
                    title: recent.d,
                    tag: recent.t,
                    url: recent.u,
                    dateTime: recent.dt,
                    author: recent.a,
                    description: recent.n
                ))
            }
        }
    }
    
    func fetch(block: (() -> ())?) {
        Alamofire
            .request(PinboardURLProvider.bookmark ?? "")
            .responseJSON { response in
                guard let data = response.result.value else {
                    block?()
                    return
                }
                
                self.bookmark.removeAll()
                
                JSON(data).forEach { (_, json) in
                    self.bookmark.append(Bookmark(json: json))
                }
                
                block?()

                DispatchQueue.global().async {
                    autoreleasepool {
                        let realm = try! Realm()

                        try! realm.write {
                            realm.delete(realm.objects(Bookmarks.self))
                            for bookmark in self.bookmark {
                                realm.add(Bookmarks(bookmark: bookmark))
                            }
                        }
                    }
                }
        }
    }
    
    func clear(block: @escaping () -> ()) {
        DispatchQueue.global().async {
            autoreleasepool {
                let realm = try! Realm()

                try! realm.write {
                    realm.delete(realm.objects(Bookmarks.self))
                }
            }
            
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
